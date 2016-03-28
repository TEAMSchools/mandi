USE KIPP_NJ
GO

ALTER VIEW TABLEAU$promo_tracker AS

SELECT co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,co.year
      ,dt.alt_name AS term
      
      ,gr.is_curterm
      ,gr.term AS finalgradename      
      ,gr.credittype
      ,gr.course_number
      ,gr.course_name      
      ,gr.teacher_name
      ,gr.excludefromgpa
      ,gr.credit_hours
      ,gr.term_gpa_points
      ,gr.term_grade_percent_adjusted
      ,gr.term_grade_letter_adjusted
      ,gr.y1_grade_percent_adjusted
      ,gr.y1_grade_letter           
      
      ,sec.SECTION_NUMBER 
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.alt_name = gr.term
LEFT OUTER JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
  ON gr.sectionid = sec.ID
WHERE co.rn = 1

UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,co.year
      ,dt.alt_name AS term
      
      ,gr.is_curterm
      ,gr.grade_category AS finalgradename
      ,gr.credittype
      ,gr.course_number
      ,NULL AS course_name            
      ,gr.teacher_name
      ,NULL AS excludefromgpa
      ,NULL AS credit_hours
      ,NULL AS term_gpa_points      
      ,gr.grade_category_pct AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,gr.grade_category_pct_y1 AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter            

      ,sec.SECTION_NUMBER
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.time_per_name = gr.reporting_term
LEFT OUTER JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
  ON gr.sectionid = sec.ID
WHERE co.rn = 1
  AND co.school_level IN ('MS','HS')