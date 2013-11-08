USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$megatron AS
SELECT sub.*
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
        + ISNULL(CONVERT(VARCHAR,[standard]),'STD') + '_'
        + ISNULL(CONVERT(VARCHAR,std_freq_rn),'0') + '_' AS time_hash
      ,ISNULL(CONVERT(VARCHAR,student_number),'SN') + '_'        
        + ISNULL(CONVERT(VARCHAR,[standard]),'STD') + '_'
        + ISNULL(CONVERT(VARCHAR,std_freq_rn),'0') + '_' AS stu_time_hash
      ,ISNULL(CONVERT(VARCHAR,schoolid),'SCHOOL') + '_'        
        + ISNULL(CONVERT(VARCHAR,[standard]),'STD') + '_'
        + ISNULL(CONVERT(VARCHAR,std_freq_rn),'0') + '_' AS school_time_hash
FROM
     (SELECT co.schoolid
            ,co.grade_level
            ,s.id AS studentid
            ,s.student_number
            ,s.lastfirst
            ,s.team
            ,results.assessment_id
            ,assessments.title            
            ,assessments.subject
            ,assessments.scope
            ,assessments.administered_at            
            ,results.custom_code AS standard
            ,results.description AS std_descr
            ,results.answered
            ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct
            ,std.std_count_subject
            ,assessments.std_freq_rn            
      FROM ILLUMINATE$assessment_results_by_standard#static results WITH(NOLOCK)
      JOIN STUDENTS s WITH(NOLOCK)
        ON results.local_student_id = s.student_number      
      JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
        ON s.id = co.studentid
       AND co.year = DATEPART(YYYY,results.administered_at)
       AND co.RN = 1
      JOIN ILLUMINATE$assessments assessments WITH(NOLOCK)
        ON results.assessment_id = assessments.assessment_id
       AND results.standard_id = assessments.standard_id
       AND co.grade_level = assessments.grade_level
      LEFT OUTER JOIN ILLUMINATE$standards_tested#static std
        ON DATEPART(YYYY,assessments.administered_at) = std.year
       AND co.schoolid = std.schoolid
       AND co.grade_level = std.grade_level
       AND assessments.subject = std.subject
       AND assessments.standard_id = std.standard_id
      WHERE s.enroll_status = 0
     ) sub