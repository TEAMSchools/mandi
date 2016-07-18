USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card_comments#ES AS

WITH tests_long AS (
  SELECT a.repository_id                
        ,a.title
        ,f.label
        ,f.name AS field_name
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON a.repository_id = f.repository_id     
  WHERE a.repository_id = 46
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
      ,t.term            
      ,comm.subject
      ,RIGHT(l.label,1) AS comment_number
      ,comm.comment
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN tests_long l
  ON l.label != 'Term'
JOIN terms t
  ON co.student_number = t.student_number  
 AND l.repository_id = t.repository_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
  ON co.student_number = res.student_id
 AND l.repository_id = res.repository_id
 AND l.field_name = res.field
 AND t.repository_row_id = res.repository_row_id
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_RC_comment_bank comm WITH(NOLOCK)
  ON CONVERT(INT,CONVERT(FLOAT,res.value)) = comm.code
 AND LEFT(l.label, (CHARINDEX(' ', l.label) - 1)) = comm.subject
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND (co.grade_level <= 4 AND co.schoolid != 73252)