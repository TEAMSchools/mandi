USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$reporting_FSA_results_by_standard AS
SELECT TOP (100) PERCENT *
FROM
     (SELECT s.schoolid            
            ,s.id AS studentid
            ,s.student_number            
            ,s.lastfirst
            ,s.grade_level
            ,s.team
            ,assessments.title
            ,results.assessment_id --probably easier to match off of
            --dates.week_number after table is created
            ,assessments.administered_at
            ,assessments.subject
            ,results.answered
            ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct
            ,CASE
              WHEN results.percent_correct >= 0  AND results.percent_correct < 60 THEN 1
              WHEN results.percent_correct >= 60 AND results.percent_correct < 80 THEN 2
              WHEN results.percent_correct >= 80 THEN 3
              ELSE NULL
             END AS proficiency
            ,results.custom_code
            ,results.description
            ,ISNULL(assessments.grade,'grade')
              + '_' + SUBSTRING(title,CHARINDEX('FSA',title)+3,2) --FSA week derived from title name, no bueno -- use dates.week_number when table is created
              + '_' + ISNULL(assessments.subject,'subject')
              + '_' + ISNULL(results.custom_code,'standard') --standard tested
              + '_' + ISNULL(team,'team')
              + '_' + ISNULL(CONVERT(VARCHAR,student_number),'sn')
             AS reporting_hash
      FROM STUDENTS s
      JOIN ILLUMINATE$assessment_results_by_standard results
        ON s.student_number = results.local_student_id
      JOIN ILLUMINATE$assessments assessments
        ON results.assessment_id = assessments.assessment_id
      --JOIN REPORTING$key_dates dates
        --ON assessments.administered_at >= dates.start_date
       --AND assessments.administered_at <= dates.end_date
      WHERE s.schoolid IN (73254,73255,73256)
        AND s.enroll_status = 0
        --AND assessments.type = 'fsa'
     )sub
ORDER BY schoolid, reporting_hash