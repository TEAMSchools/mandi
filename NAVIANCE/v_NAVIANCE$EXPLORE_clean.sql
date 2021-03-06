USE KIPP_NJ
GO

ALTER VIEW NAVIANCE$EXPLORE_clean AS

SELECT *
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number
              ORDER BY test_date ASC) AS n_attempt
FROM
    (
     SELECT sub1.nav_studentid
           ,sub1.student_number
           ,sub1.studentid           
           ,CASE WHEN sub1.english >= 1 AND sub1.english <= 36 THEN sub1.english ELSE NULL END AS english
           ,CASE WHEN sub1.math >= 1 AND sub1.math <= 36 THEN sub1.math ELSE NULL END AS math
           ,CASE WHEN sub1.reading >= 1 AND sub1.reading <= 36 THEN sub1.reading ELSE NULL END AS reading
           ,CASE WHEN sub1.science >= 1 AND sub1.science <= 36 THEN sub1.science ELSE NULL END AS science                      
           ,CASE 
             WHEN (sub1.composite < 1 OR sub1.composite > 36) 
               OR sub1.composite != 
                   ROUND((CASE WHEN sub1.english >= 1 AND sub1.english <= 36 THEN CONVERT(FLOAT,sub1.english) ELSE NULL END
                           + CASE WHEN sub1.math >= 1 AND sub1.math <= 36 THEN CONVERT(FLOAT,sub1.math) ELSE NULL END
                           + CASE WHEN sub1.reading >= 1 AND sub1.reading <= 36 THEN CONVERT(FLOAT,sub1.reading) ELSE NULL END
                           + CASE WHEN sub1.science >= 1 AND sub1.science <= 36 THEN CONVERT(FLOAT,sub1.science) ELSE NULL END) / 4,0)
               THEN NULL
             ELSE sub1.composite
            END AS composite
           ,CASE WHEN sub1.test_date <= GETDATE() THEN sub1.test_date ELSE NULL END AS test_date
           ,co.year
           ,ROW_NUMBER() OVER(
              PARTITION BY sub1.student_number, test_date
                  ORDER BY test_date) AS dupe_audit
     FROM
         (
          SELECT studentid AS nav_studentid
                ,hs_student_id AS student_number
                ,s.id AS studentid                             
                ,CONVERT(INT,english) AS english
                ,CONVERT(INT,math) AS math
                ,CONVERT(INT,reading) AS reading
                ,CONVERT(INT,science) AS science                
                ,CONVERT(INT,composite) AS composite
                ,CASE WHEN ISDATE(REPLACE(test_date,'-00','-01')) = 1 THEN CONVERT(DATE,REPLACE(test_date,'-00','-01')) ELSE NULL END AS test_date                
          FROM AUTOLOAD$NAVIANCE_explore_scores act WITH(NOLOCK)
          JOIN PS$STUDENTS#static s WITH(NOLOCK)
            ON act.hs_student_id = s.student_number          
         ) sub1    
    LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
      ON sub1.studentid = co.studentid
     AND sub1.test_date >= co.ENTRYDATE
     AND sub1.test_date <= co.exitdate    
   ) sub2
WHERE dupe_audit = 1