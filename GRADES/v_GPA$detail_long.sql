USE KIPP_NJ
GO

ALTER VIEW GPA$detail_long AS

SELECT SCHOOLID
      ,STUDENT_NUMBER
      ,studentid
      ,term
      ,GPA_all
      ,GPA_core
FROM
    (
     SELECT STUDENT_NUMBER
           ,STUDENTID
           ,SCHOOLID
           ,UPPER(LTRIM(RTRIM(SUBSTRING(term, 5, 2)))) AS term      
           ,REPLACE(term, SUBSTRING(term, 5, 3), '') AS gpa_type
           ,gpa
     FROM 
         (
          SELECT STUDENT_NUMBER
                ,STUDENTID
                ,SCHOOLID
                ,GPA_t1_all
                ,GPA_t2_all
                ,GPA_t3_all
                ,GPA_t1_core
                ,GPA_t2_core
                ,GPA_t3_core
                ,NULL AS GPA_Q1_all
                ,NULL AS GPA_Q2_all
                ,NULL AS GPA_Q3_all
                ,NULL AS GPA_Q4_all
          FROM GPA$detail#MS WITH(NOLOCK)
          
          UNION ALL

          SELECT STUDENT_NUMBER
                ,STUDENTID
                ,SCHOOLID
                ,NULL AS GPA_t1_all
                ,NULL AS GPA_t2_all
                ,NULL AS GPA_t3_all
                ,NULL AS GPA_t1_core
                ,NULL AS GPA_t2_core
                ,NULL AS GPA_t3_core
                ,GPA_Q1 AS gpa_q1_all
                ,GPA_Q2 AS gpa_q2_all
                ,GPA_Q3 AS gpa_q3_all
                ,GPA_Q4 AS gpa_q4_all
          FROM GPA$detail#NCA WITH(NOLOCK)
         ) sub
     UNPIVOT (
       gpa
       FOR term IN (GPA_t1_all
                   ,GPA_t2_all
                   ,GPA_t3_all
                   ,GPA_t1_core
                   ,GPA_t2_core
                   ,GPA_t3_core
                   ,GPA_Q1_all
                   ,GPA_Q2_all
                   ,GPA_Q3_all
                   ,GPA_Q4_all)
      ) u
     ) sub

PIVOT (
  MAX(gpa)
  FOR gpa_type IN ([GPA_all], [GPA_core])
 ) p