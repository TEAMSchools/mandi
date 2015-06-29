USE KIPP_NJ
GO

ALTER VIEW REPORTING$ARFR_reasons#ES AS

SELECT student_number
      ,repository_row_id
      ,CASE 
        WHEN LEN([Year]) < 4 THEN NULL
        ELSE LEFT([Year], 4)
       END AS academic_year
      ,[Term] AS term            
      ,CASE
        WHEN [Term] = 'T3' THEN [Status]
        ELSE 'At Risk for Retention due to: '
               + CASE 
                  WHEN [Achievement] IS NOT NULL AND [Attendance] IS NOT NULL THEN [Achievement] + ' & ' + [ATTENDANCE] 
                  ELSE COALESCE([Achievement], [Attendance]) 
                 END
       END AS ARFR_reason
FROM 
    (
     SELECT repo.student_id AS student_number
           ,repo.repository_row_id      
           ,fields.label AS field
           ,repo.value
     FROM KIPP_NJ..ILLUMINATE$summary_assessment_results_long#static repo WITH(NOLOCK)
     JOIN KIPP_NJ..ILLUMINATE$repository_fields fields WITH(NOLOCK)
       ON repo.repository_id = fields.repository_id
      AND repo.field = fields.name 
     WHERE repo.repository_id IN (
                                  SELECT DISTINCT repository_id
                                  FROM KIPP_NJ..ILLUMINATE$summary_assessments#static WITH(NOLOCK)
                                  WHERE scope = 'Reporting'
                                    AND subject = 'ARFR'
                                 )
    ) sub
PIVOT(
  MAX(value)
  FOR field IN ([Term]               
               ,[Year]
               ,[Achievement]
               ,[Attendance]
               ,[Status])
 ) p