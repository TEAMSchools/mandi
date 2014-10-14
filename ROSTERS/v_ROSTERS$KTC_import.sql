USE KIPP_NJ
GO

ALTER VIEW ROSTERS$KTC_import AS

WITH entry_grade AS (
  SELECT studentid
        ,grade_level
        ,entrydate
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE year_in_network = 1
    AND studentid IN (SELECT id FROM STUDENTS WITH(NOLOCK) WHERE ENROLL_STATUS = 0 AND grade_level >= 8)
)

SELECT REPLACE(sch.NAME,' Charter SChool','') AS school_name
      ,s.last_name
      ,s.first_name
      ,LEFT(s.middle_name,1) AS middle_init
      ,co.cohort
      ,s.GRADE_LEVEL
      ,'School ID' AS [Student ID Type]
      ,NULL AS [Student ID Type "Other" Description]
      ,s.student_number
      ,NULL AS [Contact Owner Name]
      ,NULL AS [Contact Owner 15-Digit Salesforce ID]
      ,gr.entrydate AS [School Enrollment Date]
      ,gr.grade_level AS [School Enrollment Grade]
      ,NULL AS [Enrollment Status Comment]
      ,CASE WHEN s.SCHOOLID = 73253 AND gr.grade_level <= 8 THEN 'TRUE' ELSE 'FALSE' END AS [KIPP MS Graduate? (HS students only)]
      ,s.dob
      ,s.Gender
      ,s.Ethnicity
      ,s.STREET
      ,s.CITY
      ,s.STATE
      ,CONVERT(VARCHAR,s.ZIP) AS ZIP
      ,REPLACE(cs.DEFAULT_STUDENT_WEB_ID,'.student','') + '@teamstudents.org' AS student_email
      ,NULL AS [Student Mobile]
      ,COALESCE(cs.MOTHER_HOME,cs.father_home) AS home_phone
      ,LTRIM(RTRIM(LEFT(COALESCE(s.MOTHER,s.father), CHARINDEX(' ',COALESCE(s.MOTHER,s.father))))) AS [Parent1 First Name]
      ,LTRIM(RTRIM(REVERSE(LEFT(REVERSE(COALESCE(s.MOTHER,s.father)), CHARINDEX(' ',REVERSE(COALESCE(s.MOTHER,s.father))))))) AS [Parent1 Last Name]
      ,COALESCE(cs.MOTHER_DAY,cs.father_day) AS [Parent1 Work Phone]
      ,COALESCE(cs.MOTHER_HOME,cs.father_home) AS [Parent 1 Home Phone]
      ,NULL AS [Parent1 E-mail]
      ,LTRIM(RTRIM(LEFT(COALESCE(s.father,s.mother), CHARINDEX(' ',COALESCE(s.father,s.mother))))) AS [Parent2 First Name]
      ,LTRIM(RTRIM(REVERSE(LEFT(REVERSE(COALESCE(s.father,s.mother)), CHARINDEX(' ',REVERSE(COALESCE(s.father,s.mother))))))) AS [Parent2 Last Name]
      ,COALESCE(cs.father_DAY,cs.mother_day) AS [Parent2 Work Phone]
      ,COALESCE(cs.father_HOME,cs.mother_home) AS [Parent 2 Home Phone]
      ,NULL AS [Parent2 E-mail]
FROM STUDENTS s WITH(NOLOCK)
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON s.id = co.studentid
 AND co.year = dbo.fn_Global_Academic_Year()
 AND co.rn = 1
JOIN entry_grade gr WITH(NOLOCK)
  ON co.studentid = gr.studentid
JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.STUDENTID
JOIN SCHOOLS sch WITH(NOLOCK)
  ON s.schoolid = sch.school_number
WHERE s.enroll_status = 0
  AND s.grade_level >= 8