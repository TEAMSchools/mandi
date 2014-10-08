USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$FSA_scores_wide AS

WITH fsa_rn AS (
  SELECT *
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid, grade_level, scope, fsa_week
             ORDER BY subject, standards_tested) AS fsa_std_rn      
  FROM
      (
       SELECT DISTINCT
              a.schoolid      
             ,a.grade_level
             ,a.academic_year
             ,a.assessment_id
             ,a.fsa_week
             ,a.administered_at           
             ,a.scope
             ,a.subject      
             ,a.standards_tested            
             ,CONVERT(VARCHAR(250),nxt.next_steps_mastered) AS FSA_nxtstp_y
             ,CONVERT(VARCHAR(250),nxt.next_steps_notmastered) AS FSA_nxtstp_n
             ,CONVERT(VARCHAR(250),nxt.objective) AS FSA_obj
       FROM ILLUMINATE$assessments#static a WITH(NOLOCK)
       JOIN GDOCS$FSA_longterm_clean nxt WITH(NOLOCK)
         ON a.SCHOOLID = nxt.schoolid
        AND a.GRADE_LEVEL = nxt.grade_level
        AND a.fsa_week = nxt.week_num
        AND a.standards_tested = nxt.ccss_standard  
       WHERE a.schoolid IN (73254, 73255, 73256, 73257, 179901)
         AND a.scope = 'FSA'
         AND a.subject IS NOT NULL
         AND a.fsa_week IS NOT NULL
         AND a.academic_year = dbo.fn_Global_Academic_Year()
      ) sub  
 )    

,fsa_scaffold AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,cs.SPEDLEP
        ,a.assessment_id
        ,a.fsa_week
        ,a.schoolid
        ,a.grade_level
        ,a.standards_tested
        ,CONVERT(VARCHAR(250),a.subject) AS FSA_subject
        ,CONVERT(VARCHAR(250),a.standards_tested) AS FSA_standard
        ,a.FSA_nxtstp_y
        ,a.FSA_nxtstp_n
        ,a.FSA_obj
        ,a.FSA_std_rn
  FROM fsa_rn a WITH(NOLOCK)
  JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
    ON a.schoolid = co.SCHOOLID
   AND a.grade_level = co.GRADE_LEVEL   
   AND a.academic_year = co.year   
   AND co.rn = 1  
  JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.STUDENTID
 )

SELECT *
FROM
    (
     SELECT studentid
           ,STUDENT_NUMBER
           ,fsa_week
           ,ROUND(CONVERT(FLOAT,n_mastered) / CONVERT(FLOAT,n_total) * 100,0) AS pct_mastered_wk
           ,identifier + '_' + CONVERT(VARCHAR,fsa_std_rn) AS identifier
           ,value
     FROM
         (
          SELECT a.studentid
                ,a.student_number           
                ,a.FSA_week
                ,a.FSA_subject
                ,a.FSA_standard
                ,a.FSA_obj                
                ,CASE
                  WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 60 THEN a.FSA_nxtstp_y
                  WHEN a.SPEDLEP = 'SPED' AND res.percent_correct < 60 THEN a.FSA_nxtstp_n
                  WHEN res.percent_correct >= 80 THEN a.FSA_nxtstp_y
                  WHEN res.percent_correct < 80 THEN a.FSA_nxtstp_n
                 END AS FSA_nxtstp
                ,a.FSA_std_rn
                ,CONVERT(VARCHAR(250),
                  CASE 
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 60 THEN 3
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 30 AND res.percent_correct < 60 THEN 2
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct < 30 THEN 1
                   WHEN res.percent_correct >= 80 THEN 3
                   WHEN res.percent_correct >= 60 AND res.percent_correct < 80 THEN 2
                   WHEN res.percent_correct < 60 THEN 1
                  END) AS FSA_score
                ,CONVERT(VARCHAR(250),
                  CASE
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 60 THEN 'Proficient' 
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 30 AND res.percent_correct < 60 THEN 'Approaching'
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct < 30 THEN 'Not Yet'
                   WHEN res.percent_correct >= 80 THEN 'Proficient' 
                   WHEN res.percent_correct >= 60 AND res.percent_correct < 80 THEN 'Approaching'
                   WHEN res.percent_correct < 60 THEN 'Not Yet'
                  END) AS FSA_prof                
                ,CONVERT(FLOAT,SUM(CASE
                                    WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 60 THEN 1
                                    WHEN a.SPEDLEP = 'SPED' AND res.percent_correct < 60 THEN 0
                                    WHEN res.percent_correct >= 80 THEN 1
                                    WHEN res.percent_correct < 80 THEN 0
                                   END) OVER(PARTITION BY a.studentid, a.fsa_week)) AS n_mastered
                ,CONVERT(FLOAT,COUNT(a.FSA_standard) OVER(PARTITION BY a.studentid, a.fsa_week)) AS n_total
          FROM fsa_scaffold a WITH(NOLOCK)
          LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static res WITH(NOLOCK)  
            ON a.student_number = res.local_student_id           
           AND a.assessment_id = res.assessment_id
           AND res.custom_code = a.standards_tested
         ) sub
         
     UNPIVOT (
       value
       FOR identifier IN ([FSA_subject]
                         ,[FSA_score]
                         ,[FSA_prof]
                         ,[FSA_standard]
                         ,[FSA_nxtstp]                         
                         ,[FSA_obj])
      ) unpiv
    ) sub2  

--/*
PIVOT (
  MAX(value)
  FOR identifier IN ([FSA_subject_1]
                    ,[FSA_subject_2]
                    ,[FSA_subject_3]
                    ,[FSA_subject_4]
                    ,[FSA_subject_5]
                    ,[FSA_subject_6]
                    ,[FSA_subject_7]
                    ,[FSA_subject_8]
                    ,[FSA_subject_9]
                    ,[FSA_subject_10]
                    ,[FSA_subject_11]
                    ,[FSA_subject_12]
                    ,[FSA_subject_13]
                    ,[FSA_subject_14]
                    ,[FSA_subject_15]
                    ,[FSA_standard_1]
                    ,[FSA_standard_2]
                    ,[FSA_standard_3]
                    ,[FSA_standard_4]
                    ,[FSA_standard_5]
                    ,[FSA_standard_6]
                    ,[FSA_standard_7]
                    ,[FSA_standard_8]
                    ,[FSA_standard_9]
                    ,[FSA_standard_10]
                    ,[FSA_standard_11]
                    ,[FSA_standard_12]
                    ,[FSA_standard_13]
                    ,[FSA_standard_14]
                    ,[FSA_standard_15]
                    ,[FSA_obj_1]
                    ,[FSA_obj_2]
                    ,[FSA_obj_3]
                    ,[FSA_obj_4]
                    ,[FSA_obj_5]
                    ,[FSA_obj_6]
                    ,[FSA_obj_7]
                    ,[FSA_obj_8]
                    ,[FSA_obj_9]
                    ,[FSA_obj_10]
                    ,[FSA_obj_11]
                    ,[FSA_obj_12]
                    ,[FSA_obj_13]
                    ,[FSA_obj_14]
                    ,[FSA_obj_15]
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
                    ,[FSA_score_11]
                    ,[FSA_score_12]
                    ,[FSA_score_13]
                    ,[FSA_score_14]
                    ,[FSA_score_15]
                    ,[FSA_prof_1]
                    ,[FSA_prof_2]
                    ,[FSA_prof_3]
                    ,[FSA_prof_4]
                    ,[FSA_prof_5]
                    ,[FSA_prof_6]
                    ,[FSA_prof_7]
                    ,[FSA_prof_8]
                    ,[FSA_prof_9]
                    ,[FSA_prof_10]
                    ,[FSA_prof_11]
                    ,[FSA_prof_12]
                    ,[FSA_prof_13]
                    ,[FSA_prof_14]
                    ,[FSA_prof_15]
                    ,[FSA_nxtstp_1]
                    ,[FSA_nxtstp_2]
                    ,[FSA_nxtstp_3]
                    ,[FSA_nxtstp_4]
                    ,[FSA_nxtstp_5]
                    ,[FSA_nxtstp_6]
                    ,[FSA_nxtstp_7]
                    ,[FSA_nxtstp_8]
                    ,[FSA_nxtstp_9]
                    ,[FSA_nxtstp_10]
                    ,[FSA_nxtstp_11]
                    ,[FSA_nxtstp_12]
                    ,[FSA_nxtstp_13]
                    ,[FSA_nxtstp_14]
                    ,[FSA_nxtstp_15])
 ) piv
 --*/