USE KIPP_NJ
GO

--work file holding core roster CTE and mulitple program roster file formats

WITH roster AS (
	 SELECT DISTINCT 
	        s.id as studentid
		   ,s.student_number
		   ,s.lastfirst
		   ,s.last_name
		   ,s.first_name
		   ,s.team
		   ,CAST(s.grade_level AS VARCHAR(20)) AS grade_level
		   ,s.schoolid
		   ,schools.abbreviation
		   ,schools.name
		   ,cohort.boy_status
		   ,cohort.retained_yr_flag
		   ,cohort.year_in_network
		   ,s.entrydate

		   ,cc.section_number
		   ,cc.course_number

		   ,cc.teacher_name
		   ,t.last_name AS teacher_last
		   ,t.first_name AS teacher_first
		   ,CAST(t.teachernumber AS VARCHAR(20)) as teachernumber
		   ,t.EMAIL_ADDR AS teacher_email
		   ,cc.dateenrolled
		   ,cc.dateleft

	   	  ,ROW_NUMBER() OVER(
		   PARTITION BY s.student_number, course_number
		   ORDER BY CONVERT(DATE,dateleft) DESC) AS dupe

		   ,accounts.student_web_id AS core_login
		   ,accounts.student_web_password AS password
		   ,accounts.student_web_id + '@teamstudents.org' AS google_login

	 FROM COHORT$identifiers_long#static cohort WITH(NOLOCK)

	 JOIN PS$students#static s WITH(NOLOCK)
	   ON cohort.studentid = s.id 
	  AND s.ENROLL_STATUS = 0

	 JOIN PS$schools schools WITH(NOLOCK)
	   ON s.schoolid = schools.SCHOOL_NUMBER

	 JOIN ROSTERS$PS_access_accounts accounts WITH(NOLOCK)
	   ON cohort.student_number = accounts.student_number

	 LEFT OUTER JOIN PS$course_enrollments#static cc WITH(NOLOCK)
	   ON cohort.studentid = cc.studentid
	  AND cc.course_number = 'HR'
	  AND cc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

	 
	 LEFT OUTER JOIN PS$TEACHERS#static t WITH(NOLOCK)
	   ON cc.teachernumber = t.teachernumber

	 WHERE cohort.year = KIPP_NJ.dbo.fn_Global_Academic_Year()


	 --ORDER BY student_number
)

--Student Logins Google Doc Display for Staff

/*

SELECT student_number AS "SN"
      ,lastfirst AS "Last, First"
	  ,last_name AS "Last Name"
	  ,first_name AS "First_Name"
	  ,grade_level AS "Gr"
	  ,abbreviation AS "School"
	  ,core_login AS "Core Login"
	  ,password AS "Password"
	  ,google_login AS "Google Login"
	  ,entrydate
	  ,dateenrolled
	  
FROM roster

ORDER BY abbreviation, grade_level, lastfirst

WHERE dupe = 1

*/

--FOLLETT DESTINY

/*

SELECT roster.last_name AS slast
      ,roster.first_name AS sfirst
	  ,roster.student_number AS districtid
	  ,roster.student_number AS barcode
	  ,roster.grade_level AS sgrade
	  ,roster.core_login
	  ,roster.password
	  ,CASE WHEN roster.schoolid = 133570965 THEN 'TEAM' 
	        WHEN roster.schoolid = 73252 THEN 'RISE'
			WHEN roster.schoolid = 73253 THEN 'NCA'
			WHEN roster.schoolid = 73254 THEN 'SPARK'
			WHEN roster.schoolid = 73255 THEN 'THRIVE'
			WHEN roster.schoolid = 73256 THEN 'SEEK'
			WHEN roster.schoolid = 73257 THEN 'LIFE'
			WHEN roster.schoolid = 179901 THEN 'LP1'
			WHEN roster.schoolid = 73258 THEN 'BOLD'
			WHEN roster.schoolid = 179902 THEN 'LM1'
			WHEN roster.schoolid = 179903 THEN 'WM'
	   ELSE NULL
	   END AS siteshortname
	  ,roster.section_number AS homeroom

FROM roster

WHERE roster.ENTRYDATE >= '2016-08-01'
AND dupe = 1

ORDER BY roster.schoolid
		,roster.grade_level
		,roster.lastfirst

*/

--FASTT MATH
/*

SELECT student_number AS SIS_ID
      ,grade_level AS GRADE
	  ,first_name AS FIRST_NAME
	  ,last_name AS LAST_NAME
	  ,core_login AS USER_NAME
	  ,password AS PASSWORD
	  ,abbreviation AS SCHOOL_NAME
	  ,CAST(2016 AS VARCHAR(20)) + '_' + CAST(grade_level AS VARCHAR(20)) + 'th' AS CLASS_NAME
	  ,dateenrolled

FROM roster

--WHERE schoolid = 179902
 -- AND entrydate > '2015-08-05'

WHERE schoolid IN (133570965,73252,73258,179901,179903)
  AND entrydate >= '2016-08-26'
  AND dupe = 1

ORDER BY schoolid
        ,grade
		,lastfirst


*/

--READ LIVE SERIOUSLY DIE
--this gets a roster of all new students for Rise and TEAM... because you cannot update students via import to readlive, only add new students (!)
/*

SELECT roster.first_name AS "Student First Name"
      ,roster.last_name AS "Student Last Name"
	  ,roster.student_number AS "Student ID"
	  ,roster.grade_level AS "Student Grade"
	  ,roster.core_login AS "Student User ID"
	  ,roster.password AS "Password"
	  ,roster.schoolid AS "Parent1 First Name"

FROM roster

--WHERE roster.boy_status IN ('New')
WHERE roster.schoolid IN (133570965,73252)

/*
UNION ALL

SELECT roster.first_name AS "Student First Name"
      ,roster.last_name AS "Student Last Name"
	  ,roster.student_number AS "Student ID"
	  ,roster.grade_level AS "Student Grade"
	  ,roster.core_login AS "Student User ID"
	  ,roster.password AS "Password"
	  ,roster.schoolid AS "Parent1 First Name"

FROM roster

--WHERE roster.boy_status IN ('Promoted')
--  AND roster.year_in_network > 1
--  AND roster.grade_level = 5
*/


*/


--LEXIA	STUDENTS

/*

SELECT roster.student_number AS "Lexia id"
      ,roster.first_name AS "First Name"
	  ,NULL AS "MI"
	  ,roster.last_name AS "Last Name"
	  ,roster.core_login AS "Username"
	  ,roster.password AS "Password"
	  ,NULL AS "Date of Birth"
	  ,NULL AS "Sex"
	  ,CASE WHEN roster.grade_level = 0 THEN 'K'
	  	   ELSE grade_level 
	   END AS "Grade"
	  ,roster.section_number AS "Class"
	  ,roster.abbreviation AS "School"
	  ,roster.dateenrolled AS NOIMPORT_HR_ENROLL
	  ,roster.entrydate AS NOIMPORT_ENROLLDATE

	  
FROM roster

WHERE entrydate > '2015-12-25'
  --AND grade_level < 6
-- roster.schoolid IN (133570965,73252,73258,179902)
  -- WHERE entrydate >= '2015-09-08'
 

ORDER BY roster.abbreviation, roster.grade_level, roster.teacherloginid, roster.lastfirst

*/

--LEXA STAFF

/*
SELECT DISTINCT
       roster.teacher_first AS "First Name"
      ,roster.teacher_last AS "Last Name"
	  ,roster.teacher_email AS "Username"
	  ,LOWER('15' + roster.abbreviation) AS "Password"
      ,'C' AS "Access"
	  ,roster.abbreviation AS "School"
	  ,roster.section_number AS "Class"

	 
	  
FROM roster

WHERE roster.grade_level < 5 AND roster.schoolid != 73252


ORDER BY roster.ABBREVIATION, roster.section_number

*/

-- ST MATH STUDENTS

--/*

SELECT
	 CASE 
		WHEN schoolid =  73252 THEN 'RIS0JQ'
		WHEN schoolid =  73254 THEN 'SPA0JR'
		WHEN schoolid =  73255 THEN 'THR0JQ'
		WHEN schoolid =  73256 THEN 'SEE0JQ'
		WHEN schoolid =  73257 THEN 'LIF0JR'
		WHEN schoolid =  73258 THEN 'KIP0JQ'
		WHEN schoolid =  179901 THEN 'KIP0MI'
		WHEN schoolid =  179902 THEN 'LAN0MI'
		WHEN schoolid =  179903 THEN 'KIP0MJ'
		WHEN schoolid =  999999 THEN 'DIS0JQ'
		WHEN schoolid =  133570965 THEN 'TEA0JR'
	 ELSE NULL
	 END AS "iid"
    ,schoolid AS "district_school_id"
	,CASE
		WHEN schoolid =  73252 THEN 'Rise Academy'
		WHEN schoolid =  73254 THEN 'Spark Academy'
		WHEN schoolid =  73255 THEN 'Thrive Academy'
		WHEN schoolid =  73256 THEN 'Seek Academy'
		WHEN schoolid =  73257 THEN 'Life Academy'
		WHEN schoolid =  73258 THEN 'KIPP Bold Academy'
		WHEN schoolid =  179901 THEN 'Lanning Square Primary'
		WHEN schoolid =  179902 THEN 'Lanning Square Middle School'
		WHEN schoolid =  179903 THEN 'KIPP Whittier Middle'
		WHEN schoolid =  999999 THEN 'District Office of Team Charter'
		WHEN schoolid =  133570965 THEN 'Team Academy Charter School'
	ELSE NULL 
	END AS "school"
   ,teachernumber AS "district_teacher_id"
   ,teacher_email AS "teacher_email"
   ,teacher_last AS "teacher_last_name"
   ,teacher_first AS "teacher_first_name"
   ,CASE WHEN grade_level = 0 THEN 'K' ELSE grade_level END AS "grade"
   ,'' AS "period"
   ,'' AS "curriculum"
   ,student_number AS "student_id"
   ,last_name AS "student_last_name"
   ,first_name AS "student_first_name"
   ,core_login AS "student_username"
   ,password AS "student_password"
   ,CASE WHEN grade_level <= 1 THEN 'text' 
	ELSE 'visual' 
	END AS "permanent_login"
   ,'' AS "birth_date"
   ,'' AS "action"
   ,roster.dateenrolled
   ,roster.entrydate
   ,roster.dateleft
FROM roster

WHERE dupe = 1
      AND entrydate >= '2017-03-08'
	  AND grade_level <= 8
--	  AND ENTRYDATE >= '2016-10-04'
	  	 -- AND grade_level <= 8
--	  AND LAST_NAME = 'McQuiller'
-- AND SCHOOLID != 73252
--	  AND schoolid NOT IN (179901)
--    AND schoolid = 73254

ORDER BY schoolid
        ,grade_level
		,teacher_last_name

--*/