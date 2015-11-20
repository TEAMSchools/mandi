USE KIPP_NJ
GO

ALTER VIEW LIT$word_work_long AS

SELECT a.academic_year 
      ,a.repository_id      
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