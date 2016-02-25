USE KIPP_NJ
GO

ALTER VIEW GRADES$final_grades_wide AS

WITH course_order AS (
  SELECT student_number
        ,academic_year
        ,course_number
        ,credittype        
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
        ,is_curterm        
        ,credittype
        ,course_number
        ,course_name
        ,sectionid
        ,teacher_name
        ,credit_hours
        ,class_rn
        ,y1_grade_letter
        ,y1_grade_percent
        ,e1_grade_percent
        ,e2_grade_percent
        ,CONCAT(rt,'_',field) AS pivot_field
        ,CONVERT(VARCHAR(64),value) AS value
  FROM
      (
       SELECT fg.student_number      
             ,fg.academic_year      
             ,fg.term       
             ,fg.is_curterm
      
             ,fg.credittype
             ,fg.sectionid
             ,fg.course_number
             ,fg.course_name
             ,fg.teacher_name
             ,fg.credit_hours
             ,fg.rt            
             ,o.class_rn     

             ,CONVERT(VARCHAR(64),fg.e1_adjusted) AS e1_grade_percent /* using only F* adjusted, when applicable */
             ,CONVERT(VARCHAR(64),fg.e2_adjusted) AS e2_grade_percent /* using only F* adjusted, when applicable */
             --,CONVERT(VARCHAR(64),fg.y1_grade_percent) AS y1_grade_percent
             ,CONVERT(VARCHAR(64),fg.y1_grade_percent_adjusted) AS y1_grade_percent /* using only F* adjusted, when applicable */             
             ,CONVERT(VARCHAR(64),fg.y1_grade_letter) AS y1_grade_letter

             ,CONVERT(VARCHAR(64),fg.term_grade_letter) AS term_grade_letter
             ,CONVERT(VARCHAR(64),fg.term_grade_percent) AS term_grade_percent
             ,CONVERT(VARCHAR(64),fg.term_grade_letter_adjusted) AS term_grade_letter_adjusted
             ,CONVERT(VARCHAR(64),fg.term_grade_percent_adjusted) AS term_grade_percent_adjusted                          
       FROM KIPP_NJ..GRADES$final_grades_long#static fg WITH(NOLOCK)
       JOIN course_order o
         ON fg.student_number = o.student_number
        AND fg.academic_year = o.academic_year
        AND fg.course_number = o.course_number
       WHERE fg.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND fg.credittype NOT IN ('LOG')
         AND fg.course_number NOT IN ('')         

       UNION ALL

       SELECT fg.student_number      
             ,fg.academic_year      
             ,fg.term       
             ,fg.is_curterm
      
             ,fg.credittype
             ,fg.sectionid
             ,fg.course_number
             ,fg.course_name
             ,fg.teacher_name
             ,fg.credit_hours
             ,'CUR' AS rt
             ,o.class_rn     

             ,CONVERT(VARCHAR(64),fg.e1_adjusted) AS e1_grade_percent /* using only F* adjusted, when applicable */
             ,CONVERT(VARCHAR(64),fg.e2_adjusted) AS e2_grade_percent /* using only F* adjusted, when applicable */
             --,CONVERT(VARCHAR(64),fg.y1_grade_percent) AS y1_grade_percent
             ,CONVERT(VARCHAR(64),fg.y1_grade_percent_adjusted) AS y1_grade_percent /* using only F* adjusted, when applicable */             
             ,CONVERT(VARCHAR(64),fg.y1_grade_letter) AS y1_grade_letter

             ,CONVERT(VARCHAR(64),fg.term_grade_letter) AS term_grade_letter
             ,CONVERT(VARCHAR(64),fg.term_grade_percent) AS term_grade_percent
             ,CONVERT(VARCHAR(64),fg.term_grade_letter_adjusted) AS term_grade_letter_adjusted
             ,CONVERT(VARCHAR(64),fg.term_grade_percent_adjusted) AS term_grade_percent_adjusted                          
       FROM KIPP_NJ..GRADES$final_grades_long#static fg WITH(NOLOCK)
       JOIN course_order o
         ON fg.student_number = o.student_number
        AND fg.academic_year = o.academic_year
        AND fg.course_number = o.course_number
       WHERE fg.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND fg.credittype NOT IN ('LOG')
         AND fg.course_number NOT IN ('')         
         --AND fg.is_curterm = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (term_grade_letter
                 ,term_grade_percent
                 ,term_grade_letter_adjusted
                 ,term_grade_percent_adjusted)                 
   ) u
 )

SELECT student_number
      ,academic_year
      ,term
      ,is_curterm
      ,class_rn      
      ,credittype
      ,course_number      
      ,sectionid
      ,CONVERT(VARCHAR(64),course_name) AS course_name
      ,CONVERT(VARCHAR(64),teacher_name) AS teacher_name
      ,CONVERT(VARCHAR(64),credit_hours) AS credit_hours
      ,y1_grade_letter
      ,y1_grade_percent
      ,MAX(e1_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS e1_grade_percent
      ,MAX(e2_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS e2_grade_percent
      ,MAX(RT1_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_letter
      ,MAX(RT1_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_letter_adjusted
      ,MAX(RT1_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_percent
      ,MAX(RT1_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT1_term_grade_percent_adjusted      
      
      ,MAX(RT2_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_letter
      ,MAX(RT2_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_letter_adjusted
      ,MAX(RT2_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_percent
      ,MAX(RT2_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT2_term_grade_percent_adjusted      
      
      ,MAX(RT3_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_letter
      ,MAX(RT3_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_letter_adjusted
      ,MAX(RT3_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_percent
      ,MAX(RT3_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT3_term_grade_percent_adjusted      
      
      ,MAX(RT4_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_letter
      ,MAX(RT4_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_letter_adjusted
      ,MAX(RT4_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_percent
      ,MAX(RT4_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term ASC) AS RT4_term_grade_percent_adjusted

      ,[CUR_term_grade_letter]
      ,[CUR_term_grade_letter_adjusted]
      ,[CUR_term_grade_percent]
      ,[CUR_term_grade_percent_adjusted]

      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, term, credittype
           ORDER BY course_number ASC) AS rn_credittype
FROM grades_unpivot
PIVOT(
  MAX(value)
  FOR pivot_field IN ([RT1_term_grade_letter]
                     ,[RT1_term_grade_letter_adjusted]
                     ,[RT1_term_grade_percent]
                     ,[RT1_term_grade_percent_adjusted]                     
                     ,[RT2_term_grade_letter]
                     ,[RT2_term_grade_letter_adjusted]
                     ,[RT2_term_grade_percent]
                     ,[RT2_term_grade_percent_adjusted]                     
                     ,[RT3_term_grade_letter]
                     ,[RT3_term_grade_letter_adjusted]
                     ,[RT3_term_grade_percent]
                     ,[RT3_term_grade_percent_adjusted]                     
                     ,[RT4_term_grade_letter]
                     ,[RT4_term_grade_letter_adjusted]
                     ,[RT4_term_grade_percent]
                     ,[RT4_term_grade_percent_adjusted]
                     ,[CUR_term_grade_letter]
                     ,[CUR_term_grade_letter_adjusted]
                     ,[CUR_term_grade_percent]
                     ,[CUR_term_grade_percent_adjusted])
 ) p