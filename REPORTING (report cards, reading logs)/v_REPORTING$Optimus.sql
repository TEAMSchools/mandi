USE KIPP_NJ
GO

--ALTER VIEW REPORTING$Optimus AS
SELECT 'KIPP NJ' AS Network
      ,CASE
        WHEN s.schoolid IN (73252,73253,73254,73255,73256,133570965) THEN 'Newark'
        ELSE NULL 
       END AS Region
      ,CASE
        WHEN s.schoolid IN (73254,73255,73256) THEN 'ES'
        WHEN s.schoolid IN (73252,133570965) THEN 'MS'
        WHEN s.schoolid IN (73253) THEN 'HS'
       END AS school_level
      ,CASE
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
      ,a.title
      ,a.scope      
      ,CASE
        WHEN a.subject IN ('Arts: Music','Arts: Visual Arts','Performing Arts') THEN 'Arts'
        WHEN a.subject IN ('Comprehension','English Language Arts','Grammar','Phonics','Reading','Word Work','Writing') THEN 'Literacy'
        WHEN a.subject IN ('Historical Arts','History-Social Science') THEN 'Social Studies'
        WHEN a.subject IN ('Mathematics') THEN 'Math'
        WHEN a.subject IN ('Science') THEN 'Science'
        WHEN a.subject IN ('Spanish') THEN 'World Language'
       END AS department
      ,a.subject
      ,a.term
      ,a.administered_at
      ,CONVERT(NVARCHAR(255),a.standards_tested) AS standards_tested
      ,a.standard_descr
      --,CASE WHEN a.parent_standard IS NULL THEN a.standards_tested ELSE a.parent_standard END AS parent_standard
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
--WHERE a.scope = 'District Benchmark' 