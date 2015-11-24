USE KIPP_NJ
GO

ALTER VIEW REPORTING$social_skills#ES AS

WITH tests_long AS (
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
        ,f.label
        ,f.name AS field_name
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)    
  JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON a.repository_id = f.repository_id     
  WHERE a.scope = 'Reporting' 
    AND a.subject_area = 'Social Skills'
    AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
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

,skills_long AS (
  SELECT res.student_id AS student_number            
        ,t.term
        ,l.label AS social_skill      
        ,res.value AS score      
  FROM tests_long l       
  JOIN terms t
    ON l.schoolid = t.schoolid   
   AND l.repository_id = t.repository_id
  JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
    ON l.repository_id = res.repository_id
   AND l.field_name = res.field
   AND t.repository_row_id = res.repository_row_id
  WHERE l.label != 'Term'
  
  UNION ALL

  SELECT res.student_id AS student_number                  
        ,t.term                  
        ,l.label AS social_skill      
        ,res.value AS score      
  FROM tests_long l
  JOIN terms t
    ON l.repository_id = t.repository_id
   AND LEFT(l.title, 2) = t.term
  JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
    ON l.repository_id = res.repository_id
   AND l.field_name = res.field
   AND t.repository_row_id = res.repository_row_id  
  WHERE l.label != 'Term'
    AND l.schoolid = 732570 
 )

SELECT co.student_number
      ,dt.alt_name AS term      
      ,soc.social_skill
      ,soc.score
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
 AND dt.alt_name != 'Summer School'
JOIN skills_long soc
  ON co.student_number = soc.student_number
 AND dt.alt_name = soc.term
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND (co.grade_level <= 4 AND co.schoolid != 73252)
  AND co.team NOT LIKE '%Pathways%'
  AND co.rn = 1