USE KIPP_NJ
GO

ALTER VIEW GRADES$GPA_detail_long AS

SELECT student_number
      ,schoolid
      ,grade_level
      ,academic_year
      ,term
      ,semester
      ,rt
      ,is_curterm      
      ,total_credit_hours
      
      ,term_grade_avg
      ,GPA_points_total_term
      ,weighted_GPA_points_term
      ,GPA_term
      
      ,y1_grade_avg
      ,GPA_points_total_y1
      ,weighted_GPA_points_Y1
      ,GPA_Y1
      
      ,n_failing_y1

      ,AVG(term_grade_avg) OVER(PARTITION BY student_number, academic_year, semester) AS semester_grade_avg
      ,SUM(GPA_points_total_term) OVER(PARTITION BY student_number, academic_year, semester) AS GPA_points_total_semester
      ,SUM(weighted_GPA_points_term) OVER(PARTITION BY student_number, academic_year, semester) AS weighted_GPA_points_semester
      ,SUM(total_credit_hours) OVER(PARTITION BY student_number, academic_year, semester) AS total_credit_hours_semester
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM(weighted_GPA_points_term) OVER(PARTITION BY student_number, academic_year, semester)
         / SUM(term_credit_hours) OVER(PARTITION BY student_number, academic_year, semester)),2)) AS GPA_semester
FROM
    (
     SELECT student_number
           ,schoolid
           ,grade_level
      
           ,academic_year      
           ,term            
           ,CASE 
             WHEN term IN ('Q1','Q2') THEN 'S1'
             WHEN term IN ('Q3','Q4') THEN 'S2'
            END AS semester
           ,rt 
           ,is_curterm
      
           ,SUM(CASE WHEN y1_grade_percent_adjusted IS NULL THEN NULL ELSE credit_hours END) AS total_credit_hours

           ,ROUND(AVG(term_grade_percent),0) AS term_grade_avg      
           ,SUM(term_gpa_points) AS GPA_points_total_term
           ,SUM((credit_hours * term_gpa_points)) AS weighted_GPA_points_term      
           ,SUM(CASE WHEN term_grade_percent IS NULL THEN NULL ELSE credit_hours END) AS term_credit_hours
           /* when no term pct, then exclude credit hours */
           ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM((credit_hours * term_gpa_points)) / SUM(CASE WHEN term_grade_percent IS NULL THEN NULL ELSE credit_hours END)),2)) AS GPA_term                       
      
           ,ROUND(AVG(y1_grade_percent_adjusted),0) AS y1_grade_avg      
           ,SUM(y1_gpa_points) AS GPA_points_total_y1
           ,SUM((credit_hours * y1_gpa_points)) AS weighted_GPA_points_Y1
           /* when no y1 pct, then exclude credit hours */
           ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM((credit_hours * y1_gpa_points)) / SUM(CASE WHEN y1_grade_percent_adjusted IS NULL THEN NULL ELSE credit_hours END)),2)) AS GPA_Y1
           
           ,SUM(CASE WHEN y1_grade_letter LIKE 'F%' THEN 1 ELSE 0 END) AS n_failing_y1
     FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
     WHERE excludefromgpa = 0
     GROUP BY student_number
             ,academic_year      
             ,term
             ,rt 
             ,is_curterm
             ,schoolid
             ,grade_level
     HAVING SUM(credit_hours) > 0
    ) sub