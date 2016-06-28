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
      ,gr.term_grade_percent AS term_pct
      ,gr.term_grade_letter AS term_letter
      ,NULL AS y1_pct /* replaced by UNION */
      ,NULL AS y1_letter /* replaced by UNION */
      ,gr.is_curterm AS curterm_flag
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year 
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'
JOIN KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.alt_name = gr.term 
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND gr.sectionid = enr.sectionid
 AND enr.drop_flags = 0
 AND enr.course_enr_status = 0
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
      ,'Y1' AS alt_name
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
      ,'Y1' AS finalgradename
      ,gr.y1_grade_percent_adjusted  AS term_pct
      ,gr.y1_grade_letter AS term_letter            
      ,NULL AS y1_pct /* replaced by UNION */
      ,NULL AS y1_letter /* replaced by UNION */
      ,gr.is_curterm AS curterm_flag
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid 
 AND CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
JOIN KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.alt_name = gr.term  
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND gr.sectionid = enr.sectionid
 AND enr.drop_flags = 0
 AND enr.course_enr_status = 0
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
      ,ele.grade_category AS finalgradename
      ,ele.grade_category_pct AS term_pct
      ,NULL AS term_letter
      ,NULL AS y1_pct
      ,NULL AS y1_letter
      ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 ELSE 0 END AS curterm_flag
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year 
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_long#static ele WITH(NOLOCK)
  ON co.student_number = ele.student_number
 AND co.year = ele.academic_year
 AND dt.time_per_name = ele.reporting_term 
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND ele.sectionid = enr.sectionid
 AND enr.drop_flags = 0
 AND enr.course_enr_status = 0
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
      ,'Y1' AS alt_name
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
      ,ele.grade_category AS finalgradename
      ,ele.grade_category_pct_y1 AS term_pct
      ,NULL AS term_letter
      ,NULL AS y1_pct
      ,NULL AS y1_letter
      ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 ELSE 0 END AS curterm_flag
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid 
 AND CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_long#static ele WITH(NOLOCK)
  ON co.student_number = ele.student_number
 AND co.year = ele.academic_year
 AND dt.time_per_name = ele.reporting_term 
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND ele.sectionid = enr.sectionid
 AND enr.drop_flags = 0
 AND enr.course_enr_status = 0
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.grade_level != 99
  AND co.rn = 1