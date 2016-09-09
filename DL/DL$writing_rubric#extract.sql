USE KIPP_NJ
GO

ALTER VIEW DL$writing_rubric#extract AS

SELECT student_number
      ,academic_year
      ,composition_type
      ,rubric_type
      ,rubric_strand
      ,[M1]
      ,[M2]
      ,[M3]
      ,[M4]
      ,[M5]
FROM
    (
     SELECT res.local_student_id AS student_number                           
           ,a.academic_year
           ,CASE
             WHEN a.title LIKE '%Informative/Expository%' THEN 'Expository'
             WHEN a.title LIKE '%Narrative%' THEN 'Narrative'
            END AS composition_type
           ,CASE
             WHEN a.title LIKE '%Language' THEN 'Language'
             WHEN a.title LIKE '%Content' THEN 'Content'
             ELSE 'Narrative'
            END AS rubric_type      
           ,REPLACE(CONVERT(VARCHAR(MAX),std.description),'"','''') AS rubric_strand
           ,CASE
             WHEN a.title LIKE '%PARCC Simulation%' THEN 'M4'
             WHEN PATINDEX('%M[0-9]%', a.title) = 0 THEN NULL 
             ELSE SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title), 2) 
            END AS module_num
           ,CASE WHEN res.answered = 0 THEN NULL ELSE res.points END AS rubric_score
     FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
     JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
       ON a.assessment_id = astd.assessment_id
     JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
       ON astd.standard_id = std.standard_id
      AND std.custom_code LIKE 'T_S.W.%'
     JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
       ON a.assessment_id = res.assessment_id
      AND astd.standard_id  = res.standard_id
     WHERE a.scope = 'CMA - End-of-Module'
       AND a.subject_area = 'Writing'
       AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
PIVOT(
  MAX(rubric_score)
  FOR module_num IN ([M1]
                    ,[M2]
                    ,[M3]
                    ,[M4]
                    ,[M5])
 ) p