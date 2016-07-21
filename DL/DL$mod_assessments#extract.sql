WITH assessments AS (
  SELECT assessment_id
        ,academic_year
        ,subject_area
        ,module_num
        --,title
        ,scope
        ,grade_level_tags      
        ,MIN(rn) OVER(PARTITION BY grade_level_tags, subject_area, module_num) AS rn_unit
  FROM
      (
       SELECT a.assessment_id        
             ,a.academic_year
             ,CASE
               WHEN a.subject_area = 'Text Study' THEN 'ELA'
               WHEN a.subject_area = 'Mathematics' THEN 'MATH'               
              END AS subject_area                 
             ,a.title                           
             ,a.administered_at
             ,CASE 
               WHEN PATINDEX('%M[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title) + 1, 1) 
               WHEN PATINDEX('%U[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%U[0-9]%', a.title) + 1, 1)                  
              END AS module_num
             ,CASE 
               WHEN a.scope = 'CMA - End-of-Module' THEN 'End-of-Module'
               WHEN a.scope = 'CMA - Mid-Module' AND a.title LIKE '%Checkpoint%' THEN CONCAT('Checkpoint ',SUBSTRING(a.title, CHARINDEX('Checkpoint', a.title) + 11, 1))
               WHEN a.scope = 'CMA - Mid-Module' AND a.title NOT LIKE '%Checkpoint%' THEN 'Mid-Module'
              END AS scope
             ,KIPP_NJ.dbo.fn_StripCharacters(tags,'^0-9,K') AS grade_level_tags      
             ,ROW_NUMBER() OVER(
                PARTITION BY a.subject_area, KIPP_NJ.dbo.fn_StripCharacters(tags,'^0-9,K')
                  ORDER BY CASE 
                            WHEN PATINDEX('%M[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title) + 1, 1) 
                            WHEN PATINDEX('%U[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%U[0-9]%', a.title) + 1, 1)                  
                           END) AS rn
       FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)       
       WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')    
         AND a.subject_area IN ('Text Study','Mathematics')
         AND a.academic_year = 2015 --KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
 )

SELECT subject_area
      ,academic_year
      ,module_num
      ,scope
      ,student_number
      ,percent_correct
      ,CASE
        WHEN percent_correct >= 80 THEN 'Exceeded Expectations'
        WHEN percent_correct >= 60 THEN 'Met Expectations'
        WHEN percent_correct >= 50 THEN 'Approached Expectations'
        WHEN percent_correct >= 40 THEN 'Partially Met Expectations'
        WHEN percent_correct < 40 THEN 'Did Not Yet Meet Expectations'
       END AS proficiency_label
FROM
    (
     SELECT a.subject_area
           ,a.academic_year
           ,CONVERT(INT,a.module_num) AS module_num
           ,a.scope      
           ,CONVERT(INT,ovr.local_student_id) AS student_number
           ,ROUND(AVG(CONVERT(FLOAT,ovr.percent_correct)),0) AS percent_correct      
           ,MIN(rn_unit) AS rn_unit
     FROM assessments a    
     JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
       ON a.assessment_id = ovr.assessment_id   
      AND ovr.answered > 0
     GROUP BY a.subject_area
             ,a.academic_year
             ,a.module_num
             ,a.scope        
             ,ovr.local_student_id             
    ) sub
ORDER BY student_number, subject_area, module_num, rn_unit