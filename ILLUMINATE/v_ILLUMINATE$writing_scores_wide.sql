USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$writing_scores_wide AS

SELECT student_number
      ,writing_header
      ,Expository_Content
      ,Expository_Language
      ,Narrative_Narrative
FROM
    (
     SELECT student_number
           ,composition_type_rubric
           ,MAX(writing_header) AS writing_header
           ,KIPP_NJ.dbo.GROUP_CONCAT_DS(std_score, CHAR(10), 1) AS std_score_grouped
     FROM
         (
          SELECT student_number      
                ,CONCAT(composition_type, '_', rubric_type) AS composition_type_rubric           
                ,CONCAT(REPLICATE(' ', MAX(len_standard_description) OVER(PARTITION BY student_number))
                       ,REPLICATE(CHAR(9), 2)
                       ,'Q1', CHAR(9)
                       ,'Q2', CHAR(9)
                       ,'Q3', CHAR(9)
                       ,'Q4') AS writing_header
                ,CONCAT(standard_description
                       ,REPLICATE(' ', MAX(len_standard_description) OVER(PARTITION BY student_number) - LEN(CONVERT(VARCHAR(MAX),standard_description)))
                       ,REPLICATE(CHAR(9), 2)
                       ,[M1], CHAR(9)
                       ,[M2], CHAR(9)
                       ,[M3], CHAR(9)
                       ,[M4]) AS std_score
          FROM
              (
               SELECT CASE WHEN PATINDEX('%M[0-9]%', a.title) = 0 THEN NULL ELSE SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title), 2) END AS module_num
                     ,CASE
                       WHEN a.title LIKE '%Informative/Expository%' THEN 'Expository'
                       WHEN a.title LIKE '%Narrative%' THEN 'Narrative'
                      END AS composition_type
                     ,CASE
                       WHEN a.title LIKE '%Language' THEN 'Language'
                       WHEN a.title LIKE '%Content' THEN 'Content'
                       ELSE 'Narrative'
                      END AS rubric_type      
                     ,res.local_student_id AS student_number
                     ,LEN(CONVERT(VARCHAR(MAX),std.description)) AS len_standard_description
                     ,CONVERT(VARCHAR(MAX),std.description) AS standard_description            
                     ,CASE WHEN res.answered = 0 THEN NULL ELSE res.points END AS points      
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
            MAX(points)
            FOR module_num IN ([M1],[M2],[M3],[M4])
           ) p
         ) sub
     GROUP BY student_number
             ,composition_type_rubric
    ) sub
PIVOT(
  MAX(std_score_grouped)
  FOR composition_type_rubric IN ([Expository_Content]
                                 ,[Expository_Language]
                                 ,[Narrative_Narrative])
 ) p