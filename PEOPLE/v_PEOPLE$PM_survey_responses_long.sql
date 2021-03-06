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
  SELECT type
        ,survey_timestamp
        ,academic_year
        ,date_taken
        ,surveyed_by_appslogin
        ,staff_member
        ,is_instructional
        ,question_code
        ,response        
  FROM
      (
       SELECT 'Manager' AS type
              ,CONVERT(DATETIME,timestamp) AS survey_timestamp
              ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
              ,CONVERT(DATE,timestamp) AS date_taken
              ,[username] AS surveyed_by_appslogin
              ,[manager_name] AS [staff_member]
              ,NULL AS [is_instructional]
              ,[q1]
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
              ,[q18]
       FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PM_manager_survey_forms] so WITH(NOLOCK)
       UNION ALL
       SELECT type
             ,survey_timestamp
             ,academic_year
             ,date_taken
             ,surveyed_by_appslogin
             ,staff_member
             ,is_instructional
             ,q1
             ,q2
             ,q3
             ,q4
             ,q5
             ,q6
             ,q7
             ,q8
             ,q9
             ,q10
             ,q11
             ,q12
             ,q13
             ,q14
             ,q15
             ,q16
             ,q17
             ,q18
       FROM
           (
            SELECT 'Manager' AS type
                   ,CONVERT(DATETIME,timestamp) AS survey_timestamp
                   ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
                   ,CONVERT(DATE,timestamp) AS date_taken
                   ,CONCAT(LEFT(username, CHARINDEX('@',[username])-1),'@apps.teamschools.org') AS surveyed_by_appslogin      
                   ,managername AS [staff_member]
                   ,NULL AS [is_instructional]
                   ,[q1]
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
                   ,[q18]
                   ,ROW_NUMBER() OVER(
                      PARTITION BY username, managername, timestamp
                        ORDER BY BINI_ID DESC) AS rn
            FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PM_manager_survey_gizmo] so WITH(NOLOCK)
           ) sub
       WHERE rn = 1
      ) sub
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
  SELECT type
        ,survey_timestamp
        ,academic_year
        ,date_taken
        ,surveyed_by_appslogin
        ,staff_member
        ,is_instructional
        ,question_code
        ,response
  FROM
      (
       SELECT 'R9' AS type
             ,CONVERT(DATETIME,timestamp) AS survey_timestamp
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
             ,CONVERT(DATE,timestamp) AS date_taken
             ,[username] AS surveyed_by_appslogin
             ,'Room 9' AS [staff_member]
             ,NULL AS [is_instructional]
             ,[q1_1]
             ,[q1_2]
             ,[q1_3]
             ,[q1_4]
             ,[q1_5]      
             ,[q2_1]
             ,[q2_2]
             ,[q2_3]
             ,[q2_4]
             ,[q2_5]
             ,[q2_6]
             ,[q2_7]
             ,[q3_1]      
             ,[q3_2]
             ,[q3_3]
             ,[q3_4]
             ,[q3_5]
             ,[q3_6]
             ,[q3_7]
             ,[q3_8]
             ,[q3_9]
             ,[q3_10]
             ,[q4_1]
             ,[q4_2]
             ,[q4_3]
             ,[q4_4]
             ,[q4_5]
             ,[q5_1]      
             ,[q5_2]
             ,[q5_3]
             ,[q5_4]
             ,[q5_5]
             ,[q5_6]
             ,[q5_7]
             ,[q5_8]
             --,[q5_9]
             ,[q5_10]
             ,[q5_11]
             ,[q5_12]                         
             ,[q6_1]      
             ,[q6_2]
             ,[q6_3]
             ,[q6_4]
             ,[q6_5]
             ,[q6_6]
             ,[q6_7]
             ,[q6_8]
             ,[q6_9]
             ,[q6_10]
             ,[q6_11]
             ,[q7_1]
             ,[q7_2]
             ,[q7_3]
             ,[q7_4]
             ,[q7_5]
             ,[q7_6]
             ,[q7_7]
             ,[q8_1]      
             ,[q8_2]
             ,[q8_3]
             ,[q8_4]
             ,[q8_5]
             ,[q8_6]
             ,[q8_7]
             ,[q8_8]
             ,[q8_9]
             ,[q8_10]
             ,[q8_11]
             ,[q8_12]
             ,[q8_13]
             ,[q9_1]
             ,[q9_2]
             ,[q9_3]
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
             ,[q14_2]
             ,[q14_3]
             ,[q14_4]
             ,[q14_5]
             ,[q14_6]
             ,[q14_7]
             ,[q14_8]
             ,[q14_9]
             ,[q14_10]
             ,[q14_11]
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
             ,[r9q12_12]
             ,NULL AS q13
             ,NULL AS q14
             ,NULL AS q15
             ,NULL AS q16
             ,NULL AS q17
             ,NULL AS q18
             ,NULL AS q19
             ,NULL AS q20
             ,NULL AS q21
             ,NULL AS q22
             ,NULL AS q23
             ,NULL AS q24
             ,NULL AS q25
             ,NULL AS q26
             ,NULL AS q27
             ,NULL AS q28
             ,NULL AS q29
             ,NULL AS q30
             ,NULL AS q31
             ,NULL AS q32
             ,NULL AS q33
             ,NULL AS q34
             ,NULL AS q35
             ,NULL AS q36
             ,NULL AS q37
             ,NULL AS q39
             ,NULL AS q40
             ,NULL AS q41
             ,NULL AS q42
             ,NULL AS q43
             ,NULL AS q44
             ,NULL AS q45
             ,NULL AS q46
             ,NULL AS q47
             ,NULL AS q48
             ,NULL AS q49
             ,NULL AS q50
             ,NULL AS q51
             ,NULL AS q52
             ,NULL AS q53
             ,NULL AS q54
             ,NULL AS q55
             ,NULL AS q56
             ,NULL AS q57
             ,NULL AS q58
             ,NULL AS q59
             ,NULL AS q60
             ,NULL AS q61
             ,NULL AS q62
             ,NULL AS q63
             ,NULL AS q64
             ,NULL AS q65
             ,NULL AS q66
             ,NULL AS q67
             ,NULL AS q68
             ,NULL AS q69
             ,NULL AS q70
             ,NULL AS q71
             ,NULL AS q72
             ,NULL AS q73
             ,NULL AS r9
       FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_r9_survey WITH(NOLOCK)

       UNION ALL

       SELECT 'R9' AS type
             ,CONVERT(DATETIME,timestamp) AS survey_timestamp
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
             ,CONVERT(DATE,timestamp) AS date_taken
             ,CONCAT(LEFT(username, CHARINDEX('@',[username])-1),'@apps.teamschools.org') AS surveyed_by_appslogin      
             ,'Room 9' AS [staff_member]
             ,NULL AS [is_instructional]
             ,NULL AS q1_1
             ,NULL AS q1_2
             ,NULL AS q1_3
             ,NULL AS q1_4
             ,NULL AS q1_5
             ,NULL AS q2_1
             ,NULL AS q2_2
             ,NULL AS q2_3
             ,NULL AS q2_4
             ,NULL AS q2_5
             ,NULL AS q2_6
             ,NULL AS q2_7
             ,NULL AS q3_1
             ,NULL AS q3_2
             ,NULL AS q3_3
             ,NULL AS q3_4
             ,NULL AS q3_5
             ,NULL AS q3_6
             ,NULL AS q3_7
             ,NULL AS q3_8
             ,NULL AS q3_9
             ,NULL AS q3_10
             ,NULL AS q4_1
             ,NULL AS q4_2
             ,NULL AS q4_3
             ,NULL AS q4_4
             ,NULL AS q4_5
             ,NULL AS q5_1
             ,NULL AS q5_2
             ,NULL AS q5_3
             ,NULL AS q5_4
             ,NULL AS q5_5
             ,NULL AS q5_6
             ,NULL AS q5_7
             ,NULL AS q5_8
             --,NULL AS q5_9
             ,NULL AS q5_10
             ,NULL AS q5_11
             ,NULL AS q5_12
             ,NULL AS q6_1
             ,NULL AS q6_2
             ,NULL AS q6_3
             ,NULL AS q6_4
             ,NULL AS q6_5
             ,NULL AS q6_6
             ,NULL AS q6_7
             ,NULL AS q6_8
             ,NULL AS q6_9
             ,NULL AS q6_10
             ,NULL AS q6_11
             ,NULL AS q7_1
             ,NULL AS q7_2
             ,NULL AS q7_3
             ,NULL AS q7_4
             ,NULL AS q7_5
             ,NULL AS q7_6
             ,NULL AS q7_7
             ,NULL AS q8_1
             ,NULL AS q8_2
             ,NULL AS q8_3
             ,NULL AS q8_4
             ,NULL AS q8_5
             ,NULL AS q8_6
             ,NULL AS q8_7
             ,NULL AS q8_8
             ,NULL AS q8_9
             ,NULL AS q8_10
             ,NULL AS q8_11
             ,NULL AS q8_12
             ,NULL AS q8_13
             ,NULL AS q9_1
             ,NULL AS q9_2
             ,NULL AS q9_3
             ,NULL AS q10_1
             ,NULL AS q10_2
             ,NULL AS q10_3
             ,NULL AS q11_1
             ,NULL AS q11_2
             ,NULL AS q11_3
             ,NULL AS q11_4
             ,q11_5
             ,NULL AS q11_6
             ,NULL AS q12_1
             ,NULL AS q12_2
             ,NULL AS q12_3
             ,NULL AS q12_4
             ,NULL AS q12_5
             ,NULL AS q13_1
             ,NULL AS q13_2
             ,NULL AS q13_3
             ,NULL AS q13_4
             ,NULL AS q13_5
             ,NULL AS q14_1
             ,NULL AS q14_2
             ,NULL AS q14_3
             ,NULL AS q14_4
             ,NULL AS q14_5
             ,NULL AS q14_6
             ,NULL AS q14_7
             ,NULL AS q14_8
             ,NULL AS q14_9
             ,NULL AS q14_10
             ,NULL AS q14_11
             ,NULL AS q15_1
             ,NULL AS q15_2
             ,NULL AS q15_3
             ,NULL AS q15_4
             ,NULL AS q15_5
             ,NULL AS q15_6
             ,NULL AS q16_1
             ,NULL AS q16_2
             ,NULL AS q16_3
             ,NULL AS q16_4
             ,NULL AS q17_1
             ,NULL AS q17_2
             ,NULL AS q18_1
             ,NULL AS q18_2
             ,NULL AS q18_3
             ,NULL AS q18_4
             ,NULL AS q18_5
             ,NULL AS q18_6
             ,NULL AS q18_7
             ,r9q12_01
             ,r9q12_02
             ,r9q12_03
             ,r9q12_04
             ,r9q12_05
             ,r9q12_06
             ,r9q12_07
             ,r9q12_08
             ,r9q12_09
             ,r9q12_10
             ,r9q12_11
             ,r9q12_12
             ,q13
             ,q14
             ,q15
             ,q16
             ,q17
             ,q18
             ,q19
             ,q20
             ,q21
             ,q22
             ,q23
             ,q24
             ,q25
             ,q26
             ,q27
             ,q28
             ,q29
             ,q30
             ,q31
             ,q32
             ,q33
             ,q34
             ,q35
             ,q36
             ,q37
             ,q39
             ,q40
             ,q41
             ,q42
             ,q43
             ,q44
             ,q45
             ,q46
             ,q47
             ,q48
             ,q49
             ,q50
             ,q51
             ,q52
             ,q53
             ,q54
             ,q55
             ,q56
             ,q57
             ,q58
             ,q59
             ,q60
             ,q61
             ,q62
             ,q63
             ,q64
             ,q65
             ,q66
             ,q67
             ,q68
             ,q69
             ,q70
             ,q71
             ,q72
             ,q73
             ,r9
       FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_r9_survey_gizmo WITH(NOLOCK)
      ) sub
  UNPIVOT(
    response
    FOR question_code IN (q1_1
                         ,q1_2
                         ,q1_3
                         ,q1_4
                         ,q1_5
                         ,q2_1
                         ,q2_2
                         ,q2_3
                         ,q2_4
                         ,q2_5
                         ,q2_6
                         ,q2_7
                         ,q3_1
                         ,q3_2
                         ,q3_3
                         ,q3_4
                         ,q3_5
                         ,q3_6
                         ,q3_7
                         ,q3_8
                         ,q3_9
                         ,q3_10
                         ,q4_1
                         ,q4_2
                         ,q4_3
                         ,q4_4
                         ,q4_5
                         ,q5_1
                         ,q5_2
                         ,q5_3
                         ,q5_4
                         ,q5_5
                         ,q5_6
                         ,q5_7
                         ,q5_8
                         ,q5_10
                         ,q5_11
                         ,q5_12
                         ,q6_1
                         ,q6_2
                         ,q6_3
                         ,q6_4
                         ,q6_5
                         ,q6_6
                         ,q6_7
                         ,q6_8
                         ,q6_9
                         ,q6_10
                         ,q6_11
                         ,q7_1
                         ,q7_2
                         ,q7_3
                         ,q7_4
                         ,q7_5
                         ,q7_6
                         ,q7_7
                         ,q8_1
                         ,q8_2
                         ,q8_3
                         ,q8_4
                         ,q8_5
                         ,q8_6
                         ,q8_7
                         ,q8_8
                         ,q8_9
                         ,q8_10
                         ,q8_11
                         ,q8_12
                         ,q8_13
                         ,q9_1
                         ,q9_2
                         ,q9_3
                         ,q10_1
                         ,q10_2
                         ,q10_3
                         ,q11_1
                         ,q11_2
                         ,q11_3
                         ,q11_4
                         ,q11_5
                         ,q11_6
                         ,q12_1
                         ,q12_2
                         ,q12_3
                         ,q12_4
                         ,q12_5
                         ,q13_1
                         ,q13_2
                         ,q13_3
                         ,q13_4
                         ,q13_5
                         ,q14_1
                         ,q14_2
                         ,q14_3
                         ,q14_4
                         ,q14_5
                         ,q14_6
                         ,q14_7
                         ,q14_8
                         ,q14_9
                         ,q14_10
                         ,q14_11
                         ,q15_1
                         ,q15_2
                         ,q15_3
                         ,q15_4
                         ,q15_5
                         ,q15_6
                         ,q16_1
                         ,q16_2
                         ,q16_3
                         ,q16_4
                         ,q17_1
                         ,q17_2
                         ,q18_1
                         ,q18_2
                         ,q18_3
                         ,q18_4
                         ,q18_5
                         ,q18_6
                         ,q18_7
                         ,r9q12_01
                         ,r9q12_02
                         ,r9q12_03
                         ,r9q12_04
                         ,r9q12_05
                         ,r9q12_06
                         ,r9q12_07
                         ,r9q12_08
                         ,r9q12_09
                         ,r9q12_10
                         ,r9q12_11
                         ,r9q12_12
                         ,q13
                         ,q14
                         ,q15
                         ,q16
                         ,q17
                         ,q18
                         ,q19
                         ,q20
                         ,q21
                         ,q22
                         ,q23
                         ,q24
                         ,q25
                         ,q26
                         ,q27
                         ,q28
                         ,q29
                         ,q30
                         ,q31
                         ,q32
                         ,q33
                         ,q34
                         ,q35
                         ,q36
                         ,q37
                         ,q39
                         ,q40
                         ,q41
                         ,q42
                         ,q43
                         ,q44
                         ,q45
                         ,q46
                         ,q47
                         ,q48
                         ,q49
                         ,q50
                         ,q51
                         ,q52
                         ,q53
                         ,q54
                         ,q55
                         ,q56
                         ,q57
                         ,q58
                         ,q59
                         ,q60
                         ,q61
                         ,q62
                         ,q63
                         ,q64
                         ,q65
                         ,q66
                         ,q67
                         ,q68
                         ,q69
                         ,q70
                         ,q71
                         ,q72
                         ,q73
                         ,r9)
   ) u
 )

,exit_survey AS (
  SELECT type
        ,survey_timestamp
        ,academic_year
        ,date_taken
        ,surveyed_by_appslogin
        ,staff_member
        ,is_instructional
        ,question_code
        ,response
  FROM
      (
       SELECT 'Exit' AS type
             ,CONVERT(DATETIME,timestamp) AS survey_timestamp
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[timestamp])) AS academic_year      
             ,CONVERT(DATE,timestamp) AS date_taken
             ,associate_id AS surveyed_by_appslogin
             ,personal_identifier AS staff_member
             ,NULL AS [is_instructional]
             ,CONVERT(VARCHAR(MAX),[Q1]) AS [Q1]
             ,CONVERT(VARCHAR(MAX),[Q2]) AS [Q2]
             ,CONVERT(VARCHAR(MAX),[Q3]) AS [Q3]
             ,CONVERT(VARCHAR(MAX),[Q4]) AS [Q4]
             ,CONVERT(VARCHAR(MAX),[Q5]) AS [Q5]
             ,CONVERT(VARCHAR(MAX),[Q6]) AS [Q6]
             ,CONVERT(VARCHAR(MAX),[Q7]) AS [Q7]
             ,CONVERT(VARCHAR(MAX),[Q8]) AS [Q8]
             ,CONVERT(VARCHAR(MAX),[Q9]) AS [Q9]
             ,CONVERT(VARCHAR(MAX),[Q10]) AS [Q10]
             ,CONVERT(VARCHAR(MAX),[Q11]) AS [Q11]
             ,CONVERT(VARCHAR(MAX),[Q12]) AS [Q12]
             ,CONVERT(VARCHAR(MAX),[Q13]) AS [Q13]
             ,CONVERT(VARCHAR(MAX),[Q14]) AS [Q14]
             ,CONVERT(VARCHAR(MAX),[Q15]) AS [Q15]
             ,CONVERT(VARCHAR(MAX),[Q16]) AS [Q16]
             ,CONVERT(VARCHAR(MAX),[Q17]) AS [Q17]
             ,CONVERT(VARCHAR(MAX),[Q18]) AS [Q18]
             ,CONVERT(VARCHAR(MAX),[Q19]) AS [Q19]
             ,CONVERT(VARCHAR(MAX),[Q20]) AS [Q20]
             ,CONVERT(VARCHAR(MAX),[Q21]) AS [Q21]
             ,CONVERT(VARCHAR(MAX),[Q22]) AS [Q22]
             ,CONVERT(VARCHAR(MAX),[Q23]) AS [Q23]
             ,CONVERT(VARCHAR(MAX),[Q24]) AS [Q24]
             ,CONVERT(VARCHAR(MAX),[Q25]) AS [Q25]
             ,CONVERT(VARCHAR(MAX),[Q26]) AS [Q26]
       FROM [KIPP_NJ]..AUTOLOAD$GDOCS_SURVEY_exit_survey WITH(NOLOCK)
      ) sub
  UNPIVOT(
    response
    FOR question_code IN ([Q1]
                         ,[Q2]
                         ,[Q3]
                         ,[Q4]
                         ,[Q5]
                         ,[Q6]
                         ,[Q7]
                         ,[Q8]
                         ,[Q9]
                         ,[Q10]
                         ,[Q11]
                         ,[Q12]
                         ,[Q13]
                         ,[Q14]
                         ,[Q15]
                         ,[Q16]
                         ,[Q17]
                         ,[Q18]
                         ,[Q19]
                         ,[Q20]
                         ,[Q21]
                         ,[Q22]
                         ,[Q23]
                         ,[Q24]
                         ,[Q25]
                         ,[Q26])
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
  UNION ALL
  SELECT *
  FROM exit_survey
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
          WHEN qk.open_ended = 'Y' THEN NULL          
          /* Y/N */          
          WHEN so.response IN ('Yes','Right Track') THEN 5
          WHEN so.response IN ('No','Wrong Direction') THEN 1
          /* S&O scale */
          WHEN so.survey_type = 'SO' AND so.response = 'Rarely' THEN 1
          WHEN so.survey_type = 'SO' AND so.response = 'Sometimes' THEN 2
          WHEN so.survey_type = 'SO' AND so.response = 'Frequently' THEN 3
          WHEN so.survey_type = 'SO' AND so.response = 'Almost Always' THEN 4
          WHEN so.survey_type = 'SO' AND so.response = 'Always' THEN 5                  
          /* Manager, SL, R9 */
          WHEN so.response = 'Strongly Disagree' THEN 1
          WHEN so.response = 'Disagree' THEN 2
          WHEN so.response = 'Neutral' THEN 3
          WHEN so.response = 'Agree' THEN 4
          WHEN so.response = 'Strongly Agree' THEN 5          
         END AS response_value

        ,dt.alt_name AS term
      
        ,subject.associate_id AS subject_associate_id
        ,subject.reporting_location AS subject_reporting_location
        ,NULL AS team /* broken by new staff survey -- need to re-define team */
        --,subject.team AS subject_team
        ,subject.manager_name AS subject_manager_name

        /* broken until we can fix GApps email issue */
        ,ad.associate_id AS responder_associate_id
        ,CASE
          WHEN so.survey_type = 'SO' THEN ISNULL(responder.firstlast, 'NO MATCH')
          ELSE so.surveyed_by_appslogin 
         END AS responder_name
        --,ISNULL(responder.firstlast, 'NO MATCH') AS responder_name
        ,responder.reporting_location AS responder_reporting_location
      
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
  LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static ad WITH(NOLOCK)
    ON REPLACE(so.surveyed_by_appslogin,'apps.teamschools','kippnj') = ad.mail
  LEFT OUTER JOIN AUTOLOAD$GDOCS_PM_survey_roster responder WITH(NOLOCK)
    ON ad.associate_id = responder.associate_id
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

SELECT cd.survey_type
      ,cd.survey_timestamp
      ,cd.academic_year
      ,cd.subject_name
      ,cd.is_instructional
      ,cd.question_code
      ,cd.response
      ,cd.response_value
      ,cd.term
      ,cd.subject_associate_id
      ,cd.subject_reporting_location
      ,cd.team
      ,cd.subject_manager_name
      ,cd.responder_associate_id
      ,cd.responder_name
      ,cd.responder_reporting_location
      ,cd.competency
      ,cd.is_open_ended
      ,cd.question_text
      ,cd.exclude_from_agg
      ,cd.exclude_location
      ,cd.exclude_department
      ,cd.exclude_role
FROM clean_data cd
JOIN dedupe dd
  ON cd.subject_name = dd.subject_name
 AND cd.responder_name = dd.responder_name
 AND cd.survey_type = dd.survey_type
 AND cd.survey_timestamp = dd.survey_timestamp
 AND dd.rn = 1