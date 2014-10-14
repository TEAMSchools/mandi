USE KIPP_NJ
GO

--ALTER VIEW TABLEAU$writing_summary_assessments AS

SELECT co.year
      ,co.SCHOOLID
      ,co.grade_level      
      ,co.STUDENT_NUMBER
      ,co.lastfirst      
      ,a.repository_id
      ,a.title
      ,a.scope
      ,a.subject      
      ,a.date_administered
      ,f.label AS field_label
      ,res.value AS field_value
FROM COHORT$comprehensive_long#static co WITH(NOLOCK) 
JOIN ILLUMINATE$summary_assessments#static a WITH(NOLOCK)
  ON co.year = dbo.fn_DateToSY(a.date_administered)
 AND co.schoolid = a.SCHOOLID
 AND co.grade_level = a.GRADE_LEVEL
 AND a.subject = 'Writing'
LEFT OUTER JOIN ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
  ON co.student_number = res.student_id
 AND a.repository_id = res.repository_id
JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
  ON res.repository_id = f.repository_id
 AND res.field = f.name
WHERE co.year >= 2013
  AND co.rn = 1