USE [KIPP_NJ]
GO

ALTER VIEW ILLUMINATE$reporting_FSA_results_by_standard AS

SELECT TOP 100 PERCENT *
FROM
   (SELECT s.schoolid
          ,s.id as studentid
          ,s.student_number
          ,s.lastfirst
          ,s.grade_level
          ,s.team
          ,results.assessment_id
          ,assessments.administered_at
          --,SUBSTRING(title,CHARINDEX(' -',title),2)
          ,assessments.title
          ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct
          ,CASE
            WHEN results.percent_correct >= 0  AND results.percent_correct < 60 THEN 1
            WHEN results.percent_correct >= 60 AND results.percent_correct < 80 THEN 2
            WHEN results.percent_correct >= 80 THEN 3
            ELSE NULL
           END AS proficiency
          ,results.answered
          ,results.custom_code
          ,results.description
          ,CONVERT(VARCHAR,grade_level)
            + '_' + SUBSTRING(title,CHARINDEX('FSA',title)+3,2) --FSA week derived from title name, no bueno
            + '_' + custom_code 
            + '_' + ISNULL(team,'noteam') 
            + '_' + CONVERT(VARCHAR,student_number) 
           AS reporting_hash
    FROM STUDENTS s
    JOIN ILLUMINATE$assessment_results_by_standard results
      ON s.id = results.student_id
    JOIN ILLUMINATE$assessments assessments
      ON results.assessment_id = assessments.assessment_id
    WHERE s.schoolid IN (73254,73255,73256)
      AND assessments.title NOT LIKE '%ample%'
      and results.assessment_id = 1148
   )sub
ORDER BY LASTFIRST
--ORDER BY schoolid, grade_level, studentid, assessment_id, reporting_hash