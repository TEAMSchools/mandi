USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$FSA_scores_wide AS

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

,next_steps AS (
  SELECT grade_level
        ,REPLACE(LEFT(week_num,7),' ','_') AS week_num
        ,subject
        ,ccss_standard
        ,alt_standard
        ,parent_obj
        ,nxtstps_mastered
        ,nxtstps_notmastered      
  FROM GDOCS$FSA_long_term WITH(NOLOCK)
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
                ,CONVERT(VARCHAR,res.custom_code) AS FSA_standard
                ,CONVERT(VARCHAR,nxt.nxtstps_mastered) AS FSA_nxtstp_y
                ,CONVERT(VARCHAR,nxt.nxtstps_notmastered) AS FSA_nxtstp_n
                ,CONVERT(VARCHAR,nxt.parent_obj) AS FSA_obj
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
          LEFT OUTER JOIN next_steps nxt
            ON res.custom_code = nxt.ccss_standard
           AND a.fsa_week = nxt.week_num
           AND s.GRADE_LEVEL = nxt.grade_level
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
                         ,[FSA_prof]
                         ,[FSA_standard]
                         ,[FSA_nxtstp_y]
                         ,[FSA_nxtstp_n]
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
                    ,[FSA_nxtstp_y_1]
                    ,[FSA_nxtstp_y_2]
                    ,[FSA_nxtstp_y_3]
                    ,[FSA_nxtstp_y_4]
                    ,[FSA_nxtstp_y_5]
                    ,[FSA_nxtstp_y_6]
                    ,[FSA_nxtstp_y_7]
                    ,[FSA_nxtstp_y_8]
                    ,[FSA_nxtstp_y_9]
                    ,[FSA_nxtstp_y_10]
                    ,[FSA_nxtstp_y_11]
                    ,[FSA_nxtstp_y_12]
                    ,[FSA_nxtstp_y_13]
                    ,[FSA_nxtstp_y_14]
                    ,[FSA_nxtstp_y_15]
                    ,[FSA_nxtstp_n_1]
                    ,[FSA_nxtstp_n_2]
                    ,[FSA_nxtstp_n_3]
                    ,[FSA_nxtstp_n_4]
                    ,[FSA_nxtstp_n_5]
                    ,[FSA_nxtstp_n_6]
                    ,[FSA_nxtstp_n_7]
                    ,[FSA_nxtstp_n_8]
                    ,[FSA_nxtstp_n_9]
                    ,[FSA_nxtstp_n_10]
                    ,[FSA_nxtstp_n_11]
                    ,[FSA_nxtstp_n_12]
                    ,[FSA_nxtstp_n_13]
                    ,[FSA_nxtstp_n_14]
                    ,[FSA_nxtstp_n_15])
 ) piv
 --*/