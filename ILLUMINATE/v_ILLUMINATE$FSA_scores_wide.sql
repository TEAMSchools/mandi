USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$FSA_scores_wide AS

WITH fsa_rn AS (
  SELECT schoolid
        ,grade_level
        ,academic_year
        ,assessment_id
        ,reporting_wk
        ,administered_at
        ,scope
        ,subject_area
        ,standard_id
        ,standard_code        
        ,standard_description
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid, grade_level, scope, reporting_wk
             ORDER BY subject_area, standard_code) AS fsa_std_rn      
  FROM
      (
       SELECT a.schoolid      
             ,a.grade_level
             ,a.academic_year
             ,a.assessment_id
             ,a.reporting_wk
             ,a.administered_at           
             ,a.scope
             ,CONVERT(VARCHAR,a.subject_area) AS subject_area
             ,a.standard_id
             ,CONVERT(VARCHAR,a.standard_code) AS standard_code
             ,CONVERT(VARCHAR,a.standard_description) AS standard_description
       FROM KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)       
       WHERE a.grade_level <= 4
         AND a.scope = 'FSA'
         AND a.subject_area IS NOT NULL
         AND a.reporting_wk IS NOT NULL
         --AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub  
 )    

,fsa_scaffold AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,co.SPEDLEP
        ,a.assessment_id
        ,a.reporting_wk
        ,a.schoolid
        ,a.grade_level
        ,a.standard_id
        ,a.standard_code
        ,a.subject_area
        ,a.standard_description
        ,a.FSA_std_rn
  FROM fsa_rn a WITH(NOLOCK)
  JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
    ON a.schoolid = co.SCHOOLID
   AND a.grade_level = co.GRADE_LEVEL   
   AND a.academic_year = co.year   
   AND co.rn = 1  
 )

SELECT studentid
      ,STUDENT_NUMBER
      ,reporting_wk      
      ,FSA_subject_1
      ,FSA_subject_2
      ,FSA_subject_3
      ,FSA_subject_4
      ,FSA_subject_5
      ,FSA_subject_6
      ,FSA_subject_7
      ,FSA_subject_8
      ,FSA_subject_9
      ,FSA_subject_10
      ,FSA_subject_11
      ,FSA_subject_12
      ,FSA_subject_13
      ,FSA_subject_14
      ,FSA_subject_15
      ,FSA_standard_1
      ,FSA_standard_2
      ,FSA_standard_3
      ,FSA_standard_4
      ,FSA_standard_5
      ,FSA_standard_6
      ,FSA_standard_7
      ,FSA_standard_8
      ,FSA_standard_9
      ,FSA_standard_10
      ,FSA_standard_11
      ,FSA_standard_12
      ,FSA_standard_13
      ,FSA_standard_14
      ,FSA_standard_15
      ,FSA_obj_1
      ,FSA_obj_2
      ,FSA_obj_3
      ,FSA_obj_4
      ,FSA_obj_5
      ,FSA_obj_6
      ,FSA_obj_7
      ,FSA_obj_8
      ,FSA_obj_9
      ,FSA_obj_10
      ,FSA_obj_11
      ,FSA_obj_12
      ,FSA_obj_13
      ,FSA_obj_14
      ,FSA_obj_15
      ,FSA_score_1
      ,FSA_score_2
      ,FSA_score_3
      ,FSA_score_4
      ,FSA_score_5
      ,FSA_score_6
      ,FSA_score_7
      ,FSA_score_8
      ,FSA_score_9
      ,FSA_score_10
      ,FSA_score_11
      ,FSA_score_12
      ,FSA_score_13
      ,FSA_score_14
      ,FSA_score_15
      ,FSA_prof_1
      ,FSA_prof_2
      ,FSA_prof_3
      ,FSA_prof_4
      ,FSA_prof_5
      ,FSA_prof_6
      ,FSA_prof_7
      ,FSA_prof_8
      ,FSA_prof_9
      ,FSA_prof_10
      ,FSA_prof_11
      ,FSA_prof_12
      ,FSA_prof_13
      ,FSA_prof_14
      ,FSA_prof_15
FROM
    (
     SELECT studentid
           ,STUDENT_NUMBER
           ,reporting_wk           
           ,identifier + '_' + CONVERT(VARCHAR,fsa_std_rn) AS identifier
           ,value
     FROM
         (
          SELECT a.studentid
                ,a.student_number           
                ,a.reporting_wk
                ,a.subject_area AS FSA_subject
                ,a.standard_code AS FSA_standard
                ,a.standard_description AS FSA_obj                       
                ,ROW_NUMBER() OVER(
                   PARTITION BY student_number, schoolid, grade_level, reporting_wk
                     ORDER BY subject_area, standard_code) AS fsa_std_rn
                ,CONVERT(VARCHAR,
                  CASE 
                    WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 60 THEN '3'
                    WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 30 AND res.percent_correct < 60 THEN '2'
                    WHEN a.SPEDLEP = 'SPED' AND res.percent_correct < 30 THEN '1'
                    WHEN res.percent_correct >= 80 THEN '3'
                    WHEN res.percent_correct >= 60 AND res.percent_correct < 80 THEN '2'
                    WHEN res.percent_correct < 60 THEN '1'
                   END) AS FSA_score
                ,CONVERT(VARCHAR,
                  CASE
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 60 THEN 'Proficient' 
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct >= 30 AND res.percent_correct < 60 THEN 'Approaching'
                   WHEN a.SPEDLEP = 'SPED' AND res.percent_correct < 30 THEN 'Not Yet'
                   WHEN res.percent_correct >= 80 THEN 'Proficient' 
                   WHEN res.percent_correct >= 60 AND res.percent_correct < 80 THEN 'Approaching'
                   WHEN res.percent_correct < 60 THEN 'Not Yet'
                  END) AS FSA_prof                                
          FROM fsa_scaffold a WITH(NOLOCK)
          JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard#static res WITH(NOLOCK)  
            ON a.student_number = res.local_student_id           
           AND a.assessment_id = res.assessment_id
           AND a.standard_id = res.standard_id
         ) sub         
     UNPIVOT (
       value
       FOR identifier IN ([FSA_subject]
                         ,[FSA_score]
                         ,[FSA_prof]
                         ,[FSA_standard]                         
                         ,[FSA_obj])
      ) unpiv
    ) sub2  
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
                    ,[FSA_prof_15])
 ) p