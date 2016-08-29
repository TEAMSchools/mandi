USE KIPP_NJ
GO

ALTER VIEW PEOPLE$PM_survey_responses_long AS

WITH so_survey AS (
  SELECT 'SO' AS survey_type
        ,CONVERT(DATETIME,timestamp) AS survey_timestamp
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
        ,CONVERT(DATE,timestamp) AS date_taken
        ,[username] AS surveyed_by_appslogin
        ,[staff_member]
        ,[is_instructional]
        ,question_code
        ,response      
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PM_self_and_others] so WITH(NOLOCK)
  UNPIVOT(
    response
    FOR question_code IN ([q1_1]
                         ,[q1_2]
                         ,[q1_3]
                         ,[q1_4]
                         ,[q1_5]
                         ,[q1_6]
                         ,[q2_1]
                         ,[q2_2]
                         ,[q2_3]
                         ,[q2_4]
                         ,[q2_5]
                         ,[q3_1]
                         ,[q3_2]
                         ,[q3_3]
                         ,[q3_4]
                         ,[q3_5]
                         ,[q3_6]
                         ,[q4_1]
                         ,[q4_2]
                         ,[q4_3]
                         ,[q4_4]
                         ,[q5_1]
                         ,[q5_2]
                         ,[q5_3]
                         ,[q5_4]
                         ,[q5_5]
                         ,[q5_6]
                         ,[q5_7]
                         ,[q6_1]
                         ,[q6_2]
                         ,[q6_3]
                         ,[q6_4]
                         ,[q6_5]
                         ,[q6_6]      
                         ,[q7_1]
                         ,[q7_2]
                         ,[q7_3]
                         ,[q7_4]
                         ,[q7_5]
                         ,[q8_1]
                         ,[q8_2]
                         ,[q8_3]
                         ,[q8_4]
                         ,[q9_1]
                         ,[q9_2]
                         ,[q9_3]
                         ,[q9_4]
                         ,[q9_5]
                         ,[q9_6])
   ) u
 )

,manager_survey AS (
  SELECT 'Manager' AS type
         ,CONVERT(DATETIME,timestamp) AS survey_timestamp
         ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
         ,CONVERT(DATE,timestamp) AS date_taken
         ,[username] AS surveyed_by_appslogin
         ,[manager_name] AS [staff_member]
         ,NULL AS [is_instructional]
         ,question_code
         ,response      
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PM_manager_survey] so WITH(NOLOCK)
  UNPIVOT(
    response
    FOR question_code IN ([q1]
                         ,[q2]
                         ,[q3]
                         ,[q4]
                         ,[q5]
                         ,[q6]
                         ,[q7]
                         ,[q8]
                         ,[q9]
                         ,[q10]
                         ,[q11]
                         ,[q12]
                         ,[q13]
                         ,[q14]
                         ,[q15]
                         ,[q16]
                         ,[q17]
                         ,[q18])
   ) u
)

,school_leader AS (
  SELECT 'SL' AS type
        ,CONVERT(DATETIME,timestamp) AS survey_timestamp
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
        ,CONVERT(DATE,timestamp) AS date_taken
        ,[username] AS surveyed_by_appslogin
        ,school_leader AS [staff_member]
        ,NULL AS [is_instructional]
        ,question_code
        ,response      
  FROM [KIPP_NJ]..AUTOLOAD$GDOCS_SURVEY_sl_feedback so WITH(NOLOCK)
  UNPIVOT(
    response
    FOR question_code IN ([q1]
                         ,[q2]
                         ,[q3])
   ) u
 )

,r9project AS (
  SELECT 'Projects' AS type
        ,CONVERT(DATETIME,timestamp) AS survey_timestamp
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
        ,CONVERT(DATE,timestamp) AS date_taken
        ,[username] AS surveyed_by_appslogin
        ,project AS [staff_member]
        ,NULL AS [is_instructional]
        ,question_code
        ,response      
  FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_r9_project_survey so WITH(NOLOCK)
  UNPIVOT(
    response
    FOR question_code IN ([q1]
                         ,[q2]
                         ,[q3]
                         ,[q4]
                         ,[q5]
                         ,[q6])
   ) u
 )

,r9q12 AS (
  SELECT 'R9' AS type
        ,CONVERT(DATETIME,timestamp) AS survey_timestamp
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
        ,CONVERT(DATE,timestamp) AS date_taken
        ,[username] AS surveyed_by_appslogin
        ,'Room 9' AS [staff_member]
        ,NULL AS [is_instructional]
        ,question_code
        ,response      
  FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_r9_survey so WITH(NOLOCK)
  UNPIVOT(
    response
    FOR question_code IN ([q1_1]
                         ,[q1_2]
                         ,[q1_3]
                         ,[q1_4]
                         ,[q1_5]
                         ,[q10_1]
                         ,[q10_2]
                         ,[q10_3]
                         ,[q11_1]
                         ,[q11_2]
                         ,[q11_3]
                         ,[q11_4]
                         ,[q11_5]
                         ,[q11_6]
                         ,[q12_1]
                         ,[q12_2]
                         ,[q12_3]
                         ,[q12_4]
                         ,[q12_5]
                         ,[q13_1]
                         ,[q13_2]
                         ,[q13_3]
                         ,[q13_4]
                         ,[q13_5]
                         ,[q14_1]
                         ,[q14_10]
                         ,[q14_11]
                         ,[q14_2]
                         ,[q14_3]
                         ,[q14_4]
                         ,[q14_5]
                         ,[q14_6]
                         ,[q14_7]
                         ,[q14_8]
                         ,[q14_9]
                         ,[q15_1]
                         ,[q15_2]
                         ,[q15_3]
                         ,[q15_4]
                         ,[q15_5]
                         ,[q15_6]
                         ,[q16_1]
                         ,[q16_2]
                         ,[q16_3]
                         ,[q16_4]
                         ,[q17_1]
                         ,[q17_2]
                         ,[q18_1]
                         ,[q18_2]
                         ,[q18_3]
                         ,[q18_4]
                         ,[q18_5]
                         ,[q18_6]
                         ,[q18_7]
                         ,[q2_1]
                         ,[q2_2]
                         ,[q2_3]
                         ,[q2_4]
                         ,[q2_5]
                         ,[q2_6]
                         ,[q2_7]
                         ,[q3_1]
                         ,[q3_10]
                         ,[q3_2]
                         ,[q3_3]
                         ,[q3_4]
                         ,[q3_5]
                         ,[q3_6]
                         ,[q3_7]
                         ,[q3_8]
                         ,[q3_9]
                         ,[q4_1]
                         ,[q4_2]
                         ,[q4_3]
                         ,[q4_4]
                         ,[q4_5]
                         ,[q5_1]
                         ,[q5_10]
                         ,[q5_11]
                         ,[q5_12]
                         ,[q5_2]
                         ,[q5_3]
                         ,[q5_4]
                         ,[q5_5]
                         ,[q5_6]
                         ,[q5_7]
                         ,[q5_8]                         
                         ,[q6_1]
                         ,[q6_10]
                         ,[q6_11]
                         ,[q6_2]
                         ,[q6_3]
                         ,[q6_4]
                         ,[q6_5]
                         ,[q6_6]
                         ,[q6_7]
                         ,[q6_8]
                         ,[q6_9]
                         ,[q7_1]
                         ,[q7_2]
                         ,[q7_3]
                         ,[q7_4]
                         ,[q7_5]
                         ,[q7_6]
                         ,[q7_7]
                         ,[q8_1]
                         ,[q8_10]
                         ,[q8_11]
                         ,[q8_12]
                         ,[q8_13]
                         ,[q8_2]
                         ,[q8_3]
                         ,[q8_4]
                         ,[q8_5]
                         ,[q8_6]
                         ,[q8_7]
                         ,[q8_8]
                         ,[q8_9]
                         ,[q9_1]
                         ,[q9_2]
                         ,[q9_3]
                         ,[r9q12_01]
                         ,[r9q12_02]
                         ,[r9q12_03]
                         ,[r9q12_04]
                         ,[r9q12_05]
                         ,[r9q12_06]
                         ,[r9q12_07]
                         ,[r9q12_08]
                         ,[r9q12_09]
                         ,[r9q12_10]
                         ,[r9q12_11]
                         ,[r9q12_12])
   ) u
 )

,responses_long AS (
  SELECT *
  FROM so_survey
  UNION ALL
  SELECT *
  FROM manager_survey
  UNION ALL
  SELECT *
  FROM school_leader
  UNION ALL
  SELECT *
  FROM r9project
  UNION ALL
  SELECT *
  FROM r9q12 
)

,clean_data AS (
  SELECT so.survey_type
        ,so.survey_timestamp
        ,so.academic_year      
        ,ISNULL(so.staff_member, so.survey_type) AS subject_name
        ,so.is_instructional
        ,so.question_code      
        ,so.response
        ,CASE
          /* Y/N */
          WHEN so.response IN ('Yes','Right Track') THEN 5
          WHEN so.response IN ('No','Wrong Direction') THEN 1
          /* S&O scale */
          WHEN so.survey_type = 'SO' AND so.response = 'Rarely' THEN 1
          WHEN so.survey_type = 'SO' AND so.response = 'Sometimes' THEN 2
          WHEN so.survey_type = 'SO' AND so.response = 'Frequently' THEN 3
          WHEN so.survey_type = 'SO' AND so.response = 'Almost Always' THEN 4
          WHEN so.survey_type = 'SO' AND so.response = 'Always' THEN 5        
          /* R9/Q12 */
          WHEN so.survey_type = 'R9' AND so.response = 'Strongly Disagree' THEN 1
          WHEN so.survey_type = 'R9' AND so.response = 'Disagree' THEN 2
          WHEN so.survey_type = 'R9' AND so.response = 'Neutral' THEN 3
          WHEN so.survey_type = 'R9' AND so.response = 'Agree' THEN 4
          WHEN so.survey_type = 'R9' AND so.response = 'Strongly Agree' THEN 5
          /* Manager, SL, R9 Project scale */
          WHEN so.response = 'Strongly Disagree' THEN 1
          WHEN so.response = 'Disagree' THEN 2
          WHEN so.response = 'Agree' THEN 3
          WHEN so.response = 'Strongly Agree' THEN 4
          WHEN so.response = 'N/A' THEN NULL
         END AS response_value

        ,dt.alt_name AS term
      
        ,subject.reporting_location AS subject_reporting_location
        ,NULL AS team /* broken by new staff survey -- need to re-define team */
        --,subject.team AS subject_team
        ,subject.manager_name AS subject_manager_name

        /* broken until we can fix GApps email issue */
        ,so.surveyed_by_appslogin AS responder_name
        ,NULL AS responder_reporting_location
        --,ISNULL(responder.firstlast, 'NO MATCH') AS responder_name
        --,responder.reporting_location AS responder_reporting_location
      
        ,qk.competency
        ,CASE WHEN qk.open_ended = 'Y' THEN 1 ELSE 0 END AS is_open_ended
        ,qk.question_text
        ,qk.exclude_from_agg
	       ,qk.exclude_location
	       ,qk.exclude_department
	       ,qk.exclude_role
  FROM responses_long so
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON so.date_taken BETWEEN dt.start_date AND dt.end_date
   AND dt.identifier = 'SURVEY'
   AND dt.schoolid = 0
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_question_key qk WITH(NOLOCK)
    ON so.question_code = qk.question_code
   AND so.survey_type = qk.type
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_survey_roster subject WITH(NOLOCK)
    ON so.staff_member = subject.firstlast
  --LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_survey_roster responder WITH(NOLOCK)
  --  ON so.surveyed_by_appslogin = responder.gapps_email            
 )

,dedupe AS (
  SELECT survey_type
        ,academic_year
        ,term
        ,subject_name
        ,responder_name
        ,survey_timestamp
        ,ROW_NUMBER() OVER(
           PARTITION BY subject_name, academic_year, term, survey_type, responder_name
             ORDER BY survey_timestamp DESC) AS rn
  FROM
      (
       SELECT DISTINCT 
              survey_type
             ,academic_year
             ,term
             ,subject_name
             ,responder_name            
             ,survey_timestamp
       FROM clean_data
      ) sub
 )

SELECT cd.*
FROM clean_data cd
JOIN dedupe dd
  ON cd.subject_name = dd.subject_name
 AND cd.responder_name = dd.responder_name
 AND cd.survey_type = dd.survey_type
 AND cd.survey_timestamp = dd.survey_timestamp
 AND dd.rn = 1