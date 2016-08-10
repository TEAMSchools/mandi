USE KIPP_NJ
GO

ALTER VIEW ROSTERS$GApp_students AS

WITH temp_gapps_exclude AS (
  SELECT c.studentid, c.student_number
  FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
  WHERE c.year = 2016
    AND c.schoolid = 73252
    AND c.exitdate <= CONVERT(DATE,GETDATE())
 )

SELECT co.student_number
      ,co.schoolid
      ,co.first_name AS firstname
      ,co.last_name AS lastname      
      ,acct.student_web_id + '@teamstudents.org' AS email
      ,acct.STUDENT_WEB_PASSWORD AS [password]
      ,CASE WHEN co.schoolid = 73253 THEN 'on' ELSE 'off' END AS changepassword
      ,CASE WHEN co.enroll_status = 0 THEN 'off' ELSE 'on' END AS suspended
      ,'/Students/' + CASE WHEN co.enroll_status = 0 THEN co.school_name ELSE 'Disabled' END AS org
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..ROSTERS$PS_access_accounts acct WITH(NOLOCK)
  ON co.student_number = acct.STUDENT_NUMBER
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.studentid NOT IN (SELECT studentid FROM temp_gapps_exclude)
