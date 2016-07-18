USE KIPP_NJ
GO

ALTER VIEW GRADES$final_grades_wide AS

WITH grades_unpivot AS (
  SELECT student_number
        ,academic_year
        ,term              
        ,rn_curterm                
        ,course_number
        ,sectionid
        ,teacher_name
        ,y1_grade_letter
        ,y1_grade_percent
        ,e1_grade_percent
        ,e2_grade_percent
        ,need_90
        ,need_80
        ,need_70
        ,need_65
        ,CONCAT(rt,'_',field) AS pivot_field
        ,CONVERT(VARCHAR(64),value) AS value
  FROM
      (
       SELECT fg.student_number      
             ,fg.academic_year      
             ,fg.term                    
             ,fg.course_number                                       
             ,fg.rt                                  
             ,fg.rn_curterm                          
             ,fg.sectionid                              
             ,fg.teacher_name

             ,CONVERT(VARCHAR(64),fg.e1_adjusted) AS e1_grade_percent /* using only F* adjusted, when applicable */
             ,CONVERT(VARCHAR(64),fg.e2_adjusted) AS e2_grade_percent /* using only F* adjusted, when applicable */             
             ,CONVERT(VARCHAR(64),fg.y1_grade_percent_adjusted) AS y1_grade_percent /* using only F* adjusted, when applicable */             
             ,CONVERT(VARCHAR(64),fg.y1_grade_letter) AS y1_grade_letter

             /* empty strings preserve term structure when there aren't any grades */
             ,CONVERT(VARCHAR(64),fg.term_grade_letter) AS term_grade_letter
             ,CONVERT(VARCHAR(64),fg.term_grade_percent) AS term_grade_percent
             ,CONVERT(VARCHAR(64),fg.term_grade_letter_adjusted) AS term_grade_letter_adjusted
             ,CONVERT(VARCHAR(64),fg.term_grade_percent_adjusted) AS term_grade_percent_adjusted                          

             ,CONVERT(VARCHAR(64),fg.need_90) AS need_90
             ,CONVERT(VARCHAR(64),fg.need_80) AS need_80
             ,CONVERT(VARCHAR(64),fg.need_70) AS need_70
             ,CONVERT(VARCHAR(64),fg.need_65) AS need_65
       FROM KIPP_NJ..GRADES$final_grades_long#static fg WITH(NOLOCK)                

       UNION ALL

       SELECT fg.student_number      
             ,fg.academic_year      
             ,fg.term                    
             ,fg.course_number                                       
             ,'CUR' AS rt                                  
             ,fg.rn_curterm                          
             ,fg.sectionid                              
             ,fg.teacher_name

             ,CONVERT(VARCHAR(64),fg.e1_adjusted) AS e1_grade_percent /* using only F* adjusted, when applicable */
             ,CONVERT(VARCHAR(64),fg.e2_adjusted) AS e2_grade_percent /* using only F* adjusted, when applicable */             
             ,CONVERT(VARCHAR(64),fg.y1_grade_percent_adjusted) AS y1_grade_percent /* using only F* adjusted, when applicable */             
             ,CONVERT(VARCHAR(64),fg.y1_grade_letter) AS y1_grade_letter

             /* empty strings preserve term structure when there aren't any grades */
             ,CONVERT(VARCHAR(64),fg.term_grade_letter) AS term_grade_letter
             ,CONVERT(VARCHAR(64),fg.term_grade_percent) AS term_grade_percent
             ,CONVERT(VARCHAR(64),fg.term_grade_letter_adjusted) AS term_grade_letter_adjusted
             ,CONVERT(VARCHAR(64),fg.term_grade_percent_adjusted) AS term_grade_percent_adjusted                          

             ,CONVERT(VARCHAR(64),fg.need_90) AS need_90
             ,CONVERT(VARCHAR(64),fg.need_80) AS need_80
             ,CONVERT(VARCHAR(64),fg.need_70) AS need_70
             ,CONVERT(VARCHAR(64),fg.need_65) AS need_65
       FROM KIPP_NJ..GRADES$final_grades_long#static fg WITH(NOLOCK)                
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
      ,rn_curterm
      ,class_rn
      ,credittype
      ,course_number
      ,sectionid
      ,course_name
      ,teacher_name
      ,credit_hours
      ,y1_grade_letter
      ,y1_grade_percent
      ,need_90
      ,need_80
      ,need_70
      ,need_65

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
FROM
    (
     SELECT o.student_number
           ,o.academic_year
           ,o.term
           ,o.is_curterm
           ,o.class_rn      
           ,o.credittype
           ,o.course_number      
           ,CONVERT(VARCHAR(64),o.course_name) AS course_name
           ,CONVERT(VARCHAR(64),o.credit_hours) AS credit_hours
           ,o.sectionid           
           ,CONVERT(VARCHAR(64),o.teacher_name) AS teacher_name                                 

           ,gr.rn_curterm           
           ,gr.e1_grade_percent
           ,gr.e2_grade_percent           
           ,gr.y1_grade_letter
           ,gr.y1_grade_percent      
           ,gr.need_90
           ,gr.need_80
           ,gr.need_70
           ,gr.need_65

           ,gr.pivot_field
           ,gr.value
     FROM KIPP_NJ..PS$course_order_scaffold#static o WITH(NOLOCK)
     LEFT OUTER JOIN grades_unpivot gr
       ON o.student_number = gr.student_number
      AND o.academic_year = gr.academic_year
      AND o.term = gr.term
      AND o.COURSE_NUMBER = gr.COURSE_NUMBER
     --WHERE o.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
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