USE KIPP_NJ
GO

ALTER VIEW ROSTERS$GApp_students AS

SELECT co.student_number
      ,co.first_name AS firstname
      ,co.last_name AS lastname      
      ,acct.student_web_id + '@teamstudents.org' AS email
      ,acct.STUDENT_WEB_PASSWORD AS [password]
      ,CASE WHEN co.enroll_status = 0 THEN 'off' ELSE 'on' END AS suspended
      ,'/Students/' + CASE WHEN co.enroll_status = 0 THEN co.school_name ELSE 'Disabled' END AS org
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..ROSTERS$PS_access_accounts acct WITH(NOLOCK)
  ON co.student_number = acct.STUDENT_NUMBER
WHERE co.year = 2015
  AND co.rn = 1