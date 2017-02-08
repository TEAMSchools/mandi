USE KIPP_NJ
GO

ALTER VIEW TABLEAU$gradebook_dashboard AS

WITH section_teacher AS (
  SELECT scaff.studentid
        ,scaff.year
        ,scaff.course_number
        ,scaff.teacher_name
        ,scaff.sectionid        
        ,sec.SECTION_NUMBER        
        ,p.ABBREVIATION AS period
        ,ROW_NUMBER() OVER(
           PARTITION BY scaff.studentid, scaff.year, scaff.course_number
             ORDER BY scaff.term DESC) AS rn        
  FROM KIPP_NJ..PS$course_section_scaffold#static scaff WITH(NOLOCK)
  JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
    ON scaff.sectionid = sec.ID
  LEFT OUTER JOIN KIPP_NJ..PS$PERIOD#static p WITH(NOLOCK)
    ON sec.academic_year = p.academic_year
   AND sec.schoolid = p.SCHOOLID
   AND sec.expression = CONVERT(VARCHAR,p.PERIOD_NUMBER)
  WHERE scaff.teacher_name IS NOT NULL
    AND scaff.term IS NOT NULL
    AND scaff.COURSE_NUMBER IS NOT NULL
    --AND scaff.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 
 )

/* final grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.enroll_status
      ,co.year
      ,co.spedlep
      ,dt.alt_name AS term
      
      ,gr.is_curterm
      ,gr.term AS finalgradename      
      ,gr.credittype
      ,gr.course_number
      ,gr.course_name      
      ,st.sectionid
      ,st.teacher_name
      ,gr.excludefromgpa
      ,gr.credit_hours
      ,gr.term_gpa_points
      ,gr.term_grade_percent_adjusted
      ,gr.term_grade_letter_adjusted
      ,gr.y1_grade_percent_adjusted
      ,gr.y1_grade_letter           
      ,gr.y1_gpa_points
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_65 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_65
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_70 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_70
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_80 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_80
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_90 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_90
      
      ,st.SECTION_NUMBER       
      ,st.period
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.alt_name = gr.term
LEFT OUTER JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.year = st.year
 AND gr.course_number = st.COURSE_NUMBER
 AND st.rn = 1
WHERE co.rn = 1
  AND co.school_level IN ('MS','HS')
  --AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 

UNION ALL

/* category grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.enroll_status
      ,co.year
      ,co.spedlep
      ,dt.alt_name AS term
      
      ,gr.is_curterm
      ,CASE 
        WHEN co.schoolid != 73253 AND gr.grade_category = 'E' THEN 'HWQ'
        WHEN co.schoolid != 73253 AND co.year <= 2014 AND gr.grade_category = 'Q' THEN 'HWQ'
        ELSE gr.grade_category
       END AS finalgradename
      ,gr.credittype
      ,gr.course_number
      ,cou.course_name            
      ,st.sectionid
      ,st.teacher_name
      ,NULL AS excludefromgpa
      ,NULL AS credit_hours
      ,NULL AS term_gpa_points      
      ,gr.grade_category_pct AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,gr.grade_category_pct_y1 AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter            
      ,NULL AS y1_gpa_points
      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90

      ,st.SECTION_NUMBER       
      ,st.period
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.time_per_name = gr.reporting_term 
LEFT OUTER JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.year = st.year
 AND gr.course_number = st.COURSE_NUMBER
 AND st.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON gr.COURSE_NUMBER = cou.COURSE_NUMBER
WHERE co.rn = 1
  AND co.school_level IN ('MS','HS')
  --AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 

/* Y1 grades as additional term */
UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.enroll_status
      ,co.year
      ,co.spedlep
      ,'Y1' AS term
      
      ,gr.is_curterm
      ,'Y1' AS finalgradename      
      ,gr.credittype
      ,gr.course_number
      ,gr.course_name      
      ,st.sectionid
      ,st.teacher_name
      ,gr.excludefromgpa
      ,gr.credit_hours
      ,gr.y1_gpa_points AS term_gpa_points
      ,gr.y1_grade_percent_adjusted AS term_grade_percent_adjusted
      ,gr.y1_grade_letter AS term_grade_letter_adjusted
      ,gr.y1_grade_percent_adjusted
      ,gr.y1_grade_letter           
      ,gr.y1_gpa_points
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_65 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_65
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_70 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_70
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_80 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_80
      ,MAX(CASE WHEN gr.is_curterm = 1 THEN gr.need_90 ELSE NULL END) OVER(PARTITION BY co.student_number, co.year, gr.course_number) AS need_90
      
      ,st.SECTION_NUMBER       
      ,st.period
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
JOIN KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.alt_name = gr.term
 AND gr.is_curterm = 1
LEFT OUTER JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.year = st.year
 AND gr.course_number = st.COURSE_NUMBER
 AND st.rn = 1
WHERE co.rn = 1
  AND co.school_level IN ('MS','HS')  

UNION ALL

/* Transfer grades */
SELECT s.student_number
      ,s.lastfirst
      ,s.schoolid
      ,s.grade_level
      ,s.team
      ,cs.advisor
      ,s.enroll_status
      ,gr.academic_year AS year
      ,cs.spedlep
      ,'Y1' AS term
      
      ,1 AS is_curterm
      ,'Y1' AS finalgradename      
      ,'TRANSFER' AS credittype
      ,CONCAT(gr.course_number, gr.bini_id) AS course_number
      ,gr.course_name      
      ,gr.sectionid
      ,'TRANSFER' AS teacher_name
      ,gr.excludefromgpa
      ,gr.POTENTIALCRHRS AS credit_hours
      ,gr.GPA_POINTS AS term_gpa_points
      ,gr.PCT AS term_grade_percent_adjusted
      ,gr.GRADE AS term_grade_letter_adjusted
      ,gr.PCT AS y1_grade_percent_adjusted
      ,gr.GRADE AS y1_grade_letter           
      ,gr.GPA_POINTS AS y1_gpa_points
      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
      
      ,'TRANSFER' AS SECTION_NUMBER       
      ,NULL AS period
FROM KIPP_NJ..GRADES$STOREDGRADES#static gr WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON gr.STUDENTID = s.ID 
 AND gr.SCHOOLID = s.SCHOOLID
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
WHERE gr.STORECODE = 'Y1'
  AND gr.COURSE_NUMBER = 'TRANSFER'
  
UNION ALL

SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.enroll_status
      ,co.year
      ,co.spedlep
      ,'Y1' AS term
      
      ,gr.is_curterm
      ,CONCAT(CASE 
               WHEN co.schoolid != 73253 AND gr.grade_category = 'E' THEN 'HWQ'
               WHEN co.schoolid != 73253 AND co.year <= 2014 AND gr.grade_category = 'Q' THEN 'HWQ'
               ELSE gr.grade_category
              END
             ,'Y1') AS finalgradename
      ,gr.credittype
      ,gr.course_number
      ,cou.course_name            
      ,st.sectionid
      ,st.teacher_name
      ,NULL AS excludefromgpa
      ,NULL AS credit_hours
      ,NULL AS term_gpa_points      
      ,gr.grade_category_pct_y1 AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,gr.grade_category_pct_y1 AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter            
      ,NULL AS y1_gpa_points
      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90

      ,st.SECTION_NUMBER       
      ,st.period
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
JOIN KIPP_NJ..GRADES$category_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.time_per_name = gr.reporting_term
 AND gr.is_curterm = 1 
LEFT OUTER JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.year = st.year
 AND gr.course_number = st.COURSE_NUMBER
 AND st.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON gr.COURSE_NUMBER = cou.COURSE_NUMBER
WHERE co.rn = 1
  AND co.school_level IN ('MS','HS')
  --AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 

UNION ALL

/* NCA exam grades */
SELECT co.student_number
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,co.enroll_status
      ,co.year
      ,co.spedlep
      ,CASE 
        WHEN gr.e1 IS NOT NULL THEN 'Q2' 
        WHEN gr.e2 IS NOT NULL THEN 'Q4'
       END AS term
      
      ,gr.is_curterm
      ,'E' AS finalgradename 
      ,gr.credittype
      ,gr.course_number
      ,gr.course_name      
      ,st.sectionid
      ,st.teacher_name
      ,gr.excludefromgpa
      ,gr.credit_hours
      ,NULL AS term_gpa_points
      ,COALESCE(gr.e1, gr.e2) AS term_grade_percent_adjusted
      ,NULL AS term_grade_letter_adjusted
      ,NULL AS y1_grade_percent_adjusted
      ,NULL AS y1_grade_letter           
      ,NULL AS y1_gpa_points
      ,NULL AS need_65
      ,NULL AS need_70
      ,NULL AS need_80
      ,NULL AS need_90
      
      ,st.SECTION_NUMBER       
      ,st.period
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
JOIN KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
 AND co.year = gr.academic_year
 AND dt.alt_name = gr.term
 AND (gr.e1 IS NOT NULL OR gr.e2 IS NOT NULL)
LEFT OUTER JOIN section_teacher st
  ON co.studentid = st.studentid
 AND co.year = st.year
 AND gr.course_number = st.COURSE_NUMBER
 AND st.rn = 1
WHERE co.rn = 1
  AND co.schoolid = 73253
  --AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 

--UNION ALL

--SELECT a.student_number
--      ,s.lastfirst
--      ,a.schoolid
--      ,a.grade_level
--      ,a.team
--      ,a.advisor
--      ,a.enroll_status
--      ,a.year
--      ,a.spedlep
--      ,a.term
--      ,a.is_curterm
--      ,a.finalgradename
--      ,a.credittype
--      ,a.course_number
--      ,a.course_name
--      ,a.sectionid
--      ,a.teacher_name
--      ,a.excludefromgpa
--      ,a.credit_hours
--      ,a.term_gpa_points
--      ,a.term_grade_percent_adjusted
--      ,a.term_grade_letter_adjusted
--      ,a.y1_grade_percent_adjusted
--      ,a.y1_grade_letter
--      ,a.y1_gpa_points
--      ,a.need_65
--      ,a.need_70
--      ,a.need_80
--      ,a.need_90
--      ,a.SECTION_NUMBER
--      ,a.period
--FROM KIPP_NJ..TABLEAU$gradebook_dashboard#archive a WITH(NOLOCK)
--JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
--  ON a.student_number = s.STUDENT_NUMBER