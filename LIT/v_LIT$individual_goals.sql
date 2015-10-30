USE KIPP_NJ
GO

ALTER VIEW LIT$individual_goals AS

WITH gdoc_long AS (
  SELECT [SN] AS student_number
        ,academic_year        
        ,UPPER(LEFT(field, CHARINDEX('_', field) - 1)) AS test_round
        ,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(goal, '_', ' '),'STEP',''),'FP',''))) AS goal
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_LIT_Goals] WITH(NOLOCK)
  UNPIVOT (
    goal
    FOR field IN ([diagnostic_goal]
                 ,[q1_goal]
                 ,[q2_goal]
                 ,[q3_goal]
                 ,[q4_goal])
   ) u
 )

SELECT s.schoolid
      ,s.studentid      
      ,g.student_number
      ,g.academic_year
      ,CASE         
        WHEN g.academic_year <= 2014 AND g.test_round = 'Q4' THEN 'EOY'
        WHEN g.academic_year <= 2014 AND g.test_round IN ('Q1','Q2','Q3') THEN REPLACE(g.test_round,'Q','T')
        ELSE REPLACE(g.test_round,'DIAGNOSTIC','DR') 
       END AS test_round
      ,g.goal
      ,gleq.GLEQ
      ,gleq.lvl_num
FROM gdoc_long g
JOIN COHORT$identifiers_long#static s WITH(NOLOCK)
  ON g.student_number = s.STUDENT_NUMBER
 AND g.academic_year = s.year
 AND s.rn = 1
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
  ON g.goal = gleq.read_lvl