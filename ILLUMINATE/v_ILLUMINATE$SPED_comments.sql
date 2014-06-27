USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$SPED_comments AS

SELECT CONVERT(INT,student_id) AS student_number
      ,[field_subject] AS subject
      ,[field_comment] AS comment
      ,CONVERT(DATE,[field_date]) AS date
      ,ROW_NUMBER() OVER (
          PARTITION BY student_id, field_subject
              ORDER BY field_date DESC) AS rn
FROM (
      SELECT student_id
            ,repository_row_id
            ,field
            ,value
      FROM ILLUMINATE$summary_assessment_results_long#static WITH(NOLOCK)
      WHERE repository_id = 58
     ) sub

PIVOT(
  MAX(value)
  FOR field IN ([field_subject]
               ,[field_comment]
               ,[field_date])
 ) p