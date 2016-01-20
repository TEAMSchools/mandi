USE KIPP_NJ
GO

ALTER VIEW TABLEAU$ACT_prep_scores AS

WITH act_data AS (
  SELECT act.student_number
        ,act.academic_year
        ,act.administration_round
        ,act.subject_area
        ,CASE
          WHEN act.subject_area IN ('English','Reading') THEN 'ENG'
          WHEN act.subject_area IN ('Mathematics') THEN 'MATH'
          WHEN act.subject_area IN ('Science') THEN 'SCI'
          ELSE act.subject_area
         END AS credittype
        ,act.overall_number_correct
        ,act.scale_score
        ,act.overall_performance_band
        ,REPLACE(act.standard_code,'ACCRS.','') AS standard_code
        ,act.standard_description
        ,act.standard_percent_correct
        --,act.rn_dupe
  FROM KIPP_NJ..ACT$test_prep_scores act WITH(NOLOCK)

  UNION ALL

  SELECT act.student_number
        ,act.academic_year
        ,act.administration_round
        ,act.subject_area
        ,'RHET' AS credittype
        ,act.overall_number_correct
        ,act.scale_score
        ,act.overall_performance_band
        ,REPLACE(act.standard_code,'ACCRS.','') AS standard_code
        ,act.standard_description
        ,act.standard_percent_correct
        --,act.rn_dupe            
  FROM KIPP_NJ..ACT$test_prep_scores act WITH(NOLOCK)
  WHERE act.subject_area IN ('English','Reading')
 )

SELECT co.year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.SPEDLEP
      ,co.enroll_status
      ,enr.CREDITTYPE AS course_subject
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.teacher_name
      ,enr.period

      ,act.administration_round
      ,act.subject_area
      ,act.overall_number_correct
      ,act.scale_score
      ,act.overall_performance_band
      ,act.standard_code
      ,act.standard_description
      ,act.standard_percent_correct      
      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.year, act.administration_round, act.subject_area
           ORDER BY act.student_number) AS rn_assessment /* 1 row per student, per test (overall) */      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.year, act.administration_round, act.subject_area, act.standard_code
           ORDER BY act.student_number) AS rn_assessment_standard /* 1 row per student, per test (by standard) */      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.CREDITTYPE IN ('ENG','MATH','SCI','RHET')
 AND enr.drop_flags = 0
 AND enr.course_number NOT IN ('ENG05')
LEFT OUTER JOIN act_data act WITH(NOLOCK)
  ON co.student_number = act.student_number
 AND co.year = act.academic_year
 AND ((enr.CREDITTYPE = act.credittype) OR (act.credittype = 'Composite'))
WHERE co.rn = 1
  AND co.schoolid = 73253
  AND co.grade_level != 99
  AND co.year >= 2015 /* 1st year with ACT prep */  
