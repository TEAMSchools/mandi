USE KIPP_NJ
GO

ALTER VIEW TABLEAU$PARCC_CMA_correlation AS

WITH parcc AS (
  SELECT local_student_identifier AS student_number
        ,CASE           
          WHEN test_name LIKE '%ELA%' THEN 'Text Study'
          ELSE 'Mathematics'
         END AS test_subject
        ,test_name
        ,performance_level
        ,scale_score
  FROM KIPP_NJ..AUTOLOAD$GDOCS_PARCC_preliminary_data WITH(NOLOCK)
 )

SELECT co.schoolid
      ,co.year AS academic_year
      ,co.grade_level      
      ,co.student_number
      ,co.lastfirst
      ,co.spedlep  
      ,co.enroll_status               

      ,a.assessment_id
      ,a.title
      ,a.scope            
      ,a.subject_area AS subject           
      
      ,ovr.percent_correct AS overall_pct_correct       
      ,ovr.performance_band_level AS cma_proficiency_band

      ,parcc.test_name AS parcc_test_name
      ,parcc.scale_score
      ,parcc.performance_level
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  ON co.year = a.academic_year
 AND CHARINDEX(REPLACE(co.grade_level, 0, 'K'), a.tags) > 0 
 AND a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')
 AND a.subject_area IN ('Text Study','Mathematics')
 AND (a.title NOT LIKE '%replacement%' AND a.title NOT LIKE '%modified%')
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON co.student_number = ovr.local_student_id
 AND a.assessment_id = ovr.assessment_id  
LEFT OUTER JOIN parcc
  ON co.student_number = parcc.student_number
 AND a.subject_area = parcc.test_subject
WHERE co.year = 2015
  AND co.rn = 1       
  --AND co.team NOT LIKE '%Pathways%'