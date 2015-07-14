USE KIPP_NJ
GO

ALTER VIEW ROSTERS$KTC_import AS

WITH entry_grade AS (
  SELECT studentid
        ,grade_level
        ,entrydate
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE year_in_network = 1
    AND studentid IN (SELECT id FROM PS$STUDENTS#static WITH(NOLOCK) WHERE ENROLL_STATUS = 0 AND grade_level >= 8)
)

SELECT co.school_name
      ,co.last_name
      ,co.first_name
      ,LEFT(co.middle_name,1) AS middle_init
      ,co.cohort
      ,co.GRADE_LEVEL
      ,'School ID' AS [Student ID Type]
      ,NULL AS [Student ID Type "Other" Description]
      ,co.student_number
      ,NULL AS [Contact Owner Name]
      ,NULL AS [Contact Owner 15-Digit Salesforce ID]
      ,gr.entrydate AS [School Enrollment Date]
      ,gr.grade_level AS [School Enrollment Grade]
      ,NULL AS [Enrollment Status Comment]
      ,CASE WHEN co.SCHOOLID = 73253 AND gr.grade_level <= 8 THEN 'TRUE' ELSE 'FALSE' END AS [KIPP MS Graduate? (HS students only)]
      ,co.dob
      ,co.Gender
      ,co.Ethnicity
      ,co.STREET
      ,co.CITY
      ,co.STATE
      ,CONVERT(VARCHAR,co.ZIP) AS ZIP
      ,REPLACE(co.STUDENT_WEB_ID,'.student','') + '@teamstudents.org' AS student_email
      ,NULL AS [Student Mobile]
      ,COALESCE(co.MOTHER_HOME,co.father_home) AS home_phone
      ,LTRIM(RTRIM(LEFT(COALESCE(co.MOTHER,co.father), CHARINDEX(' ',COALESCE(co.MOTHER,co.father))))) AS [Parent1 First Name]
      ,LTRIM(RTRIM(REVERSE(LEFT(REVERSE(COALESCE(co.MOTHER,co.father)), CHARINDEX(' ',REVERSE(COALESCE(co.MOTHER,co.father))))))) AS [Parent1 Last Name]
      ,COALESCE(co.MOTHER_DAY,co.father_day) AS [Parent1 Work Phone]
      ,COALESCE(co.MOTHER_HOME,co.father_home) AS [Parent 1 Home Phone]
      ,NULL AS [Parent1 E-mail]
      ,LTRIM(RTRIM(LEFT(COALESCE(co.father,co.mother), CHARINDEX(' ',COALESCE(co.father,co.mother))))) AS [Parent2 First Name]
      ,LTRIM(RTRIM(REVERSE(LEFT(REVERSE(COALESCE(co.father,co.mother)), CHARINDEX(' ',REVERSE(COALESCE(co.father,co.mother))))))) AS [Parent2 Last Name]
      ,COALESCE(co.father_DAY,co.mother_day) AS [Parent2 Work Phone]
      ,COALESCE(co.father_HOME,co.mother_home) AS [Parent 2 Home Phone]
      ,NULL AS [Parent2 E-mail]
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)   
JOIN entry_grade gr WITH(NOLOCK)
  ON co.studentid = gr.studentid
WHERE co.enroll_status = 0
  AND co.grade_level >= 8
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1