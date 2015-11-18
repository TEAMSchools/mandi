USE KIPP_NJ
GO

ALTER VIEW QA$word_work_audit AS

WITH tests_long AS (
  SELECT a.repository_id
        ,a.subject_area
        ,a.title                
        ,CASE
          WHEN PATINDEX('% G_ %',a.title) = 0 THEN NULL
          ELSE REPLACE(SUBSTRING(a.title, PATINDEX('% G_ %',a.title) + 2, 1), 'K', '0') 
         END AS grade_level        
        ,f.name AS field_name
        ,CONCAT('Week_', SUBSTRING(f.label, CHARINDEX('_', f.label) + 1, 2)) AS listweek_num
        ,SUBSTRING(f.label, CHARINDEX('_', f.label, CHARINDEX('_', f.label) + 1) + 1, LEN(f.label) - CHARINDEX('_', f.label, CHARINDEX('_', f.label) + 1)) AS word        
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)    
  JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON a.repository_id = f.repository_id   
  WHERE a.scope = 'Reporting' 
    AND a.subject_area IN ('Word Work','Spelling')
    AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,dt.alt_name AS term
      --,dt.start_date
      --,dt.end_date   
      ,rep.time_per_name
      ,t.repository_id
      ,t.subject_area
      ,t.word
      ,CONVERT(FLOAT,res.value) AS value
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
JOIN KIPP_NJ..REPORTING$dates rep WITH(NOLOCK)
  ON co.schoolid = rep.schoolid 
 AND rep.start_date BETWEEN dt.start_date AND dt.end_date
 AND rep.identifier = 'REP'
JOIN tests_long t WITH(NOLOCK)
  ON co.grade_level = t.grade_level
 AND rep.time_per_name = t.listweek_num
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
  ON co.student_number = res.student_id
 AND t.repository_id = res.repository_id
 AND t.field_name = res.field
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()