USE KIPP_NJ
GO

ALTER VIEW TABLEAU$writing_summary_assessments AS

WITH enrollments AS (
  SELECT enr.student_number
        ,enr.academic_year
        ,enr.COURSE_NUMBER
        ,enr.course_name
        ,enr.period AS course_period
        ,enr.teacher_name      
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year >= 2015
    AND enr.CREDITTYPE = 'ENG'  
    AND enr.drop_flags = 0  
    AND enr.SCHOOLID = 73253
  
  UNION ALL

  SELECT enr.student_number
        ,enr.academic_year
        ,'ENG' AS course_number
        ,enr.course_name
        ,enr.period AS course_period
        ,enr.teacher_name      
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year <= 2014
    AND enr.CREDITTYPE = 'ENG'  
    AND enr.drop_flags = 0
    AND enr.rn_subject = 1
    AND enr.SCHOOLID = 73253
 )  

SELECT co.SCHOOLID
      ,co.GRADE_LEVEL      
      ,co.student_number
      ,co.lastfirst
      ,co.team
      ,co.SPEDLEP      

      ,w.title
      ,w.academic_year
      ,w.term
      ,w.unit_number
      ,w.course_number            
      ,w.strand
      ,w.prompt_number
      ,w.field_value AS score     
      
      ,enr.course_name
      ,enr.course_period
      ,enr.teacher_name
FROM KIPP_NJ..ILLUMINATE$writing_scores_long#static w WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON w.student_number = co.student_number
 AND w.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year 
 AND w.course_number = enr.course_number 