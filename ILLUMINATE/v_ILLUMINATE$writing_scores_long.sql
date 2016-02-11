USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$writing_scores_long AS

WITH assessments AS (
  SELECT a.repository_id        
        ,a.title
        ,a.scope
        ,a.subject_area              
        ,a.date_administered
        ,a.academic_year
        ,CONCAT('Unit ', RIGHT(a.title,1)) AS unit_number
        ,LTRIM(RTRIM(f.label)) AS field_label
        ,f.name AS field_name        
        ,res.student_id AS student_number             
        ,res.repository_row_id
        ,res.value AS field_value           
        ,d.alt_name AS term        
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)  
  JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON a.repository_id = f.repository_id
  JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
    ON a.repository_id = res.repository_id
   AND f.name = res.field     
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON a.academic_year = d.academic_year
   AND a.date_administered BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'RT'
   AND d.schoolid = 73253
  WHERE ((a.scope = 'Unit Assessment' AND a.subject_area = 'English') OR a.title = 'English OE - Quarterly Assessments')
 )

,test_metadata AS (
  SELECT repository_id        
        ,repository_row_id
        ,LEFT([year],4) AS academic_year                
        ,CASE WHEN academic_year <= 2014 THEN REPLACE([quarter],'QE','Q') ELSE term END AS term
        ,CASE WHEN academic_year <= 2014 THEN [quarter] ELSE unit_number END AS unit_number
        ,CONCAT('ENG',LEFT([course],2)) AS course_number
  FROM
      (
       SELECT a.repository_id             
             ,a.field_label             
             ,a.repository_row_id
             ,a.field_value           
             ,a.academic_year
             ,a.term             
             ,a.unit_number
       FROM assessments a WITH(NOLOCK)                
       WHERE a.field_name IN ('field_interim','field_year')
      ) sub
  PIVOT(
    MAX(field_value)
    FOR field_label IN ([year],[course],[quarter])
   ) p
 )

SELECT a.repository_id
      ,a.title                                      
      ,a.student_number                          
      ,a.repository_row_id
      ,a.field_label             
      ,SUBSTRING(a.field_label, CHARINDEX('-', a.field_label) - 2, 1) AS prompt_number
      ,SUBSTRING(a.field_label, CHARINDEX('-', a.field_label) + 2, LEN(a.field_label)) AS strand
      ,CONVERT(FLOAT,a.field_value) AS field_value
      ,t.term
      ,t.unit_number
      ,RIGHT(t.unit_number,1) AS series
      ,t.academic_year             
      ,t.course_number
FROM assessments a WITH(NOLOCK)                
JOIN test_metadata t WITH(NOLOCK)
  ON a.repository_id = t.repository_id
 AND a.repository_row_id = t.repository_row_id
 AND t.term LIKE 'Q%'
WHERE a.field_name NOT IN ('field_interim','field_year')