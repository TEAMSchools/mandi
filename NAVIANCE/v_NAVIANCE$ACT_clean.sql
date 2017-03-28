USE KIPP_NJ
GO

ALTER VIEW NAVIANCE$ACT_clean AS

SELECT *
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number
              ORDER BY composite DESC) AS rn_highest
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number
              ORDER BY test_date ASC) AS n_attempt
      ,ROW_NUMBER() OVER(
          PARTITION BY student_number, year
              ORDER BY test_date ASC) AS n_attempt_year
FROM
    (
     SELECT sub1.nav_studentid
           ,sub1.student_number
           ,sub1.studentid
           ,sub1.test_type
           ,CASE WHEN sub1.english BETWEEN 1 AND 36 THEN sub1.english ELSE NULL END AS english
           ,CASE WHEN sub1.math BETWEEN 1 AND 36 THEN sub1.math ELSE NULL END AS math
           ,CASE WHEN sub1.reading BETWEEN 1 AND 36 THEN sub1.reading ELSE NULL END AS reading
           ,CASE WHEN sub1.science BETWEEN 1 AND 36 THEN sub1.science ELSE NULL END AS science
           ,CASE WHEN sub1.writing BETWEEN 1 AND 36 THEN sub1.writing ELSE NULL END AS writing
           ,CASE WHEN sub1.writing_sub BETWEEN 2 AND 12 THEN sub1.writing_sub ELSE NULL END AS writing_sub
           ,sub1.comb_eng_write
           ,sub1.ela
           ,sub1.stem
           ,CASE 
             WHEN (sub1.composite < 1 OR sub1.composite > 36) 
                     OR sub1.composite != ROUND((CASE WHEN sub1.english BETWEEN 1 AND 36 THEN CONVERT(FLOAT,sub1.english) ELSE NULL END
                                                  + CASE WHEN sub1.math BETWEEN 1 AND 36 THEN CONVERT(FLOAT,sub1.math) ELSE NULL END
                                                  + CASE WHEN sub1.reading BETWEEN 1 AND 36 THEN CONVERT(FLOAT,sub1.reading) ELSE NULL END
                                                  + CASE WHEN sub1.science BETWEEN 1 AND 36 THEN CONVERT(FLOAT,sub1.science) ELSE NULL END) 
                                                  / 4
                                                ,0)
                  THEN NULL
             ELSE sub1.composite
            END AS composite
           ,predicted_act
           ,CASE WHEN sub1.test_date <= CONVERT(DATE,GETDATE()) THEN sub1.test_date ELSE NULL END AS test_date
           ,KIPP_NJ.dbo.fn_DateToSY(test_date) AS year
           ,ROW_NUMBER() OVER(
              PARTITION BY sub1.student_number, CONVERT(DATE,test_date)
                  ORDER BY CONVERT(DATE,test_date)) AS dupe_audit
     FROM
         (
          SELECT studentid AS nav_studentid
                ,hs_student_id AS student_number
                ,s.id AS studentid             
                ,test_type
                ,CONVERT(INT,english) AS english
                ,CONVERT(INT,math) AS math
                ,CONVERT(INT,reading) AS reading
                ,CONVERT(INT,science) AS science
                ,CONVERT(INT,writing) AS writing
                ,CONVERT(INT,writing_sub) AS writing_sub
                ,CONVERT(INT,comb_eng_write) AS comb_eng_write                
                ,CONVERT(INT,ela) AS ela
                ,CONVERT(INT,stem) AS stem
                ,CONVERT(INT,composite) AS composite
                ,CONVERT(INT,predicted_act) AS predicted_act
                ,CASE WHEN ISDATE(REPLACE(test_date,'-00','-01')) = 1 THEN CONVERT(DATE,REPLACE(test_date,'-00','-01')) ELSE NULL END AS test_date                                
          FROM AUTOLOAD$NAVIANCE_3_act_scores act WITH(NOLOCK)
          JOIN PS$STUDENTS#static s WITH(NOLOCK)
            ON act.hs_student_id = s.student_number
          WHERE act.test_type LIKE 'ACT%'
         ) sub1    
   ) sub2
--WHERE dupe_audit = 1