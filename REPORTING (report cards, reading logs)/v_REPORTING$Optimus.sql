USE KIPP_NJ
GO

ALTER VIEW REPORTING$Optimus AS
SELECT CASE
        WHEN s.schoolid = 73252 THEN 'Rise'
        WHEN s.schoolid = 73253 THEN 'NCA'
        WHEN s.schoolid = 73254 THEN 'SPARK'
        WHEN s.schoolid = 73255 THEN 'THRIVE'
        WHEN s.schoolid = 73256 THEN 'Seek'
        WHEN s.schoolid = 133570965 THEN 'TEAM'
       END AS school
      ,CASE
        WHEN s.grade_level = 0 THEN 'K'
        ELSE CONVERT(VARCHAR,s.grade_level) 
       END AS grade_level      
      ,s.team
      ,s.lastfirst
      ,cs.SPEDLEP
      --,a.assessment_id
      --,a.title
      ,a.scope
      --,dates.time_per_name
      ,a.subject      
      ,a.administered_at
      ,a.standards_tested
      --,a.parent_standard_id
      ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS percent_correct
      ,CONVERT(FLOAT,res.mastered) AS mastered
FROM ILLUMINATE$assessment_results_by_standard#static res WITH (NOLOCK)
JOIN STUDENTS s WITH (NOLOCK)
  ON res.local_student_id = s.student_number
 AND s.ENROLL_STATUS = 0
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.STUDENTID
JOIN ILLUMINATE$assessments#static a WITH (NOLOCK)
  ON res.assessment_id = a.assessment_id
 AND res.standard_id = a.standard_id
 AND s.SCHOOLID = a.schoolid
 AND s.GRADE_LEVEL = a.grade_level
/*
JOIN REPORTING$dates dates WITH(NOLOCK)
  ON res.administered_at >= dates.start_date
 AND res.administered_at <= dates.end_date
 AND dates.identifier = 'RT'
 AND a.schoolid = dates.schoolid
--*/
--WHERE a.scope = 'District Benchmark' 