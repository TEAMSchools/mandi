WITH sgp_data AS (
  SELECT [LID] AS student_number      
        ,CONVERT(INT,[Grade_Level]) AS grade
        ,[LAL_MostRecentAssessmentYear]
        ,[LAL_MostRecentStudentGrowthPercentile]
        ,[LAL_MostRecentStudentGrowthLevel]
        ,[Math_MostRecentAssessmentYear]
        ,[Math_MostRecentStudentGrowthPercentile]
        ,[Math_MostRecentStudentGrowthLevel]
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'SELECT * FROM C:\data_robot\NJASKHSPA\StateScores\1314\SGP\1314_SGP_Gr4.csv'
   )

  UNION ALL

  SELECT [LID] AS student_number      
        ,CONVERT(INT,[Grade_Level]) AS grade
        ,[LAL_MostRecentAssessmentYear]
        ,[LAL_MostRecentStudentGrowthPercentile]
        ,[LAL_MostRecentStudentGrowthLevel]
        ,[Math_MostRecentAssessmentYear]
        ,[Math_MostRecentStudentGrowthPercentile]
        ,[Math_MostRecentStudentGrowthLevel]
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'SELECT * FROM C:\data_robot\NJASKHSPA\StateScores\1314\SGP\1314_SGP_Gr5.csv'
   )

  UNION ALL

  SELECT [LID] AS student_number      
        ,CONVERT(INT,[Grade_Level]) AS grade
        ,[LAL_MostRecentAssessmentYear]
        ,[LAL_MostRecentStudentGrowthPercentile]
        ,[LAL_MostRecentStudentGrowthLevel]
        ,[Math_MostRecentAssessmentYear]
        ,[Math_MostRecentStudentGrowthPercentile]
        ,[Math_MostRecentStudentGrowthLevel]
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'SELECT * FROM C:\data_robot\NJASKHSPA\StateScores\1314\SGP\1314_SGP_Gr6.csv'
   )

  UNION ALL

  SELECT [LID] AS student_number      
        ,CONVERT(INT,[Grade_Level]) AS grade
        ,[LAL_MostRecentAssessmentYear]        
        ,[LAL_MostRecentStudentGrowthPercentile]
        ,[LAL_MostRecentStudentGrowthLevel]
        ,[Math_MostRecentAssessmentYear]
        ,[Math_MostRecentStudentGrowthPercentile]
        ,[Math_MostRecentStudentGrowthLevel]
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'SELECT * FROM C:\data_robot\NJASKHSPA\StateScores\1314\SGP\1314_SGP_Gr7.csv'
   )

  UNION ALL

  SELECT [LID] AS student_number      
        ,CONVERT(INT,[Grade_Level]) AS grade
        ,[LAL_MostRecentAssessmentYear]        
        ,[LAL_MostRecentStudentGrowthPercentile]
        ,[LAL_MostRecentStudentGrowthLevel]
        ,[Math_MostRecentAssessmentYear]        
        ,[Math_MostRecentStudentGrowthPercentile]
        ,[Math_MostRecentStudentGrowthLevel]
  FROM OPENROWSET(
    'MSDASQL'
   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
   ,'SELECT * FROM C:\data_robot\NJASKHSPA\StateScores\1314\SGP\1314_SGP_Gr8.csv'
   )
 )

,sgp_unpivoted AS (
  SELECT student_number
        ,grade      
        ,SUBSTRING(field, 1, (CHARINDEX('_', field) - 1)) AS subject
        ,REPLACE(SUBSTRING(field, (CHARINDEX('_', field) + 1), LEN(field)), 'MostRecent', '') AS field
        ,value
  FROM sgp_data
  UNPIVOT(
    value
    FOR field IN ([LAL_MostRecentAssessmentYear]                 
                 ,[LAL_MostRecentStudentGrowthPercentile]
                 ,[LAL_MostRecentStudentGrowthLevel]
                 ,[Math_MostRecentAssessmentYear]                 
                 ,[Math_MostRecentStudentGrowthPercentile]
                 ,[Math_MostRecentStudentGrowthLevel])
   ) u
 )

,clean_sgp AS (
  SELECT student_number
        ,LEFT([AssessmentYear],4) AS year
        ,grade
        ,CASE WHEN subject = 'LAL' THEN 'ELA' ELSE subject END AS subject
        ,[StudentGrowthLevel] AS growth_level
        ,[StudentGrowthPercentile] AS growth_score
        --,CONVERT(VARCHAR,student_number) + '_' + LEFT([AssessmentYear],4) + '_' + CASE WHEN subject = 'LAL' THEN 'ELA' ELSE subject END AS audit_hash
  FROM sgp_unpivoted
  PIVOT(
    MAX(value)
    FOR field IN ([AssessmentYear]               
                 ,[StudentGrowthPercentile]
                 ,[StudentGrowthLevel])               
   ) p
 )

--BEGIN TRANSACTION
--ROLLBACK TRANSACTION
--COMMIT TRANSACTION
--INSERT INTO KIPP_NJ..NJASK$sgp_detail
SELECT * FROM clean_sgp
WHERE year = 2013

