USE KIPP_NJ
GO

ALTER VIEW GRADES$storedgrades#identifiers AS

SELECT sg.academic_year
      ,COALESCE(co.schoolid, 73253) AS schoolid
      ,COALESCE(co.school_name, 'NCA') AS school_name
      ,sg.studentid
      ,COALESCE(co.student_number, transf.student_number) AS student_number
      ,COALESCE(co.lastfirst, transf.lastfirst) AS student_name
      ,co.grade_level            
      ,COALESCE(enr.course_name, sg.course_name) AS course_name            
      ,sg.STORECODE AS term
      ,sg.GRADE AS grade_letter
      ,sg.PCT AS grade_pct
      ,sg.GPA_POINTS AS grade_points
      ,scale.grade_points AS grade_points_nca_unweighted
      ,NULL AS earned_crhrs
      ,enr.CREDIT_HOURS AS potential_crhrs
      
      -- student identifiers
      ,COALESCE(co.ADVISOR, transf.advisor) AS advisor
      ,co.SPEDLEP
      ,COALESCE(co.GENDER, transf.gender) AS gender
      ,COALESCE(co.enroll_status, transf.enroll_status) AS enroll_status
      ,COALESCE(co.entry_school_name, transf.entry_school_name) AS entry_school_name
      ,COALESCE(co.entry_grade_level, transf.entry_grade_level) AS entry_grade_level
      ,enr.tier
      ,enr.tier_numeric            
      
      -- course identifiers
      ,enr.CREDITTYPE
      ,enr.measurementscale      
      ,sg.COURSE_NUMBER            
      ,enr.SECTION_NUMBER
      ,enr.period            
      ,enr.teacher_name      
      ,sg.gradescale_name
      ,sg.EXCLUDEFROMGPA
      ,sg.EXCLUDEFROMGRADUATION
      ,sg.EXCLUDEFROMTRANSCRIPTS
      --,sg.SECTIONID      
      --,sg.TERMID                 
FROM KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sg.academic_year = co.year
 AND sg.STUDENTID = co.studentid
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static transf WITH(NOLOCK)
  ON sg.STUDENTID = transf.studentid
 AND transf.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 AND transf.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON sg.studentid = enr.STUDENTID
 AND sg.sectionid = enr.sectionid
LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static scale WITH(NOLOCK)
  ON sg.PCT >= scale.low_cut
 AND sg.PCT < scale.high_cut
 AND scale.scale_id = 662  
 AND co.schoolid = 73253
WHERE sg.storecode != 'Y1'

UNION ALL

SELECT DISTINCT
       sg.academic_year
      ,COALESCE(co.schoolid, 73253) AS schoolid
      ,COALESCE(co.school_name, 'NCA') AS school_name
      ,sg.studentid
      ,COALESCE(co.student_number, transf.student_number) AS student_number
      ,COALESCE(co.lastfirst, transf.lastfirst) AS student_name
      ,co.grade_level            
      ,COALESCE(enr.course_name, sg.course_name) AS course_name      
      ,sg.STORECODE AS term
      ,sg.GRADE AS grade_letter
      ,sg.PCT AS grade_pct
      ,sg.GPA_POINTS AS grade_points
      ,scale.grade_points AS grade_points_nca_unweighted
      ,sg.EARNEDCRHRS
      ,enr.CREDIT_HOURS
      
      -- student identifiers
      ,COALESCE(co.ADVISOR, transf.advisor) AS advisor
      ,co.SPEDLEP
      ,COALESCE(co.GENDER, transf.gender) AS gender
      ,COALESCE(co.enroll_status, transf.enroll_status) AS enroll_status
      ,COALESCE(co.entry_school_name, transf.entry_school_name) AS entry_school_name
      ,COALESCE(co.entry_grade_level, transf.entry_grade_level) AS entry_grade_level
      ,enr.tier
      ,enr.tier_numeric            
      
      -- course identifiers
      ,enr.CREDITTYPE
      ,enr.measurementscale      
      ,sg.COURSE_NUMBER            
      ,NULL AS SECTION_NUMBER
      ,NULL AS period  
      ,NULL AS teacher_name      
      ,sg.gradescale_name
      ,sg.EXCLUDEFROMGPA
      ,sg.EXCLUDEFROMGRADUATION
      ,sg.EXCLUDEFROMTRANSCRIPTS
      --,sg.SECTIONID      
      --,sg.TERMID                 
FROM KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sg.academic_year = co.year
 AND sg.STUDENTID = co.studentid
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static transf WITH(NOLOCK)
  ON sg.STUDENTID = transf.studentid
 AND transf.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 AND transf.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON sg.studentid = enr.STUDENTID
 AND sg.COURSE_NUMBER = enr.COURSE_NUMBER 
 AND sg.academic_year = enr.academic_year
LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static scale WITH(NOLOCK)
  ON sg.PCT >= scale.low_cut
 AND sg.PCT < scale.high_cut
 AND scale.scale_id = 662  
 AND co.schoolid = 73253
WHERE sg.storecode = 'Y1'