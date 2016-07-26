USE KIPP_NJ
GO

ALTER PROCEDURE sp_STMATH$progress_completion#MERGE AS 
BEGIN

  --very very poor man's print
  DECLARE
    @msg_value varchar(200)
   ,@msg nvarchar(200) = '''%s'''
   ,@helper1          AS NVARCHAR(MAX)
   ,@helper2          AS NVARCHAR(MAX)

		--0. ensure temp table doesn't exist in use
		IF OBJECT_ID(N'tempdb..#st_math_completion') IS NOT NULL
		BEGIN
						DROP TABLE #st_math_completion
		END
	
	--1. bulk load csv and SELECT INTO temp table				
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

  --a lot of work for a print statement...
  SET @helper1 = N'SET @X = (SELECT COUNT(*) AS N FROM #st_math_completion)'
  EXEC sp_executesql @helper1, N'@X NVARCHAR(MAX) OUT', @helper2 OUT
  SET @msg_value = 'Put ' + CAST(@helper2 AS VARCHAR) + ' rows into the temp table.'
  RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

  --2. merge into destination
		MERGE KIPP_NJ..STMATH$progress_completion_long target
		USING #st_math_completion staging
					ON target.UUID = staging.UUID
    AND target.week_ending_date = staging.week_ending_date
		WHEN MATCHED THEN
				UPDATE SET  
       target.IID = staging.IID
      ,target.Institution_name = staging.Institution_name
      ,target.TCD = staging.TCD
      ,target.Teacher_name = staging.Teacher_name
      ,target.SCD = staging.SCD
      ,target.Student_name = staging.Student_name
      ,target.YCD = staging.YCD
      ,target.start_year = staging.start_year
      ,target.GCD = staging.GCD
      ,target.num_lab_logins = staging.num_lab_logins
      ,target.num_homework_logins = staging.num_homework_logins
      ,target.K_5_Progress = staging.K_5_Progress
      ,target.K_5_Mastery = staging.K_5_Mastery
      ,target.objective_name = staging.objective_name
      ,target.curr_obj_path = staging.curr_obj_path
      ,target.cur_hurdle_num_tries = staging.cur_hurdle_num_tries
      ,target.last_login_date = staging.last_login_date
      ,target.fluency_progress = staging.fluency_progress
      ,target.fluency_mastery = staging.fluency_mastery
      ,target.fluency_path = staging.fluency_path
      ,target.fluency_time_spent = staging.fluency_time_spent
      ,target.school_student_id = staging.school_student_id
      ,target.minutes_logged_last_week = staging.minutes_logged_last_week
      ,target.state_id = staging.state_id
      ,target.first_login_date = staging.first_login_date
		WHEN NOT MATCHED BY target THEN
		INSERT (
    IID
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
   ,week_ending_date
  ) 
		VALUES (
    staging.IID
   ,staging.Institution_name
   ,staging.TCD
   ,staging.Teacher_name
   ,staging.SCD
   ,staging.Student_name
   ,staging.YCD
   ,staging.start_year
   ,staging.GCD
   ,staging.num_lab_logins
   ,staging.num_homework_logins
   ,staging.K_5_Progress
   ,staging.K_5_Mastery
   ,staging.objective_name
   ,staging.curr_obj_path
   ,staging.cur_hurdle_num_tries
   ,staging.last_login_date
   ,staging.UUID
   ,staging.fluency_progress
   ,staging.fluency_mastery
   ,staging.fluency_path
   ,staging.fluency_time_spent
   ,staging.school_student_id
   ,staging.minutes_logged_last_week
   ,staging.state_id
   ,staging.first_login_date
   ,staging.week_ending_date
  );
END

GO

