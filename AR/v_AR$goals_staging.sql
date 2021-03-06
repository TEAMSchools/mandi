USE KIPP_NJ
GO

ALTER VIEW AR$goals_staging AS

WITH roster AS (
  SELECT sub.student_number        
        ,sub.studentid
        ,sub.schoolid
        ,sub.grade_level
        ,sub.academic_year
        ,sub.enroll_status
        ,sub.is_enrolled
        
        ,CONCAT(dts.yearid,'00') AS yearid
        ,dts.time_per_name AS term        
        ,dts.start_date
        ,dts.end_date
        ,dts.time_hierarchy AS time_period_hierarchy        

        ,CASE        
          WHEN sub.school_level = 'MS' AND dts.alt_name IN ('Q1','Q2') THEN 'BOY'
          WHEN sub.school_level = 'MS' AND dts.alt_name IN ('Q3') THEN 'MOY'
          WHEN sub.school_level = 'MS' AND dts.alt_name IN ('Q4') THEN 'MOY'
          ELSE dts.alt_name
         END AS lit_test_round
  FROM
      (
       SELECT co.student_number        
             ,co.studentid
             ,co.schoolid
             ,CASE
               WHEN co.schoolid = 73252 THEN 'MS'
               WHEN co.grade_level <= 4 THEN 'ES'
               WHEN co.grade_level BETWEEN 5 AND 8 THEN 'MS'
               WHEN co.grade_level >= 9 THEN 'HS'
              END AS school_level
             ,co.grade_level
             ,co.year AS academic_year
             ,co.enroll_status        
             ,co.term
             ,MAX(is_enrolled) AS is_enrolled
       FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)  
       WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       GROUP BY co.student_number        
               ,co.studentid
               ,co.schoolid
               ,co.grade_level
               ,co.year
               ,co.term
               ,co.enroll_status      
      ) sub
  JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
    ON sub.schoolid = dts.schoolid
   AND sub.academic_year = dts.academic_year      
   AND sub.term = dts.alt_name
   AND dts.identifier = 'AR'          
 )

,ms_goals AS (
  SELECT sub.student_number
        ,sub.term      
        ,tiers.words_goal
  FROM
      (
       SELECT achv.student_number           
             ,COALESCE(boy.time_per_name, moy.time_per_name) AS term
             ,COALESCE(
                 COALESCE(achv.indep_lvl_num, achv.lvl_num)
                ,LAG(COALESCE(achv.indep_lvl_num, achv.lvl_num), 2) OVER(PARTITION BY achv.student_number, achv.academic_year ORDER BY achv.start_date)
               ) AS indep_lvl_num /* Q1 & Q2 are set by BOY, carry them forward for setting goals at beginning of year */
       FROM KIPP_NJ..LIT$achieved_by_round#static achv WITH(NOLOCK)         
       LEFT OUTER JOIN (
             SELECT 'RT1' AS time_per_name
             UNION
             SELECT 'RT2'             
            ) boy
         ON achv.test_round IN ('BOY','DR')
       LEFT OUTER JOIN (
             SELECT 'RT3' AS time_per_name
             UNION
             SELECT 'RT4'             
            ) moy
         ON achv.test_round IN ('MOY','Q2')
       WHERE achv.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND achv.test_round IN ('BOY','MOY','DR','Q2')
      ) sub
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_ar_goal_criteria goal WITH(NOLOCK)
    ON sub.indep_lvl_num BETWEEN goal.min AND goal.max
   AND goal.criteria = 'lvl_num'
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_ar_tier_goals tiers WITH(NOLOCK)
    ON goal.tier = tiers.tier
 )

,hs_goals AS (
  SELECT sub.student_number        
        ,sub.term        
        ,goal.points_goal
  FROM 
      (
       SELECT lex.student_number
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
  
       SELECT base.student_number
             ,terms.term                
             ,CASE        
               WHEN ISNULL(CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0)),0) > ISNULL(CONVERT(INT,REPLACE(base.lexile_score, 'BR', 0)),0) 
                     THEN CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0))
               ELSE CONVERT(INT,REPLACE(base.lexile_score, 'BR', 0))
              END AS lexile_for_goal
       FROM KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
         ON base.studentid = map.studentid
        AND base.year = map.academic_year
        AND base.measurementscale = map.measurementscale
        AND map.term = 'Winter'
        AND map.rn = 1
       CROSS JOIN (
                   SELECT 'RT3' term
                   UNION
                   SELECT 'RT4'
                  ) terms    
       WHERE base.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND base.measurementscale = 'Reading'
      ) sub  
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_ar_tier_goals_hs goal WITH(NOLOCK)
    ON sub.lexile_for_goal BETWEEN goal.lexile_min AND goal.lexile_max  
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
             WHEN r.is_enrolled = 0 THEN NULL
             WHEN r.grade_level >= 9 THEN NULL
             WHEN r.enroll_status != 0 THEN -1
             ELSE COALESCE(g.adjusted_goal, ms.words_goal, df.words_goal) 
            END AS words_goal
           ,CASE
             WHEN r.is_enrolled = 0 THEN NULL
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
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_ar_default_goals df WITH(NOLOCK)
       ON r.grade_level = df.grade_level
      AND r.term = df.time_period_name
     LEFT OUTER JOIN KIPP_NJ..AR$individual_goals#static g WITH(NOLOCK)
       ON r.student_number = g.student_number
      AND r.term = g.term
      AND g.rn = 1

     UNION ALL

     SELECT r.student_number
           ,r.schoolid
           ,SUM(CASE
                 WHEN r.is_enrolled = 0 THEN NULL
                 WHEN r.grade_level >= 9 THEN NULL
                 WHEN r.enroll_status != 0 THEN -1
                 ELSE COALESCE(g.adjusted_goal, ms.words_goal, df.words_goal)
                END) AS words_goal           
           ,SUM(CASE
                 WHEN r.is_enrolled = 0 THEN NULL
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
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_ar_default_goals df WITH(NOLOCK)
       ON r.grade_level = df.grade_level
      AND r.term = df.time_period_name
     LEFT OUTER JOIN KIPP_NJ..AR$individual_goals#static g WITH(NOLOCK)
       ON r.student_number = g.student_number
      AND r.term = g.term
      AND g.rn = 1
     GROUP BY r.student_number
             ,r.schoolid
             ,r.yearid        
             ,r.academic_year
    ) sub