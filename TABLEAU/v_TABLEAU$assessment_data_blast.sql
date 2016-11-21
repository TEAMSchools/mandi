USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_data_blast AS

SELECT co.reporting_schoolid AS schoolid
      ,co.year AS academic_year
      ,co.grade_level
      ,co.team      
      ,co.student_number
      ,co.lastfirst
      ,co.spedlep  
      ,co.enroll_status               

      ,dt.alt_name AS term

      ,a.assessment_id
      ,a.title
      ,a.scope            
      ,a.subject_area AS subject      
      ,a.administered_at
      ,0 AS is_replacement
      
      ,ovr.date_taken
      ,CASE 
        WHEN a.scope = 'CMA - End of Module' AND a.subject_area IN ('Text Study','Social Studies') AND mc.percent_correct IS NOT NULL THEN (ovr.percent_correct * 0.6 * 2) /* weighted SR EOM */
        WHEN a.scope = 'CMA - End of Module' AND a.subject_area IN ('Text Study','Social Studies') AND oer.percent_correct IS NOT NULL THEN (ovr.percent_correct * 0.4 * 2) /* weighted OER EOM */
        ELSE ovr.percent_correct 
       END AS overall_pct_correct            

      ,std.custom_code AS standards_tested      
      ,std.description AS standard_descr      

      ,res.percent_correct AS std_percent_correct
      ,res.mastered AS std_is_mastered
      ,res.performance_band_level AS proficiency_band

      ,mc.percent_correct AS mc_percent_correct
      ,oer.percent_correct AS oer_percent_correct
            
      ,enr.teacher_name      
      ,enr.period
      ,enr.section_number           
      
      ,goal.goal AS individualized_mastery_goal

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, a.assessment_id
           ORDER BY co.student_number) AS overall_rn      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  ON co.year = a.academic_year 
 AND a.scope IN ('CMA - End-of-Module','CMA - Mid-Module','CMA - Checkpoint 1','CMA - Checkpoint 2')
 AND a.subject_area IN ('Text Study','Mathematics','Science','Social Studies') 
 AND CHARINDEX(REPLACE(co.grade_level, 0, 'K'), a.tags) > 0 /* match on grade level */
 AND a.title NOT LIKE '%SPED%' /* exclude modified */
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 /* ES and BOLD, JOIN to HR, otherwise JOIN to course */
 AND (((co.grade_level <= 4 OR co.schoolid = 73258) AND enr.COURSE_NUMBER = 'HR') 
          OR (co.schoolid != 73258 AND co.grade_level >= 5 AND a.subject_area = enr.illuminate_subject))
 AND enr.drop_flags = 0 
 AND enr.rn_subject = 1
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
  ON astd.standard_id = std.standard_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON co.student_number = ovr.local_student_id
 AND a.assessment_id = ovr.assessment_id  
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND a.administered_at BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
  ON co.student_number = res.local_student_id
 AND a.assessment_id = res.assessment_id
 AND astd.standard_id = res.standard_id       
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static mc WITH(NOLOCK)
  ON co.student_number = mc.local_student_id
 AND a.assessment_id = mc.assessment_id
 AND mc.reporting_group = 'Multiple Choice'
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static oer WITH(NOLOCK)
  ON co.student_number = oer.local_student_id
 AND a.assessment_id = oer.assessment_id
 AND oer.reporting_group = 'Open-Ended Response'
LEFT OUTER JOIN KIPP_NJ..SPED$individual_mastery_goals#static goal WITH(NOLOCK)
  ON co.student_number = goal.student_number
 AND co.year = goal.academic_year
 AND a.subject_area = goal.subject_area
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.enroll_status = 0  
  AND co.rn = 1       
  AND co.reporting_schoolid != 5173 /* exclude OoD Placements */
    
UNION ALL

/* modified and replacements */
SELECT co.reporting_schoolid AS schoolid
      ,co.year AS academic_year
      ,co.grade_level
      ,co.team      
      ,co.student_number
      ,co.lastfirst
      ,co.spedlep  
      ,co.enroll_status               

      ,dt.alt_name AS term

      ,a.assessment_id
      ,a.title
      ,a.scope            
      ,a.subject_area AS subject      
      ,a.administered_at
      ,CASE WHEN CHARINDEX(REPLACE(co.grade_level, 0, 'K'), a.tags) = 0 THEN 1 ELSE 0 END AS is_replacement
      
      ,ovr.date_taken
      ,CASE 
        WHEN a.scope = 'CMA - End of Module' AND a.subject_area IN ('Text Study','Social Studies') AND mc.percent_correct IS NOT NULL THEN (ovr.percent_correct * 0.6 * 2) /* weighted SR EOM */
        WHEN a.scope = 'CMA - End of Module' AND a.subject_area IN ('Text Study','Social Studies') AND oer.percent_correct IS NOT NULL THEN (ovr.percent_correct * 0.4 * 2) /* weighted OER EOM */
        ELSE ovr.percent_correct 
       END AS overall_pct_correct            

      ,std.custom_code AS standards_tested      
      ,std.description AS standard_descr      

      ,res.percent_correct AS std_percent_correct
      ,res.mastered AS std_is_mastered
      ,res.performance_band_level AS proficiency_band

      ,mc.percent_correct AS mc_percent_correct
      ,oer.percent_correct AS oer_percent_correct
            
      ,enr.teacher_name      
      ,enr.period
      ,enr.section_number           
      
      ,goal.goal AS individualized_mastery_goal

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, a.assessment_id
           ORDER BY co.student_number) AS overall_rn      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON co.student_number = ovr.local_student_id 
JOIN KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  ON ovr.assessment_id = a.assessment_id 
 AND a.scope IN ('CMA - End-of-Module','CMA - Mid-Module','CMA - Checkpoint 1','CMA - Checkpoint 2')
 AND a.subject_area IN ('Text Study','Mathematics','Science','Social Studies')  
 AND (a.title LIKE '%SPED%' OR CHARINDEX(REPLACE(co.grade_level, 0, 'K'), a.tags) = 0)
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 /* ES and BOLD, JOIN to HR, otherwise JOIN to course */
 AND (((co.grade_level <= 4 OR co.schoolid = 73258) AND enr.COURSE_NUMBER = 'HR') 
          OR (co.schoolid != 73258 AND co.grade_level >= 5 AND a.subject_area = enr.illuminate_subject))
 AND enr.drop_flags = 0 
 AND enr.rn_subject = 1
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
  ON astd.standard_id = std.standard_id
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND a.administered_at BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
  ON co.student_number = res.local_student_id
 AND a.assessment_id = res.assessment_id
 AND astd.standard_id = res.standard_id       
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static mc WITH(NOLOCK)
  ON co.student_number = mc.local_student_id
 AND a.assessment_id = mc.assessment_id
 AND mc.reporting_group = 'Multiple Choice'
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static oer WITH(NOLOCK)
  ON co.student_number = oer.local_student_id
 AND a.assessment_id = oer.assessment_id
 AND oer.reporting_group = 'Open-Ended Response'
LEFT OUTER JOIN KIPP_NJ..SPED$individual_mastery_goals#static goal WITH(NOLOCK)
  ON co.student_number = goal.student_number
 AND co.year = goal.academic_year
 AND a.subject_area = goal.subject_area
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.enroll_status = 0  
  AND co.rn = 1       
  AND co.reporting_schoolid != 5173 /* exclude OoD Placements */

UNION ALL

SELECT co.reporting_schoolid AS schoolid
      ,co.year AS academic_year
      ,co.grade_level
      ,co.team      
      ,co.student_number
      ,co.lastfirst
      ,co.spedlep  
      ,co.enroll_status               

      ,dt.alt_name AS term

      ,a.assessment_id
      ,a.title
      ,a.scope            
      ,a.subject_area AS subject      
      ,a.administered_at
      ,0 AS is_replacement
      
      ,ovr.date_taken
      ,ovr.percent_correct AS overall_pct_correct            

      ,std.custom_code AS standards_tested      
      ,std.description AS standard_descr      

      ,res.percent_correct AS std_percent_correct
      ,res.mastered AS std_is_mastered
      ,res.performance_band_level AS proficiency_band

      ,mc.percent_correct AS mc_percent_correct
      ,oer.percent_correct AS oer_percent_correct
            
      ,enr.teacher_name      
      ,enr.period
      ,enr.section_number
      
      ,goal.goal AS individualized_mastery_goal

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, a.assessment_id
           ORDER BY co.student_number) AS overall_rn      
FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON a.assessment_id = ovr.assessment_id  
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK) 
  ON ovr.local_student_id = co.student_number
 AND a.academic_year = co.year             
 AND co.rn = 1
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND ovr.date_taken BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
  ON astd.standard_id = std.standard_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
  ON ovr.local_student_id = res.local_student_id
 AND a.assessment_id = res.assessment_id
 AND astd.standard_id = res.standard_id  
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static mc WITH(NOLOCK)
  ON co.student_number = mc.local_student_id
 AND a.assessment_id = mc.assessment_id
 AND mc.reporting_group = 'Multiple Choice'
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static oer WITH(NOLOCK)
  ON co.student_number = oer.local_student_id
 AND a.assessment_id = oer.assessment_id
 AND oer.reporting_group = 'Open-Ended Response'
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 /* ES and BOLD, JOIN to HR, otherwise JOIN to course */
 AND (((co.grade_level <= 4 OR co.schoolid = 73258) AND enr.COURSE_NUMBER = 'HR') 
          OR (co.schoolid != 73258 AND co.grade_level >= 5 AND a.subject_area = enr.illuminate_subject))
 AND enr.drop_flags = 0     
 AND enr.rn_subject = 1
LEFT OUTER JOIN KIPP_NJ..SPED$individual_mastery_goals#static goal WITH(NOLOCK)
  ON co.student_number = goal.student_number
 AND co.year = goal.academic_year
 AND a.subject_area = goal.subject_area
WHERE a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND (a.scope NOT IN ('CMA - End-of-Module','CMA - Mid-Module','CMA - Checkpoint 1','CMA - Checkpoint 2') OR a.scope IS NULL)
  AND co.reporting_schoolid != 5173 /* exclude OoD Placements */

UNION ALL

SELECT a.schoolid
      ,a.academic_year
      ,a.grade_level
      ,a.team
      ,a.student_number
      ,a.lastfirst
      ,a.spedlep
      ,a.enroll_status
      ,a.term
      ,a.assessment_id
      ,a.title
      ,a.scope
      ,a.subject
      ,a.administered_at
      ,a.is_replacement
      ,a.date_taken
      ,a.overall_pct_correct
      ,a.standards_tested
      ,a.standard_descr
      ,a.std_percent_correct
      ,a.std_is_mastered
      ,a.proficiency_band
      ,a.mc_percent_correct
      ,a.oer_percent_correct
      ,a.teacher_name
      ,a.period
      ,a.section_number
      ,NULL AS individualized_mastery_goal
      ,a.overall_rn
FROM KIPP_NJ..TABLEAU$assessment_dashboard#archive a WITH(NOLOCK)

/*
/* power law */
--SELECT sub.*
--      ,LOG(std_assessment_order) AS powerlaw_x -- ln of ordinal number
--      ,LOG(proficiency_band) AS powerlaw_y -- ln of score
--      ,LOG(proficiency_band) * LOG(std_assessment_order) AS powerlaw_xy -- ln(score) * ln(order)
--      ,POWER(LOG(std_assessment_order), 2) AS powerlaw_x2 -- ln(order)^2

--      ,SUM(LOG(std_assessment_order)) OVER(PARTITION BY sub.student_number, sub.standards_tested ORDER BY sub.date_taken) AS running_powerlaw_x -- ln of ordinal number
--      ,SUM(LOG(proficiency_band)) OVER(PARTITION BY sub.student_number, sub.standards_tested ORDER BY sub.date_taken) AS running_powerlaw_y -- ln of score
--      ,SUM(LOG(proficiency_band) * LOG(std_assessment_order)) OVER(PARTITION BY sub.student_number, sub.standards_tested ORDER BY sub.date_taken) AS running_powerlaw_xy -- ln(score) * ln(order)
--      ,SUM(POWER(LOG(std_assessment_order), 2)) OVER(PARTITION BY sub.student_number, sub.standards_tested ORDER BY sub.date_taken) AS running_powerlaw_x2 -- ln(order)^2
--FROM
--    (
--    ) sub
*/