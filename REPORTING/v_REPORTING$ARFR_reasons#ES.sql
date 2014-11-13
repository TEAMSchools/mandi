USE KIPP_NJ
GO

ALTER VIEW REPORTING$ARFR_reasons#ES AS

WITH valid_assessments AS (
  SELECT DISTINCT repository_id
  FROM ILLUMINATE$summary_assessments#static WITH(NOLOCK)
  WHERE scope = 'Reporting'
    AND subject = 'ARFR'
 )

SELECT student_number
      ,repository_row_id
      ,LEFT([Year],4) AS academic_year
      ,[Term] AS term      
      ,'At Risk for Retention due to: ' 
        + CASE 
           WHEN [Achievement] IS NOT NULL AND [Attendance] IS NOT NULL THEN [Achievement] + ' & ' + [ATTENDANCE]
           WHEN [Achievement] IS NOT NULL AND [Attendance] IS NULL THEN [Achievement]
           WHEN [Achievement] IS NULL AND [Attendance] IS NOT NULL THEN [ATTENDANCE]
           ELSE NULL
          END AS ARFR_reason
FROM 
    (
     SELECT repo.student_id AS student_number
           ,repo.repository_row_id      
           ,fields.label AS field
           ,repo.value
     FROM ILLUMINATE$summary_assessment_results_long#static repo WITH(NOLOCK)
     JOIN ILLUMINATE$repository_fields fields WITH(NOLOCK)
       ON repo.repository_id = fields.repository_id
      AND repo.field = fields.name 
     WHERE repo.repository_id IN (SELECT repository_id FROM valid_assessments WITH(NOLOCK))
    ) sub

PIVOT(
  MAX(value)
  FOR field IN ([Term]               
               ,[Year]
               ,[Achievement]
               ,[Attendance])
 ) p