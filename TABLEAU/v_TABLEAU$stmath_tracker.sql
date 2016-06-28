USE KIPP_NJ
GO

ALTER VIEW TABLEAU$stmath_tracker AS 

WITH enrollments AS (
  SELECT enr.student_number
        ,enr.academic_year
        ,enr.COURSE_NUMBER
        ,enr.COURSE_NAME
        ,enr.teacher_name        
        ,enr.SECTION_NUMBER
        ,ROW_NUMBER() OVER(
           PARTITION BY enr.student_number, enr.academic_year, enr.credittype
             ORDER BY enr.dateleft DESC) AS rn
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.course_enr_status = 0
    AND enr.drop_flags = 0
    AND ((enr.grade_level >= 5) OR (enr.SCHOOLID = 73252 AND enr.grade_level = 4))
    AND enr.CREDITTYPE = 'MATH'

  UNION ALL

  SELECT enr.student_number
        ,enr.academic_year
        ,enr.COURSE_NUMBER
        ,enr.COURSE_NAME
        ,enr.teacher_name        
        ,enr.SECTION_NUMBER
        ,1 AS rn
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.course_enr_status = 0
    AND enr.drop_flags = 0
    AND enr.grade_level <= 4
    AND enr.SCHOOLID != 73252
    AND enr.COURSE_NUMBER = 'HR'
 )

SELECT stm.school_student_id AS student_number                        
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.spedlep
      
      ,stm.start_year AS academic_year
      ,stm.week_ending_date           
      ,stm.GCD      
      ,stm.K_5_Progress
      ,stm.K_5_Mastery
      ,LAG(stm.K_5_progress, 1) OVER(PARTITION BY stm.school_student_id, stm.start_year, stm.GCD ORDER BY stm.week_ending_date) AS prev_week_progress
      --,MAX(stm.K_5_Progress) OVER(PARTITION BY stm.school_student_id, stm.start_year, stm.GCD) AS gcd_progress_overall
      
      ,stm.objective_name      
      ,stm.cur_hurdle_num_tries      
      
      ,stm.fluency_progress
      ,stm.fluency_mastery
      ,stm.fluency_path
      ,stm.fluency_time_spent      
      
      ,stm.num_lab_logins
      ,stm.num_homework_logins
      ,ISNULL(stm.num_lab_logins,0) + ISNULL(stm.num_homework_logins,0) AS N_logins_total
      ,stm.minutes_logged_last_week      
      ,stm.first_login_date  
      ,stm.last_login_date    
      
      ,stm.TCD AS stmath_teacher_id
      ,stm.teacher_name AS stmath_teacher_name
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.teacher_name      
      ,enr.SECTION_NUMBER

      ,ROW_NUMBER() OVER(
         PARTITION BY stm.school_student_id, stm.start_year
           ORDER BY stm.week_ending_date DESC) AS rn
      ,ROW_NUMBER() OVER(
         PARTITION BY stm.school_student_id, stm.start_year, stm.GCD
           ORDER BY stm.week_ending_date DESC) AS rn_gcd
FROM KIPP_NJ..STMATH$progress_completion_long stm WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON stm.school_student_id = co.student_number
 AND stm.start_year = co.year
 AND co.rn = 1
JOIN enrollments enr
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.rn = 1
WHERE stm.school_student_id IS NOT NULL 