USE KIPP_NJ
GO

ALTER VIEW TABLEAU$AR_dashboard AS

SELECT ar.student_number
      ,ar.grade_level
      ,ar.schoolid
      ,ar.academic_year            
      ,ar.time_period_name
      ,ar.words_goal
      ,ar.points_goal
      ,ar.start_date
      ,ar.end_date
      ,ar.words
      ,ar.points
      ,ar.mastery
      ,ar.mastery_fiction
      ,ar.mastery_nonfiction
      ,ar.pct_fiction
      ,ar.n_fiction
      ,ar.n_nonfic
      ,ar.avg_lexile
      ,ar.avg_rating
      ,ar.last_quiz
      ,ar.N_passed
      ,ar.N_total
      ,ar.last_book_date
      ,ar.last_book
      ,ar.ontrack_words
      ,ar.ontrack_points
      ,ar.stu_status_words
      ,ar.stu_status_points
      ,ar.stu_status_words_numeric
      ,ar.stu_status_points_numeric
      ,ar.words_needed
      ,ar.points_needed
      ,ar.rank_words_grade_in_school
      ,ar.rank_words_grade_in_network
      ,ar.rank_words_overall_in_school
      ,ar.rank_words_overall_in_network
      ,ar.rank_points_grade_in_school
      ,ar.rank_points_grade_in_network
      ,ar.rank_points_overall_in_school
      ,ar.rank_points_overall_in_network
      ,s.first_name
      ,s.last_name
      ,s.full_name AS student_name
      ,s.ADVISOR
      ,eng1.COURSE_NAME AS eng1_course
      ,eng1.SECTION_NUMBER AS eng1_section
      ,eng1.period AS eng1_period
      ,eng1.teacher_name AS eng1_teacher
FROM AR$progress_to_goals_long#static ar WITH(NOLOCK)
LEFT OUTER JOIN COHORT$identifiers_long#static s WITH(NOLOCK)
  ON ar.student_number = s.student_number
 AND ar.academic_year = s.year
 AND s.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static eng1 WITH(NOLOCK)
  ON s.student_number = eng1.student_number
 AND s.year = eng1.academic_year
 AND eng1.credittype = 'ENG'
 AND eng1.drop_flags = 0
 AND eng1.rn_subject = 1