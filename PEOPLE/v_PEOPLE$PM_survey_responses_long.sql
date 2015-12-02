USE KIPP_NJ
GO

ALTER VIEW PEOPLE$PM_survey_responses_long AS

WITH so_survey AS (
  SELECT 'SO' AS survey_type
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
)

SELECT so.survey_type
      ,so.academic_year      
      ,so.staff_member
      ,so.is_instructional
      ,so.question_code      
      ,so.response
      ,CASE
        /* S&O scale */
        WHEN so.response = 'Rarely' THEN 1
        WHEN so.response = 'Sometimes' THEN 2
        WHEN so.response = 'Frequently' THEN 3
        WHEN so.response = 'Almost Always' THEN 4
        WHEN so.response = 'Always' THEN 5
        /* Likert scale */
        WHEN so.response = 'Strongly Disagree' THEN 1
        WHEN so.response = 'Disagree' THEN 2
        WHEN so.response = 'Agree' THEN 3
        WHEN so.response = 'Strongly Agree' THEN 4
       END AS response_value

      ,dt.alt_name AS term
      
      ,r.reporting_location
      ,r.team      
      ,r.manager_name

      ,r2.firstlast AS surveyed_by
      
      ,qk.competency
      ,CASE WHEN qk.open_ended = 'Y' THEN 1 ELSE 0 END AS is_open_ended
      ,qk.question_text
FROM responses_long so
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON so.academic_year = dt.academic_year
 AND so.date_taken BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
 AND dt.schoolid = 73253
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_question_key qk WITH(NOLOCK)
  ON so.question_code = qk.question_code
 AND so.survey_type = qk.type
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_survey_roster r WITH(NOLOCK)
  ON so.staff_member = r.firstlast
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_survey_roster r2 WITH(NOLOCK)
  ON so.surveyed_by_appslogin = r2.gapps_email            