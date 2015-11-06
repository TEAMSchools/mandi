USE KIPP_NJ
GO

ALTER VIEW QA$report_card_comment_audit AS

WITH tests AS (
  SELECT a.repository_id      
        ,a.title        
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)    
  WHERE a.repository_id = 46
    --AND a.scope = 'Reporting' 
    --AND a.subject_area = 'Comments'    
    --AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )
 
,tests_long AS (
  SELECT a.repository_id                
        ,a.title
        ,f.label
        ,f.name AS field_name
  FROM tests a
  JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON a.repository_id = f.repository_id     
 )

,terms AS (
  SELECT t.repository_id        
        ,res.student_id AS student_number
        ,res.repository_row_id
        ,res.value AS term
  FROM tests_long t
  JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
    ON t.repository_id = res.repository_id
   AND t.field_name = res.field
  WHERE t.label = 'term'
)

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,dt.alt_name AS term            
      --,l.label AS comment_field
      ,LEFT(l.label, (CHARINDEX(' ', l.label) - 1)) AS subject_area
      ,RIGHT(l.label, 1) AS comment_number
      ,res.value AS comment_text
      --,l.repository_id
      --,l.field_name      
      --,t.repository_row_id
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'
JOIN tests_long l
  ON l.label != 'Term'
LEFT OUTER JOIN terms t
  ON co.student_number = t.student_number 
 AND dt.alt_name = t.term
 AND l.repository_id = t.repository_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
  ON co.student_number = res.student_id
 AND l.repository_id = res.repository_id
 AND l.field_name = res.field
 AND t.repository_row_id = res.repository_row_id
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND (co.grade_level <= 4 AND co.schoolid != 73252)