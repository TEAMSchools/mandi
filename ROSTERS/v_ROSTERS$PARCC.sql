USE KIPP_NJ
GO

ALTER VIEW ROSTERS$PARCC AS

WITH students AS 
	(
	SELECT student_number
      ,last_name
	  ,first_name
	  ,lastfirst
	  ,grade_level
	  ,schoolid
	  ,school_name
	  ,year_in_network
	  ,gender
	  ,ethnicity
	  ,SID
	  ,SPEDLEP
	  ,year

	FROM COHORT$identifiers_long#static WITH(NOLOCK)

	WHERE grade_level >= 3 
	  AND grade_level <= 11
	  AND year = 2015
	  AND enroll_status = 0
	  AND rn = 1
	)

,courses AS
	(
	
	SELECT academic_year
	      ,termid
		  ,student_number
		  ,schoolid
		  ,grade_level
		  ,CASE WHEN credittype = 'ENG' THEN 'ELA'
		        WHEN credittype = 'MATH' THEN 'MAT'
		   ELSE 'MS' 
		   END AS credittype
		  ,course_number
		  ,course_name
		  ,sectionid
		  ,teachernumber
		  ,teacher_name
		  ,dateenrolled
		  ,dateleft
		  ,ROW_NUMBER() OVER(
			PARTITION BY student_number, credittype
			ORDER BY dateenrolled DESC) AS rn
		  
	FROM PS$course_enrollments#static WITH(NOLOCK)

	WHERE termid = 2500
	  AND schoolid IN (133570965,73252,179902,73253)
	  AND dateleft >= '2015-12-08'
	  AND course_name NOT LIKE '%Lab%'
	  AND course_name NOT LIKE '%Independent%'
	  AND course_name NOT LIKE '%Reading Support and Intervention%'
	  AND CREDITTYPE IN ('MATH','ENG') 


	UNION ALL

	SELECT academic_year
	      ,termid
		  ,student_number
		  ,schoolid
		  ,grade_level
		  ,CASE WHEN credittype IS NULL THEN 'MAT'
		   ELSE 'ES'
		   END AS creditype
		  ,course_number
		  ,course_name
		  ,sectionid
		  ,teachernumber
		  ,teacher_name
		  ,dateenrolled
		  ,dateleft
		  ,ROW_NUMBER() OVER(
		    PARTITION BY student_number, credittype
			ORDER BY dateenrolled DESC) AS rn

		  
	FROM PS$course_enrollments#static WITH(NOLOCK)

	WHERE grade_level IN (3,4,5)
	  AND schoolid NOT IN (73252,179902,133570965)
	  AND COURSE_NUMBER = 'HR' 
	  AND termid = 2500
	  AND dateleft >= '2015-12-08'

	UNION ALL
	
	SELECT academic_year
	      ,termid
		  ,student_number
		  ,schoolid
		  ,grade_level
		  ,CASE WHEN credittype IS NULL THEN 'ELA'
		   ELSE 'ES'
		   END AS creditype
		  ,course_number
		  ,course_name
		  ,sectionid
		  ,teachernumber
		  ,teacher_name
		  ,dateenrolled		
		  ,dateleft
		  ,ROW_NUMBER() OVER(
			PARTITION BY student_number, credittype
			ORDER BY dateenrolled DESC) AS rn
		  
	FROM PS$course_enrollments#static WITH(NOLOCK)

	WHERE grade_level IN (3,4,5)
	  AND schoolid NOT IN (73252,179902,133570965)
	  AND COURSE_NUMBER = 'HR' 
	  AND termid = 2500
	  AND dateleft >= '2015-12-08'

	)

SELECT 
	   students.school_name
	  ,students.grade_level
	  ,students.student_number
      ,students.lastfirst
	  ,students.spedlep
	  ,courses.credittype AS subject
	  ,courses.course_name AS ps_course_name
	  ,CASE WHEN courses.course_number IN ('MATH10','MATH71','MATH15','M415','M400') 
					THEN 'ALG01'
			WHEN courses.course_number IN ('MATH25','MATH20') 
					THEN 'GEO01'
			WHEN courses.course_number IN ('MATH32','MATH35') 
					THEN 'ALG02'
			WHEN courses.credittype = 'MAT' AND students.grade_level <9 
					THEN courses.credittype + CONVERT(VARCHAR(20),0) + CONVERT(VARCHAR(20),students.grade_level)
			WHEN courses.course_number IN ('MATH13',',MATH72','MATH43','MATH40','MATH44')
					THEN 'No Test'
			WHEN courses.credittype = 'ELA' AND students.grade_level < 10 
					THEN courses.credittype + CONVERT(VARCHAR(20),0) + CONVERT(VARCHAR(20),students.grade_level)
			WHEN courses.credittype = 'ELA' AND students.grade_level >= 10 
					THEN courses.credittype + CONVERT(VARCHAR(20),students.grade_level)
			ELSE 'No Test' 
			END AS PARCC_testcode
	  ,CASE WHEN ROW_NUMBER() OVER(
				PARTITION BY students.student_number, courses.credittype
					ORDER BY courses.dateenrolled DESC) > 1 THEN 'Multiple Enrollments' 
			WHEN courses.credittype IS NULL THEN 'Not Enrolled in Courses'
			ELSE NULL END AS 'Flag Enrollment'
	  ,courses.teachernumber
	  ,courses.teacher_name

FROM students

LEFT OUTER JOIN courses
  ON students.student_number = courses.student_number

WHERE students.grade_level <= 8 AND courses.rn = 1
   OR students.grade_level >= 9

/*
ORDER BY students.school_name
		,students.grade_level
		,students.lastfirst
		,courses.CREDITTYPE
*/
