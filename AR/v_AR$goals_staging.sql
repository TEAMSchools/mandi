USE KIPP_NJ
GO

ALTER VIEW AR$goals_staging AS

WITH roster AS (
  SELECT co.student_number        
        ,co.studentid
        ,co.schoolid
        ,co.year AS academic_year
        ,co.enroll_status
        ,CONCAT(dts.yearid,'00') AS yearid
        ,dts.alt_name AS term
        ,CASE        
          WHEN dts.alt_name IN ('Q1','Q2') THEN 'BOY'
          WHEN dts.alt_name IN ('Q3') THEN 'MOY'
          WHEN dts.alt_name IN ('Q4') THEN 'EOY'
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
       JOIN KIPP_NJ..LIT$achieved_by_round#static achv WITH(NOLOCK)
         ON r.studentid = achv.STUDENTID
        AND r.academic_year = achv.academic_year
        AND r.lit_test_round = achv.test_round     
      ) sub
  JOIN KIPP_NJ..AR$goal_criteria#MS goal WITH(NOLOCK)
    ON sub.indep_lvl_num BETWEEN goal.min AND goal.max
   AND goal.criteria = 'lvl_num'
  JOIN KIPP_NJ..AR$tier_goals#MS tiers WITH(NOLOCK)
    ON goal.tier = tiers.tier
 )

,lexile AS (
  SELECT lex.studentid
        ,terms.term        
        ,CONVERT(INT,REPLACE(lex.lexile_score, 'BR', 0)) AS lexile_for_goal
  FROM KIPP_NJ..MAP$best_baseline#static lex WITH(NOLOCK)
  CROSS JOIN (
        SELECT 'Q1' term
        UNION
        SELECT 'Q2'
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
        SELECT 'Q3' term
        UNION
        SELECT 'Q4'
       ) terms    
  WHERE base.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND base.measurementscale = 'Reading'
 )

,hs_goals AS (
  SELECT r.student_number        
        ,r.term        
        ,goal.points_goal        
  FROM roster r WITH(NOLOCK)
  JOIN lexile lex WITH(NOLOCK)
    ON r.studentid = lex.studentid
   AND r.term = lex.term
  LEFT OUTER JOIN KIPP_NJ..AR$tier_goals#HS goal WITH(NOLOCK)
    ON lex.lexile_for_goal BETWEEN goal.lexile_min AND goal.lexile_max  
 )

--,google_doc AS (  
--  SELECT [SN] AS student_number
--        ,CONVERT(INT,points_goal) AS points_goal
--        ,term        
--        ,ROW_NUMBER() OVER(
--           PARTITION BY [SN], term
--             ORDER BY term) AS dupe_check
--  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_AR_NCA] WITH(NOLOCK)
--  WHERE [SN] IS NOT NULL  
-- )

SELECT r.student_number
      ,r.schoolid
      ,ms.words_goal
      ,hs.points_goal
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

UNION ALL

SELECT r.student_number
      ,r.schoolid
      ,SUM(ms.words_goal) AS words_goal
      ,SUM(hs.points_goal) AS points_goal
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
GROUP BY r.student_number
        ,r.schoolid
        ,r.yearid        
        ,r.academic_year