USE KIPP_NJ
GO

ALTER VIEW REPORTING$TA_results_by_standard AS
SELECT sub2.*       
      ,CONVERT(VARCHAR,grade_level) + '_' 
        + CASE
           WHEN schoolid = 73254 AND standard = 'CCSS.LA.3.L.3.2' THEN CONVERT(VARCHAR,1)
           ELSE CONVERT(VARCHAR,fsa_std_rn)
          END AS meta_hash
      ,CONVERT(VARCHAR,student_number) + '_'  
        + CONVERT(VARCHAR,subject) + '_' 
        + CASE
           WHEN schoolid = 73254 AND standard = 'CCSS.LA.3.L.3.2' THEN CONVERT(VARCHAR,1)
           ELSE CONVERT(VARCHAR,fsa_std_rn)
          END AS meta_stu_hash
FROM          
(
 SELECT *
       ,ROW_NUMBER() OVER
          (PARTITION BY sub.term, sub.studentid, sub.schoolid, sub.grade_level, sub.subject
               ORDER BY sub.standard) AS fsa_std_rn
 FROM
      (
       SELECT s.schoolid
             ,s.id AS studentid
             ,s.student_number
             ,s.lastfirst
             ,co.grade_level
             ,s.team
             ,assessments.title
             ,results.assessment_id            
             ,assessments.subject
             ,results.answered
             ,CAST(ROUND(results.percent_correct,2,2) AS FLOAT) AS percent_correct            
             ,CONVERT(FLOAT,results.label_number) AS proficiency
             ,results.custom_code AS standard
             ,results.description
             ,assessments.administered_at            
             ,ISNULL(CONVERT(VARCHAR,co.grade_level),'GRADE')              
               + '_' + ISNULL(assessments.subject,'SUBJ')
               + '_' + ISNULL(results.custom_code,'STD') --standard tested
               + '_' + ISNULL(team,'TEAM')
               + '_' + ISNULL(CONVERT(VARCHAR,student_number),'00000')
              AS reporting_hash            
             ,ISNULL(CONVERT(VARCHAR,co.grade_level),'GRADE')
               + '_' + ISNULL(results.custom_code,'STD')
              AS rollup_hash       
            ,assessments.term                   
       FROM STUDENTS s WITH(NOLOCK)
       LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static results WITH(NOLOCK)
         ON s.student_number = results.local_student_id
       LEFT OUTER JOIN ILLUMINATE$assessments#static assessments WITH(NOLOCK)
         ON results.assessment_id = assessments.assessment_id
        AND results.standard_id = assessments.standard_id
        AND s.grade_level = assessments.grade_level
        AND s.schoolid = assessments.schoolid
        AND assessments.academic_year = dbo.fn_Global_Academic_Year()   
        AND assessments.deleted_at IS NULL    
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
                                                ,'CCSS.LA.4.L.4.3'
                                                ,'CCSS.LA.K.RL.CCR.8'
                                                ,'CCSS.LA.K.RL.K.3'
                                                ,'CCSS.LA.K.RL.K.4'
                                                ,'CCSS.LA.K.RL.K.5'
                                                ,'CCSS.LA.K.RL.K.7')
       LEFT OUTER JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
         ON s.id = co.studentid
        AND co.year = CASE
                       WHEN DATEPART(MM,assessments.administered_at) >= 07 THEN DATEPART(YYYY,assessments.administered_at)
                       WHEN DATEPART(MM,assessments.administered_at) < 07 THEN (DATEPART(YYYY,assessments.administered_at) - 1)
                       ELSE NULL
                      END
        AND co.rn = 1
       WHERE s.schoolid IN (73254,73255,73256)
         AND s.enroll_status = 0                 
       ) sub
) sub2