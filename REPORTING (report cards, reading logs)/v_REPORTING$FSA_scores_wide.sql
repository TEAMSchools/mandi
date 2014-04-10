USE KIPP_NJ
GO

ALTER VIEW REPORTING$FSA_scores_wide AS

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

SELECT *
FROM
    (
     SELECT studentid
           ,STUDENT_NUMBER
           ,fsa_week
           ,identifier + '_' + CONVERT(VARCHAR,fsa_std_rn) AS identifier
           ,value
     FROM
         (
          SELECT s.id AS studentid
                ,s.student_number           
                ,a.fsa_week
                ,CONVERT(VARCHAR,a.subject) AS FSA_subject
                ,CONVERT(VARCHAR,res.performance_band_level) AS FSA_score
                ,CONVERT(VARCHAR,res.perf_band_label) AS FSA_prof                
                ,fsa_rn.fsa_std_rn
          FROM ILLUMINATE$assessments#static a WITH(NOLOCK)
          JOIN ILLUMINATE$assessment_results_by_standard#static res WITH(NOLOCK)  
            ON a.assessment_id = res.assessment_id
           AND a.standard_id = res.standard_id 
          JOIN STUDENTS s WITH(NOLOCK)
            ON res.local_student_id = s.student_number
           AND a.schoolid = s.schoolid
           AND a.grade_level = s.grade_level 
           AND s.enroll_status = 0 
          JOIN fsa_rn
            ON a.schoolid = fsa_rn.schoolid
           AND a.grade_level = fsa_rn.grade_level
           AND a.fsa_week = fsa_rn.fsa_week
           AND a.scope = fsa_rn.scope
           AND a.subject = fsa_rn.subject
           AND a.standards_tested = fsa_rn.standards_tested
          WHERE a.schoolid IN (73254,73255,73256)  
            AND a.scope = 'FSA'
            AND a.academic_year = dbo.fn_Global_Academic_Year()
            AND a.deleted_at IS NULL
         ) sub
         
     UNPIVOT (
       value
       FOR identifier IN ([FSA_subject]
                         ,[FSA_score]
                         ,[FSA_prof])
      ) unpiv
    ) sub2  

PIVOT (
  MAX(value)
  FOR identifier IN ([FSA_prof_1]
                    ,[FSA_prof_2]
                    ,[FSA_prof_3]
                    ,[FSA_prof_4]
                    ,[FSA_prof_5]
                    ,[FSA_prof_6]
                    ,[FSA_prof_7]
                    ,[FSA_prof_8]
                    ,[FSA_prof_9]
                    ,[FSA_prof_10]                    
                    ,[FSA_score_1]
                    ,[FSA_score_2]
                    ,[FSA_score_3]
                    ,[FSA_score_4]
                    ,[FSA_score_5]
                    ,[FSA_score_6]
                    ,[FSA_score_7]
                    ,[FSA_score_8]
                    ,[FSA_score_9]
                    ,[FSA_score_10]
                    ,[FSA_subject_1]
                    ,[FSA_subject_2]
                    ,[FSA_subject_3]
                    ,[FSA_subject_4]
                    ,[FSA_subject_5]
                    ,[FSA_subject_6]
                    ,[FSA_subject_7]
                    ,[FSA_subject_8]
                    ,[FSA_subject_9]
                    ,[FSA_subject_10])
 ) piv