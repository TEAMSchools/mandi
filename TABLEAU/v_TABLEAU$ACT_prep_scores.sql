USE KIPP_NJ
GO

ALTER VIEW TABLEAU$ACT_prep_scores AS

WITH real_tests AS (
  SELECT student_number      
        ,CONCAT(LEFT(DATENAME(MONTH,test_date),3), ' ''', RIGHT(DATEPART(YEAR,test_date),2)) AS administration_round
        ,test_date
        ,CASE WHEN act_subject = 'math' THEN 'Mathematics' ELSE act_subject END AS act_subject
        ,scale_score
  FROM KIPP_NJ..ACT$test_scores WITH(NOLOCK)
  UNPIVOT(
    scale_score
    FOR act_subject IN (english
                       ,math
                       ,reading
                       ,science
                       ,composite)
   ) u
  WHERE rn = 1
 )

SELECT co.year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.SPEDLEP
      ,co.enroll_status
	     ,co.advisor
      
      ,NULL AS course_subject
      ,NULL AS COURSE_NUMBER
      ,NULL AS COURSE_NAME
      ,NULL AS teacher_name
      ,NULL AS period

      ,'PREP' AS ACT_type
      ,act.assessment_id
      ,act.assessment_title      
      ,act.administration_round
      ,act.administered_at AS test_date
      ,act.subject_area
      ,act.overall_percent_correct
      ,act.overall_number_correct
      ,act.scale_score      
      ,act.prev_scale_score
      ,act.pretest_scale_score
      ,act.growth_from_pretest
      ,act.overall_performance_band
      ,act.standard_code
      ,act.standard_description
      ,act.standard_percent_correct      
      ,act.standard_strand      
      ,act.rn_dupe AS rn_assessment /* 1 row per student, per test (overall) */      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.year, act.administration_round, act.subject_area, act.standard_code
           ORDER BY act.student_number) AS rn_assessment_standard /* 1 row per student, per test (by standard) */      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
LEFT OUTER JOIN KIPP_NJ..ACT$test_prep_scores act WITH(NOLOCK)
  ON co.student_number = act.student_number
 AND co.year = act.academic_year 
WHERE co.rn = 1
  AND co.schoolid = 73253
  AND co.grade_level != 99
  AND co.year >= 2015 /* 1st year with ACT prep */  

UNION ALL

SELECT co.year
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.SPEDLEP
      ,co.enroll_status
	     ,co.advisor
      
      ,NULL AS course_subject
      ,NULL AS COURSE_NUMBER
      ,NULL AS COURSE_NAME
      ,NULL AS teacher_name
      ,NULL AS period

      ,'REAL' AS ACT_type
      ,NULL AS assessment_id
      ,NULL AS assessment_title
      ,CONVERT(NVARCHAR,co.cohort) AS administration_round
      ,r.test_date
      ,r.act_subject AS subject_area
      ,NULL AS overall_percent_correct
      ,NULL AS overall_number_correct
      ,r.scale_score
      ,NULL AS prev_scale_score
      ,NULL AS pretest_scale_score
      ,NULL AS growth_from_pretest
      ,NULL AS overall_performance_band
      ,NULL AS standard_code
      ,NULL AS standard_description
      ,NULL AS standard_percent_correct      
      ,NULL AS standard_strand
      
      ,1 AS rn_assessment
      ,1 AS rn_assessment_standard
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
JOIN real_tests r
  ON co.student_number = r.student_number
WHERE co.rn = 1
  AND co.schoolid = 73253
  AND co.all_years_rn = 1