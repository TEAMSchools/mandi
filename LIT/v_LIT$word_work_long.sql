USE KIPP_NJ
GO

ALTER VIEW LIT$word_work_long AS

SELECT a.academic_year 
      ,a.repository_id      
      ,a.subject_area      
      --,a.title                
      --,CASE
      --  WHEN PATINDEX('% G_ %',a.title) = 0 THEN NULL
      --  ELSE REPLACE(SUBSTRING(a.title, PATINDEX('% G_ %',a.title) + 2, 1), 'K', '0') 
      -- END AS grade_level              
      
      ,CONVERT(INT,SUBSTRING(f.label, CHARINDEX('_', f.label) + 1, 2)) AS listweek_num
      ,SUBSTRING(f.label, CHARINDEX('_', f.label, CHARINDEX('_', f.label) + 1) + 1, LEN(f.label) - CHARINDEX('_', f.label, CHARINDEX('_', f.label) + 1)) AS word
      --,f.name AS field_name
      --,f.label
      
      ,res.student_id AS student_number      
      ,CONVERT(FLOAT,res.value) AS score
      --,res.repository_row_id      
FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)    
JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
  ON a.repository_id = f.repository_id   
JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
  ON a.repository_id = res.repository_id
 AND f.name = res.field
WHERE a.scope = 'Reporting' 
  AND a.subject_area IN ('Word Work','Spelling')
  AND a.academic_year >= 2015 /* 2014 data unusable */