USE KIPP_NJ
GO

ALTER VIEW REPORTING$TA_results_by_standard AS
SELECT TOP (100) PERCENT
       sub.*       
      ,CONVERT(VARCHAR,grade_level) + '_' 
        + CASE
           WHEN standard = 'CCSS.LA.3.L.3.2' THEN CONVERT(VARCHAR,1)
           ELSE CONVERT(VARCHAR,fsa_std_rn)
          END AS meta_hash
      ,CONVERT(VARCHAR,student_number) + '_'  
        + CONVERT(VARCHAR,subject) + '_' 
        + CASE
           WHEN standard = 'CCSS.LA.3.L.3.2' THEN CONVERT(VARCHAR,1)
           ELSE CONVERT(VARCHAR,fsa_std_rn)
          END AS meta_stu_hash
FROM
     (SELECT s.schoolid
            ,s.id AS studentid
            ,s.student_number
            ,s.lastfirst
            ,co.grade_level
            ,s.team
            ,assessments.title
            ,results.assessment_id --probably easier to key off of
            --,dates.time_per_name AS week_num
            ,assessments.subject
            ,results.answered
            ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct
            /*
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
            */
            ,CONVERT(FLOAT,results.label_number) AS proficiency
            ,results.custom_code AS standard
            ,results.description
            ,assessments.administered_at
            --,gr.tag AS grade_tag
            ,ISNULL(CONVERT(VARCHAR,co.grade_level),'GRADE')
              --+ '_' + ISNULL(dates.time_per_name,'WEEK')
              + '_' + ISNULL(assessments.subject,'SUBJ')
              + '_' + ISNULL(results.custom_code,'STD') --standard tested
              + '_' + ISNULL(team,'TEAM')
              + '_' + ISNULL(CONVERT(VARCHAR,student_number),'00000')
             AS reporting_hash
            --,ISNULL(dates.time_per_name,'WEEK')
            --  + '_' + 
            ,ISNULL(CONVERT(VARCHAR,co.grade_level),'GRADE')
              + '_' + ISNULL(results.custom_code,'STD') --standard tested
             AS rollup_hash
            ,ROW_NUMBER() OVER
               (PARTITION BY assessments.schoolid, assessments.grade_level, assessments.subject, s.id
                    ORDER BY assessments.standards_tested) AS fsa_std_rn
            /*
            ,CASE WHEN assessments.subject = 'Writing' THEN
               ROW_NUMBER() OVER
                  (PARTITION BY assessments.schoolid, assessments.grade_level, assessments.subject, s.id
                       ORDER BY assessments.standards_tested)
              ELSE NULL
             END AS writing_std_rn
            */
            /*
            --now using row number from assessment feed
            ,ROW_NUMBER() OVER(
                PARTITION BY dates.time_per_name, assessments.grade_level, s.id
                    ORDER BY results.custom_code) AS rn
            --*/
      FROM STUDENTS s WITH(NOLOCK)
      LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static results WITH(NOLOCK)
        ON s.student_number = results.local_student_id
      LEFT OUTER JOIN ILLUMINATE$assessments#static assessments WITH(NOLOCK)
        ON results.assessment_id = assessments.assessment_id
       AND results.standard_id = assessments.standard_id
       AND s.grade_level = assessments.grade_level
       AND s.schoolid = assessments.schoolid
       AND assessments.academic_year = 2013
       --AND assessments.deleted_at IS NULL
      LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
        ON s.id = co.studentid
       AND co.year = DATEPART(YYYY,assessments.administered_at)        
      WHERE s.schoolid IN (73254,73255,73256)
        AND s.enroll_status = 0        
        AND assessments.scope = 'District Benchmark'
        AND assessments.standards_tested NOT IN ('CCSS.MA.4.4.NF.3.a'
                                                ,'CCSS.MA.4.4.NF.3.b'
                                                ,'CCSS.MA.4.4.NF.3.d'
                                                ,'CCSS.MA.4.4.NF.4.a'
                                                ,'CCSS.MA.4.4.NF.4.b'
                                                ,'CCSS.MA.4.4.NF.4.c'
                                                ,'CCSS.LA.3.RI'
                                                ,'CCSS.LA.3.RL'
                                                ,'CCSS.LA.4.RI'
                                                ,'CCSS.LA.4.RL'
                                                ,'CCSS.LA.4.L.4.1'
                                                ,'CCSS.LA.4.L.4.2'
                                                ,'CCSS.LA.4.L.4.3')
      ) sub
--ORDER BY schoolid, grade_level, week_num, team, studentid, subject, standard