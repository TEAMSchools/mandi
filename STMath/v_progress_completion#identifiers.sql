USE STMath
GO

ALTER VIEW progress_completion#identifiers AS

SELECT p.IID
      ,p.Institution_name
      ,p.TCD
      ,p.Teacher_name
      ,p.SCD
      ,p.Student_name
      ,p.YCD
      ,p.start_year
      ,p.GCD
      ,p.num_lab_logins
      ,p.num_homework_logins
      ,p.K_5_Progress
      ,p.K_5_Mastery
      ,p.objective_name
      ,p.curr_obj_path
      ,p.cur_hurdle_num_tries
      ,p.last_login_date
      ,p.UUID
      ,p.fluency_progress
      ,p.fluency_mastery
      ,p.fluency_path
      ,p.fluency_time_spent
      ,p.school_student_id
      ,p.minutes_logged_last_week
      ,p.state_id
      ,p.first_login_date
      ,p.week_ending_date      
      ,s.id AS studentid
FROM STMath..progress_completion p
JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
  ON p.school_student_id = s.student_number