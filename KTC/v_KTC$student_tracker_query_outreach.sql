USE KIPP_NJ
GO

ALTER VIEW KTC$student_tracker_query_outreach AS

SELECT 'H1' AS ColA
      ,'601193' AS ColB --account_number
      ,'00' AS ColC
      ,'KIPP THROUGH COLLEGE NEW JERSEY' AS ColD --organization_name
      ,CONVERT(VARCHAR,REPLACE(CONVERT(DATE,GETDATE()),'-','')) AS ColE --file_creation_date
      ,'DA' AS ColF --inquiry_purpose
      ,'S' AS ColG
      ,NULL AS ColH
      ,NULL AS ColI
      ,NULL AS ColJ
      ,NULL AS ColK
      ,NULL AS ColL

UNION ALL

SELECT 'D1' AS ColA
      ,NULL AS ColB
      ,co.first_name AS ColC
      ,NULL AS ColD --middle_initial
      ,co.last_name AS ColE
      ,NULL AS ColF --name_suffix
      ,CONVERT(VARCHAR,REPLACE(CONVERT(DATE,co.DOB),'-','')) AS ColG --date_of_birth
      ,CONVERT(VARCHAR,REPLACE(CONVERT(DATE,co.exitdate),'-','')) AS ColH --search_begin_date
      ,NULL AS ColI
      ,NULL AS ColJ
      ,'00' AS ColK
      ,CONVERT(VARCHAR,co.student_number) AS ColL --requestor_return_field
FROM KIPP_NJ..KTC$team_and_family_roster co WITH(NOLOCK)
WHERE co.cohort <= KIPP_NJ.dbo.fn_Global_Academic_Year()

UNION ALL

SELECT 'T1'
      ,CONVERT(VARCHAR,COUNT(student_number) + 2)
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
FROM KIPP_NJ..KTC$team_and_family_roster co WITH(NOLOCK)
WHERE co.cohort <= KIPP_NJ.dbo.fn_Global_Academic_Year()