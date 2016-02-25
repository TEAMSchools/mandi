USE KIPP_NJ
GO

ALTER VIEW GRADES$GPA_detail_wide AS

WITH gpa_long AS (
  SELECT student_number
        ,academic_year
        ,term
        ,CONCAT(field, '_', rt) AS pivot_field
        ,value
  FROM
      (
       SELECT student_number
             ,academic_year
             ,term
             ,rt
             ,total_credit_hours                              
             ,GPA_term               
             ,GPA_Y1
             ,CONVERT(FLOAT,RANK() OVER(PARTITION BY academic_year, term, schoolid, grade_level ORDER BY GPA_term DESC)) AS GPA_term_rank
             ,CONVERT(FLOAT,RANK() OVER(PARTITION BY academic_year, term, schoolid, grade_level ORDER BY GPA_y1 DESC)) AS GPA_y1_rank
       FROM KIPP_NJ..GRADES$GPA_detail_long#static WITH(NOLOCK)
  
       UNION ALL

       SELECT student_number
             ,academic_year
             ,term
             ,'CUR' AS rt
             ,total_credit_hours                              
             ,GPA_term               
             ,GPA_Y1
             ,CONVERT(FLOAT,RANK() OVER(PARTITION BY academic_year, term, schoolid, grade_level ORDER BY GPA_term DESC)) AS GPA_term_rank
             ,CONVERT(FLOAT,RANK() OVER(PARTITION BY academic_year, term, schoolid, grade_level ORDER BY GPA_y1 DESC)) AS GPA_y1_rank
       FROM KIPP_NJ..GRADES$GPA_detail_long#static WITH(NOLOCK)
       --WHERE is_curterm = 1
      ) sub  
  UNPIVOT(
    value
    FOR field IN (total_credit_hours                              
                 ,GPA_term               
                 ,GPA_Y1
                 ,GPA_term_rank
                 ,GPA_y1_rank)
   ) u
 )

SELECT student_number
      ,academic_year
      ,term
      ,MAX([GPA_term_CUR]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_CUR
      ,MAX([GPA_term_rank_CUR]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_rank_CUR
      ,MAX([GPA_term_rank_RT1]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_rank_RT1
      ,MAX([GPA_term_rank_RT2]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_rank_RT2
      ,MAX([GPA_term_rank_RT3]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_rank_RT3
      ,MAX([GPA_term_rank_RT4]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_rank_RT4
      ,MAX([GPA_term_RT1]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_RT1
      ,MAX([GPA_term_RT2]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_RT2
      ,MAX([GPA_term_RT3]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_RT3
      ,MAX([GPA_term_RT4]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_term_RT4
      ,MAX([GPA_Y1_CUR]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_Y1_CUR
      ,MAX([GPA_y1_rank_CUR]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_y1_rank_CUR
      ,MAX([GPA_y1_rank_RT1]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_y1_rank_RT1
      ,MAX([GPA_y1_rank_RT2]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_y1_rank_RT2
      ,MAX([GPA_y1_rank_RT3]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_y1_rank_RT3
      ,MAX([GPA_y1_rank_RT4]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_y1_rank_RT4
      ,MAX([GPA_Y1_RT1]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_Y1_RT1
      ,MAX([GPA_Y1_RT2]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_Y1_RT2
      ,MAX([GPA_Y1_RT3]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_Y1_RT3
      ,MAX([GPA_Y1_RT4]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS GPA_Y1_RT4      
      ,MAX([total_credit_hours_CUR]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS total_credit_hours_CUR
      ,MAX([total_credit_hours_RT1]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS total_credit_hours_RT1
      ,MAX([total_credit_hours_RT2]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS total_credit_hours_RT2
      ,MAX([total_credit_hours_RT3]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS total_credit_hours_RT3
      ,MAX([total_credit_hours_RT4]) OVER(PARTITION BY student_number, academic_year ORDER BY term ASC) AS total_credit_hours_RT4
FROM gpa_long
PIVOT(
  MAX(value)
  FOR pivot_field IN ([GPA_term_CUR]
                     ,[GPA_term_rank_CUR]
                     ,[GPA_term_rank_RT1]
                     ,[GPA_term_rank_RT2]
                     ,[GPA_term_rank_RT3]
                     ,[GPA_term_rank_RT4]
                     ,[GPA_term_RT1]
                     ,[GPA_term_RT2]
                     ,[GPA_term_RT3]
                     ,[GPA_term_RT4]
                     ,[GPA_Y1_CUR]
                     ,[GPA_y1_rank_CUR]
                     ,[GPA_y1_rank_RT1]
                     ,[GPA_y1_rank_RT2]
                     ,[GPA_y1_rank_RT3]
                     ,[GPA_y1_rank_RT4]
                     ,[GPA_Y1_RT1]
                     ,[GPA_Y1_RT2]
                     ,[GPA_Y1_RT3]
                     ,[GPA_Y1_RT4]                     
                     ,[total_credit_hours_CUR]
                     ,[total_credit_hours_RT1]
                     ,[total_credit_hours_RT2]
                     ,[total_credit_hours_RT3]
                     ,[total_credit_hours_RT4])
 ) p