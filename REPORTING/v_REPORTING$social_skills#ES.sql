USE KIPP_NJ
GO

ALTER VIEW REPORTING$social_skills#ES AS

WITH valid_assessments AS (
  SELECT DISTINCT repository_id
  FROM ILLUMINATE$summary_assessments#static WITH(NOLOCK)
  WHERE scope = 'Reporting'
    AND subject = 'Social Skills'
 )

,scores_long AS (  
  SELECT repo.student_id AS student_number
        ,repo.repository_row_id      
        ,fields.label AS field
        ,repo.value
  FROM ILLUMINATE$summary_assessment_results_long#static repo WITH(NOLOCK)
  JOIN ILLUMINATE$repository_fields fields WITH(NOLOCK)
    ON repo.repository_id = fields.repository_id
   AND repo.field = fields.name 
  WHERE repo.repository_id IN (SELECT repository_id FROM valid_assessments WITH(NOLOCK))
 )

SELECT student_number           
      ,term
      ,field AS soc_skill
      ,value AS score
      ,'soc_skill_descr_' + CONVERT(VARCHAR,soc_skill_rn) AS descr_pivot_hash
      ,'soc_skill_' + term + '_score_' + CONVERT(VARCHAR,soc_skill_rn) AS score_pivot_hash
      ,soc_skill_rn
FROM
    (
     SELECT term.student_number
           ,term.repository_row_id
           ,term.value AS term
           ,data.field
           ,data.value
           ,ROW_NUMBER() OVER(
              PARTITION BY term.student_number, term.repository_row_id
                ORDER BY data.field) AS soc_skill_rn
     FROM scores_long term WITH(NOLOCK)
     JOIN scores_long data WITH(NOLOCK)
       ON term.student_number = data.student_number
      AND term.repository_row_id = data.repository_row_id
      AND data.field NOT IN ('Term', 'Grade Level')
      AND data.value IS NOT NULL
     WHERE term.field = 'Term'
    ) sub