--this view is used for the core data feed (consiting of roster, MAP info) in Rise/TEAM blended learning google doc dashboards

USE KIPP_NJ
GO

--ALTER VIEW REPORTING$blended_learning_details AS

WITH

	--roster of students
 
	roster AS
	(
      SELECT c.student_number	AS base_student_number
            ,c.studentid		AS base_studentid
            ,c.lastfirst		AS stu_lastfirst
            ,c.first_name		AS stu_firstname
            ,c.last_name		AS stu_lastname
            ,c.grade_level		AS stu_grade_level
			,c.team				AS travel_group     
			,c.spedlep			AS SPED
			,c.gender      
			,c.school_name		AS school
      FROM KIPP_NJ..COHORT$identifiers_long#static c  WITH (NOLOCK)        
	  WHERE year = 2014
        AND c.enroll_status = 0
		AND c.grade_level >= 5
		AND c.grade_level <= 8
	)

	,grades_math AS
	(
      SELECT grades_math.*
			,sections.section_number
      FROM KIPP_NJ..GRADES$DETAIL#MS grades_math  WITH (NOLOCK)
	  JOIN KIPP_NJ..sections sections WITH (NOLOCK)
	    ON grades_math.T1_ENR_SECTIONID = sections.id     
	  WHERE grades_math.schoolid IN (73252,133570965) 
  	    AND grades_math.credittype = 'MATH'
	)

	,grades_sci AS
	(
      SELECT grades_sci.*
			,sections.section_number
      FROM KIPP_NJ..GRADES$DETAIL#MS grades_sci  WITH (NOLOCK)
	  JOIN KIPP_NJ..sections sections WITH (NOLOCK)
	    ON grades_sci.T1_ENR_SECTIONID = sections.id     
	  WHERE grades_sci.schoolid IN (73252,133570965) 
  	    AND grades_sci.credittype = 'SCI'
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


	--map science data

	,map_sci AS
	(
	SELECT map_sci.*
	FROM TABLEAU$MAP_tracker map_sci WITH (NOLOCK)

	WHERE map_sci.measurementscale LIKE 'Sci%' 
	 AND map_sci.year IN (2014)
	 AND map_sci.fallwinterspring = 'Fall'
	)


	--map reading data

	,map_read AS
	(
	SELECT map_read.*
	FROM TABLEAU$MAP_tracker map_read WITH (NOLOCK)

	WHERE map_read.measurementscale LIKE 'Read%' 
	 AND map_read.year IN (2014)
	 AND map_read.fallwinterspring = 'Fall'
	)

	--map language data

	,map_lang AS
	(
	SELECT map_lang.*
	FROM TABLEAU$MAP_tracker map_lang WITH (NOLOCK)

	WHERE map_lang.measurementscale LIKE 'lang%' 
	 AND map_lang.year IN (2014)
	 AND map_lang.fallwinterspring = 'Fall'
	)


--select fields for view

SELECT 
	   roster.base_student_number	AS ID
	  ,roster.stu_lastfirst			AS LastFirst
	  ,roster.stu_grade_level		AS GR
   	  ,roster.sped					AS SPED
	  ,roster.travel_group			AS Travel
	  ,roster.gender				AS MF

	  ,grades_math.section_number	AS math_sec
	  ,grades_math.Y1				AS math_y1
	  ,grades_sci.section_number	AS sci_sec
	  ,grades_sci.Y1				AS sci_y1

	  ,roster.school			

	  ,map_math.base_rit			AS  math_rit
	  ,map_math.base_pct			AS	math_pctile
	  ,map_math.keep_up_rit			AS	math_ku	
	  ,map_math.rutgers_ready_rit	AS	math_rr

	  ,map_sci.base_rit				AS  sci_rit
	  ,map_sci.base_pct				AS	sci_pctile
	  ,map_sci.keep_up_rit			AS	sci_ku
	  ,map_sci.rutgers_ready_rit	AS	sci_rr

	  ,map_read.base_rit			AS  read_rit
	  ,map_read.base_pct			AS	read_pctile
	  ,map_read.keep_up_rit			AS	read_ku
	  ,map_read.rutgers_ready_rit	AS	read_rr

	  ,map_lang.base_rit			AS  lang_rit
	  ,map_lang.base_pct			AS	lang_pctile
	  ,map_lang.keep_up_rit			AS	lang_ku	
	  ,map_lang.rutgers_ready_rit	AS	lang_rr
	
	
FROM roster 

LEFT OUTER JOIN map_math
  ON roster.base_studentid = map_math.studentid

LEFT OUTER JOIN map_sci
  ON roster.base_studentid = map_sci.studentid

LEFT OUTER JOIN map_read
  ON roster.base_studentid = map_read.studentid

LEFT OUTER JOIN map_lang
  ON roster.base_studentid = map_lang.studentid

LEFT OUTER JOIN grades_math
  ON roster.base_studentid = grades_math.studentid

LEFT OUTER JOIN grades_sci
  ON roster.base_studentid = grades_sci.studentid