USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$reporting_FSA_results_by_standard_wr AS

WITH fsa_rn AS (
SELECT *
      ,ROW_NUMBER() OVER(
          PARTITION BY schoolid, grade_level, scope, DATEPART(WEEK,administered_at)
              ORDER BY subject, standards_tested) AS fsa_std_rn      
FROM
    (
     SELECT DISTINCT
            schoolid      
           ,grade_level
           ,fsa_week
           ,administered_at           
           ,scope
           ,subject      
           ,standards_tested
     FROM ILLUMINATE$assessments#static WITH(NOLOCK)
     WHERE schoolid IN (73254, 73255, 73256)
       AND scope = 'FSA'
       AND subject IS NOT NULL
    ) sub
)    

SELECT TOP (100) PERCENT
       sub.*
      ,week_num + '_' 
        + CONVERT(VARCHAR,grade_level) + '_' 
        + CONVERT(VARCHAR,fsa_std_rn) AS meta_hash
      ,CONVERT(VARCHAR,student_number) + '_'  
        + week_num + '_' 
        + CONVERT(VARCHAR,fsa_std_rn) AS meta_stu_hash
FROM
     (SELECT s.schoolid
            ,s.id AS studentid
            ,s.student_number
            ,s.lastfirst
            ,s.grade_level
            ,s.team
            ,assessments.title
            ,results.assessment_id
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
              --IEP student proficiency
              WHEN s.SCHOOLID = 73254 AND s.grade_level IN (3,4) AND cs.SPEDLEP LIKE 'SPED' AND results.percent_correct >= 0  AND results.percent_correct < 30 THEN 1
              WHEN s.SCHOOLID = 73254 AND s.grade_level IN (3,4) AND cs.SPEDLEP LIKE 'SPED' AND results.percent_correct >= 30 AND results.percent_correct < 60 THEN 2
              WHEN s.SCHOOLID = 73254 AND s.grade_level IN (3,4) AND cs.SPEDLEP LIKE 'SPED' AND results.percent_correct >= 60 THEN 3
              ELSE CONVERT(FLOAT,results.label_number)
             END AS proficiency
            ,results.custom_code AS standard
            ,results.description
            ,assessments.administered_at
            --,gr.tag AS grade_tag
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
            ,fsa_rn.fsa_std_rn
      FROM STUDENTS s WITH(NOLOCK)
      LEFT OUTER JOIN CUSTOM_STUDENTS cs
        ON s.id = cs.STUDENTID
      LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static results WITH(NOLOCK)
        ON s.student_number = results.local_student_id
      LEFT OUTER JOIN ILLUMINATE$assessments#static assessments WITH(NOLOCK)
        ON results.assessment_id = assessments.assessment_id
       AND results.standard_id = assessments.standard_id
       AND s.grade_level = assessments.grade_level
       AND s.schoolid = assessments.schoolid
       AND assessments.academic_year = 2013
      LEFT OUTER JOIN fsa_rn
        ON assessments.schoolid = fsa_rn.schoolid
       AND assessments.grade_level = fsa_rn.grade_level
       AND assessments.fsa_week = fsa_rn.fsa_week
       AND assessments.scope = fsa_rn.scope
       AND assessments.subject = fsa_rn.subject
       AND assessments.standards_tested = fsa_rn.standards_tested
      WHERE s.schoolid IN (73254,73255,73256)
        AND s.enroll_status = 0
        AND results.custom_code NOT IN ('CCSS.LA.3.R', 'CCSS.LA.3.RL', 'CCSS.LA.4.L.4.6', 'TES.CCSS.LA.K.W.K.3.b','TES.CCSS.LA.K.W.K.3.c','TES.CCSS.LA.K.W.K.3.d'
                                          ,'TES.CCSS.LA.K.W.K.3.i','TES.CCSS.LA.K.W.K.3.j','TES.CCSS.LA.K.W.K.3.g','TES.CCSS.LA.K.W.K.3')
        AND assessments.scope = 'FSA'        
      ) sub
--ORDER BY schoolid, grade_level, week_num, team, studentid, subject, standard