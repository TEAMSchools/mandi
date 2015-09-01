USE KIPP_NJ
GO

ALTER VIEW TABLEAU$sight_words_tracker AS

WITH valid_tests AS (
  SELECT a.repository_id        
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)    
  WHERE a.scope = 'Reporting' 
    AND a.subject_area = 'Word Work'
 )

SELECT res.student_id AS student_number             
      ,s.SCHOOLID
      ,s.LASTFIRST
      ,s.GRADE_LEVEL
      ,s.TEAM
      ,cs.SPEDLEP
      ,CONVERT(INT,SUBSTRING(label, CHARINDEX('_',label) + 1, 2)) AS list_num
      ,REVERSE(LEFT(REVERSE(label),CHARINDEX('_', REVERSE(label)) - 1)) AS word
      ,CASE WHEN CONVERT(FLOAT,value) = 9 THEN NULL ELSE CONVERT(FLOAT,value) END AS value        
FROM KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
  ON res.repository_id = f.repository_id 
 AND res.field = f.name 
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON res.student_id = s.STUDENT_NUMBER
LEFT OUTER JOIN KIPP_NJ..PS$CUSTOM_STUDENTS#static cs WITH(NOLOCK)
  ON s.id = cs.STUDENTID
WHERE res.repository_id IN (SELECT repository_id FROM valid_tests WITH(NOLOCK))