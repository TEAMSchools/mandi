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
        ,NULL AS [mc_subscore]
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
        ,NULL AS [writing_test]      
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
           ,CASE WHEN sub1.test_date <= GETDATE() THEN sub1.test_date ELSE NULL END AS test_date
           ,co.year AS academic_year
           ,ROW_NUMBER() OVER(
              PARTITION BY sub1.student_number, test_date
                  ORDER BY sub1.test_date) AS dupe_audit
     FROM
         (
          SELECT sat.student_id AS nav_studentid
                ,hs_student_id AS student_number
                ,s.id AS studentid                
                ,CONVERT(FLOAT,evidence_based_reading_writing) AS verbal
                ,CONVERT(FLOAT,math) AS math
                ,CONVERT(FLOAT,writing) AS writing
                ,essay_subscore
                ,mc_subscore                
                ,CONVERT(FLOAT,evidence_based_reading_writing) + CONVERT(FLOAT,math) AS math_verbal_total
                ,CASE WHEN CONVERT(FLOAT,evidence_based_reading_writing) >= 200 AND CONVERT(FLOAT,evidence_based_reading_writing) <= 800 THEN CONVERT(FLOAT,evidence_based_reading_writing) ELSE NULL END
                  + CASE WHEN CONVERT(FLOAT,math) >= 200 AND CONVERT(FLOAT,math) <= 800 THEN CONVERT(FLOAT,math) ELSE NULL END
                  + CASE WHEN CONVERT(FLOAT,writing) >= 200 AND CONVERT(FLOAT,writing) <= 800 THEN CONVERT(FLOAT,writing) ELSE NULL END                        
                  AS all_tests_total
                ,test_date              
                ,sat.BINI_ID  
          FROM unioned_tables sat WITH(NOLOCK)
          LEFT OUTER JOIN PS$STUDENTS#static s WITH(NOLOCK)
            ON sat.hs_student_id = s.student_number          
         ) sub1    
    LEFT OUTER JOIN COHORT$comprehensive_long#static co
      ON sub1.studentid = co.studentid
     AND sub1.test_date BETWEEN co.ENTRYDATE AND co.exitdate
   ) sub2
--WHERE dupe_audit = 1