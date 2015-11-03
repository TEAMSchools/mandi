USE KIPP_NJ
GO

ALTER VIEW TABLEAU$grades_detail_long AS

SELECT co.schoolid
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.year AS academic_year
      ,co.GENDER
      ,co.enroll_status
      ,co.lunchstatus
      ,co.SPEDLEP
      ,co.advisor
      ,co.entry_schoolid
      ,co.retained_yr_flag
      ,co.retained_ever_flag
      ,dt.alt_name
      ,dt.start_date
      ,dt.end_date      
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.SECTION_NUMBER
      ,enr.period
      ,enr.TEACHERNUMBER
      ,enr.teacher_name
      ,enr.dateenrolled
      ,enr.dateleft
      ,enr.tier_numeric
      ,enr.behavior_tier_numeric            
      ,enr.GRADESCALEID
      ,enr.EXCLUDEFROMGPA      
      ,gr.term AS finalgradename
      ,gr.term_pct
      ,gr.term_letter
      ,gr.y1_pct
      ,gr.y1_letter
      ,gr.curterm_flag
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year 
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND dt.end_date BETWEEN enr.dateenrolled AND enr.dateleft
 AND enr.drop_flags = 0
 AND enr.COURSE_NUMBER != 'HR'
LEFT OUTER JOIN KIPP_NJ..GRADES$detail_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND dt.alt_name = gr.term
 AND enr.COURSE_NUMBER = gr.course_number
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.grade_level != 99
  AND co.rn = 1

UNION ALL

SELECT co.schoolid
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.year AS academic_year
      ,co.GENDER
      ,co.enroll_status
      ,co.lunchstatus
      ,co.SPEDLEP
      ,co.advisor
      ,co.entry_schoolid
      ,co.retained_yr_flag
      ,co.retained_ever_flag
      ,dt.alt_name
      ,dt.start_date
      ,dt.end_date      
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.SECTION_NUMBER
      ,enr.period
      ,enr.TEACHERNUMBER
      ,enr.teacher_name
      ,enr.dateenrolled
      ,enr.dateleft
      ,enr.tier_numeric
      ,enr.behavior_tier_numeric            
      ,enr.GRADESCALEID
      ,enr.EXCLUDEFROMGPA      
      ,ele.pgf_type AS finalgradename
      ,ele.grade AS term_pct
      ,NULL AS term_letter
      ,y1.grade AS y1_pct
      ,NULL AS y1_letter
      ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 ELSE 0 END AS curterm_flag
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year 
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND dt.end_date BETWEEN enr.dateenrolled AND enr.dateleft
 AND enr.drop_flags = 0
 AND enr.COURSE_NUMBER != 'HR'
LEFT OUTER JOIN KIPP_NJ..GRADES$elements_long ele WITH(NOLOCK)
  ON co.studentid = ele.studentid
 AND co.year = ele.academic_year
 AND dt.alt_name = ele.term
 AND enr.COURSE_NUMBER = ele.course_number
 AND ele.term != 'Y1'
LEFT OUTER JOIN KIPP_NJ..GRADES$elements_long y1 WITH(NOLOCK)
  ON co.studentid = y1.studentid 
 AND co.year = y1.academic_year 
 AND enr.COURSE_NUMBER = y1.course_number  
 AND ele.pgf_type = y1.pgf_type
 AND y1.term = 'Y1' 
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.grade_level != 99
  AND co.rn = 1