USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$reporting_FSA_results_by_standard AS
SELECT TOP (100) PERCENT
       sub.*
      ,week_num + '_' 
        + CONVERT(VARCHAR,grade_level) + '_' 
        + CONVERT(VARCHAR,rn) AS meta_hash
FROM
     (SELECT s.schoolid
            ,s.id AS studentid
            ,s.student_number
            ,s.lastfirst
            ,co.grade_level
            ,s.team
            ,assessments.title
            ,results.assessment_id --probably easiest to key off of in excel
            ,dates.time_per_name AS week_num
            ,assessments.subject
            ,results.answered
            ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct
            ,CASE
              WHEN results.percent_correct >= 0  AND results.percent_correct < 60 THEN 1
              WHEN results.percent_correct >= 60 AND results.percent_correct < 80 THEN 2
              WHEN results.percent_correct >= 80 THEN 3
              ELSE NULL
             END AS proficiency
            ,results.custom_code AS standard
            ,results.description
            ,assessments.administered_at
            --,gr.tag AS grade_tag
            ,ISNULL(CONVERT(VARCHAR,co.grade_level),'GRADE')
              + '_' + ISNULL(dates.time_per_name,'WEEK')
              + '_' + ISNULL(assessments.subject,'SUBJ')
              + '_' + ISNULL(results.custom_code,'STD') --standard tested
              + '_' + ISNULL(team,'TEAM')
              + '_' + ISNULL(CONVERT(VARCHAR,student_number),'00000')
             AS reporting_hash
            ,ISNULL(dates.time_per_name,'WEEK')
              + '_' + ISNULL(CONVERT(VARCHAR,co.grade_level),'GRADE')
              + '_' + ISNULL(results.custom_code,'STD') --standard tested
             AS rollup_hash
            ,ROW_NUMBER() OVER(
                PARTITION BY s.id, dates.time_per_name, co.grade_level
                    ORDER BY results.custom_code) AS rn
      FROM STUDENTS s
      LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static results
        ON s.student_number = results.local_student_id
      LEFT OUTER JOIN ILLUMINATE$assessments assessments
        ON results.assessment_id = assessments.assessment_id
      LEFT OUTER JOIN COHORT$comprehensive_long#static co
        ON s.id = co.studentid
       AND co.year = DATEPART(YYYY,assessments.administered_at)  
      JOIN REPORTING$dates dates
        ON assessments.administered_at >= dates.start_date
       AND assessments.administered_at <= dates.end_date
       AND dates.identifier = 'FSA'
       AND dates.school_level = 'ES'
      WHERE s.schoolid IN (73254,73255,73256)
        AND s.enroll_status = 0
        --AND assessments.scope IN ('FSA','Site Assessment')
      ) sub
--ORDER BY schoolid, grade_level, week_num, team, studentid, subject, standard