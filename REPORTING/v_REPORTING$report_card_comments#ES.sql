USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card_comments#ES AS

WITH valid_assessments AS (
  SELECT repository_id
  FROM ILLUMINATE$summary_assessments#static WITH(NOLOCK)
  WHERE scope = 'Reporting'
    AND subject = 'Comments'
 )

SELECT student_number
      ,repository_row_id
      ,[Year_comment] AS academic_year
      ,[Term_comment] AS term
      ,[Attendance_comment]
      ,[Achievement_comment]
      ,[ELA_comment]
      ,[Humanities_comment]
      ,[Math_comment]
      ,[PerformingArts_comment]
      ,[Science_comment]
      ,[SocialSkills_comment]
      ,[Spanish_comment]      
      ,[VisualArts_comment]
      ,[Writing_comment]      
FROM 
    (
     SELECT repo.student_id AS student_number
           ,repo.repository_row_id      
           ,CASE 
             WHEN fields.label = 'Humanities (SSSL, Social Studies)' THEN 'Humanities_comment'
             ELSE REPLACE(fields.label,' ','') + '_comment'
            END AS field
           ,repo.value
     FROM ILLUMINATE$summary_assessment_results_long#static repo WITH(NOLOCK)
     JOIN ILLUMINATE$repository_fields fields WITH(NOLOCK)
       ON repo.repository_id = fields.repository_id
      AND repo.field = fields.name 
     WHERE repo.repository_id IN (SELECT repository_id FROM valid_assessments WITH(NOLOCK))
    ) sub

PIVOT(
  MAX(value)
  FOR field IN ([Achievement_comment]
               ,[Attendance_comment]
               ,[ELA_comment]
               ,[Humanities_comment]
               ,[Math_comment]
               ,[PerformingArts_comment]
               ,[Science_comment]
               ,[SocialSkills_comment]
               ,[Spanish_comment]
               ,[Term_comment]
               ,[VisualArts_comment]
               ,[Writing_comment]
               ,[Year_comment])
 ) p

-- not sure if I need to do it this way instead
--SELECT student_number
--      ,academic_year
--      ,term
--FROM 
--    (
--     SELECT comment.student_number      
--           ,year.value AS academic_year
--           ,term.value AS term
--           ,comment.field AS subject
--           ,comment.value AS comment
--     FROM raw_data comment WITH(NOLOCK)
--     LEFT OUTER JOIN raw_data term WITH(NOLOCK)
--       ON comment.student_number = term.student_number
--      AND comment.repository_row_id = term.repository_row_id
--      AND term.field = 'Term'
--     LEFT OUTER JOIN raw_data year WITH(NOLOCK)
--       ON comment.student_number = year.student_number
--      AND comment.repository_row_id = year.repository_row_id
--      AND year.field = 'Year'
--     WHERE comment.field NOT IN ('Year','Term')
--    ) sub
--PIVOT(
--  MAX(comment)
--  FOR subject IN ()