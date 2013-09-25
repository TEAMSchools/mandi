USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$reporting_FSA_results_by_standard AS
SELECT TOP (100) PERCENT *
FROM 
     (SELECT DISTINCT s.schoolid
                     ,s.id AS studentid
                     ,s.student_number
                     ,s.lastfirst
                     ,s.grade_level
                     ,s.team
                     ,assessments.title
                     ,results.assessment_id --probably easier to key off of
                     ,dates.time_per_name
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
                     ,assessments.administered_at
                     ,gr.tag AS grade_tag
                     ,ISNULL(gr.tag,'GRADE')
                       + '_' + ISNULL(dates.time_per_name,'WEEK')
                       + '_' + ISNULL(assessments.subject,'SUBJ')
                       + '_' + ISNULL(results.custom_code,'STD') --standard tested
                       + '_' + ISNULL(team,'TEAM')
                       + '_' + ISNULL(CONVERT(VARCHAR,student_number),'00000')
                      AS reporting_hash
               FROM STUDENTS s
               JOIN ILLUMINATE$assessment_results_by_standard results
                 ON s.student_number = results.local_student_id
               LEFT OUTER JOIN ILLUMINATE$assessments assessments
                 ON results.assessment_id = assessments.assessment_id
               LEFT OUTER JOIN ILLUMINATE$assessments gr
                 ON results.assessment_id = gr.assessment_id
                AND gr.tag_type = 'grade'      
               JOIN REPORTING$dates dates
                 ON assessments.administered_at >= dates.start_date
                AND assessments.administered_at <= dates.end_date
                AND dates.identifier = 'FSA'
                AND dates.schoolid = 'ES'
               WHERE s.schoolid IN (73254,73255,73256)
                 AND s.enroll_status = 0
                 AND assessments.scope IN ('FSA','Site Assessment')
     )sub
ORDER BY schoolid, reporting_hash