USE KIPP_NJ
GO

ALTER VIEW DL$mod_assessments#extract AS

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
               WHEN PATINDEX('%M[0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]/[0-9]%', a.title) + 1, 3) 
               WHEN PATINDEX('%M[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title) + 1, 1)               
               WHEN PATINDEX('%U[0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%U[0-9]/[0-9]%', a.title) + 1, 3)
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
                            WHEN PATINDEX('%M[0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]/[0-9]%', a.title) + 1, 3) 
                            WHEN PATINDEX('%M[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title) + 1, 1)               
                            WHEN PATINDEX('%U[0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%U[0-9]/[0-9]%', a.title) + 1, 3)
                            WHEN PATINDEX('%U[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%U[0-9]%', a.title) + 1, 1)
                           END) AS rn
       FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)       
       WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module','CMA - Checkpoint 1','CMA - Checkpoint 2')
         AND a.subject_area IN ('Text Study','Mathematics')
         AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
 )

SELECT subject_area
      ,academic_year
      ,module_num
      ,scope
      ,student_number
      ,percent_correct
      ,rn_unit
      ,CASE
        WHEN percent_correct >= 85 THEN 'Above Target'
        WHEN percent_correct >= 70 THEN 'Target'
        WHEN percent_correct >= 50 THEN 'Near Target'
        WHEN percent_correct >= 35 THEN 'Below Target'
        WHEN percent_correct < 35 THEN 'Far Below Target'
       END AS proficiency_label
FROM
    (
     SELECT a.subject_area
           ,a.academic_year
           ,a.module_num
           ,a.scope      
           ,CONVERT(INT,ovr.local_student_id) AS student_number
           ,ROUND(AVG(CONVERT(FLOAT,CASE 
                                     WHEN a.scope = 'CMA - End of Module' AND a.subject_area IN ('Text Study','Social Studies') AND mc.percent_correct IS NOT NULL THEN (ovr.percent_correct * 0.6 * 2) /* weighted SR EOM */
                                     WHEN a.scope = 'CMA - End of Module' AND a.subject_area IN ('Text Study','Social Studies') AND oer.percent_correct IS NOT NULL THEN (ovr.percent_correct * 0.4 * 2) /* weighted OER EOM */
                                     ELSE ovr.percent_correct 
                                    END)),0) AS percent_correct      
           ,MIN(rn_unit) AS rn_unit
     FROM assessments a    
     JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
       ON a.assessment_id = ovr.assessment_id   
      AND ovr.answered > 0
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static mc WITH(NOLOCK)
       ON ovr.local_student_id = mc.local_student_id
      AND a.assessment_id = mc.assessment_id
      AND mc.reporting_group = 'Multiple Choice'
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static oer WITH(NOLOCK)
       ON ovr.local_student_id = oer.local_student_id
      AND a.assessment_id = oer.assessment_id
      AND oer.reporting_group = 'Open-Ended Response'
     GROUP BY a.subject_area
             ,a.academic_year
             ,a.module_num
             ,a.scope        
             ,ovr.local_student_id             
    ) sub