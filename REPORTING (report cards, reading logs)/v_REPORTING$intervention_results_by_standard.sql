USE KIPP_NJ
GO

ALTER VIEW REPORTING$intervention_results_by_standard AS
SELECT TOP (100) PERCENT
       schoolid
      ,studentid
      ,student_number
      ,lastfirst
      ,grade_level
      ,team
      ,title
      ,assessment_id
      ,week_num
      ,subject
      ,answered
      ,percent_correct
      ,proficiency
      ,standard
      ,description
      ,administered_at
      ,reporting_hash
      ,rollup_hash
      ,fsa_std_rn      
      ,week_num + '_' 
        + CONVERT(VARCHAR,grade_level) + '_' 
        + CONVERT(VARCHAR,fsa_std_rn) AS meta_hash
      ,SPEDLEP
FROM
     (
      SELECT s.schoolid
            ,s.id AS studentid
            ,s.student_number
            ,s.lastfirst
            ,s.grade_level
            ,s.team            
            ,assessments.title
            ,results.assessment_id --probably easiest to key off of in excel
            ,assessments.fsa_week AS week_num
            ,assessments.subject
            ,results.answered
            ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct      
            ,CASE
              WHEN assessments.subject != 'Writing' AND results.percent_correct >= 0  AND results.percent_correct < 60 THEN 1
              WHEN assessments.subject != 'Writing' AND results.percent_correct >= 60 AND results.percent_correct < 80 THEN 2
              WHEN assessments.subject != 'Writing' AND results.percent_correct >= 80 THEN 3
              WHEN assessments.subject = 'Writing' AND results.percent_correct >= 0  AND results.percent_correct < 16.6 THEN 1
              --WHEN assessments.subject = 'Writing' AND results.percent_correct >= 60 AND results.percent_correct < 80 THEN 2
              WHEN assessments.subject = 'Writing' AND results.percent_correct >= 16.6 THEN 3
              WHEN assessments.schoolid = 73254 AND assessments.subject NOT IN ('Comprehension','Math','Phonics','Grammar','Writing') AND results.percent_correct < 25 THEN 1
              WHEN assessments.schoolid = 73254 AND assessments.subject NOT IN ('Comprehension','Math','Phonics','Grammar','Writing') AND results.percent_correct >= 25 AND results.percent_correct < 50 THEN 2
              WHEN assessments.schoolid = 73254 AND assessments.subject NOT IN ('Comprehension','Math','Phonics','Grammar','Writing') AND results.percent_correct >= 50 AND results.percent_correct < 75 THEN 3
              WHEN assessments.schoolid = 73254 AND assessments.subject NOT IN ('Comprehension','Math','Phonics','Grammar','Writing') AND results.percent_correct >= 75 THEN 4
              ELSE CONVERT(FLOAT,results.label_number)
             END AS proficiency
            ,results.custom_code AS standard
            ,results.description
            ,assessments.administered_at      
            ,ISNULL(CONVERT(VARCHAR,s.grade_level),'GRADE')
              + '_' + ISNULL(assessments.fsa_week,'WEEK')
              + '_' + ISNULL(assessments.subject,'SUBJ')
              + '_' + ISNULL(results.custom_code,'STD') --standard tested
              + '_' + ISNULL(team,'TEAM')
              + '_' + ISNULL(CONVERT(VARCHAR,student_number),'00000')
               AS reporting_hash
            ,ISNULL(assessments.fsa_week,'WEEK')
              + '_' + ISNULL(CONVERT(VARCHAR,s.grade_level),'GRADE')
              + '_' + ISNULL(results.custom_code,'STD') --standard tested
               AS rollup_hash      
            ,assessments.fsa_std_rn      
            ,cs.SPEDLEP      
      FROM STUDENTS s  WITH(NOLOCK)
      LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
        ON s.id = cs.studentid
      LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static results WITH(NOLOCK)
        ON s.student_number = results.local_student_id
       AND results.custom_code NOT IN ('TES.CCSS.LA.K.W.K.3.b','TES.CCSS.LA.K.W.K.3.c','TES.CCSS.LA.K.W.K.3.d','TES.CCSS.LA.K.W.K.3.i','TES.CCSS.LA.K.W.K.3.j'
                                          ,'TES.CCSS.LA.K.W.K.3.g','TES.CCSS.LA.K.W.K.3')
      JOIN ILLUMINATE$assessments#static assessments WITH(NOLOCK)
        ON results.assessment_id = assessments.assessment_id
       AND results.standard_id = assessments.standard_id
       AND s.grade_level = assessments.grade_level
       AND s.schoolid = assessments.schoolid
       AND assessments.academic_year = 2013
       AND assessments.scope = 'Intervention'
      WHERE s.enroll_status = 0
        AND s.schoolid IN (73254,73255,73256)        
      ) sub