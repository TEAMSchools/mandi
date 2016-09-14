USE KIPP_NJ
GO

ALTER PROCEDURE sp_STMATH$progress_completion#MERGE AS 
BEGIN

  IF OBJECT_ID(N'tempdb..#st_math_completion') IS NOT NULL
		BEGIN
						DROP TABLE #st_math_completion
		END;
	
  SELECT IID
						  ,Institution_name
						  ,TCD
						  ,Teacher_name
						  ,SCD
						  ,Student_name
						  ,YCD
						  ,start_year
						  ,GCD
						  ,num_lab_logins
						  ,num_homework_logins
						  ,K_5_Progress
						  ,K_5_Mastery
						  ,objective_name
						  ,curr_obj_path
						  ,CASE WHEN ISNUMERIC(curr_hurdle_num_tries) = 1 THEN curr_hurdle_num_tries ELSE NULL END AS cur_hurdle_num_tries
						  ,CASE WHEN ISDATE(last_login_date) = 1 THEN CONVERT(DATE,last_login_date) ELSE NULL END AS last_login_date
						  ,UUID
						  ,CASE WHEN ISNUMERIC(fluency_progress) = 1 THEN fluency_progress ELSE NULL END AS fluency_progress
						  ,CASE WHEN ISNUMERIC(fluency_mastery) = 1 THEN fluency_mastery ELSE NULL END AS fluency_mastery
						  ,CASE WHEN fluency_path = '\N' THEN NULL ELSE fluency_path END AS fluency_path
						  ,CASE WHEN ISNUMERIC(fluency_time_spent) = 1 THEN fluency_time_spent ELSE NULL END AS fluency_time_spent
						  ,CASE WHEN school_student_id != '\N' THEN CONVERT(INT,REPLACE(school_student_id,'.0','')) ELSE NULL END AS school_student_id
						  ,CASE WHEN ISNUMERIC(minutes_logged_last_week) = 1 THEN minutes_logged_last_week ELSE NULL END AS minutes_logged_last_week
						  ,state_id	
						  ,CASE WHEN ISDATE(first_login_date) = 1 THEN CONVERT(DATE,first_login_date) ELSE NULL END AS first_login_date
						  ,week_ending_date
  INTO #st_math_completion
  FROM KIPP_NJ..AUTOLOAD$STMATH_progress_completion WITH(NOLOCK);  
  
		MERGE KIPP_NJ..STMATH$progress_completion_long TARGET
		USING #st_math_completion SOURCE
					ON TARGET.UUID = SOURCE.UUID
    AND TARGET.week_ending_date = SOURCE.week_ending_date
		WHEN MATCHED THEN UPDATE 
    SET TARGET.IID = SOURCE.IID
       ,TARGET.Institution_name = SOURCE.Institution_name
       ,TARGET.TCD = SOURCE.TCD
       ,TARGET.Teacher_name = SOURCE.Teacher_name
       ,TARGET.SCD = SOURCE.SCD
       ,TARGET.Student_name = SOURCE.Student_name
       ,TARGET.YCD = SOURCE.YCD
       ,TARGET.start_year = SOURCE.start_year
       ,TARGET.GCD = SOURCE.GCD
       ,TARGET.num_lab_logins = SOURCE.num_lab_logins
       ,TARGET.num_homework_logins = SOURCE.num_homework_logins
       ,TARGET.K_5_Progress = SOURCE.K_5_Progress
       ,TARGET.K_5_Mastery = SOURCE.K_5_Mastery
       ,TARGET.objective_name = SOURCE.objective_name
       ,TARGET.curr_obj_path = SOURCE.curr_obj_path
       ,TARGET.cur_hurdle_num_tries = SOURCE.cur_hurdle_num_tries
       ,TARGET.last_login_date = SOURCE.last_login_date
       ,TARGET.fluency_progress = SOURCE.fluency_progress
       ,TARGET.fluency_mastery = SOURCE.fluency_mastery
       ,TARGET.fluency_path = SOURCE.fluency_path
       ,TARGET.fluency_time_spent = SOURCE.fluency_time_spent
       ,TARGET.school_student_id = SOURCE.school_student_id
       ,TARGET.minutes_logged_last_week = SOURCE.minutes_logged_last_week
       ,TARGET.state_id = SOURCE.state_id
       ,TARGET.first_login_date = SOURCE.first_login_date
		WHEN NOT MATCHED BY TARGET THEN 
    INSERT (IID
           ,Institution_name
           ,TCD
           ,Teacher_name
           ,SCD
           ,Student_name
           ,YCD
           ,start_year
           ,GCD
           ,num_lab_logins
           ,num_homework_logins
           ,K_5_Progress
           ,K_5_Mastery
           ,objective_name
           ,curr_obj_path
           ,cur_hurdle_num_tries
           ,last_login_date
           ,UUID
           ,fluency_progress
           ,fluency_mastery
           ,fluency_path
           ,fluency_time_spent
           ,school_student_id
           ,minutes_logged_last_week
           ,state_id
           ,first_login_date
           ,week_ending_date) 
		  VALUES (SOURCE.IID
           ,SOURCE.Institution_name
           ,SOURCE.TCD
           ,SOURCE.Teacher_name
           ,SOURCE.SCD
           ,SOURCE.Student_name
           ,SOURCE.YCD
           ,SOURCE.start_year
           ,SOURCE.GCD
           ,SOURCE.num_lab_logins
           ,SOURCE.num_homework_logins
           ,SOURCE.K_5_Progress
           ,SOURCE.K_5_Mastery
           ,SOURCE.objective_name
           ,SOURCE.curr_obj_path
           ,SOURCE.cur_hurdle_num_tries
           ,SOURCE.last_login_date
           ,SOURCE.UUID
           ,SOURCE.fluency_progress
           ,SOURCE.fluency_mastery
           ,SOURCE.fluency_path
           ,SOURCE.fluency_time_spent
           ,SOURCE.school_student_id
           ,SOURCE.minutes_logged_last_week
           ,SOURCE.state_id
           ,SOURCE.first_login_date
           ,SOURCE.week_ending_date);
END

GO