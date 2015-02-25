USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card_comments#ES AS

WITH valid_assessments AS (
  SELECT DISTINCT repository_id
  FROM KIPP_NJ..ILLUMINATE$summary_assessments#static WITH(NOLOCK)
  WHERE scope = 'Reporting'
    AND subject = 'Comments'
 )

--,specialist_comments AS (
--  SELECT REPLACE(subject, 'Humanities', 'Humanities (SSSL, Social Studies)') AS subject
--        ,code        
--        ,Comment
--        ,dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(comment, 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â') AS comment
--        ,ROW_NUMBER() OVER(
--           PARTITION BY subject, code
--             ORDER BY comment) AS rn
--  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_TA_Specialist_Comments] WITH(NOLOCK)
-- )

SELECT student_number
      ,repository_row_id
      ,[Year_comment] AS academic_year
      ,[Term_comment] AS term      
      ,'ELA: ' + [ELA_comment] AS ela_comment
      ,'Humanities: ' + [Humanities_comment] AS humanities_comment
      ,'Math: ' + [Math_comment] AS math_comment
      ,'Performing Arts: ' + [PerformingArts_comment] AS perfarts_comment
      ,'Science: ' + [Science_comment] AS sci_comment
      ,'Social Skills: ' + [SocialSkills_comment] AS socskills_comment
      ,'Spanish: ' + [Spanish_comment] AS span_comment
      ,'Visual Arts: ' + [VisualArts_comment] AS viz_comment
      ,'Writing: ' + [Writing_comment] AS writing_comment
      ,'Dance: ' + [Dance_comment] AS dance_comment
FROM 
    (
     SELECT repo.student_id AS student_number
           ,repo.repository_row_id           
           ,CASE 
             WHEN fields.label = 'Humanities (SSSL, Social Studies)' THEN 'Humanities_comment'
             ELSE REPLACE(fields.label,' ','') + '_comment'
            END AS field
           ,repo.value
     FROM KIPP_NJ..ILLUMINATE$summary_assessment_results_long#static repo WITH(NOLOCK)
     JOIN KIPP_NJ..ILLUMINATE$repository_fields fields WITH(NOLOCK)
       ON repo.repository_id = fields.repository_id
      AND repo.field = fields.name 
     --LEFT OUTER JOIN specialist_comments spec WITH(NOLOCK)
     --  ON fields.label = spec.subject
     -- AND repo.value = spec.code
     -- AND spec.rn = 1
     WHERE repo.repository_id IN (SELECT repository_id FROM valid_assessments WITH(NOLOCK))
    ) sub
PIVOT(
  MAX(value)
  FOR field IN ([ELA_comment]
               ,[Humanities_comment]
               ,[Math_comment]
               ,[PerformingArts_comment]
               ,[Science_comment]
               ,[SocialSkills_comment]
               ,[Spanish_comment]
               ,[Term_comment]
               ,[VisualArts_comment]
               ,[Writing_comment]
               ,[Dance_comment]
               ,[Year_comment])
 ) p