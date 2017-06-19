USE KIPP_NJ
GO

ALTER VIEW NAVIANCE$SAT_clean AS

WITH unioned_tables AS (
  SELECT [student_id]
        ,[hs_student_id]            
      
        ,[evidence_based_reading_writing]
        ,[math]      
        ,NULL AS writing
        ,[total]
      
        ,[reading_test]
        ,[writing_test]      
        ,[math_test]
        ,NULL AS [essay_subscore]
        ,CONVERT(FLOAT,[math_test]) + CONVERT(FLOAT,[reading_test]) AS [mc_subscore]
        ,CONVERT(DATE,CONCAT(RIGHT(test_date,4), '-', RIGHT(CONCAT('0', LEFT(test_date, CHARINDEX('/',test_date)-1)),2), '-01')) AS test_date
        ,BINI_ID
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$NAVIANCE_16_sat_scores]

  UNION ALL

  SELECT [studentid]
        ,[hs_student_id]      
      
        ,[verbal]
        ,[math]            
        ,[writing]
        ,[total]

        ,NULL AS [reading_test]
        ,[essay_subscore] AS [writing_test]      
        ,NULL AS [math_test]
        ,[essay_subscore]
        ,[mc_subscore]
        ,CASE WHEN ISDATE(REPLACE(test_date,'-00','-01')) = 1 THEN CONVERT(DATE,REPLACE(test_date,'-00','-01')) END AS test_date
        ,BINI_ID
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$NAVIANCE_2_sat_scores_before_Mar_2016]
 )

SELECT *
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number
              ORDER BY test_date ASC) AS n_attempt
FROM
    (
     SELECT sub1.nav_studentid
           ,sub1.student_number
           ,sub1.studentid
           ,sub1.verbal
           ,sub1.math
           ,sub1.writing
           ,sub1.essay_subscore
           ,sub1.mc_subscore
           ,sub1.math_verbal_total
           ,sub1.all_tests_total
           ,sub1.bini_id
           ,sub1.test_date
           ,sub1.test_date_flag
           ,sub1.total_flag
           ,KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
           ,ROW_NUMBER() OVER(
              PARTITION BY sub1.student_number, test_date
                  ORDER BY sub1.test_date) AS dupe_audit
     FROM
         (
          SELECT sat.student_id AS nav_studentid
                ,s.student_number
                ,s.id AS studentid                
                ,CONVERT(DATE,test_date) AS test_date
                ,CONVERT(FLOAT,evidence_based_reading_writing) AS verbal
                ,CONVERT(FLOAT,math) AS math
                ,CONVERT(FLOAT,writing) AS writing
                ,essay_subscore
                ,mc_subscore                
                ,CONVERT(FLOAT,evidence_based_reading_writing) + CONVERT(FLOAT,math) AS math_verbal_total                
                ,CONVERT(FLOAT,total) AS all_tests_total
                ,CASE
                  WHEN (CASE WHEN CONVERT(FLOAT,evidence_based_reading_writing) BETWEEN 200 AND 800 THEN CONVERT(FLOAT,evidence_based_reading_writing) END
                         + CASE WHEN CONVERT(FLOAT,math) BETWEEN 200 AND 800 THEN CONVERT(FLOAT,math) END
                         + CASE WHEN CONVERT(FLOAT,writing) BETWEEN 200 AND 800 THEN CONVERT(FLOAT,writing) END) != total 
                       THEN 1 
                  WHEN total NOT BETWEEN 600 AND 2400 THEN 1
                 END AS total_flag
                ,CASE WHEN sat.test_date > CONVERT(DATE,GETDATE()) THEN 1 END AS test_date_flag
                ,sat.BINI_ID  
          FROM unioned_tables sat WITH(NOLOCK)
          LEFT OUTER JOIN PS$STUDENTS#static s WITH(NOLOCK)
            ON sat.hs_student_id = s.student_number          
         ) sub1
   ) sub2