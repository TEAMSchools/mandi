USE KIPP_NJ
GO

ALTER VIEW GRADES$wide_by_term AS

WITH course_order AS (
  SELECT *
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY CASE
                       WHEN credittype = 'ENG' THEN 01
                       WHEN credittype = 'RHET' THEN 02
                       WHEN credittype = 'MATH' THEN 03
                       WHEN credittype = 'SCI' THEN 04
                       WHEN credittype = 'SOC' THEN 05
                       WHEN credittype = 'WLANG' THEN 11
                       WHEN credittype = 'PHYSED' THEN 12
                       WHEN credittype = 'ART' THEN 13
                       WHEN credittype = 'STUDY' THEN 21
                       WHEN credittype = 'COCUR' THEN 22
                       WHEN credittype = 'ELEC' THEN 22
                       WHEN credittype = 'LOG' THEN 22
                      END
                     ,course_number) AS class_rn      
  FROM
      (
       SELECT DISTINCT
              student_number      
             ,academic_year            
             ,course_number      
             ,credittype      
       FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
       WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND credittype NOT IN ('LOG')
         AND course_number NOT IN ('')
      ) sub
 )

,grades_unpivot AS (
  SELECT student_number
        ,academic_year
        ,term      
        ,course_name
        ,teacher_name
        ,credit_hours
        ,class_rn
        ,CONCAT(rt,'_',field) AS pivot_field
        ,value
  FROM
      (
       SELECT fg.student_number      
             ,fg.academic_year      
             ,fg.term       
      
             ,fg.course_name
             ,fg.teacher_name
             ,fg.credit_hours
             ,fg.rt            
             ,o.class_rn     

             ,CONVERT(VARCHAR(MAX),fg.term_grade_letter) AS term_grade_letter
             ,CONVERT(VARCHAR(MAX),fg.term_grade_percent) AS term_grade_percent
             ,CONVERT(VARCHAR(MAX),fg.term_grade_letter_adjusted) AS term_grade_letter_adjusted
             ,CONVERT(VARCHAR(MAX),fg.term_grade_percent_adjusted) AS term_grade_percent_adjusted
             ,CONVERT(VARCHAR(MAX),fg.y1_grade_letter) AS y1_grade_letter
             ,CONVERT(VARCHAR(MAX),fg.y1_grade_percent) AS y1_grade_percent
       FROM KIPP_NJ..GRADES$final_grades_long#static fg WITH(NOLOCK)
       JOIN course_order o
         ON fg.student_number = o.student_number
        AND fg.academic_year = o.academic_year
        AND fg.course_number = o.course_number
       WHERE fg.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND fg.credittype NOT IN ('LOG')
         AND fg.course_number NOT IN ('')         
      ) sub
  UNPIVOT(
    value
    FOR field IN (term_grade_letter
                 ,term_grade_percent
                 ,term_grade_letter_adjusted
                 ,term_grade_percent_adjusted                  
                 ,y1_grade_letter
                 ,y1_grade_percent)
   ) u
 )

,grade_repivot AS (
  SELECT student_number
        ,academic_year
        ,term
        ,class_rn      
        ,CONVERT(VARCHAR(MAX),course_name) AS course_name
        ,CONVERT(VARCHAR(MAX),teacher_name) AS teacher_name
        ,CONVERT(VARCHAR(MAX),credit_hours) AS credit_hours
        ,MAX(RT1_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_letter
        ,MAX(RT1_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_letter_adjusted
        ,MAX(RT1_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_percent
        ,MAX(RT1_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_percent_adjusted
        ,MAX(RT1_y1_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_y1_grade_letter
        ,MAX(RT1_y1_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_y1_grade_percent
      
        ,MAX(RT2_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_letter
        ,MAX(RT2_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_letter_adjusted
        ,MAX(RT2_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_percent
        ,MAX(RT2_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_percent_adjusted
        ,MAX(RT2_y1_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_y1_grade_letter
        ,MAX(RT2_y1_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_y1_grade_percent
      
        ,MAX(RT3_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_letter
        ,MAX(RT3_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_letter_adjusted
        ,MAX(RT3_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_percent
        ,MAX(RT3_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_percent_adjusted
        ,MAX(RT3_y1_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_y1_grade_letter
        ,MAX(RT3_y1_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_y1_grade_percent
      
        ,MAX(RT4_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_letter
        ,MAX(RT4_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_letter_adjusted
        ,MAX(RT4_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_percent
        ,MAX(RT4_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_percent_adjusted
        ,MAX(RT4_y1_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_y1_grade_letter
        ,MAX(RT4_y1_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_y1_grade_percent
  FROM grades_unpivot
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([RT1_term_grade_letter]
                       ,[RT1_term_grade_letter_adjusted]
                       ,[RT1_term_grade_percent]
                       ,[RT1_term_grade_percent_adjusted]
                       ,[RT1_y1_grade_letter]
                       ,[RT1_y1_grade_percent]
                       ,[RT2_term_grade_letter]
                       ,[RT2_term_grade_letter_adjusted]
                       ,[RT2_term_grade_percent]
                       ,[RT2_term_grade_percent_adjusted]
                       ,[RT2_y1_grade_letter]
                       ,[RT2_y1_grade_percent]
                       ,[RT3_term_grade_letter]
                       ,[RT3_term_grade_letter_adjusted]
                       ,[RT3_term_grade_percent]
                       ,[RT3_term_grade_percent_adjusted]
                       ,[RT3_y1_grade_letter]
                       ,[RT3_y1_grade_percent]
                       ,[RT4_term_grade_letter]
                       ,[RT4_term_grade_letter_adjusted]
                       ,[RT4_term_grade_percent]
                       ,[RT4_term_grade_percent_adjusted]
                       ,[RT4_y1_grade_letter]
                       ,[RT4_y1_grade_percent])
   ) p
 )

,course_unpivot AS (
  SELECT student_number
        ,academic_year
        ,term      
        ,CONCAT('rc', RIGHT(CONCAT('0',class_rn),2), '_', field) AS pivot_field
        ,value
  FROM grade_repivot
  UNPIVOT(
    value
    FOR field IN (course_name
                 ,teacher_name
                 ,credit_hours
                 ,RT1_term_grade_letter
                 ,RT1_term_grade_letter_adjusted
                 ,RT1_term_grade_percent
                 ,RT1_term_grade_percent_adjusted
                 ,RT1_y1_grade_letter
                 ,RT1_y1_grade_percent
                 ,RT2_term_grade_letter
                 ,RT2_term_grade_letter_adjusted
                 ,RT2_term_grade_percent
                 ,RT2_term_grade_percent_adjusted
                 ,RT2_y1_grade_letter
                 ,RT2_y1_grade_percent
                 ,RT3_term_grade_letter
                 ,RT3_term_grade_letter_adjusted
                 ,RT3_term_grade_percent
                 ,RT3_term_grade_percent_adjusted
                 ,RT3_y1_grade_letter
                 ,RT3_y1_grade_percent
                 ,RT4_term_grade_letter
                 ,RT4_term_grade_letter_adjusted
                 ,RT4_term_grade_percent
                 ,RT4_term_grade_percent_adjusted
                 ,RT4_y1_grade_letter
                 ,RT4_y1_grade_percent)
   ) u
 )

SELECT *
FROM course_unpivot
PIVOT(
  MAX(value)
  FOR pivot_field IN ([rc01_course_name]
                     ,[rc02_course_name]
                     ,[rc03_course_name]
                     ,[rc04_course_name]
                     ,[rc05_course_name]
                     ,[rc06_course_name]
                     ,[rc07_course_name]
                     ,[rc08_course_name]
                     ,[rc09_course_name]
                     ,[rc10_course_name]
                     ,[rc11_course_name]
                     ,[rc12_course_name]
                     ,[rc01_teacher_name]
                     ,[rc02_teacher_name]
                     ,[rc03_teacher_name]
                     ,[rc04_teacher_name]
                     ,[rc05_teacher_name]
                     ,[rc06_teacher_name]
                     ,[rc07_teacher_name]
                     ,[rc08_teacher_name]
                     ,[rc09_teacher_name]
                     ,[rc10_teacher_name]
                     ,[rc11_teacher_name]
                     ,[rc12_teacher_name]
                     ,[rc01_credit_hours]
                     ,[rc02_credit_hours]
                     ,[rc03_credit_hours]
                     ,[rc04_credit_hours]
                     ,[rc05_credit_hours]
                     ,[rc06_credit_hours]
                     ,[rc07_credit_hours]
                     ,[rc08_credit_hours]
                     ,[rc09_credit_hours]
                     ,[rc10_credit_hours]
                     ,[rc11_credit_hours]
                     ,[rc12_credit_hours]
                     ,[rc01_RT1_term_grade_letter]
                     ,[rc01_RT1_term_grade_letter_adjusted]
                     ,[rc01_RT1_term_grade_percent]
                     ,[rc01_RT1_term_grade_percent_adjusted]
                     ,[rc01_RT1_y1_grade_letter]
                     ,[rc01_RT1_y1_grade_percent]
                     ,[rc01_RT2_term_grade_letter]
                     ,[rc01_RT2_term_grade_letter_adjusted]
                     ,[rc01_RT2_term_grade_percent]
                     ,[rc01_RT2_term_grade_percent_adjusted]
                     ,[rc01_RT2_y1_grade_letter]
                     ,[rc01_RT2_y1_grade_percent]
                     ,[rc01_RT3_term_grade_letter]
                     ,[rc01_RT3_term_grade_letter_adjusted]
                     ,[rc01_RT3_term_grade_percent]
                     ,[rc01_RT3_term_grade_percent_adjusted]
                     ,[rc01_RT3_y1_grade_letter]
                     ,[rc01_RT3_y1_grade_percent]
                     ,[rc01_RT4_term_grade_letter]
                     ,[rc01_RT4_term_grade_letter_adjusted]
                     ,[rc01_RT4_term_grade_percent]
                     ,[rc01_RT4_term_grade_percent_adjusted]
                     ,[rc01_RT4_y1_grade_letter]
                     ,[rc01_RT4_y1_grade_percent]
                     ,[rc02_RT1_term_grade_letter]
                     ,[rc02_RT1_term_grade_letter_adjusted]
                     ,[rc02_RT1_term_grade_percent]
                     ,[rc02_RT1_term_grade_percent_adjusted]
                     ,[rc02_RT1_y1_grade_letter]
                     ,[rc02_RT1_y1_grade_percent]
                     ,[rc02_RT2_term_grade_letter]
                     ,[rc02_RT2_term_grade_letter_adjusted]
                     ,[rc02_RT2_term_grade_percent]
                     ,[rc02_RT2_term_grade_percent_adjusted]
                     ,[rc02_RT2_y1_grade_letter]
                     ,[rc02_RT2_y1_grade_percent]
                     ,[rc02_RT3_term_grade_letter]
                     ,[rc02_RT3_term_grade_letter_adjusted]
                     ,[rc02_RT3_term_grade_percent]
                     ,[rc02_RT3_term_grade_percent_adjusted]
                     ,[rc02_RT3_y1_grade_letter]
                     ,[rc02_RT3_y1_grade_percent]
                     ,[rc02_RT4_term_grade_letter]
                     ,[rc02_RT4_term_grade_letter_adjusted]
                     ,[rc02_RT4_term_grade_percent]
                     ,[rc02_RT4_term_grade_percent_adjusted]
                     ,[rc02_RT4_y1_grade_letter]
                     ,[rc02_RT4_y1_grade_percent]
                     ,[rc03_RT1_term_grade_letter]
                     ,[rc03_RT1_term_grade_letter_adjusted]
                     ,[rc03_RT1_term_grade_percent]
                     ,[rc03_RT1_term_grade_percent_adjusted]
                     ,[rc03_RT1_y1_grade_letter]
                     ,[rc03_RT1_y1_grade_percent]
                     ,[rc03_RT2_term_grade_letter]
                     ,[rc03_RT2_term_grade_letter_adjusted]
                     ,[rc03_RT2_term_grade_percent]
                     ,[rc03_RT2_term_grade_percent_adjusted]
                     ,[rc03_RT2_y1_grade_letter]
                     ,[rc03_RT2_y1_grade_percent]
                     ,[rc03_RT3_term_grade_letter]
                     ,[rc03_RT3_term_grade_letter_adjusted]
                     ,[rc03_RT3_term_grade_percent]
                     ,[rc03_RT3_term_grade_percent_adjusted]
                     ,[rc03_RT3_y1_grade_letter]
                     ,[rc03_RT3_y1_grade_percent]
                     ,[rc03_RT4_term_grade_letter]
                     ,[rc03_RT4_term_grade_letter_adjusted]
                     ,[rc03_RT4_term_grade_percent]
                     ,[rc03_RT4_term_grade_percent_adjusted]
                     ,[rc03_RT4_y1_grade_letter]
                     ,[rc03_RT4_y1_grade_percent]
                     ,[rc04_RT1_term_grade_letter]
                     ,[rc04_RT1_term_grade_letter_adjusted]
                     ,[rc04_RT1_term_grade_percent]
                     ,[rc04_RT1_term_grade_percent_adjusted]
                     ,[rc04_RT1_y1_grade_letter]
                     ,[rc04_RT1_y1_grade_percent]
                     ,[rc04_RT2_term_grade_letter]
                     ,[rc04_RT2_term_grade_letter_adjusted]
                     ,[rc04_RT2_term_grade_percent]
                     ,[rc04_RT2_term_grade_percent_adjusted]
                     ,[rc04_RT2_y1_grade_letter]
                     ,[rc04_RT2_y1_grade_percent]
                     ,[rc04_RT3_term_grade_letter]
                     ,[rc04_RT3_term_grade_letter_adjusted]
                     ,[rc04_RT3_term_grade_percent]
                     ,[rc04_RT3_term_grade_percent_adjusted]
                     ,[rc04_RT3_y1_grade_letter]
                     ,[rc04_RT3_y1_grade_percent]
                     ,[rc04_RT4_term_grade_letter]
                     ,[rc04_RT4_term_grade_letter_adjusted]
                     ,[rc04_RT4_term_grade_percent]
                     ,[rc04_RT4_term_grade_percent_adjusted]
                     ,[rc04_RT4_y1_grade_letter]
                     ,[rc04_RT4_y1_grade_percent]
                     ,[rc05_RT1_term_grade_letter]
                     ,[rc05_RT1_term_grade_letter_adjusted]
                     ,[rc05_RT1_term_grade_percent]
                     ,[rc05_RT1_term_grade_percent_adjusted]
                     ,[rc05_RT1_y1_grade_letter]
                     ,[rc05_RT1_y1_grade_percent]
                     ,[rc05_RT2_term_grade_letter]
                     ,[rc05_RT2_term_grade_letter_adjusted]
                     ,[rc05_RT2_term_grade_percent]
                     ,[rc05_RT2_term_grade_percent_adjusted]
                     ,[rc05_RT2_y1_grade_letter]
                     ,[rc05_RT2_y1_grade_percent]
                     ,[rc05_RT3_term_grade_letter]
                     ,[rc05_RT3_term_grade_letter_adjusted]
                     ,[rc05_RT3_term_grade_percent]
                     ,[rc05_RT3_term_grade_percent_adjusted]
                     ,[rc05_RT3_y1_grade_letter]
                     ,[rc05_RT3_y1_grade_percent]
                     ,[rc05_RT4_term_grade_letter]
                     ,[rc05_RT4_term_grade_letter_adjusted]
                     ,[rc05_RT4_term_grade_percent]
                     ,[rc05_RT4_term_grade_percent_adjusted]
                     ,[rc05_RT4_y1_grade_letter]
                     ,[rc05_RT4_y1_grade_percent]
                     ,[rc06_RT1_term_grade_letter]
                     ,[rc06_RT1_term_grade_letter_adjusted]
                     ,[rc06_RT1_term_grade_percent]
                     ,[rc06_RT1_term_grade_percent_adjusted]
                     ,[rc06_RT1_y1_grade_letter]
                     ,[rc06_RT1_y1_grade_percent]
                     ,[rc06_RT2_term_grade_letter]
                     ,[rc06_RT2_term_grade_letter_adjusted]
                     ,[rc06_RT2_term_grade_percent]
                     ,[rc06_RT2_term_grade_percent_adjusted]
                     ,[rc06_RT2_y1_grade_letter]
                     ,[rc06_RT2_y1_grade_percent]
                     ,[rc06_RT3_term_grade_letter]
                     ,[rc06_RT3_term_grade_letter_adjusted]
                     ,[rc06_RT3_term_grade_percent]
                     ,[rc06_RT3_term_grade_percent_adjusted]
                     ,[rc06_RT3_y1_grade_letter]
                     ,[rc06_RT3_y1_grade_percent]
                     ,[rc06_RT4_term_grade_letter]
                     ,[rc06_RT4_term_grade_letter_adjusted]
                     ,[rc06_RT4_term_grade_percent]
                     ,[rc06_RT4_term_grade_percent_adjusted]
                     ,[rc06_RT4_y1_grade_letter]
                     ,[rc06_RT4_y1_grade_percent]
                     ,[rc07_RT1_term_grade_letter]
                     ,[rc07_RT1_term_grade_letter_adjusted]
                     ,[rc07_RT1_term_grade_percent]
                     ,[rc07_RT1_term_grade_percent_adjusted]
                     ,[rc07_RT1_y1_grade_letter]
                     ,[rc07_RT1_y1_grade_percent]
                     ,[rc07_RT2_term_grade_letter]
                     ,[rc07_RT2_term_grade_letter_adjusted]
                     ,[rc07_RT2_term_grade_percent]
                     ,[rc07_RT2_term_grade_percent_adjusted]
                     ,[rc07_RT2_y1_grade_letter]
                     ,[rc07_RT2_y1_grade_percent]
                     ,[rc07_RT3_term_grade_letter]
                     ,[rc07_RT3_term_grade_letter_adjusted]
                     ,[rc07_RT3_term_grade_percent]
                     ,[rc07_RT3_term_grade_percent_adjusted]
                     ,[rc07_RT3_y1_grade_letter]
                     ,[rc07_RT3_y1_grade_percent]
                     ,[rc07_RT4_term_grade_letter]
                     ,[rc07_RT4_term_grade_letter_adjusted]
                     ,[rc07_RT4_term_grade_percent]
                     ,[rc07_RT4_term_grade_percent_adjusted]
                     ,[rc07_RT4_y1_grade_letter]
                     ,[rc07_RT4_y1_grade_percent]
                     ,[rc08_RT1_term_grade_letter]
                     ,[rc08_RT1_term_grade_letter_adjusted]
                     ,[rc08_RT1_term_grade_percent]
                     ,[rc08_RT1_term_grade_percent_adjusted]
                     ,[rc08_RT1_y1_grade_letter]
                     ,[rc08_RT1_y1_grade_percent]
                     ,[rc08_RT2_term_grade_letter]
                     ,[rc08_RT2_term_grade_letter_adjusted]
                     ,[rc08_RT2_term_grade_percent]
                     ,[rc08_RT2_term_grade_percent_adjusted]
                     ,[rc08_RT2_y1_grade_letter]
                     ,[rc08_RT2_y1_grade_percent]
                     ,[rc08_RT3_term_grade_letter]
                     ,[rc08_RT3_term_grade_letter_adjusted]
                     ,[rc08_RT3_term_grade_percent]
                     ,[rc08_RT3_term_grade_percent_adjusted]
                     ,[rc08_RT3_y1_grade_letter]
                     ,[rc08_RT3_y1_grade_percent]
                     ,[rc08_RT4_term_grade_letter]
                     ,[rc08_RT4_term_grade_letter_adjusted]
                     ,[rc08_RT4_term_grade_percent]
                     ,[rc08_RT4_term_grade_percent_adjusted]
                     ,[rc08_RT4_y1_grade_letter]
                     ,[rc08_RT4_y1_grade_percent]
                     ,[rc09_RT1_term_grade_letter]
                     ,[rc09_RT1_term_grade_letter_adjusted]
                     ,[rc09_RT1_term_grade_percent]
                     ,[rc09_RT1_term_grade_percent_adjusted]
                     ,[rc09_RT1_y1_grade_letter]
                     ,[rc09_RT1_y1_grade_percent]
                     ,[rc09_RT2_term_grade_letter]
                     ,[rc09_RT2_term_grade_letter_adjusted]
                     ,[rc09_RT2_term_grade_percent]
                     ,[rc09_RT2_term_grade_percent_adjusted]
                     ,[rc09_RT2_y1_grade_letter]
                     ,[rc09_RT2_y1_grade_percent]
                     ,[rc09_RT3_term_grade_letter]
                     ,[rc09_RT3_term_grade_letter_adjusted]
                     ,[rc09_RT3_term_grade_percent]
                     ,[rc09_RT3_term_grade_percent_adjusted]
                     ,[rc09_RT3_y1_grade_letter]
                     ,[rc09_RT3_y1_grade_percent]
                     ,[rc09_RT4_term_grade_letter]
                     ,[rc09_RT4_term_grade_letter_adjusted]
                     ,[rc09_RT4_term_grade_percent]
                     ,[rc09_RT4_term_grade_percent_adjusted]
                     ,[rc09_RT4_y1_grade_letter]
                     ,[rc09_RT4_y1_grade_percent]
                     ,[rc10_RT1_term_grade_letter]
                     ,[rc10_RT1_term_grade_letter_adjusted]
                     ,[rc10_RT1_term_grade_percent]
                     ,[rc10_RT1_term_grade_percent_adjusted]
                     ,[rc10_RT1_y1_grade_letter]
                     ,[rc10_RT1_y1_grade_percent]
                     ,[rc10_RT2_term_grade_letter]
                     ,[rc10_RT2_term_grade_letter_adjusted]
                     ,[rc10_RT2_term_grade_percent]
                     ,[rc10_RT2_term_grade_percent_adjusted]
                     ,[rc10_RT2_y1_grade_letter]
                     ,[rc10_RT2_y1_grade_percent]
                     ,[rc10_RT3_term_grade_letter]
                     ,[rc10_RT3_term_grade_letter_adjusted]
                     ,[rc10_RT3_term_grade_percent]
                     ,[rc10_RT3_term_grade_percent_adjusted]
                     ,[rc10_RT3_y1_grade_letter]
                     ,[rc10_RT3_y1_grade_percent]
                     ,[rc10_RT4_term_grade_letter]
                     ,[rc10_RT4_term_grade_letter_adjusted]
                     ,[rc10_RT4_term_grade_percent]
                     ,[rc10_RT4_term_grade_percent_adjusted]
                     ,[rc10_RT4_y1_grade_letter]
                     ,[rc10_RT4_y1_grade_percent]
                     ,[rc11_RT1_term_grade_letter]
                     ,[rc11_RT1_term_grade_letter_adjusted]
                     ,[rc11_RT1_term_grade_percent]
                     ,[rc11_RT1_term_grade_percent_adjusted]
                     ,[rc11_RT1_y1_grade_letter]
                     ,[rc11_RT1_y1_grade_percent]
                     ,[rc11_RT2_term_grade_letter]
                     ,[rc11_RT2_term_grade_letter_adjusted]
                     ,[rc11_RT2_term_grade_percent]
                     ,[rc11_RT2_term_grade_percent_adjusted]
                     ,[rc11_RT2_y1_grade_letter]
                     ,[rc11_RT2_y1_grade_percent]
                     ,[rc11_RT3_term_grade_letter]
                     ,[rc11_RT3_term_grade_letter_adjusted]
                     ,[rc11_RT3_term_grade_percent]
                     ,[rc11_RT3_term_grade_percent_adjusted]
                     ,[rc11_RT3_y1_grade_letter]
                     ,[rc11_RT3_y1_grade_percent]
                     ,[rc11_RT4_term_grade_letter]
                     ,[rc11_RT4_term_grade_letter_adjusted]
                     ,[rc11_RT4_term_grade_percent]
                     ,[rc11_RT4_term_grade_percent_adjusted]
                     ,[rc11_RT4_y1_grade_letter]
                     ,[rc11_RT4_y1_grade_percent]
                     ,[rc12_RT1_term_grade_letter]
                     ,[rc12_RT1_term_grade_letter_adjusted]
                     ,[rc12_RT1_term_grade_percent]
                     ,[rc12_RT1_term_grade_percent_adjusted]
                     ,[rc12_RT1_y1_grade_letter]
                     ,[rc12_RT1_y1_grade_percent]
                     ,[rc12_RT2_term_grade_letter]
                     ,[rc12_RT2_term_grade_letter_adjusted]
                     ,[rc12_RT2_term_grade_percent]
                     ,[rc12_RT2_term_grade_percent_adjusted]
                     ,[rc12_RT2_y1_grade_letter]
                     ,[rc12_RT2_y1_grade_percent]
                     ,[rc12_RT3_term_grade_letter]
                     ,[rc12_RT3_term_grade_letter_adjusted]
                     ,[rc12_RT3_term_grade_percent]
                     ,[rc12_RT3_term_grade_percent_adjusted]
                     ,[rc12_RT3_y1_grade_letter]
                     ,[rc12_RT3_y1_grade_percent]
                     ,[rc12_RT4_term_grade_letter]
                     ,[rc12_RT4_term_grade_letter_adjusted]
                     ,[rc12_RT4_term_grade_percent]
                     ,[rc12_RT4_term_grade_percent_adjusted]
                     ,[rc12_RT4_y1_grade_letter]
                     ,[rc12_RT4_y1_grade_percent])
 ) p