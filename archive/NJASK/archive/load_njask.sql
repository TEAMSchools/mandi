WITH njask AS (
  SELECT SID
        ,CONVERT(INT,[testing year]) - 1 AS academic_year
        ,grade AS test_grade_level
        ,CONVERT(INT,[ELA Scale Score]) AS [ELA Scale Score]
        ,CONVERT(INT,[ELA Proficiency Level]) AS [ELA Proficiency]
        ,CONVERT(INT,[Math Scale Score]) AS [Math Scale Score]
        ,CONVERT(INT,[Math Proficiency Level]) AS [Math Proficiency]
        ,CONVERT(INT,[Science Scale Score]) AS [Science Scale Score]
        ,CONVERT(INT,[Science Proficiency Level]) AS [Science Proficiency]
        ,CONVERT(INT,[Void Reason - ELA]) AS [ELA Void Reason]
        ,CONVERT(INT,[Void Reason - Math]) AS [Math Void Reason]
        ,CONVERT(INT,[Void Reason - Science]) AS [Science Void Reason]
  FROM OPENROWSET(
     'MSDASQL'
    ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
    ,'SELECT * FROM C:\data_robot\NJASKHSPA\NJASK_scores_roster_SY2014.csv'
   )
 )

,njask_staging AS (
  SELECT studentid
        ,STUDENT_NUMBER
        ,SID
        ,academic_year
        ,test_grade_level
        ,subject
        ,CASE 
          WHEN proficiency = 3 THEN 'Below Proficient'
          WHEN proficiency = 2 THEN 'Proficient'
          WHEN proficiency = 1 THEN 'Advanced Proficient'
         END AS njask_proficiency
        ,scale_score AS njask_scale_score
        ,CASE 
          WHEN proficiency IN (1,2) THEN 1 
          WHEN proficiency = 3 THEN 0
         END AS is_prof
        ,proficiency AS prof_level
        ,void_reason
  FROM
      (
       SELECT studentid
             ,STUDENT_NUMBER
             ,SID
             ,academic_year
             ,test_grade_level      
             ,LTRIM(RTRIM(LEFT(field, CHARINDEX(' ', field) - 1))) AS subject
             ,LTRIM(RTRIM(REPLACE(LOWER(SUBSTRING(field, CHARINDEX(' ', field) + 1, LEN(field))), ' ', '_'))) AS field
             ,value
       FROM
           (
            SELECT njask.*
                  ,co.studentid
                  ,co.STUDENT_NUMBER
            FROM njask
            LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
              ON njask.SID = cs.SID
            LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
              ON cs.STUDENTID = co.studentid
           ) sub

       UNPIVOT (
         value
         FOR field IN ([ELA Scale Score]
                      ,[ELA Proficiency]
                      ,[Math Scale Score]
                      ,[Math Proficiency]
                      ,[Science Scale Score]
                      ,[Science Proficiency]
                      ,[ELA Void Reason]
                      ,[Math Void Reason]
                      ,[Science Void Reason])
        ) u
      ) sub

  PIVOT (
     MAX(value)
     FOR field IN ([scale_score], [proficiency], [void_reason])
   ) p
 )

--COMMIT TRANSACTION
--INSERT INTO NJASK$detail
SELECT studentid
      ,STUDENT_NUMBER
      ,SID
      ,academic_year
      ,test_grade_level
      ,subject
      ,njask_proficiency
      ,njask_scale_score
      ,is_prof
      ,prof_level
      ,void_reason
FROM njask_staging