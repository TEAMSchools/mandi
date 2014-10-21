USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$writing_scores_long AS

WITH test_roster AS (
  SELECT student_number
        ,repository_id
        ,title
        ,repository_row_id
        ,Year
        ,COALESCE(interim, quarter) AS term
  FROM
      (
       SELECT res.student_id AS student_number
             ,a.repository_id
             ,a.title             
             ,f.label
             ,res.repository_row_id
             ,res.value AS field_value           
       FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)
       JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
         ON a.repository_id = f.repository_id      
        AND f.label IN ('Year','Interim','Quarter')
       JOIN ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
         ON a.repository_id = res.repository_id
        AND f.name = res.field
       WHERE a.title IN ('Writing - Interim - TEAM MS', 'English OE - Quarterly Assessments')
      ) sub
  PIVOT(
    MAX(field_value)
    FOR label IN ([Year],[Interim],[Quarter])
   ) p
 )

,test_data AS (
  SELECT DISTINCT 
         res.student_id AS student_number
        ,a.repository_id
        ,a.title                     
        ,CASE
          WHEN f.label LIKE 'Prompt%' THEN LTRIM(RTRIM(SUBSTRING(f.label, CHARINDEX('-', f.label) + 2, 32)))
          ELSE LTRIM(RTRIM(f.label))
         END AS strand
        ,f.label AS field_name
        ,res.repository_row_id
        ,CONVERT(FLOAT,res.value) AS field_value           
  FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)
  JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
    ON a.repository_id = f.repository_id      
   AND f.label NOT IN ('Year','Interim','Quarter')
  JOIN ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
    ON a.repository_id = res.repository_id
   AND f.name = res.field
  WHERE a.title IN ('Writing - Interim - TEAM MS', 'English OE - Quarterly Assessments')  
 )

SELECT t.student_number
      ,t.repository_id
      ,t.title
      ,t.repository_row_id
      ,LEFT(t.Year, 4) AS academic_year
      ,t.term
      ,res.strand
      ,t.term + '_' + res.strand AS pivot_hash
      ,res.field_name      
      ,res.field_value        
      ,RIGHT(term,1) AS series
FROM test_roster t WITH(NOLOCK)
JOIN test_data res WITH(NOLOCK)
  ON t.repository_row_id = res.repository_row_id  
 AND t.student_number = res.student_number
 AND t.repository_id = res.repository_id   