USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$reporting_FSA_results_by_standard AS

SELECT TOP 100 PERCENT *
FROM
   (SELECT
      s.schoolid
     ,s.id as studentid
     ,s.student_number
     ,s.lastfirst
     ,s.grade_level
     ,s.team
     ,results.assessment_id
     ,assessments.title
     ,ROUND(results.percent_correct,2) AS percent_correct
     ,results.answered
     ,results.custom_code
     ,results.description

   FROM STUDENTS s

   JOIN ILLUMINATE$assessment_results_by_standard results
     ON s.id = results.student_id

   JOIN ILLUMINATE$assessments assessments
     ON results.assessment_id = assessments.assessment_id

   WHERE s.schoolid IN (73254,73255,73256)
   
   )sub
ORDER BY grade_level
        ,lastfirst
        ,assessment_id