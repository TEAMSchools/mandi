USE KIPP_NJ
GO

WITH

--roster of students
 
	roster AS
	(
      SELECT s.student_number AS base_student_number
            ,s.id AS base_studentid
            ,s.lastfirst AS stu_lastfirst
            ,s.first_name AS stu_firstname
            ,s.last_name AS stu_lastname
            ,c.grade_level AS stu_grade_level
            ,s.team AS travel_group            
      FROM KIPP_NJ..COHORT$comprehensive_long#static c  WITH (NOLOCK)
      JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
        ON c.studentid = s.id
       AND s.enroll_status = 0       
      WHERE year = 2014 -- dbo.fn_Global_Academic_Year()
        AND c.rn = 1        
        AND c.schoolid = 73252 
	--	AND c.studentid = 4742       
	)

--ST Math data

   ,stmath AS
	(
	  SELECT sub.*
	  FROM
		(
		  SELECT stmath.student_number
				,stmath.studentid
				,stmath.K_5_Mastery
				,stmath.K_5_Progress
				,stmath.objective_name
				,stmath.cur_hurdle_num_tries
				,stmath.teacher_name
				,stmath.gcd
				,CASE WHEN stmath.gcd = 'Kindergarten'	THEN 0
					  WHEN stmath.gcd = 'First Grade'	THEN 1
					  WHEN stmath.gcd = 'Second Grade'	THEN 2
					  WHEN stmath.gcd = 'Third Grade'	THEN 3
					  WHEN stmath.gcd = 'Fourth Grade'	THEN 4
					  WHEN stmath.gcd = 'Fifth Grade'	THEN 5
					  WHEN stmath.gcd = 'Sixth Grade'	THEN 6
					  WHEN stmath.gcd = 'Seventh Grade' THEN 7
					  WHEN stmath.gcd = 'Eigth Grade'	THEN 8
					  WHEN stmath.gcd = 'Ninth Grade'	THEN 9
					  WHEN stmath.gcd = 'Secondary Intervention' THEN 6
				 ELSE stmath.gcd END AS stmath_level
				,stmath.num_lab_logins
				,stmath.fluency_time_spent
				,stmath.num_homework_logins
				,stmath.first_login_date
				,stmath.last_login_date
				,stmath.minutes_logged_last_week
				,ROW_NUMBER() OVER
						   (PARTITION BY stmath.student_number ORDER BY stmath.K_5_Progress DESC )
							AS progress_order 
		 FROM STMath..progress_completion#identifiers stmath WITH (NOLOCK)
		)sub
	 WHERE sub.progress_order = 1
	)

--Khan data

    ,khan AS
	(
	  SELECT sub.studentid
            ,sub.lastfirst
            ,COUNT(*) AS mastered
      FROM
			(SELECT e.studentid
					,s.lastfirst
					,s.first_name + ' ' + s.last_name AS full_name
					,s.grade_level
					,e.exercise
					,e.proficient_date
					,e.level
					,e.total_done
					,e.total_correct
				FROM Khan..composite_exercises#identifiers e WITH (NOLOCK)
				JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
				ON e.studentid = s.id               
			WHERE e.mastered = 'True'
				) sub
    GROUP BY sub.studentid
            ,sub.lastfirst
	)


--Accelerated Math
   
	,am AS
	(
	SELECT am.studentid
		,am.grade_level
		,am.year
		,am.objectives
		,am.avg_grade_level
		,am.date
				
	FROM KIPP_NJ..AM$objectives_mastered#long#static am WITH (NOLOCK)
		    
	WHERE am.year = 2013
	  AND am.date = '2014-06-20'
	)

--map data

	,map AS
	(
	SELECT map.*

	FROM MAP$comprehensive#identifiers map

	WHERE map.rn_curr = 1
	  AND map.map_year = dbo.fn_Global_Academic_Year()
	  AND map.discipline = 'Mathematics'
	)

--select fields for view

SELECT roster.stu_lastfirst
	  ,roster.stu_grade_level
	  ,roster.base_student_number
	  ,roster.base_studentid
      ,stmath.K_5_Progress AS stmath_progress
--	  ,stmath.stmath_level
	  ,CASE WHEN stmath.K_5_Progress = 100 THEN 1 
			ELSE NULL 
			END AS stmath_achieved
	  ,khan.mastered AS khan_obj
	  ,CASE WHEN roster.stu_grade_level = 6 AND khan.mastered >= 100 THEN 1 
			WHEN roster.stu_grade_level = 7 AND khan.mastered >= 200 THEN 1 
			WHEN roster.stu_grade_level = 8 AND khan.mastered >= 200 THEN 1  
			ELSE NULL 
			END AS khan_achieved
	  ,am.objectives AS am_obj
	  ,map.testritscore AS map_rit
	  ,map.testpercentile AS map_pctl
	

FROM roster 

LEFT OUTER JOIN stmath
  ON roster.base_student_number = stmath.student_number

LEFT OUTER JOIN khan
  ON roster.base_studentid = khan.studentid

LEFT OUTER JOIN am
  ON roster.base_studentid = am.studentid

LEFT OUTER JOIN map
  ON roster.base_student_number = map.studentid
