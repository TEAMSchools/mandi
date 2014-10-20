USE KIPP_NJ
GO

ALTER VIEW TABLEAU$sight_words_tracker AS

WITH valid_tests AS (
  SELECT DISTINCT a.repository_id        
  FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)    
  WHERE a.scope = 'Reporting' 
    AND a.subject = 'Word Work'
 )

SELECT res.student_id AS student_number             
      ,s.SCHOOLID
      ,s.LASTFIRST
      ,s.GRADE_LEVEL
      ,s.TEAM
      ,cs.SPEDLEP
      ,CONVERT(INT,SUBSTRING(label, CHARINDEX('_',label) + 1, 2)) AS list_num
      ,REVERSE(LEFT(REVERSE(label),CHARINDEX('_', REVERSE(label)) - 1)) AS word
      ,CASE WHEN value = 9 THEN NULL ELSE CONVERT(FLOAT,value) END AS value        
FROM ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
LEFT OUTER JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
  ON res.repository_id = f.repository_id 
 AND res.field = f.name
 AND f.rn = 1
JOIN STUDENTS s WITH(NOLOCK)
  ON res.student_id = s.STUDENT_NUMBER
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.STUDENTID
WHERE res.repository_id IN (SELECT repository_id FROM valid_tests WITH(NOLOCK))