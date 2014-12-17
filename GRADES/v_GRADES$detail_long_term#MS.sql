USE KIPP_NJ
GO

ALTER VIEW GRADES$detail_long_term#MS AS

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
    
	 )


	--grades detail long for all terms

	,grades AS
	(
		SELECT grades.student_number
			  ,grades.lastfirst
			  ,grades.grade_level
			  ,grades.credittype
			  ,grades.course_number
			  ,grades.course_name
			  ,NULL AS sectionid
     ,grades.y1			AS pct
			  ,grades.y1_letter		AS letter
			  ,'Y1'				AS term
			  ,grades.promo_test as failing_flag
		FROM GRADES$DETAIL#MS grades WITH(NOLOCK)


		UNION ALL

		SELECT grades.student_number
			  ,grades.lastfirst
			  ,grades.grade_level
			  ,grades.credittype
			  ,grades.course_number
			  ,grades.course_name
     ,grades.T1_ENR_SECTIONID AS sectionid
			  ,grades.t1			AS pct
			  ,grades.t1_letter		AS letter
			  ,'T1'					AS term
			  ,grades.promo_test as failing_flag
		FROM GRADES$DETAIL#MS grades WITH(NOLOCK)


		UNION ALL

		SELECT grades.student_number
			  ,grades.lastfirst
			  ,grades.grade_level
			  ,grades.credittype
			  ,grades.course_number
			  ,grades.course_name
     ,grades.T2_ENR_SECTIONID AS sectionid
			  ,grades.t2			AS pct
			  ,grades.t2_letter		AS letter
			  ,'T2'					AS term
			  ,grades.promo_test as failing_flag
		FROM GRADES$DETAIL#MS grades WITH(NOLOCK)


		UNION ALL

		SELECT grades.student_number
			  ,grades.lastfirst
			  ,grades.grade_level
			  ,grades.credittype
			  ,grades.course_number
			  ,grades.course_name
     ,grades.T3_ENR_SECTIONID AS sectionid
			  ,grades.t3			AS pct
			  ,grades.t3_letter		AS letter
			  ,'T3'					AS term
			  ,grades.promo_test as failing_flag
		FROM GRADES$DETAIL#MS grades WITH(NOLOCK)



	)

SELECT roster.base_student_number	AS student_number 
	  ,roster.base_studentid		AS studentid
	  ,roster.stu_lastfirst			AS lastfirst
	  ,roster.stu_grade_level		AS grade_level
	  ,roster.IEP					AS SPEDLEP
	  ,roster.school_name
	  ,grades.credittype
	  ,grades.course_number
	  ,grades.course_name
   ,grades.sectionid
	  ,grades.pct
	  ,grades.letter
	  ,grades.term
	  ,grades.failing_flag


FROM roster

JOIN grades
  ON roster.base_student_number = grades.STUDENT_NUMBER
