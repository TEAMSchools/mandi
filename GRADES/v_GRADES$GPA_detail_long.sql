USE KIPP_NJ
GO

ALTER VIEW GRADES$GPA_detail_long AS

SELECT student_number
      ,academic_year      
      ,term            
      ,SUM(credit_hours) AS total_credit_hours

      ,ROUND(AVG(term_grade_percent),0) AS term_grade_avg      
      ,SUM(term_gpa_points) AS GPA_points_total_term
      ,SUM((credit_hours * term_gpa_points)) AS weighted_GPA_points_term      
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM((credit_hours * term_gpa_points)) / SUM(credit_hours)),2)) AS GPA_term            
      
      ,ROUND(AVG(y1_grade_percent_adjusted),0) AS y1_grade_avg      
      ,SUM(y1_gpa_points) AS GPA_points_total_y1
      ,SUM((credit_hours * y1_gpa_points)) AS weighted_GPA_points_Y1
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),SUM((credit_hours * y1_gpa_points)) / SUM(credit_hours)),2)) AS GPA_Y1
FROM KIPP_NJ..GRADES$final_grades_long#static
WHERE excludefromgpa = 0
GROUP BY student_number
        ,academic_year      
        ,term