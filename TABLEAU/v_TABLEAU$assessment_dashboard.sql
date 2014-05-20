USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_dashboard AS

SELECT s.schoolid
      ,s.grade_level
      ,s.team
      ,s.student_number
      ,s.lastfirst
      ,cs.spedlep      
      ,a.title
      ,a.scope            
      ,a.subject      
      ,a.credittype      
      ,a.term
      ,a.administered_at
      ,CONVERT(VARCHAR,a.standards_tested) AS standards_tested
      ,dbo.ASCII_CONVERT(a.standard_descr) AS standard_descr
      ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS percent_correct
      ,CONVERT(FLOAT,res.mastered) AS mastered
      ,ROW_NUMBER() OVER(
          PARTITION BY s.id, a.scope, a.standards_tested
              ORDER BY a.administered_at DESC) AS rn_curr
FROM ILLUMINATE$assessment_results_by_standard#static res WITH (NOLOCK)
JOIN STUDENTS s WITH (NOLOCK)
  ON res.local_student_id = s.student_number
 AND s.enroll_status = 0
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.studentid
JOIN ILLUMINATE$assessments#static a WITH (NOLOCK)
  ON res.assessment_id = a.assessment_id
 AND res.standard_id = a.standard_id
 AND s.schoolid = a.schoolid
 AND s.grade_level = a.grade_level
 AND a.deleted_at IS NULL