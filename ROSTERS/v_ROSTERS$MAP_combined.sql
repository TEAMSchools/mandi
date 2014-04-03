/*--! MAP Combined Import File !--*/
  -- Maintenance --
  -- ANNUAL: add any new schoolids

ALTER VIEW ROSTERS$MAP_combined AS

WITH roster AS (
  SELECT sch.ABBREVIATION
        ,s.SCHOOLID
        ,s.ID
        ,s.STUDENT_NUMBER
        ,s.LAST_NAME
        ,s.FIRST_NAME
        ,LEFT(s.MIDDLE_NAME,1) AS middle_initial
        ,s.TEAM
        ,CONVERT(VARCHAR,s.DOB,101) AS DOB
        ,s.GENDER
        ,CASE WHEN s.GRADE_LEVEL = 0 THEN 'K' ELSE CONVERT(VARCHAR,s.GRADE_LEVEL) END AS grade_level -- Kindergarten needs to be K, not 0
        ,CASE WHEN s.ETHNICITY = 'T' THEN 'B' ELSE s.ETHNICITY END AS ethnicity -- NWEA is racist, import rejects ethnicity 'T'
  FROM STUDENTS s
  JOIN SCHOOLS sch
    ON s.SCHOOLID = sch.SCHOOL_NUMBER
  WHERE s.ENROLL_STATUS = 0
 )
 
,teacher_courses AS (
  SELECT t.TEACHERNUMBER
        ,t.LAST_NAME
        ,t.FIRST_NAME
        ,LEFT(t.MIDDLE_NAME,1) AS middle_initial        
        ,t.TEACHERLOGINID + '@teamschools.org' AS email_addr
        ,c.CREDITTYPE
        ,c.COURSE_NUMBER
        ,sec.SECTION_NUMBER
        ,cc.TERMID
        ,cc.STUDENTID
  FROM CC
  JOIN COURSES c
    ON cc.COURSE_NUMBER = c.COURSE_NUMBER
   AND ((c.CREDITTYPE IN ('MATH','ENG','SCI','RHET') AND cc.SCHOOLID IN (73252,73253,133570965)) -- MS/HS by course
           OR (c.COURSE_NAME = 'HR'  AND cc.SCHOOLID IN (73254,73255,73256))) -- ES only for HR teacher
  JOIN SECTIONS sec
    ON CC.SECTIONID = sec.ID
  JOIN TEACHERS t
    ON sec.TEACHER = t.ID  
  WHERE cc.TERMID >= dbo.fn_Global_Term_Id()
    AND cc.SECTIONID >= 0
 )

SELECT DISTINCT
       r.ABBREVIATION AS [School Name]
      ,tc.TEACHERNUMBER AS [Previous Instructor ID]
      ,tc.TEACHERNUMBER AS [Instructor ID]
      ,tc.LAST_NAME AS [Instructor Last Name]
      ,tc.FIRST_NAME AS [Instructor First Name]
      ,tc.middle_initial AS [Instructor Middle Initial]
      ,tc.EMAIL_ADDR AS [User Name]
      ,tc.EMAIL_ADDR AS [Email Address]
      ,CASE
        WHEN r.SCHOOLID IN (73252,133570965) THEN tc.CREDITTYPE + '_' + CONVERT(VARCHAR,r.GRADE_LEVEL)
        WHEN r.SCHOOLID IN (73254,73255,73256) THEN r.TEAM + '_' + CONVERT(VARCHAR,r.GRADE_LEVEL)
        WHEN r.SCHOOLID = 73253 THEN tc.COURSE_NUMBER + '_sect_' + tc.SECTION_NUMBER
       END AS [Class Name]
      ,r.STUDENT_NUMBER AS [Previous Student ID]
      ,r.STUDENT_NUMBER AS [Student ID]
      ,r.LAST_NAME AS [Student Last Name]
      ,r.FIRST_NAME AS [Student First Name]
      ,r.middle_initial AS [Student Middle Initial]
      ,r.DOB AS [Student Date of Birth]
      --required for reporting--
      ,r.GENDER AS [Student Gender]
      ,r.GRADE_LEVEL AS [Student Grade]
      ,r.ETHNICITY AS [Student Ethnic Group Name]
      ,CONVERT(VARCHAR,r.ID) + '_' + ISNULL(tc.CREDITTYPE,'HR') AS audit_hash
FROM roster r
JOIN teacher_courses tc
  ON r.ID = tc.STUDENTID