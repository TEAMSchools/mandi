USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$CMA_scores_wide AS

WITH assessments AS (
  SELECT academic_year
        ,assessment_id
        ,subject_area
        ,short_title
        ,grade_level
        ,MIN(rn) OVER(PARTITION BY academic_year, grade_level, subject_area, short_title) AS rn
  FROM
      (
       SELECT a.academic_year
             ,a.assessment_id        
             ,CASE
               WHEN a.subject_area IN ('English','Comprehension','Text Study') THEN 'ELA'
               WHEN a.subject_area IN ('Mathematics') THEN 'MATH'
              END AS subject_area             
             ,CASE
               WHEN title LIKE '%Checkpoint%' THEN CONCAT('CHK',RIGHT(title, 1))
               ELSE CONCAT('MOD',SUBSTRING(title, PATINDEX('%M[0-9]%',title) + 1, 1))
              END AS short_title
             ,REPLACE(SUBSTRING(title, PATINDEX('%G[0-9]%',title) + 1, 1),'K',0) AS grade_level             
             ,ROW_NUMBER() OVER(
                PARTITION BY a.subject_area, REPLACE(SUBSTRING(title, PATINDEX('% G_ %',title) + 2, 1),'K',0) /* temp fix until tags are correct*/
                  ORDER BY a.administered_at) AS rn
       FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)       
       WHERE a.scope IN ('Common Module Assessment')    
         AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()            
      ) sub
 )

,extern AS (
  SELECT a.academic_year        
        ,a.subject_area
        ,a.short_title      
        ,a.rn
        ,ovr.local_student_id AS student_number
        ,ROUND(AVG(CONVERT(FLOAT,ovr.percent_correct)),0) AS percent_correct                                
  FROM assessments a    
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
    ON a.assessment_id = ovr.assessment_id   
  GROUP BY a.academic_year          
          ,a.subject_area
          ,a.short_title      
          ,a.rn
          ,ovr.local_student_id
 )

,grouped AS (
  SELECT academic_year
        ,student_number
        ,subject_area
        ,x2.short_title
        ,y2.percent_correct
        --,y.short_title
  FROM extern
  CROSS APPLY (
               SELECT CONCAT(short_title,CHAR(9)) AS short_title                   
               FROM extern intern WITH(NOLOCK)           
               WHERE extern.student_number = intern.student_number
                 AND extern.academic_year = intern.academic_year
                 AND extern.subject_area = intern.subject_area
               ORDER BY rn
               FOR XML PATH(''), TYPE
              ) x1 (short_title)
  CROSS APPLY (
               SELECT x1.short_title.value('.', 'NVARCHAR(MAX)')
              ) x2 (short_title)
  CROSS APPLY (
               SELECT CONCAT(percent_correct,CHAR(9)) AS percent_correct
               FROM extern intern WITH(NOLOCK)           
               WHERE extern.student_number = intern.student_number
                 AND extern.academic_year = intern.academic_year
                 AND extern.subject_area = intern.subject_area
               ORDER BY rn
               FOR XML PATH(''), TYPE
              ) y1 (percent_correct)
  CROSS APPLY (
               SELECT y1.percent_correct.value('.', 'NVARCHAR(MAX)')
              ) y2 (percent_correct)
 )

SELECT academic_year
      ,student_number
      ,[MATH_short_title]
      ,[MATH_percent_correct]
      ,[ELA_short_title]
      ,[ELA_percent_correct]
FROM
    (
     SELECT academic_year
           ,student_number
           ,CONCAT(subject_area, '_', field) AS pivot_field
           ,value
     FROM grouped
     UNPIVOT(
       value
       FOR field IN (short_title
                    ,percent_correct)
      ) u
 ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([MATH_short_title]
                   ,[MATH_percent_correct]
                   ,[ELA_short_title]
                   ,[ELA_percent_correct])
 ) p