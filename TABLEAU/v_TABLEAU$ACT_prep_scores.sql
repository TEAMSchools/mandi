USE KIPP_NJ
GO

ALTER VIEW TABLEAU$ACT_prep_scores AS

SELECT co.year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.SPEDLEP
      ,co.enroll_status
      ,act.administration_round
      ,act.subject_area
      ,act.overall_number_correct
      ,act.scale_score
      ,act.overall_performance_band
      ,REPLACE(act.standard_code,'ACCRS.','') AS standard_code
      ,act.standard_description
      ,act.standard_percent_correct
      ,act.rn_dupe
      ,enr.CREDITTYPE AS course_subject
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.teacher_name
      ,enr.period
      ,ROW_NUMBER() OVER(
         PARTITION BY act.student_number, act.academic_year, act.administration_round, act.standard_code
           ORDER BY act.student_number) AS rn_course
FROM KIPP_NJ..ACT$test_prep_scores act WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON act.student_number = co.student_number
 AND act.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON act.student_number = enr.student_number
 AND act.academic_year = enr.academic_year
 AND CASE
      WHEN act.subject_area IN ('English','Reading') THEN 'ENG'
      WHEN act.subject_area IN ('Mathematics') THEN 'MATH'
      WHEN act.subject_area IN ('Science') THEN 'SCI'
     END = enr.CREDITTYPE
 AND enr.drop_flags = 0
 AND enr.course_number != 'ENG05'