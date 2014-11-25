USE KIPP_NJ
GO

--ALTER VIEW TABLEAU$blended_learning_stmath AS

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
	  WHERE year = 2014
        AND c.enroll_status = 0
  	 -- AND s.student_number = 14188      
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
      FROM KIPP_NJ..cc WITH (NOLOCK)
	  JOIN KIPP_NJ..TEACHERS teachers WITH (NOLOCK)
		ON cc.TEACHERID = teachers.ID
	  JOIN KIPP_NJ..courses WITH (NOLOCK)
	    ON cc.course_number = courses.course_number
	  JOIN KIPP_NJ..STUDENTS WITH (NOLOCK)
	    ON cc.studentid = students.id
       AND students.grade_level >= 5
       AND students.grade_level <= 8
	  WHERE courses.credittype LIKE '%MATH%' 
		AND cc.TERMID >= 2400
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
	  FROM KIPP_NJ..cc WITH (NOLOCK)
	  JOIN KIPP_NJ..TEACHERS teachers WITH (NOLOCK)
		ON cc.TEACHERID = teachers.ID
	  JOIN KIPP_NJ..courses WITH (NOLOCK)
	 	ON cc.course_number = courses.course_number
	  JOIN KIPP_NJ..STUDENTS WITH (NOLOCK)
	    ON cc.studentid = students.id
	   AND students.grade_level <=4
     WHERE courses.course_number = 'HR' 
	   AND cc.TERMID >= 2400
       AND cc.dateenrolled <= GETDATE()
       AND cc.dateleft >= GETDATE()

	)


	--st_math tracking by library

	,st_math_lib_track AS
	(
	  SELECT *
	  FROM REPORTING$st_math_tracker st WITH (NOLOCK)
	)

	--st_math overall progress and change
	,st_math AS
	(
	  SELECT *
	  FROM STMath..summary_by_enrollment WITH (NOLOCK)
	)
	
	--map math data

	,map_math AS
	(
	SELECT map_math.*
	FROM TABLEAU$MAP_tracker map_math WITH (NOLOCK)
	WHERE map_math.measurementscale LIKE 'Math%' 
	 AND map_math.year IN (2014)
	 AND map_math.fallwinterspring = 'Fall'
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


	  ,map_math.base_rit			AS  math_rit
	  ,map_math.base_pct			AS	math_pctile
	  ,map_math.keep_up_rit			AS	math_ku	
	  ,map_math.rutgers_ready_rit	AS	math_rr

FROM roster

JOIN st_math
  ON roster.base_studentid = st_math.studentid
 AND st_math.total_completion IS NOT NULL

JOIN st_math_lib_track
  ON roster.base_studentid = st_math_lib_track.studentid

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

