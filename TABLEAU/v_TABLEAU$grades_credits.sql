USE KIPP_NJ

GO

ALTER VIEW TABLEAU$grades_credits AS

WITH roster AS
(
	SELECT c.student_number
	      ,c.studentid
		  ,c.lastfirst
		  ,c.school_name
		  ,c.schoolid
		  ,c.grade_level
		  ,c.year
		  ,c.cohort
		  ,c.year_in_school
		  ,CASE WHEN c.entry_school_name IS NULL THEN 'Out of Network'
		   ELSE c.entry_school_name
		   END AS entry_school_name
		  ,c.BOY_status
		  ,c.advisor
		  ,c.ethnicity
		  ,c.SPEDLEP AS IEP_status
		  ,c.retained_ever_flag
	 
	FROM COHORT$identifiers_long#static c WITH(NOLOCK)
	JOIN PS$students#static s WITH(NOLOCK)
	  ON c.student_number = s.student_number
	WHERE c.year = dbo.fn_Global_Academic_Year()
	  AND c.schoolid = 73253
	  AND s.enroll_status = 0
)

,grades AS
(
	SELECT sg.studentid
	      ,sg.schoolid
		  ,sg.academic_year
		  ,CASE WHEN sg.course_number = 'TRANSFER' THEN 'TRANSFER' ELSE c.CREDITTYPE END AS credittype
  		  ,sg.earnedcrhrs AS credits
		  ,'Stored Credit' AS status
		  ,sg.course_number
		  ,CASE WHEN sg.course_number = 'TRANSFER' THEN sg.course_name ELSE c.course_name END AS course_name
	      ,sg.pct
		  ,sg.grade AS letter_grade
		  ,sg.GPA_POINTS
	FROM GRADES$STOREDGRADES#static sg WITH(NOLOCK)
	LEFT OUTER JOIN PS$COURSES#static c WITH(NOLOCK)
	  ON c.course_number = sg.course_number
	WHERE sg.schoolid = 73253
	  AND sg.storecode = 'Y1'
 
	UNION ALL

	SELECT g.studentid
	      ,g.schoolid
		  ,g.academic_year
		  ,g.credittype
  		  ,CASE WHEN g.y1_grade_percent >= 68 THEN g.credit_hours
		   ELSE 0
		   END AS credits
		  ,'Potential Credit' as status
		  ,g.course_number
		  ,g.course_name
	      ,g.y1_grade_percent AS pct
		  ,g.y1_grade_letter AS letter_grade
		  ,g.y1_gpa_points AS gpa_points
	FROM GRADES$final_grades_long#static g WITH(NOLOCK)
	WHERE g.schoolid = 73253
	  AND g.academic_year = dbo.fn_Global_Academic_Year()
	  AND g.term = 'Q1'
)

SELECT r.student_number
	  ,r.studentid
	  ,r.lastfirst
	  ,r.school_name
	  ,r.schoolid
	  ,r.grade_level
	  ,r.year
	  ,r.cohort
	  ,r.year_in_school
	  ,r.entry_school_name
	  ,r.BOY_status
	  ,r.retained_ever_flag
	  ,r.advisor
	  ,r.IEP_status

	  ,g.academic_year
  	  ,g.credittype
	  ,g.course_number
	  ,g.course_name
	  ,g.pct
	  ,g.letter_grade
	  ,g.gpa_points
	  ,g.credits
	  ,g.status
	  ,g.COURSE_NAME + ' (' + CONVERT(VARCHAR(20), g.pct) + ')  ' + CONVERT(VARCHAR(20), g.academic_year) AS course_pct_hash

FROM roster r
JOIN grades g
 ON r.studentid = g.STUDENTID
AND r.schoolid = g.SCHOOLID

