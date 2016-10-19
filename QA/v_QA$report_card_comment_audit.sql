USE KIPP_NJ
GO

ALTER VIEW QA$report_card_comment_audit AS

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
      ,co.studentid
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,dt.alt_name AS term            
      
      --,l.label AS comment_field
      ,LEFT(l.label, (CHARINDEX(' ', l.label) - 1)) AS subject_area
      ,LEFT(l.label, (CHARINDEX(' ', l.label) - 1)) AS course_name
      ,NULL AS teacher_name
      ,RIGHT(l.label, 1) AS comment_number
      ,CASE 
        WHEN CONVERT(INT,CONVERT(FLOAT,res.value)) NOT BETWEEN 1 AND 225 THEN NULL
        WHEN LEFT(l.label, (CHARINDEX(' ', l.label) - 1)) != comm.subject THEN NULL
        ELSE CONVERT(VARCHAR,res.value)
       END AS comment_text
      ,l.repository_id
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
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_RC_comment_bank comm WITH(NOLOCK)
  ON CONVERT(INT,CONVERT(FLOAT,res.value)) = comm.code
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND (co.grade_level <= 4 AND co.schoolid != 73252)
  AND co.enroll_status = 0

UNION ALL

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,scaff.term            
      
      ,cou.credittype AS subject_area
      ,cou.course_name
      ,scaff.teacher_name
      ,1 AS comment_number
      ,comm.teacher_comment AS comment_text
      ,NULL AS repository_id
      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..PS$course_section_scaffold#static scaff WITH(NOLOCK)
  ON co.studentid = scaff.studentid
 AND co.year = scaff.year
LEFT OUTER JOIN KIPP_NJ..PS$comments#static comm WITH(NOLOCK)
  ON co.studentid = comm.studentid
 AND scaff.term = comm.term
 AND scaff.course_number = comm.course_number
LEFT OUTER JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON scaff.course_number = cou.course_number 
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND ((co.grade_level = 4 AND co.schoolid = 73252) OR (co.grade_level >= 5))
  AND co.enroll_status = 0