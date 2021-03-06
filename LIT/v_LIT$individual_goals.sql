USE KIPP_NJ
GO

ALTER VIEW LIT$individual_goals AS

WITH gdoc_long AS (
  SELECT student_number
        ,academic_year        
        ,UPPER(LEFT(field, CHARINDEX('_', field) - 1)) AS test_round
        ,goal        
  FROM 
      (
       SELECT CONVERT(INT,[SN]) AS student_number
             ,CONVERT(INT,academic_year) AS academic_year
             ,SUBSTRING([diagnostic_goal], CHARINDEX(' ',[diagnostic_goal]) + 1, LEN([diagnostic_goal])) AS diagnostic_goal
             ,SUBSTRING([q1_goal], CHARINDEX(' ',[q1_goal]) + 1, LEN([q1_goal])) AS q1_goal
             ,SUBSTRING([q2_goal], CHARINDEX(' ',[q2_goal]) + 1, LEN([q2_goal])) AS q2_goal
             ,SUBSTRING([q3_goal], CHARINDEX(' ',[q3_goal]) + 1, LEN([q3_goal])) AS q3_goal
             ,SUBSTRING([q4_goal], CHARINDEX(' ',[q4_goal]) + 1, LEN([q4_goal])) AS q4_goal
             ,NULL AS boy_goal
             ,NULL AS moy_goal
             ,NULL AS eoy_goal
       FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_LIT_individual_goals_es] WITH(NOLOCK)
       WHERE sn IS NOT NULL
         AND CONCAT(diagnostic_goal,q1_goal,q2_goal,q3_goal,q4_goal) != ''

       UNION 

       SELECT CONVERT(INT,[SN]) AS student_number
             ,CONVERT(INT,academic_year) AS academic_year
             ,NULL AS diagnostic_goal
             ,NULL AS q1_goal
             ,NULL AS q2_goal
             ,NULL AS q3_goal
             ,NULL AS q4_goal
             ,SUBSTRING(boy_goal, CHARINDEX(' ',boy_goal) + 1, LEN(boy_goal)) AS boy_goal
             ,SUBSTRING(moy_goal, CHARINDEX(' ',moy_goal) + 1, LEN(moy_goal)) AS moy_goal
             ,SUBSTRING(eoy_goal, CHARINDEX(' ',eoy_goal) + 1, LEN(eoy_goal)) AS eoy_goal
       FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_LIT_individual_goals_ms] WITH(NOLOCK)
       WHERE sn IS NOT NULL
         AND CONCAT(boy_goal, moy_goal, eoy_goal) != ''

       UNION

       SELECT SN AS student_number
             ,academic_year        
             ,CASE 
               WHEN SUBSTRING([diagnostic_goal], CHARINDEX('_',[diagnostic_goal]) + 1, LEN([diagnostic_goal])) = 'DNA' THEN 'Pre DNA'
               ELSE SUBSTRING([diagnostic_goal], CHARINDEX('_',[diagnostic_goal]) + 1, LEN([diagnostic_goal]))
              END AS diagnostic_goal
             ,CASE 
               WHEN SUBSTRING([q1_goal], CHARINDEX('_',[q1_goal]) + 1, LEN([q1_goal])) = 'DNA' THEN 'Pre DNA'
               ELSE SUBSTRING([q1_goal], CHARINDEX('_',[q1_goal]) + 1, LEN([q1_goal]))
              END AS q1_goal
             ,CASE 
               WHEN SUBSTRING([q2_goal], CHARINDEX('_',[q2_goal]) + 1, LEN([q2_goal])) = 'DNA' THEN 'Pre DNA'
               ELSE SUBSTRING([q2_goal], CHARINDEX('_',[q2_goal]) + 1, LEN([q2_goal]))
              END AS q2_goal
             ,CASE 
               WHEN SUBSTRING([q3_goal], CHARINDEX('_',[q3_goal]) + 1, LEN([q3_goal])) = 'DNA' THEN 'Pre DNA'
               ELSE SUBSTRING([q3_goal], CHARINDEX('_',[q3_goal]) + 1, LEN([q3_goal]))
              END AS q3_goal
             ,CASE 
               WHEN SUBSTRING([q4_goal], CHARINDEX('_',[q4_goal]) + 1, LEN([q4_goal])) = 'DNA' THEN 'Pre DNA'
               ELSE SUBSTRING([q4_goal], CHARINDEX('_',[q4_goal]) + 1, LEN([q4_goal]))
              END AS q4_goal
             ,NULL AS boy_goal
             ,NULL AS moy_goal
             ,NULL AS eoy_goal
       FROM KIPP_NJ..LIT$individual_goals#archive WITH(NOLOCK)
      ) sub
  UNPIVOT (
    goal
    FOR field IN ([diagnostic_goal]
                 ,[q1_goal]
                 ,[q2_goal]
                 ,[q3_goal]
                 ,[q4_goal]
                 ,[boy_goal]
                 ,[moy_goal]
                 ,[eoy_goal])
   ) u
 )

SELECT g.student_number
      ,g.academic_year
      ,REPLACE(g.test_round,'DIAGNOSTIC','DR') AS test_round
      ,g.goal      
      ,CASE 
        WHEN gleq.testid = 3273 THEN gleq.fp_lvl_num /* when F&P, use F&P number */
        ELSE gleq.lvl_num
       END AS lvl_num
FROM gdoc_long g
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
  ON g.goal = gleq.read_lvl