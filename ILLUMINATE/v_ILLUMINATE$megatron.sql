USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$megatron AS
WITH roster AS
     (
      SELECT s.id AS studentid
            ,s.student_number
            ,s.lastfirst
            ,co.schoolid
            ,co.grade_level
            ,s.team
            ,s.gender
            ,cs.spedlep
            ,co.year
      FROM STUDENTS s WITH (NOLOCK)
      LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
        ON s.id = cs.studentid
      LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH (NOLOCK)
        ON s.id = co.studentid  
       --AND co.year = 2013
       AND co.rn = 1
      WHERE s.enroll_status = 0
     )

     ,assessments AS
      (
       SELECT a.assessment_id
             ,a.schoolid
             ,a.grade_level
             ,a.title
             ,a.subject
             ,a.scope
             ,a.standards_tested
             ,a.standard_id
             ,a.parent_standard_id
             ,a.academic_year
             ,a.administered_at
             ,a.std_freq_rn
             ,std.std_count_subject             
       FROM ILLUMINATE$assessments#static a WITH (NOLOCK)
       JOIN ILLUMINATE$standards_tested#static std WITH (NOLOCK)
         ON a.academic_year = std.year
        AND a.schoolid = std.schoolid
        AND a.grade_level = std.grade_level
        AND a.subject = std.subject
        AND a.standard_id = std.standard_id       
      )

SELECT schoolid
      ,grade_level
      ,studentid
      ,student_number
      ,lastfirst
      ,team
      ,sub.assessment_id
      ,title
      ,subject
      ,scope
      ,sub.administered_at
      ,sub.standards_tested AS standard
      ,NULL AS std_descr
      ,results.answered
      ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct
      ,CASE
        WHEN sub.subject != 'Writing' AND results.percent_correct >= 0  AND results.percent_correct < 60 THEN 1
        WHEN sub.subject != 'Writing' AND results.percent_correct >= 60 AND results.percent_correct < 80 THEN 2
        WHEN sub.subject != 'Writing' AND results.percent_correct >= 80 THEN 3
        WHEN sub.subject = 'Writing' AND results.percent_correct >= 0  AND results.percent_correct < 16.6 THEN 1
        --WHEN sub.subject = 'Writing' AND results.percent_correct >= 60 AND results.percent_correct < 80 THEN 2
        WHEN sub.subject = 'Writing' AND results.percent_correct >= 16.6 THEN 3
        ELSE NULL
       END AS proficiency
      ,std_count_subject
      ,std_freq_rn
      ,ISNULL(CONVERT(VARCHAR,schoolid),'SCHOOL') + '_'
        + ISNULL(CONVERT(VARCHAR,grade_level),'GR') + '_'
        + ISNULL(CONVERT(VARCHAR,subject),'SUBJ') + '_'
        + ISNULL(CONVERT(VARCHAR,std_count_subject),'0') AS overview_hash
      ,ISNULL(CONVERT(VARCHAR,schoolid),'SCHOOL') + '_'
        + ISNULL(CONVERT(VARCHAR,grade_level),'GR') + '_'
        + ISNULL(CONVERT(VARCHAR,subject),'SUBJ') + '_'
        + ISNULL(CONVERT(VARCHAR,std_count_subject),'0') + '_'
        + ISNULL(CONVERT(VARCHAR,student_number),'SN') AS stu_overview_hash
      ,ISNULL(CONVERT(VARCHAR,schoolid),'SCHOOL') + '_'
        + ISNULL(CONVERT(VARCHAR,team),'HR') + '_'
        + ISNULL(CONVERT(VARCHAR,standards_tested),'STD') + '_'
        + ISNULL(CONVERT(VARCHAR,std_freq_rn),'0') AS time_hash
      ,ISNULL(CONVERT(VARCHAR,student_number),'SN') + '_'
        + ISNULL(CONVERT(VARCHAR,standards_tested),'STD') + '_'
        + ISNULL(CONVERT(VARCHAR,std_freq_rn),'0') AS stu_time_hash
      ,ISNULL(CONVERT(VARCHAR,schoolid),'SCHOOL') + '_'
        + ISNULL(CONVERT(VARCHAR,standards_tested),'STD') + '_'
        + ISNULL(CONVERT(VARCHAR,std_freq_rn),'0') AS school_time_hash
      ,spedlep AS SPED
      --,results.points
      --,results.points_possible
      --,results.number_of_questions
FROM
     (
      SELECT roster.studentid
            ,roster.student_number
            ,roster.lastfirst
            ,roster.schoolid
            ,roster.grade_level
            ,roster.team
            ,roster.gender
            ,roster.spedlep
            ,roster.year
            ,assessments.assessment_id
            ,assessments.title
            ,assessments.subject
            ,assessments.scope
            ,assessments.standards_tested
            ,assessments.standard_id
            ,assessments.parent_standard_id
            ,assessments.academic_year
            ,assessments.administered_at
            ,assessments.std_freq_rn
            ,assessments.std_count_subject
      FROM roster WITH (NOLOCK)
      JOIN assessments WITH (NOLOCK)
        ON roster.schoolid = assessments.schoolid
       AND roster.grade_level = assessments.grade_level
       AND roster.year = assessments.academic_year      
     ) sub
LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static results WITH (NOLOCK)
  ON sub.student_number = results.local_student_id
 AND sub.assessment_id = results.assessment_id
 AND sub.standard_id = results.standard_id