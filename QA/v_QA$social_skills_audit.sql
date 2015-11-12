USE KIPP_NJ
GO

ALTER VIEW QA$social_skills_audit AS

WITH tests AS (
  SELECT a.repository_id      
        ,a.title
        ,CASE
          WHEN a.title LIKE '%SPARK%' THEN 73254
          WHEN a.title LIKE '%THRIVE%' THEN 73255
          WHEN a.title LIKE '%Seek%' THEN 73256
          WHEN a.title LIKE '%Life%' THEN 73257
          WHEN a.title LIKE '%Lanning%' THEN 179901          
          WHEN a.title LIKE '%Pathways%' THEN 732570
         END AS schoolid
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)    
  WHERE a.scope = 'Reporting' 
    AND a.subject_area = 'Social Skills'
    AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )
 
,tests_long AS (
  SELECT a.repository_id        
        ,a.schoolid
        ,a.title
        ,f.label
        ,f.name AS field_name
  FROM tests a
  JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON a.repository_id = f.repository_id     
 )

,terms AS (
  SELECT t.repository_id
        ,t.schoolid        
        ,res.student_id AS student_number
        ,res.repository_row_id
        ,CASE WHEN t.title LIKE '%Pathways%' THEN LEFT(t.title, 2) ELSE res.value END AS term
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
      ,l.label AS social_skill      
      ,res.value AS score
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
  ON co.schoolid = l.schoolid
 AND l.label != 'Term'
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
  AND co.team NOT LIKE '%Pathways%'

UNION ALL

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,732570 AS schoolid /* fake Pathways ID */
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,dt.alt_name AS term                  
      ,l.label AS social_skill      
      ,res.value AS score
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
  ON dt.alt_name = LEFT(l.title, 2)
 AND l.schoolid = 732570 
 AND l.label != 'Term'
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
  AND co.team LIKE '%Pathways%'