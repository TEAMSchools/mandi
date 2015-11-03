USE KIPP_NJ
GO

ALTER VIEW NAVIANCE$PSAT_clean AS

SELECT *
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number
              ORDER BY test_date ASC) AS n_attempt
FROM
    (
     SELECT sub1.nav_studentid
           ,sub1.student_number
           ,sub1.studentid
           ,sub1.total
           ,sub1.evidence_based_reading_writing
           ,sub1.math
           ,sub1.reading_test
           ,sub1.math_test   
           ,sub1.writing_test         
           --,reading_test + math AS math_reading_total
           --,CASE WHEN CONVERT(INT,critical_reading) >= 20 AND CONVERT(INT,critical_reading) <= 80 THEN CONVERT(INT,critical_reading) ELSE NULL END
           --       + CASE WHEN CONVERT(INT,math) >= 20 AND CONVERT(INT,math) <= 80 THEN CONVERT(INT,math) ELSE NULL END
           --       + CASE WHEN CONVERT(INT,writing) >= 20 AND CONVERT(INT,writing) <= 80 THEN CONVERT(INT,writing) ELSE NULL END                        
           --       AS all_tests_total
           ,CASE WHEN sub1.test_date <= GETDATE() THEN sub1.test_date ELSE NULL END AS test_date
           ,co.year AS academic_year
           ,ROW_NUMBER() OVER(
              PARTITION BY sub1.student_number, test_date
                  ORDER BY sub1.test_date) AS dupe_audit
     FROM
         (
          SELECT sat.studentid AS nav_studentid
                ,sat.hs_student_id AS student_number
                ,s.id AS studentid                
                ,CONVERT(INT,total) AS total
                ,CONVERT(INT,evidence_based_reading_writing) AS evidence_based_reading_writing
                ,CONVERT(INT,math) AS math                
                ,CONVERT(INT,reading_test) AS reading_test
                ,CONVERT(INT,math_test) AS math_test
                ,CONVERT(INT,writing_test) AS writing_test                
                /* not sure how these should be cleaned up */
                --,CASE WHEN CONVERT(INT,reading_test) BETWEEN 20 AND 80 THEN CONVERT(INT,reading_test) ELSE NULL END AS reading_test
                --,CASE WHEN CONVERT(INT,math) BETWEEN 20 AND 80 THEN CONVERT(INT,math) ELSE NULL END AS math
                --,CASE WHEN CONVERT(INT,writing_test) BETWEEN 20 AND 80 THEN CONVERT(INT,writing_test) ELSE NULL END AS writing_test                                                
                ,CASE WHEN ISDATE(REPLACE(test_date,'-00','-01')) = 1 THEN CONVERT(DATE,REPLACE(test_date,'-00','-01')) ELSE NULL END AS test_date                
          FROM AUTOLOAD$NAVIANCE_psat_scores sat WITH(NOLOCK)
          LEFT OUTER JOIN PS$STUDENTS#static s WITH(NOLOCK)
            ON sat.hs_student_id = s.student_number
          WHERE ISNUMERIC(sat.hs_student_id) = 1
         ) sub1    
    LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
      ON sub1.studentid = co.studentid
     AND sub1.test_date >= co.ENTRYDATE
     AND sub1.test_date <= co.exitdate    
   ) sub2
WHERE dupe_audit = 1