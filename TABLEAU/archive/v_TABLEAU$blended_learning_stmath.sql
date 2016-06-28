USE KIPP_NJ
GO

ALTER VIEW TABLEAU$blended_learning_stmath AS

WITH

	roster AS
	(
      SELECT c.student_number	AS base_student_number
            ,c.studentid		AS base_studentid
            ,c.lastfirst		AS stu_lastfirst
            ,c.first_name		AS stu_firstname
            ,c.last_name		AS stu_lastname
            ,c.grade_level		AS stu_grade_level
            ,c.school_name
			,c.team				AS travel_group      
			,c.spedlep			AS IEP
			,c.gender      
      FROM COHORT$identifiers_long#static c  WITH (NOLOCK)        
	  WHERE year = dbo.fn_Global_Academic_Year()
        AND c.enroll_status = 0
  	  --AND c.student_number = 13827      
	 )


	--class and teacher information
	,enrollment AS
	(
      SELECT cc.studentid
			,cc.sectionid
			,cc.teacherid
			,teachers.ID
			,teachers.lastfirst
			,cc.course_number
			,courses.COURSE_NAME
			,courses.CREDITTYPE
			,cc.SECTION_NUMBER
      FROM KIPP_NJ..PS$CC#static cc WITH (NOLOCK)
	  JOIN KIPP_NJ..PS$TEACHERS#static teachers WITH (NOLOCK)
		ON cc.TEACHERID = teachers.ID
	  JOIN KIPP_NJ..PS$COURSES#static courses WITH (NOLOCK)
	    ON cc.course_number = courses.course_number
	  JOIN KIPP_NJ..STUDENTS WITH (NOLOCK)
	    ON cc.studentid = students.id
       AND students.grade_level >= 4
       AND students.grade_level <= 8
	   AND students.schoolid IN (133570965,73252,179902)
	  WHERE courses.credittype LIKE '%MATH%' 
		AND cc.TERMID >= dbo.fn_Global_Term_Id()
		AND cc.dateenrolled <= GETDATE()
        AND cc.dateleft >= GETDATE()

  UNION ALL 

	SELECT cc.studentid
		  ,cc.sectionid
		  ,cc.teacherid
		  ,teachers.ID
		  ,teachers.lastfirst
		  ,cc.course_number
		  ,courses.COURSE_NAME
		  ,courses.CREDITTYPE
    	  ,cc.SECTION_NUMBER
	  FROM KIPP_NJ..PS$CC#static cc WITH (NOLOCK)
	  JOIN KIPP_NJ..PS$TEACHERS#static teachers WITH (NOLOCK)
		ON cc.TEACHERID = teachers.ID
	  JOIN KIPP_NJ..PS$COURSES#static courses WITH (NOLOCK)
	 	ON cc.course_number = courses.course_number
	  JOIN KIPP_NJ..PS$STUDENTS#static students WITH (NOLOCK)
	    ON cc.studentid = students.id
	   AND students.grade_level <=4
	   AND students.schoolid != 73252
     WHERE courses.course_number = 'HR'
	   AND cc.TERMID >= dbo.fn_Global_Term_Id()
       AND cc.dateenrolled <= GETDATE()
       AND cc.dateleft >= GETDATE()

	)


	--st_math tracking by library

	,st_math_lib_track AS
	(
	  SELECT *
	  FROM REPORTING$st_math_tracker#static st WITH (NOLOCK)
	)

	--st_math overall progress and change
	,st_math AS
	(
	  SELECT *
	  FROM REPORTING$st_math_summary_by_enrollment#static WITH (NOLOCK)
	)

	--st math usage
	,st_usage AS 
	(
	  SELECT studentid
	        ,school_student_id
			,K_5_Progress
			,K_5_Mastery
	        ,num_lab_logins
	   	    ,num_homework_logins
			,objective_name
			,cur_hurdle_num_tries
			,minutes_logged_last_week
			,fluency_progress
			,fluency_mastery
			,fluency_time_spent
			,first_login_date
			,last_login_date
			,week_ending_date
			,start_year
			,ROW_NUMBER() OVER(
			   PARTITION BY school_student_id,start_year
			     ORDER BY week_ending_date DESC) AS rn

	  FROM STMATH..progress_completion#identifiers st_usage WITH(NOLOCK)
	)

	--map math data

	,map_math AS
	(
	SELECT map_math.studentid
       ,map_math.testritscore
       ,map_math.testpercentile
       ,rr.keep_up_rit
       ,rr.rutgers_ready_rit
	FROM MAP$best_baseline#static map_math WITH(NOLOCK)
	LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
		ON map_math.studentid = rr.studentid
		AND map_math.year = rr.year
		AND map_math.measurementscale = rr.measurementscale
	WHERE map_math.measurementscale LIKE 'Math%' 
		AND map_math.year = dbo.fn_Global_Academic_Year()	 
	)

SELECT roster.*

	  ,enrollment.course_name AS course
	  ,enrollment.section_number AS section
	  ,enrollment.lastfirst AS teacher

	  ,st_math.total_completion
	  ,st_math.cur_lib
	  ,st_math.change

	  ,st_math_lib_track.lib_K
	  ,st_math_lib_track.lib_1st
	  ,st_math_lib_track.lib_2nd
	  ,st_math_lib_track.lib_3rd
	  ,st_math_lib_track.lib_4th
	  ,st_math_lib_track.lib_5th
	  ,st_math_lib_track.lib_6th

	 ,st_usage.K_5_Progress
	 ,st_usage.K_5_Mastery
	 ,st_usage.num_lab_logins
	 ,st_usage.num_homework_logins
	 ,st_usage.objective_name
	 ,st_usage.cur_hurdle_num_tries
	 ,st_usage.minutes_logged_last_week
	 ,st_usage.fluency_progress
	 ,st_usage.fluency_mastery
	 ,st_usage.fluency_time_spent
	 ,st_usage.first_login_date
	 ,st_usage.last_login_date
	 ,st_usage.week_ending_date


	  ,map_math.testritscore			AS  math_rit
	  ,map_math.testpercentile			AS	math_pctile
	  ,map_math.keep_up_rit			AS	math_ku	
	  ,map_math.rutgers_ready_rit	AS	math_rr

FROM roster

JOIN st_math
  ON roster.base_studentid = st_math.studentid
 AND st_math.total_completion IS NOT NULL

JOIN st_math_lib_track
  ON roster.base_studentid = st_math_lib_track.studentid

JOIN st_usage
  ON roster.base_studentid = st_usage.studentid
 AND st_usage.rn = 1
 AND st_usage.start_year = dbo.fn_Global_Academic_Year()	 

LEFT OUTER JOIN enrollment
  ON roster.base_studentid = enrollment.studentid
  

LEFT OUTER JOIN map_math
  ON roster.base_studentid = map_math.studentid

/*
ORDER BY school_name
		,stu_grade_level
		,stu_lastfirst
		,travel_group
*/

