USE KIPP_NJ
GO

ALTER VIEW AR$goals_staging AS

WITH roster AS (
  SELECT co.student_number        
        ,co.studentid
        ,co.schoolid
        ,co.grade_level
        ,co.year AS academic_year
        ,co.enroll_status
        ,CONCAT(dts.yearid,'00') AS yearid
        ,dts.time_per_name AS term
        ,CASE        
          WHEN dts.alt_name IN ('Q1','Q2') THEN 'BOY'
          WHEN dts.alt_name IN ('Q3') THEN 'MOY'
          WHEN dts.alt_name IN ('Q4') THEN 'MOY'
         END AS lit_test_round
        ,dts.start_date
        ,dts.end_date
        ,dts.time_hierarchy AS time_period_hierarchy
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
    ON dts.schoolid = co.schoolid      
   AND dts.academic_year = co.year
   AND dts.identifier = 'AR'        
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.rn = 1
 )

,ms_goals AS (
  SELECT sub.student_number
        ,sub.term      
        ,tiers.words_goal
  FROM
      (
       SELECT r.student_number           
             ,r.term
             ,COALESCE(
                 COALESCE(achv.indep_lvl_num, achv.lvl_num)
                ,LAG(COALESCE(achv.indep_lvl_num, achv.lvl_num), 2) OVER(PARTITION BY r.student_number, r.academic_year ORDER BY r.start_date)
               ) AS indep_lvl_num /* Q1 & Q2 are set by BOY, carry them forward for setting goals at beginning of year */
       FROM roster r
       LEFT OUTER JOIN KIPP_NJ..LIT$achieved_by_round#static achv WITH(NOLOCK)
         ON r.studentid = achv.STUDENTID
        AND r.academic_year = achv.academic_year
        AND r.lit_test_round = achv.test_round     
      ) sub
  LEFT OUTER JOIN KIPP_NJ..AR$goal_criteria#MS goal WITH(NOLOCK)
    ON sub.indep_lvl_num BETWEEN goal.min AND goal.max
   AND goal.criteria = 'lvl_num'
  LEFT OUTER JOIN KIPP_NJ..AR$tier_goals#MS tiers WITH(NOLOCK)
    ON goal.tier = tiers.tier
 )

,lexile AS (
  SELECT lex.studentid
        ,terms.term        
        ,CONVERT(INT,REPLACE(lex.lexile_score, 'BR', 0)) AS lexile_for_goal
  FROM KIPP_NJ..MAP$best_baseline#static lex WITH(NOLOCK)
  CROSS JOIN (
        SELECT 'RT1' term
        UNION
        SELECT 'RT2'
       ) terms    
  WHERE lex.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND lex.measurementscale = 'Reading'  
  UNION ALL
  SELECT base.studentid
        ,terms.term                
        ,CASE        
          WHEN ISNULL(CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0)),0) > ISNULL(CONVERT(INT,REPLACE(base.lexile_score, 'BR', 0)),0) 
                THEN CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0))
          ELSE CONVERT(INT,REPLACE(base.lexile_score, 'BR', 0))
         END AS lexile_for_goal
  FROM KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map WITH(NOLOCK)
    ON base.studentid = map.ps_studentid
   AND base.year = map.map_year_academic
   AND base.measurementscale = map.measurementscale
   AND map.fallwinterspring = 'Winter'
   AND map.rn = 1
  CROSS JOIN (
        SELECT 'RT3' term
        UNION
        SELECT 'RT4'
       ) terms    
  WHERE base.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND base.measurementscale = 'Reading'
 )

,hs_goals AS (
  SELECT r.student_number        
        ,r.term        
        ,goal.points_goal
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN lexile lex WITH(NOLOCK)
    ON r.studentid = lex.studentid
   AND r.term = lex.term
  LEFT OUTER JOIN KIPP_NJ..AR$tier_goals#HS goal WITH(NOLOCK)
    ON lex.lexile_for_goal BETWEEN goal.lexile_min AND goal.lexile_max  
  WHERE r.grade_level >= 9
 )

,google_doc AS (  
  SELECT sn
        ,REPLACE(cycle,'Q','RT') AS cycle
        ,CONVERT(FLOAT,REPLACE(adjusted_goal,',','')) AS adjusted_goal
        ,ROW_NUMBER() OVER(
           PARTITION BY sn, cycle
             ORDER BY adjusted_goal DESC) AS rn
        
  FROM
      (
       SELECT sn
             ,cycle
             ,adjusted_goal
       FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_NCA WITH(NOLOCK)
       WHERE sn IS NOT NULL  
       UNION ALL
       SELECT sn
             ,cycle
             ,adjusted_goal
       FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_rise WITH(NOLOCK)
       WHERE sn IS NOT NULL  
       UNION ALL
       SELECT sn
             ,cycle
             ,adjusted_goal
       FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_team WITH(NOLOCK)
       WHERE sn IS NOT NULL  
       UNION ALL
       SELECT sn
             ,cycle
             ,adjusted_goal
       FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_bold WITH(NOLOCK)
       WHERE sn IS NOT NULL  
       UNION ALL
       SELECT sn
             ,cycle
             ,adjusted_goal
       FROM KIPP_NJ..AUTOLOAD$GDOCS_AR_lsm WITH(NOLOCK)
       WHERE sn IS NOT NULL    
      ) sub
 )

SELECT student_number
      ,schoolid
      ,words_goal
      ,points_goal
      ,yearid
      ,time_period_name
      ,time_period_start
      ,time_period_end
      ,time_period_hierarchy
      ,academic_year
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, time_period_name
           ORDER BY time_period_name DESC) AS rn
FROM
    (
     SELECT r.student_number
           ,r.schoolid
           ,CASE
             WHEN r.grade_level >= 9 THEN NULL
             WHEN r.enroll_status != 0 THEN -1
             ELSE COALESCE(g.adjusted_goal, ms.words_goal, df.words_goal) 
            END AS words_goal
           ,CASE
             WHEN r.grade_level <= 8 THEN NULL
             WHEN r.enroll_status != 0 THEN -1
             ELSE COALESCE(g.adjusted_goal, hs.points_goal, df.points_goal)
            END AS points_goal
           ,r.yearid
           ,r.term AS time_period_name
           ,r.start_date AS time_period_start
           ,r.end_date AS time_period_end
           ,r.time_period_hierarchy
           ,r.academic_year
     FROM roster r
     LEFT OUTER JOIN ms_goals ms
       ON r.student_number = ms.student_number
      AND r.term = ms.term
     LEFT OUTER JOIN hs_goals hs
       ON r.student_number = hs.student_number
      AND r.term = hs.term
     LEFT OUTER JOIN KIPP_NJ..AR$default_goals df WITH(NOLOCK)
       ON r.grade_level = df.grade_level
      AND r.term = df.time_period_name
     LEFT OUTER JOIN google_doc g
       ON r.student_number = g.sn
      AND r.term = g.cycle      
      AND g.rn = 1

     UNION ALL

     SELECT r.student_number
           ,r.schoolid
           ,SUM(CASE
                 WHEN r.grade_level >= 9 THEN NULL
                 WHEN r.enroll_status != 0 THEN -1
                 ELSE COALESCE(g.adjusted_goal, ms.words_goal, df.words_goal)
                END) AS words_goal           
           ,SUM(CASE
                 WHEN r.grade_level <= 8 THEN NULL
                 WHEN r.enroll_status != 0 THEN -1
                 ELSE COALESCE(g.adjusted_goal, hs.points_goal, df.points_goal)
                END) AS points_goal
           ,r.yearid
           ,'Year' AS time_period_name
           ,MIN(r.start_date) AS time_period_start
           ,MAX(r.end_date) AS time_period_end
           ,1 AS time_period_hierarchy
           ,r.academic_year
     FROM roster r
     LEFT OUTER JOIN ms_goals ms
       ON r.student_number = ms.student_number
      AND r.term = ms.term
     LEFT OUTER JOIN hs_goals hs
       ON r.student_number = hs.student_number
      AND r.term = hs.term
     LEFT OUTER JOIN KIPP_NJ..AR$default_goals df WITH(NOLOCK)
       ON r.grade_level = df.grade_level
      AND r.term = df.time_period_name
     LEFT OUTER JOIN google_doc g
       ON r.student_number = g.sn
      AND r.term = g.cycle      
      AND g.rn = 1
     GROUP BY r.student_number
             ,r.schoolid
             ,r.yearid        
             ,r.academic_year
    ) sub