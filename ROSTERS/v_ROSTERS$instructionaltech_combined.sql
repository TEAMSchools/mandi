USE KIPP_NJ
GO

WITH roster AS (
	
	 SELECT s.id as studentid
		   ,s.student_number
		   ,s.lastfirst
		   ,s.last_name
		   ,s.first_name
		   ,s.grade_level
		   ,s.schoolid
		   ,schools.abbreviation
		   ,schools.name

		   ,hr.teacher_name
		   ,teachers.loginid
		   ,CAST(hr.teachernumber AS VARCHAR(20)) as teachernumber
		   ,teachers.teacherloginid
		   ,teachers.EMAIL_ADDR AS teacher_email
		   ,hr.dateenrolled

		   ,accounts.student_web_id AS core_login
		   ,accounts.student_web_password password
		   ,accounts.student_web_id + '@teamstudents.org' AS google_login

	 FROM COHORT$identifiers_long#static cohort WITH(NOLOCK)

	 JOIN PS$students#static s WITH(NOLOCK)
	   ON cohort.studentid = s.id 
	  AND s.ENROLL_STATUS = 0

	 JOIN PS$schools schools WITH(NOLOCK)
	   ON s.schoolid = schools.SCHOOL_NUMBER

	 JOIN ROSTERS$PS_access_accounts accounts
	   ON cohort.student_number = accounts.student_number

	 LEFT OUTER JOIN COHORT$student_homerooms hr
	   ON cohort.studentid = hr.studentid
	  AND hr.rn_stu_year = 1
	  AND hr.year = 2015 --KIPP_NJ.dbo.fn_Global_Academic_Year()

	 LEFT OUTER JOIN PS$TEACHERS#static teachers
	   ON CAST(hr.teachernumber AS VARCHAR(20)) = CAST(teachers.teachernumber AS VARCHAR(20))

	 WHERE cohort.year = 2015 --KIPP_NJ.dbo.fn_Global_Academic_Year()

	)

SELECT *

FROM roster
	
	
