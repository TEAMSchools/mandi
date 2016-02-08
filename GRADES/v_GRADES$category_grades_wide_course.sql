USE KIPP_NJ
GO

ALTER VIEW GRADES$category_grades_wide_course AS

WITH grades_unpivot AS (
  SELECT student_number
        ,SCHOOLID
        ,academic_year      
        ,reporting_term      
        --,CONCAT('rc', RIGHT(CONCAT('0', class_rn),2), '_', field) AS pivot_field
        ,class_rn
        ,field
        ,value
        --,CREDITTYPE
        --,COURSE_NUMBER
        --,sectionid
        --,teacher_name
  FROM KIPP_NJ..GRADES$category_grades_wide#static WITH(NOLOCK)
  UNPIVOT(
    value
    FOR field IN (A_term
                 ,C_term
                 ,H_term
                 ,P_term
                 ,S_term
                 ,E_term
                 ,A_Y1
                 ,C_Y1
                 ,H_Y1
                 ,P_Y1
                 ,S_Y1
                 ,E_Y1)
   ) u
 )

,grades_union AS (
  /* one column, data changes via current term */
  SELECT student_number
        ,SCHOOLID
        ,academic_year
        ,reporting_term      
        ,CONCAT('rc', RIGHT(CONCAT('0', class_rn),2), '_', field) AS pivot_field
        ,value
  FROM grades_unpivot

  UNION ALL

  /* multiple columns, one for each term */
  SELECT student_number
        ,SCHOOLID
        ,academic_year
        ,reporting_term      
        ,CONCAT('rc', RIGHT(CONCAT('0', class_rn),2), '_', reporting_term, '_', field) AS pivot_field
        ,value
  FROM grades_unpivot
  WHERE field NOT LIKE '%Y1'
 )

SELECT student_number
      ,SCHOOLID
      ,academic_year
      ,reporting_term
      ,[rc01_A_term]
      ,[rc01_A_Y1]
      ,[rc01_C_term]
      ,[rc01_C_Y1]
      ,[rc01_E_term]
      ,[rc01_E_Y1]
      ,[rc01_H_term]
      ,[rc01_H_Y1]
      ,[rc01_P_term]
      ,[rc01_P_Y1]
      ,[rc01_S_term]
      ,[rc01_S_Y1]
      ,[rc02_A_term]
      ,[rc02_A_Y1]
      ,[rc02_C_term]
      ,[rc02_C_Y1]
      ,[rc02_E_term]
      ,[rc02_E_Y1]
      ,[rc02_H_term]
      ,[rc02_H_Y1]
      ,[rc02_P_term]
      ,[rc02_P_Y1]
      ,[rc02_S_term]
      ,[rc02_S_Y1]
      ,[rc03_A_term]
      ,[rc03_A_Y1]
      ,[rc03_C_term]
      ,[rc03_C_Y1]
      ,[rc03_E_term]
      ,[rc03_E_Y1]
      ,[rc03_H_term]
      ,[rc03_H_Y1]
      ,[rc03_P_term]
      ,[rc03_P_Y1]
      ,[rc03_S_term]
      ,[rc03_S_Y1]
      ,[rc04_A_term]
      ,[rc04_A_Y1]
      ,[rc04_C_term]
      ,[rc04_C_Y1]
      ,[rc04_E_term]
      ,[rc04_E_Y1]
      ,[rc04_H_term]
      ,[rc04_H_Y1]
      ,[rc04_P_term]
      ,[rc04_P_Y1]
      ,[rc04_S_term]
      ,[rc04_S_Y1]
      ,[rc05_A_term]
      ,[rc05_A_Y1]
      ,[rc05_C_term]
      ,[rc05_C_Y1]
      ,[rc05_E_term]
      ,[rc05_E_Y1]
      ,[rc05_H_term]
      ,[rc05_H_Y1]
      ,[rc05_P_term]
      ,[rc05_P_Y1]
      ,[rc05_S_term]
      ,[rc05_S_Y1]
      ,[rc06_A_term]
      ,[rc06_A_Y1]
      ,[rc06_C_term]
      ,[rc06_C_Y1]
      ,[rc06_E_term]
      ,[rc06_E_Y1]
      ,[rc06_H_term]
      ,[rc06_H_Y1]
      ,[rc06_P_term]
      ,[rc06_P_Y1]
      ,[rc06_S_term]
      ,[rc06_S_Y1]
      ,[rc07_A_term]
      ,[rc07_A_Y1]
      ,[rc07_C_term]
      ,[rc07_C_Y1]
      ,[rc07_E_term]
      ,[rc07_E_Y1]
      ,[rc07_H_term]
      ,[rc07_H_Y1]
      ,[rc07_P_term]
      ,[rc07_P_Y1]
      ,[rc07_S_term]
      ,[rc07_S_Y1]
      ,[rc08_A_term]
      ,[rc08_A_Y1]
      ,[rc08_C_term]
      ,[rc08_C_Y1]
      ,[rc08_E_term]
      ,[rc08_E_Y1]
      ,[rc08_H_term]
      ,[rc08_H_Y1]
      ,[rc08_P_term]
      ,[rc08_P_Y1]
      ,[rc08_S_term]
      ,[rc08_S_Y1]
      ,[rc09_A_term]
      ,[rc09_A_Y1]
      ,[rc09_C_term]
      ,[rc09_C_Y1]
      ,[rc09_E_term]
      ,[rc09_E_Y1]
      ,[rc09_H_term]
      ,[rc09_H_Y1]
      ,[rc09_P_term]
      ,[rc09_P_Y1]
      ,[rc09_S_term]
      ,[rc09_S_Y1]
      ,[rc10_A_term]
      ,[rc10_A_Y1]
      ,[rc10_C_term]
      ,[rc10_C_Y1]
      ,[rc10_E_term]
      ,[rc10_E_Y1]
      ,[rc10_H_term]
      ,[rc10_H_Y1]
      ,[rc10_P_term]
      ,[rc10_P_Y1]
      ,[rc10_S_term]
      ,[rc10_S_Y1]
      ,[rc11_A_term]
      ,[rc11_A_Y1]
      ,[rc11_C_term]
      ,[rc11_C_Y1]
      ,[rc11_E_term]
      ,[rc11_E_Y1]
      ,[rc11_H_term]
      ,[rc11_H_Y1]
      ,[rc11_P_term]
      ,[rc11_P_Y1]
      ,[rc11_S_term]
      ,[rc11_S_Y1]
      ,[rc12_A_term]
      ,[rc12_A_Y1]
      ,[rc12_C_term]
      ,[rc12_C_Y1]
      ,[rc12_E_term]
      ,[rc12_E_Y1]
      ,[rc12_H_term]
      ,[rc12_H_Y1]
      ,[rc12_P_term]
      ,[rc12_P_Y1]
      ,[rc12_S_term]
      ,[rc12_S_Y1]
      ,MAX([rc01_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT1_A_term
      ,MAX([rc01_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT1_C_term
      ,MAX([rc01_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT1_H_term
      ,MAX([rc01_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT1_P_term
      ,MAX([rc01_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT1_S_term
      ,MAX([rc01_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT1_E_term
      ,MAX([rc01_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT2_A_term
      ,MAX([rc01_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT2_C_term
      ,MAX([rc01_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT2_H_term
      ,MAX([rc01_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT2_P_term
      ,MAX([rc01_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT2_S_term
      ,MAX([rc01_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT2_E_term
      ,MAX([rc01_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT3_A_term
      ,MAX([rc01_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT3_C_term
      ,MAX([rc01_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT3_H_term
      ,MAX([rc01_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT3_P_term
      ,MAX([rc01_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT3_S_term
      ,MAX([rc01_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT3_E_term
      ,MAX([rc01_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT4_A_term
      ,MAX([rc01_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT4_C_term
      ,MAX([rc01_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT4_H_term
      ,MAX([rc01_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT4_P_term
      ,MAX([rc01_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT4_S_term
      ,MAX([rc01_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc01_RT4_E_term
      ,MAX([rc02_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT1_A_term
      ,MAX([rc02_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT1_C_term
      ,MAX([rc02_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT1_H_term
      ,MAX([rc02_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT1_P_term
      ,MAX([rc02_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT1_S_term
      ,MAX([rc02_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT1_E_term
      ,MAX([rc02_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT2_A_term
      ,MAX([rc02_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT2_C_term
      ,MAX([rc02_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT2_H_term
      ,MAX([rc02_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT2_P_term
      ,MAX([rc02_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT2_S_term
      ,MAX([rc02_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT2_E_term
      ,MAX([rc02_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT3_A_term
      ,MAX([rc02_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT3_C_term
      ,MAX([rc02_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT3_H_term
      ,MAX([rc02_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT3_P_term
      ,MAX([rc02_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT3_S_term
      ,MAX([rc02_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT3_E_term
      ,MAX([rc02_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT4_A_term
      ,MAX([rc02_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT4_C_term
      ,MAX([rc02_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT4_H_term
      ,MAX([rc02_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT4_P_term
      ,MAX([rc02_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT4_S_term
      ,MAX([rc02_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc02_RT4_E_term
      ,MAX([rc03_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT1_A_term
      ,MAX([rc03_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT1_C_term
      ,MAX([rc03_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT1_H_term
      ,MAX([rc03_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT1_P_term
      ,MAX([rc03_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT1_S_term
      ,MAX([rc03_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT1_E_term
      ,MAX([rc03_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT2_A_term
      ,MAX([rc03_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT2_C_term
      ,MAX([rc03_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT2_H_term
      ,MAX([rc03_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT2_P_term
      ,MAX([rc03_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT2_S_term
      ,MAX([rc03_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT2_E_term
      ,MAX([rc03_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT3_A_term
      ,MAX([rc03_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT3_C_term
      ,MAX([rc03_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT3_H_term
      ,MAX([rc03_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT3_P_term
      ,MAX([rc03_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT3_S_term
      ,MAX([rc03_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT3_E_term
      ,MAX([rc03_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT4_A_term
      ,MAX([rc03_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT4_C_term
      ,MAX([rc03_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT4_H_term
      ,MAX([rc03_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT4_P_term
      ,MAX([rc03_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT4_S_term
      ,MAX([rc03_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc03_RT4_E_term
      ,MAX([rc04_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT1_A_term
      ,MAX([rc04_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT1_C_term
      ,MAX([rc04_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT1_H_term
      ,MAX([rc04_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT1_P_term
      ,MAX([rc04_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT1_S_term
      ,MAX([rc04_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT1_E_term
      ,MAX([rc04_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT2_A_term
      ,MAX([rc04_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT2_C_term
      ,MAX([rc04_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT2_H_term
      ,MAX([rc04_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT2_P_term
      ,MAX([rc04_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT2_S_term
      ,MAX([rc04_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT2_E_term
      ,MAX([rc04_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT3_A_term
      ,MAX([rc04_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT3_C_term
      ,MAX([rc04_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT3_H_term
      ,MAX([rc04_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT3_P_term
      ,MAX([rc04_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT3_S_term
      ,MAX([rc04_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT3_E_term
      ,MAX([rc04_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT4_A_term
      ,MAX([rc04_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT4_C_term
      ,MAX([rc04_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT4_H_term
      ,MAX([rc04_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT4_P_term
      ,MAX([rc04_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT4_S_term
      ,MAX([rc04_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc04_RT4_E_term
      ,MAX([rc05_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT1_A_term
      ,MAX([rc05_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT1_C_term
      ,MAX([rc05_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT1_H_term
      ,MAX([rc05_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT1_P_term
      ,MAX([rc05_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT1_S_term
      ,MAX([rc05_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT1_E_term
      ,MAX([rc05_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT2_A_term
      ,MAX([rc05_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT2_C_term
      ,MAX([rc05_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT2_H_term
      ,MAX([rc05_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT2_P_term
      ,MAX([rc05_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT2_S_term
      ,MAX([rc05_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT2_E_term
      ,MAX([rc05_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT3_A_term
      ,MAX([rc05_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT3_C_term
      ,MAX([rc05_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT3_H_term
      ,MAX([rc05_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT3_P_term
      ,MAX([rc05_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT3_S_term
      ,MAX([rc05_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT3_E_term
      ,MAX([rc05_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT4_A_term
      ,MAX([rc05_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT4_C_term
      ,MAX([rc05_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT4_H_term
      ,MAX([rc05_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT4_P_term
      ,MAX([rc05_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT4_S_term
      ,MAX([rc05_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc05_RT4_E_term
      ,MAX([rc06_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT1_A_term
      ,MAX([rc06_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT1_C_term
      ,MAX([rc06_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT1_H_term
      ,MAX([rc06_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT1_P_term
      ,MAX([rc06_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT1_S_term
      ,MAX([rc06_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT1_E_term
      ,MAX([rc06_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT2_A_term
      ,MAX([rc06_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT2_C_term
      ,MAX([rc06_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT2_H_term
      ,MAX([rc06_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT2_P_term
      ,MAX([rc06_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT2_S_term
      ,MAX([rc06_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT2_E_term
      ,MAX([rc06_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT3_A_term
      ,MAX([rc06_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT3_C_term
      ,MAX([rc06_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT3_H_term
      ,MAX([rc06_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT3_P_term
      ,MAX([rc06_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT3_S_term
      ,MAX([rc06_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT3_E_term
      ,MAX([rc06_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT4_A_term
      ,MAX([rc06_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT4_C_term
      ,MAX([rc06_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT4_H_term
      ,MAX([rc06_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT4_P_term
      ,MAX([rc06_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT4_S_term
      ,MAX([rc06_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc06_RT4_E_term
      ,MAX([rc07_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT1_A_term
      ,MAX([rc07_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT1_C_term
      ,MAX([rc07_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT1_H_term
      ,MAX([rc07_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT1_P_term
      ,MAX([rc07_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT1_S_term
      ,MAX([rc07_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT1_E_term
      ,MAX([rc07_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT2_A_term
      ,MAX([rc07_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT2_C_term
      ,MAX([rc07_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT2_H_term
      ,MAX([rc07_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT2_P_term
      ,MAX([rc07_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT2_S_term
      ,MAX([rc07_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT2_E_term
      ,MAX([rc07_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT3_A_term
      ,MAX([rc07_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT3_C_term
      ,MAX([rc07_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT3_H_term
      ,MAX([rc07_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT3_P_term
      ,MAX([rc07_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT3_S_term
      ,MAX([rc07_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT3_E_term
      ,MAX([rc07_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT4_A_term
      ,MAX([rc07_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT4_C_term
      ,MAX([rc07_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT4_H_term
      ,MAX([rc07_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT4_P_term
      ,MAX([rc07_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT4_S_term
      ,MAX([rc07_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc07_RT4_E_term
      ,MAX([rc08_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT1_A_term
      ,MAX([rc08_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT1_C_term
      ,MAX([rc08_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT1_H_term
      ,MAX([rc08_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT1_P_term
      ,MAX([rc08_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT1_S_term
      ,MAX([rc08_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT1_E_term
      ,MAX([rc08_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT2_A_term
      ,MAX([rc08_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT2_C_term
      ,MAX([rc08_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT2_H_term
      ,MAX([rc08_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT2_P_term
      ,MAX([rc08_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT2_S_term
      ,MAX([rc08_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT2_E_term
      ,MAX([rc08_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT3_A_term
      ,MAX([rc08_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT3_C_term
      ,MAX([rc08_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT3_H_term
      ,MAX([rc08_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT3_P_term
      ,MAX([rc08_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT3_S_term
      ,MAX([rc08_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT3_E_term
      ,MAX([rc08_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT4_A_term
      ,MAX([rc08_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT4_C_term
      ,MAX([rc08_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT4_H_term
      ,MAX([rc08_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT4_P_term
      ,MAX([rc08_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT4_S_term
      ,MAX([rc08_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc08_RT4_E_term
      ,MAX([rc09_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT1_A_term
      ,MAX([rc09_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT1_C_term
      ,MAX([rc09_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT1_H_term
      ,MAX([rc09_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT1_P_term
      ,MAX([rc09_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT1_S_term
      ,MAX([rc09_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT1_E_term
      ,MAX([rc09_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT2_A_term
      ,MAX([rc09_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT2_C_term
      ,MAX([rc09_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT2_H_term
      ,MAX([rc09_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT2_P_term
      ,MAX([rc09_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT2_S_term
      ,MAX([rc09_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT2_E_term
      ,MAX([rc09_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT3_A_term
      ,MAX([rc09_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT3_C_term
      ,MAX([rc09_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT3_H_term
      ,MAX([rc09_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT3_P_term
      ,MAX([rc09_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT3_S_term
      ,MAX([rc09_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT3_E_term
      ,MAX([rc09_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT4_A_term
      ,MAX([rc09_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT4_C_term
      ,MAX([rc09_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT4_H_term
      ,MAX([rc09_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT4_P_term
      ,MAX([rc09_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT4_S_term
      ,MAX([rc09_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc09_RT4_E_term
      ,MAX([rc10_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT1_A_term
      ,MAX([rc10_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT1_C_term
      ,MAX([rc10_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT1_H_term
      ,MAX([rc10_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT1_P_term
      ,MAX([rc10_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT1_S_term
      ,MAX([rc10_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT1_E_term
      ,MAX([rc10_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT2_A_term
      ,MAX([rc10_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT2_C_term
      ,MAX([rc10_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT2_H_term
      ,MAX([rc10_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT2_P_term
      ,MAX([rc10_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT2_S_term
      ,MAX([rc10_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT2_E_term
      ,MAX([rc10_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT3_A_term
      ,MAX([rc10_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT3_C_term
      ,MAX([rc10_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT3_H_term
      ,MAX([rc10_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT3_P_term
      ,MAX([rc10_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT3_S_term
      ,MAX([rc10_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT3_E_term
      ,MAX([rc10_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT4_A_term
      ,MAX([rc10_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT4_C_term
      ,MAX([rc10_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT4_H_term
      ,MAX([rc10_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT4_P_term
      ,MAX([rc10_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT4_S_term
      ,MAX([rc10_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc10_RT4_E_term
      ,MAX([rc11_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT1_A_term
      ,MAX([rc11_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT1_C_term
      ,MAX([rc11_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT1_H_term
      ,MAX([rc11_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT1_P_term
      ,MAX([rc11_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT1_S_term
      ,MAX([rc11_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT1_E_term
      ,MAX([rc11_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT2_A_term
      ,MAX([rc11_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT2_C_term
      ,MAX([rc11_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT2_H_term
      ,MAX([rc11_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT2_P_term
      ,MAX([rc11_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT2_S_term
      ,MAX([rc11_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT2_E_term
      ,MAX([rc11_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT3_A_term
      ,MAX([rc11_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT3_C_term
      ,MAX([rc11_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT3_H_term
      ,MAX([rc11_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT3_P_term
      ,MAX([rc11_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT3_S_term
      ,MAX([rc11_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT3_E_term
      ,MAX([rc11_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT4_A_term
      ,MAX([rc11_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT4_C_term
      ,MAX([rc11_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT4_H_term
      ,MAX([rc11_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT4_P_term
      ,MAX([rc11_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT4_S_term
      ,MAX([rc11_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc11_RT4_E_term
      ,MAX([rc12_RT1_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT1_A_term
      ,MAX([rc12_RT1_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT1_C_term
      ,MAX([rc12_RT1_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT1_H_term
      ,MAX([rc12_RT1_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT1_P_term
      ,MAX([rc12_RT1_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT1_S_term
      ,MAX([rc12_RT1_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT1_E_term
      ,MAX([rc12_RT2_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT2_A_term
      ,MAX([rc12_RT2_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT2_C_term
      ,MAX([rc12_RT2_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT2_H_term
      ,MAX([rc12_RT2_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT2_P_term
      ,MAX([rc12_RT2_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT2_S_term
      ,MAX([rc12_RT2_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT2_E_term
      ,MAX([rc12_RT3_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT3_A_term
      ,MAX([rc12_RT3_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT3_C_term
      ,MAX([rc12_RT3_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT3_H_term
      ,MAX([rc12_RT3_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT3_P_term
      ,MAX([rc12_RT3_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT3_S_term
      ,MAX([rc12_RT3_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT3_E_term
      ,MAX([rc12_RT4_A_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT4_A_term
      ,MAX([rc12_RT4_C_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT4_C_term
      ,MAX([rc12_RT4_H_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT4_H_term
      ,MAX([rc12_RT4_P_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT4_P_term
      ,MAX([rc12_RT4_S_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT4_S_term
      ,MAX([rc12_RT4_E_term]) OVER(PARTITION BY student_number, academic_year ORDER BY reporting_term ASC) AS rc12_RT4_E_term
FROM grades_union
PIVOT(
  MAX(value)
  FOR pivot_field IN ([rc01_A_term]
                     ,[rc01_A_Y1]
                     ,[rc01_C_term]
                     ,[rc01_C_Y1]
                     ,[rc01_E_term]
                     ,[rc01_E_Y1]
                     ,[rc01_H_term]
                     ,[rc01_H_Y1]
                     ,[rc01_P_term]
                     ,[rc01_P_Y1]
                     ,[rc01_S_term]
                     ,[rc01_S_Y1]
                     ,[rc02_A_term]
                     ,[rc02_A_Y1]
                     ,[rc02_C_term]
                     ,[rc02_C_Y1]
                     ,[rc02_E_term]
                     ,[rc02_E_Y1]
                     ,[rc02_H_term]
                     ,[rc02_H_Y1]
                     ,[rc02_P_term]
                     ,[rc02_P_Y1]
                     ,[rc02_S_term]
                     ,[rc02_S_Y1]
                     ,[rc03_A_term]
                     ,[rc03_A_Y1]
                     ,[rc03_C_term]
                     ,[rc03_C_Y1]
                     ,[rc03_E_term]
                     ,[rc03_E_Y1]
                     ,[rc03_H_term]
                     ,[rc03_H_Y1]
                     ,[rc03_P_term]
                     ,[rc03_P_Y1]
                     ,[rc03_S_term]
                     ,[rc03_S_Y1]
                     ,[rc04_A_term]
                     ,[rc04_A_Y1]
                     ,[rc04_C_term]
                     ,[rc04_C_Y1]
                     ,[rc04_E_term]
                     ,[rc04_E_Y1]
                     ,[rc04_H_term]
                     ,[rc04_H_Y1]
                     ,[rc04_P_term]
                     ,[rc04_P_Y1]
                     ,[rc04_S_term]
                     ,[rc04_S_Y1]
                     ,[rc05_A_term]
                     ,[rc05_A_Y1]
                     ,[rc05_C_term]
                     ,[rc05_C_Y1]
                     ,[rc05_E_term]
                     ,[rc05_E_Y1]
                     ,[rc05_H_term]
                     ,[rc05_H_Y1]
                     ,[rc05_P_term]
                     ,[rc05_P_Y1]
                     ,[rc05_S_term]
                     ,[rc05_S_Y1]
                     ,[rc06_A_term]
                     ,[rc06_A_Y1]
                     ,[rc06_C_term]
                     ,[rc06_C_Y1]
                     ,[rc06_E_term]
                     ,[rc06_E_Y1]
                     ,[rc06_H_term]
                     ,[rc06_H_Y1]
                     ,[rc06_P_term]
                     ,[rc06_P_Y1]
                     ,[rc06_S_term]
                     ,[rc06_S_Y1]
                     ,[rc07_A_term]
                     ,[rc07_A_Y1]
                     ,[rc07_C_term]
                     ,[rc07_C_Y1]
                     ,[rc07_E_term]
                     ,[rc07_E_Y1]
                     ,[rc07_H_term]
                     ,[rc07_H_Y1]
                     ,[rc07_P_term]
                     ,[rc07_P_Y1]
                     ,[rc07_S_term]
                     ,[rc07_S_Y1]
                     ,[rc08_A_term]
                     ,[rc08_A_Y1]
                     ,[rc08_C_term]
                     ,[rc08_C_Y1]
                     ,[rc08_E_term]
                     ,[rc08_E_Y1]
                     ,[rc08_H_term]
                     ,[rc08_H_Y1]
                     ,[rc08_P_term]
                     ,[rc08_P_Y1]
                     ,[rc08_S_term]
                     ,[rc08_S_Y1]
                     ,[rc09_A_term]
                     ,[rc09_A_Y1]
                     ,[rc09_C_term]
                     ,[rc09_C_Y1]
                     ,[rc09_E_term]
                     ,[rc09_E_Y1]
                     ,[rc09_H_term]
                     ,[rc09_H_Y1]
                     ,[rc09_P_term]
                     ,[rc09_P_Y1]
                     ,[rc09_S_term]
                     ,[rc09_S_Y1]
                     ,[rc10_A_term]
                     ,[rc10_A_Y1]
                     ,[rc10_C_term]
                     ,[rc10_C_Y1]
                     ,[rc10_E_term]
                     ,[rc10_E_Y1]
                     ,[rc10_H_term]
                     ,[rc10_H_Y1]
                     ,[rc10_P_term]
                     ,[rc10_P_Y1]
                     ,[rc10_S_term]
                     ,[rc10_S_Y1]
                     ,[rc11_A_term]
                     ,[rc11_A_Y1]
                     ,[rc11_C_term]
                     ,[rc11_C_Y1]
                     ,[rc11_E_term]
                     ,[rc11_E_Y1]
                     ,[rc11_H_term]
                     ,[rc11_H_Y1]
                     ,[rc11_P_term]
                     ,[rc11_P_Y1]
                     ,[rc11_S_term]
                     ,[rc11_S_Y1]
                     ,[rc12_A_term]
                     ,[rc12_A_Y1]
                     ,[rc12_C_term]
                     ,[rc12_C_Y1]
                     ,[rc12_E_term]
                     ,[rc12_E_Y1]
                     ,[rc12_H_term]
                     ,[rc12_H_Y1]
                     ,[rc12_P_term]
                     ,[rc12_P_Y1]
                     ,[rc12_S_term]
                     ,[rc12_S_Y1]
                     ,[rc01_RT1_A_term]
                     ,[rc01_RT1_C_term]
                     ,[rc01_RT1_H_term]
                     ,[rc01_RT1_P_term]
                     ,[rc01_RT1_S_term]
                     ,[rc01_RT1_E_term]
                     ,[rc01_RT2_A_term]
                     ,[rc01_RT2_C_term]
                     ,[rc01_RT2_H_term]
                     ,[rc01_RT2_P_term]
                     ,[rc01_RT2_S_term]
                     ,[rc01_RT2_E_term]
                     ,[rc01_RT3_A_term]
                     ,[rc01_RT3_C_term]
                     ,[rc01_RT3_H_term]
                     ,[rc01_RT3_P_term]
                     ,[rc01_RT3_S_term]
                     ,[rc01_RT3_E_term]
                     ,[rc01_RT4_A_term]
                     ,[rc01_RT4_C_term]
                     ,[rc01_RT4_H_term]
                     ,[rc01_RT4_P_term]
                     ,[rc01_RT4_S_term]
                     ,[rc01_RT4_E_term]
                     ,[rc02_RT1_A_term]
                     ,[rc02_RT1_C_term]
                     ,[rc02_RT1_H_term]
                     ,[rc02_RT1_P_term]
                     ,[rc02_RT1_S_term]
                     ,[rc02_RT1_E_term]
                     ,[rc02_RT2_A_term]
                     ,[rc02_RT2_C_term]
                     ,[rc02_RT2_H_term]
                     ,[rc02_RT2_P_term]
                     ,[rc02_RT2_S_term]
                     ,[rc02_RT2_E_term]
                     ,[rc02_RT3_A_term]
                     ,[rc02_RT3_C_term]
                     ,[rc02_RT3_H_term]
                     ,[rc02_RT3_P_term]
                     ,[rc02_RT3_S_term]
                     ,[rc02_RT3_E_term]
                     ,[rc02_RT4_A_term]
                     ,[rc02_RT4_C_term]
                     ,[rc02_RT4_H_term]
                     ,[rc02_RT4_P_term]
                     ,[rc02_RT4_S_term]
                     ,[rc02_RT4_E_term]
                     ,[rc03_RT1_A_term]
                     ,[rc03_RT1_C_term]
                     ,[rc03_RT1_H_term]
                     ,[rc03_RT1_P_term]
                     ,[rc03_RT1_S_term]
                     ,[rc03_RT1_E_term]
                     ,[rc03_RT2_A_term]
                     ,[rc03_RT2_C_term]
                     ,[rc03_RT2_H_term]
                     ,[rc03_RT2_P_term]
                     ,[rc03_RT2_S_term]
                     ,[rc03_RT2_E_term]
                     ,[rc03_RT3_A_term]
                     ,[rc03_RT3_C_term]
                     ,[rc03_RT3_H_term]
                     ,[rc03_RT3_P_term]
                     ,[rc03_RT3_S_term]
                     ,[rc03_RT3_E_term]
                     ,[rc03_RT4_A_term]
                     ,[rc03_RT4_C_term]
                     ,[rc03_RT4_H_term]
                     ,[rc03_RT4_P_term]
                     ,[rc03_RT4_S_term]
                     ,[rc03_RT4_E_term]
                     ,[rc04_RT1_A_term]
                     ,[rc04_RT1_C_term]
                     ,[rc04_RT1_H_term]
                     ,[rc04_RT1_P_term]
                     ,[rc04_RT1_S_term]
                     ,[rc04_RT1_E_term]
                     ,[rc04_RT2_A_term]
                     ,[rc04_RT2_C_term]
                     ,[rc04_RT2_H_term]
                     ,[rc04_RT2_P_term]
                     ,[rc04_RT2_S_term]
                     ,[rc04_RT2_E_term]
                     ,[rc04_RT3_A_term]
                     ,[rc04_RT3_C_term]
                     ,[rc04_RT3_H_term]
                     ,[rc04_RT3_P_term]
                     ,[rc04_RT3_S_term]
                     ,[rc04_RT3_E_term]
                     ,[rc04_RT4_A_term]
                     ,[rc04_RT4_C_term]
                     ,[rc04_RT4_H_term]
                     ,[rc04_RT4_P_term]
                     ,[rc04_RT4_S_term]
                     ,[rc04_RT4_E_term]
                     ,[rc05_RT1_A_term]
                     ,[rc05_RT1_C_term]
                     ,[rc05_RT1_H_term]
                     ,[rc05_RT1_P_term]
                     ,[rc05_RT1_S_term]
                     ,[rc05_RT1_E_term]
                     ,[rc05_RT2_A_term]
                     ,[rc05_RT2_C_term]
                     ,[rc05_RT2_H_term]
                     ,[rc05_RT2_P_term]
                     ,[rc05_RT2_S_term]
                     ,[rc05_RT2_E_term]
                     ,[rc05_RT3_A_term]
                     ,[rc05_RT3_C_term]
                     ,[rc05_RT3_H_term]
                     ,[rc05_RT3_P_term]
                     ,[rc05_RT3_S_term]
                     ,[rc05_RT3_E_term]
                     ,[rc05_RT4_A_term]
                     ,[rc05_RT4_C_term]
                     ,[rc05_RT4_H_term]
                     ,[rc05_RT4_P_term]
                     ,[rc05_RT4_S_term]
                     ,[rc05_RT4_E_term]
                     ,[rc06_RT1_A_term]
                     ,[rc06_RT1_C_term]
                     ,[rc06_RT1_H_term]
                     ,[rc06_RT1_P_term]
                     ,[rc06_RT1_S_term]
                     ,[rc06_RT1_E_term]
                     ,[rc06_RT2_A_term]
                     ,[rc06_RT2_C_term]
                     ,[rc06_RT2_H_term]
                     ,[rc06_RT2_P_term]
                     ,[rc06_RT2_S_term]
                     ,[rc06_RT2_E_term]
                     ,[rc06_RT3_A_term]
                     ,[rc06_RT3_C_term]
                     ,[rc06_RT3_H_term]
                     ,[rc06_RT3_P_term]
                     ,[rc06_RT3_S_term]
                     ,[rc06_RT3_E_term]
                     ,[rc06_RT4_A_term]
                     ,[rc06_RT4_C_term]
                     ,[rc06_RT4_H_term]
                     ,[rc06_RT4_P_term]
                     ,[rc06_RT4_S_term]
                     ,[rc06_RT4_E_term]
                     ,[rc07_RT1_A_term]
                     ,[rc07_RT1_C_term]
                     ,[rc07_RT1_H_term]
                     ,[rc07_RT1_P_term]
                     ,[rc07_RT1_S_term]
                     ,[rc07_RT1_E_term]
                     ,[rc07_RT2_A_term]
                     ,[rc07_RT2_C_term]
                     ,[rc07_RT2_H_term]
                     ,[rc07_RT2_P_term]
                     ,[rc07_RT2_S_term]
                     ,[rc07_RT2_E_term]
                     ,[rc07_RT3_A_term]
                     ,[rc07_RT3_C_term]
                     ,[rc07_RT3_H_term]
                     ,[rc07_RT3_P_term]
                     ,[rc07_RT3_S_term]
                     ,[rc07_RT3_E_term]
                     ,[rc07_RT4_A_term]
                     ,[rc07_RT4_C_term]
                     ,[rc07_RT4_H_term]
                     ,[rc07_RT4_P_term]
                     ,[rc07_RT4_S_term]
                     ,[rc07_RT4_E_term]
                     ,[rc08_RT1_A_term]
                     ,[rc08_RT1_C_term]
                     ,[rc08_RT1_H_term]
                     ,[rc08_RT1_P_term]
                     ,[rc08_RT1_S_term]
                     ,[rc08_RT1_E_term]
                     ,[rc08_RT2_A_term]
                     ,[rc08_RT2_C_term]
                     ,[rc08_RT2_H_term]
                     ,[rc08_RT2_P_term]
                     ,[rc08_RT2_S_term]
                     ,[rc08_RT2_E_term]
                     ,[rc08_RT3_A_term]
                     ,[rc08_RT3_C_term]
                     ,[rc08_RT3_H_term]
                     ,[rc08_RT3_P_term]
                     ,[rc08_RT3_S_term]
                     ,[rc08_RT3_E_term]
                     ,[rc08_RT4_A_term]
                     ,[rc08_RT4_C_term]
                     ,[rc08_RT4_H_term]
                     ,[rc08_RT4_P_term]
                     ,[rc08_RT4_S_term]
                     ,[rc08_RT4_E_term]
                     ,[rc09_RT1_A_term]
                     ,[rc09_RT1_C_term]
                     ,[rc09_RT1_H_term]
                     ,[rc09_RT1_P_term]
                     ,[rc09_RT1_S_term]
                     ,[rc09_RT1_E_term]
                     ,[rc09_RT2_A_term]
                     ,[rc09_RT2_C_term]
                     ,[rc09_RT2_H_term]
                     ,[rc09_RT2_P_term]
                     ,[rc09_RT2_S_term]
                     ,[rc09_RT2_E_term]
                     ,[rc09_RT3_A_term]
                     ,[rc09_RT3_C_term]
                     ,[rc09_RT3_H_term]
                     ,[rc09_RT3_P_term]
                     ,[rc09_RT3_S_term]
                     ,[rc09_RT3_E_term]
                     ,[rc09_RT4_A_term]
                     ,[rc09_RT4_C_term]
                     ,[rc09_RT4_H_term]
                     ,[rc09_RT4_P_term]
                     ,[rc09_RT4_S_term]
                     ,[rc09_RT4_E_term]
                     ,[rc10_RT1_A_term]
                     ,[rc10_RT1_C_term]
                     ,[rc10_RT1_H_term]
                     ,[rc10_RT1_P_term]
                     ,[rc10_RT1_S_term]
                     ,[rc10_RT1_E_term]
                     ,[rc10_RT2_A_term]
                     ,[rc10_RT2_C_term]
                     ,[rc10_RT2_H_term]
                     ,[rc10_RT2_P_term]
                     ,[rc10_RT2_S_term]
                     ,[rc10_RT2_E_term]
                     ,[rc10_RT3_A_term]
                     ,[rc10_RT3_C_term]
                     ,[rc10_RT3_H_term]
                     ,[rc10_RT3_P_term]
                     ,[rc10_RT3_S_term]
                     ,[rc10_RT3_E_term]
                     ,[rc10_RT4_A_term]
                     ,[rc10_RT4_C_term]
                     ,[rc10_RT4_H_term]
                     ,[rc10_RT4_P_term]
                     ,[rc10_RT4_S_term]
                     ,[rc10_RT4_E_term]
                     ,[rc11_RT1_A_term]
                     ,[rc11_RT1_C_term]
                     ,[rc11_RT1_H_term]
                     ,[rc11_RT1_P_term]
                     ,[rc11_RT1_S_term]
                     ,[rc11_RT1_E_term]
                     ,[rc11_RT2_A_term]
                     ,[rc11_RT2_C_term]
                     ,[rc11_RT2_H_term]
                     ,[rc11_RT2_P_term]
                     ,[rc11_RT2_S_term]
                     ,[rc11_RT2_E_term]
                     ,[rc11_RT3_A_term]
                     ,[rc11_RT3_C_term]
                     ,[rc11_RT3_H_term]
                     ,[rc11_RT3_P_term]
                     ,[rc11_RT3_S_term]
                     ,[rc11_RT3_E_term]
                     ,[rc11_RT4_A_term]
                     ,[rc11_RT4_C_term]
                     ,[rc11_RT4_H_term]
                     ,[rc11_RT4_P_term]
                     ,[rc11_RT4_S_term]
                     ,[rc11_RT4_E_term]
                     ,[rc12_RT1_A_term]
                     ,[rc12_RT1_C_term]
                     ,[rc12_RT1_H_term]
                     ,[rc12_RT1_P_term]
                     ,[rc12_RT1_S_term]
                     ,[rc12_RT1_E_term]
                     ,[rc12_RT2_A_term]
                     ,[rc12_RT2_C_term]
                     ,[rc12_RT2_H_term]
                     ,[rc12_RT2_P_term]
                     ,[rc12_RT2_S_term]
                     ,[rc12_RT2_E_term]
                     ,[rc12_RT3_A_term]
                     ,[rc12_RT3_C_term]
                     ,[rc12_RT3_H_term]
                     ,[rc12_RT3_P_term]
                     ,[rc12_RT3_S_term]
                     ,[rc12_RT3_E_term]
                     ,[rc12_RT4_A_term]
                     ,[rc12_RT4_C_term]
                     ,[rc12_RT4_H_term]
                     ,[rc12_RT4_P_term]
                     ,[rc12_RT4_S_term]
                     ,[rc12_RT4_E_term])
 ) p