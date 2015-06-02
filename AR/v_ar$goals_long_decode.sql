USE KIPP_NJ
GO

ALTER VIEW AR$goals_long_decode AS

WITH default_scaffold AS (
  SELECT co.STUDENT_NUMBER
        ,co.schoolid
        ,ar_default.words_goal
        ,ar_default.points_goal
        ,ar_default.yearid
        ,ar_default.time_period_name
        ,ar_default.time_period_start
        ,ar_default.time_period_end
        ,ar_default.time_period_hierarchy
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN AR$goals ar_default WITH(NOLOCK)
    ON co.schoolid = ar_default.schoolid
   AND ('Default_Gr' + CONVERT(VARCHAR,co.grade_level)) = CONVERT(VARCHAR,ar_default.student_number)
   AND ((co.year - 1990) * 100) = ar_default.yearid
  WHERE co.rn = 1
    AND co.schoolid != 999999
 )

SELECT CONVERT(VARCHAR,ar_default.student_number) AS student_number
      ,ar_default.schoolid
      ,COALESCE(ar_explicit.words_goal, ar_default.words_goal) AS words_goal
      ,COALESCE(ar_explicit.points_goal, ar_default.points_goal) AS points_goal
      ,ar_default.yearid
      ,KIPP_NJ.dbo.fn_TermToYear(ar_default.yearid) AS academic_year
      ,ar_default.time_period_name
      ,COALESCE(ar_explicit.time_period_start, ar_default.time_period_start) AS time_period_start
      ,COALESCE(ar_explicit.time_period_end, ar_default.time_period_end) AS time_period_end
      ,COALESCE(ar_explicit.time_period_hierarchy, ar_default.time_period_hierarchy) AS time_period_hierarchy      
FROM default_scaffold ar_default WITH(NOLOCK)
LEFT OUTER JOIN AR$goals ar_explicit WITH(NOLOCK)
  ON CONVERT(VARCHAR,ar_default.STUDENT_NUMBER) = CONVERT(VARCHAR,ar_explicit.student_number)
 AND ar_default.yearid = ar_explicit.yearid
 AND ar_default.time_period_name = ar_explicit.time_period_name
 AND ar_default.time_period_hierarchy = ar_explicit.time_period_hierarchy