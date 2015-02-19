USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$time_series#UPSERT AS

BEGIN

  WITH assignment_scores AS (
    SELECT gr.ASSIGN_DATE                        
          ,cat.FINALGRADENAME
          ,CASE WHEN cat.FINALGRADESETUPTYPE = 'TotalPoints' THEN 'Total' ELSE gr.category END AS category -- ensure TotalPoints gradebooks aren't weighted strangely
          ,cat.course_number
          ,sco.STUDENT_NUMBER
          ,(CONVERT(FLOAT,sco.SCORE) + ISNULL(CONVERT(FLOAT,sco.EXTRACREDITPOINTS),0.0)) * gr.[weight] AS weighted_score -- add any extra credit points and multiply by assignment weight
          ,CASE WHEN sco.score IS NULL THEN NULL ELSE gr.POINTSPOSSIBLE END * gr.[weight] AS weighted_points_possible -- multiply by assignment weight, if socre is exempt or empty, NULL
          ,CASE WHEN cat.FINALGRADESETUPTYPE = 'TotalPoints' THEN 1 ELSE cat.WEIGHTING END AS weighting -- even weight to all assignments for TotalPoints setups
    FROM KIPP_NJ..GRADES$assignments#static gr WITH(NOLOCK)    
    JOIN KIPP_NJ..GRADES$assignment_scores#static sco WITH(NOLOCK)
      ON gr.ASSIGNMENTID = sco.ASSIGNMENTID   
     AND sco.EXEMPT = 0 -- exclude exempted assignments
    JOIN KIPP_NJ..PS$category_weighting_setup#static cat WITH(NOLOCK) 
      ON gr.psm_sectionid = cat.PSM_SECTIONID
     AND ((cat.FINALGRADESETUPTYPE = 'WeightedFGSetup' AND cat.INCLUDEINFINALGRADES = 1) -- if weighted, only include categories that factor into final grades
          OR (cat.FINALGRADESETUPTYPE = 'TotalPoints'))  -- avoids killing TotalPoints setups
     AND (gr.ASSIGN_DATE >= cat.STARTDATE AND gr.ASSIGN_DATE <= cat.ENDDATE) -- avoid dupes
     AND (gr.CATEGORY = cat.ABBREVIATION OR cat.ABBREVIATION IS NULL) -- avoids killing TotalPoints setups
    WHERE gr.ISFINALSCORECALCULATED = 1 -- specific assignments can be excluded from final grades
   )

  ,grades_long AS (
    SELECT student_number
          ,schoolid
          ,date
          ,course_number
          ,finalgradename
          ,ROUND(SUM(cat_weighted_pct) * 100,0) AS moving_average
    FROM
        (
         SELECT sub.student_number
               ,sub.schoolid
               ,sub.date
               ,sub.course_number      
               ,sub.FINALGRADENAME             
               -- multiply each assignment score by its category weight (% of total)
               ,sub.weighted_pct * (sub.WEIGHTING / CASE 
                                                     WHEN SUM(sub.WEIGHTING) OVER(PARTITION BY sub.student_number, sub.date, sub.course_number, sub.finalgradename) = 0 THEN NULL 
                                                     ELSE SUM(sub.WEIGHTING) OVER(PARTITION BY sub.student_number, sub.date, sub.course_number, sub.finalgradename)
                                                    END) AS cat_weighted_pct
         FROM
             (
              SELECT co.student_number
                    ,co.schoolid
                    ,co.date                      
                    ,asmt.course_number
                    ,asmt.FINALGRADENAME
                    ,asmt.CATEGORY                   
                    ,MAX(asmt.WEIGHTING) AS weighting
                    ,((SUM(asmt.weighted_score) / CASE WHEN SUM(asmt.weighted_points_possible) = 0 THEN NULL ELSE SUM(asmt.weighted_points_possible) END)) AS weighted_pct
              FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
              LEFT OUTER JOIN assignment_scores asmt WITH(NOLOCK)
                ON co.student_number = asmt.STUDENT_NUMBER           
               AND co.date >= asmt.ASSIGN_DATE -- join to all assignments to date
              WHERE co.year = 2014              
                AND co.date = CONVERT(DATE,GETDATE())
                --AND co.date <= CONVERT(DATE,GETDATE()) -- for backfilling data, could be any date range
                AND co.schoolid IN (73252,73253,133570965)                          
              GROUP BY co.student_number
                      ,co.schoolid
                      ,co.date                        
                      ,asmt.course_number
                      ,asmt.CATEGORY 
                      ,asmt.FINALGRADENAME
             ) sub
        ) sub
    GROUP BY student_number
            ,schoolid
            ,date
            ,course_number
            ,finalgradename
   )

  ,ts_update AS (
    SELECT student_number
          ,schoolid
          ,date
          ,course_number
          ,finalgradename
          ,moving_average
    FROM grades_long
    WHERE COURSE_NUMBER IS NOT NULL

    UNION ALL

    -- calculate Y1, taking F* into account
    SELECT student_number
          ,schoolid
          ,date
          ,course_number
          ,'Y1' AS FINALGRADENAME      
          ,ROUND((SUM(weighted_average) / SUM(weighted_points)) * 100,0) AS moving_average
    FROM
        (
         SELECT student_number
               ,schoolid
               ,date
               ,course_number
               ,FINALGRADENAME      
               ,CASE WHEN moving_average < 50 THEN 50 ELSE moving_average END AS unweighted_average
               ,CASE 
                 WHEN (schoolid = 73253 AND FINALGRADENAME LIKE 'Q%') THEN (CASE WHEN moving_average < 50 THEN 50 ELSE moving_average END) * 0.225
                 WHEN (schoolid = 73253 AND FINALGRADENAME LIKE 'E%') THEN (CASE WHEN moving_average < 50 THEN 50 ELSE moving_average END) * 0.05
                 WHEN (schoolid = 133570965 AND FINALGRADENAME LIKE 'T%') THEN (CASE WHEN moving_average < 55 THEN 55 ELSE moving_average END)
                 ELSE moving_average
                END AS weighted_average
               ,CASE
                 WHEN FINALGRADENAME LIKE 'Q%' THEN 22.5
                 WHEN FINALGRADENAME LIKE 'E%' THEN 5.0
                 WHEN FINALGRADENAME LIKE 'T%' THEN 100
                END AS weighted_points
         FROM grades_long
         WHERE COURSE_NUMBER IS NOT NULL
           AND ((SCHOOLID = 73253 AND (FINALGRADENAME LIKE 'Q%' OR FINALGRADENAME LIKE 'E%')) 
                 OR (SCHOOLID != 73253 AND FINALGRADENAME LIKE 'T%'))
        ) sub
    GROUP BY student_number
            ,schoolid
            ,date
            ,course_number
   )

  MERGE KIPP_NJ..GRADES$time_series#STAGING AS TARGET
  USING ts_update AS SOURCE
     ON TARGET.student_number = SOURCE.student_number
    AND TARGET.date = SOURCE.date
    AND TARGET.course_number = SOURCE.course_number
    AND TARGET.finalgradename = SOURCE.finalgradename
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.moving_average = SOURCE.moving_average       
  WHEN NOT MATCHED THEN
   INSERT
    (student_number
    ,schoolid
    ,date
    ,course_number
    ,finalgradename
    ,moving_average)
   VALUES
    (SOURCE.student_number
    ,SOURCE.schoolid	
    ,SOURCE.date
    ,SOURCE.course_number
    ,SOURCE.finalgradename
    ,SOURCE.moving_average);

END

GO