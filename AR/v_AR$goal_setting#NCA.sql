USE KIPP_NJ
GO

ALTER VIEW AR$goal_setting#NCA AS

WITH roster AS (
  -- NCA
  SELECT co.student_number      
        ,co.studentid
        ,co.lastfirst      
        ,co.grade_level
        ,co.advisor
        ,co.enroll_status
        ,terms.alt_name AS term 
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates terms WITH(NOLOCK) 
    ON co.schoolid = terms.schoolid
   AND co.year = terms.academic_year
   AND terms.identifier IN ('HEX', 'RT_IR')
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.schoolid = 73253    
    AND co.rn = 1
 )

,lexile AS (
  SELECT lex.studentid
        ,terms.term
        ,lex.lexile_score AS base_lexile
        ,lex.lexile_score AS term_lexile        
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
        ,base.lexile_score AS base_lexile
        ,map.rittoreadingscore AS term_lexile
        ,CASE        
          WHEN ISNULL(CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0)),0) > ISNULL(CONVERT(INT,REPLACE(base.lexile_score, 'BR', 0)),0) THEN CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0))
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

,google_doc AS (  
  SELECT [SN] AS student_number
        ,CONVERT(INT,[points goal]) AS points_goal
        ,term        
        ,ROW_NUMBER() OVER(
           PARTITION BY [SN], term
             ORDER BY term) AS dupe_check
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_AR_NCA] WITH(NOLOCK)
  WHERE [SN] IS NOT NULL  
 )

,goals_long AS (
  SELECT r.student_number
        ,r.lastfirst
        ,r.grade_level
        ,r.advisor
        ,r.term
        ,r.enroll_status
        ,lex.base_lexile
        ,lex.term_lexile
        ,lex.lexile_for_goal      
        ,COALESCE(gdoc.points_goal, CASE WHEN r.enroll_status != 0 THEN -1 ELSE NULL END, goal.points_goal) AS points_goal
        --,CASE WHEN goal.points_goal IS NULL THEN 1 ELSE NULL END AS missing_lexile_flag
  FROM roster r WITH(NOLOCK)
  JOIN lexile lex WITH(NOLOCK)
    ON r.studentid = lex.studentid
   AND r.term = lex.term
  LEFT OUTER JOIN KIPP_NJ..AR$tier_goals#HS goal WITH(NOLOCK)
    ON lex.lexile_for_goal >= goal.lexile_min
   AND lex.lexile_for_goal <= goal.lexile_max
  LEFT OUTER JOIN google_doc gdoc WITH(NOLOCK)
    ON r.student_number = gdoc.student_number
   AND r.term = gdoc.term
   AND gdoc.dupe_check = 1  
 )

SELECT student_number
      ,lastfirst
      ,grade_level
      ,ADVISOR
      ,term
      ,base_lexile
      ,term_lexile
      ,lexile_for_goal
      ,points_goal      
FROM goals_long

UNION ALL

SELECT student_number
      ,lastfirst
      ,grade_level
      ,ADVISOR
      ,'Y1' AS term
      ,MAX(base_lexile) AS base_lexile
      ,MAX(term_lexile) AS term_lexile
      ,MAX(lexile_for_goal) AS lexile_for_goal
      ,CASE 
        WHEN enroll_status != 0 THEN -1
        WHEN COUNT(points_goal) < 4 THEN NULL 
        ELSE SUM(points_goal) 
       END AS points_goal
      --,CASE WHEN COUNT(points_goal) < 4 THEN 1 ELSE NULL END AS missing_lexile_flag
FROM goals_long
GROUP BY student_number
        ,enroll_status
        ,lastfirst
        ,grade_level
        ,ADVISOR