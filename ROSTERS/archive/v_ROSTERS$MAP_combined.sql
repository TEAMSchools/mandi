USE KIPP_NJ
GO

ALTER VIEW ROSTERS$MAP_combined AS

WITH roster AS (
  SELECT s.school_name
        ,s.SCHOOLID
        ,s.studentid
        ,s.STUDENT_NUMBER
        ,s.LAST_NAME
        ,s.FIRST_NAME
        ,LEFT(s.MIDDLE_NAME,1) AS middle_initial
        ,s.TEAM
        ,CONVERT(VARCHAR,s.DOB,101) AS DOB
        ,s.GENDER
        ,CASE WHEN s.GRADE_LEVEL = 0 THEN 'K' ELSE CONVERT(VARCHAR,s.GRADE_LEVEL) END AS grade_level -- Kindergarten needs to be K, not 0
        ,CASE WHEN s.ETHNICITY = 'T' THEN 'B' ELSE s.ETHNICITY END AS ethnicity -- NWEA is racist, import rejects ethnicity 'T'
  FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)  
  WHERE s.ENROLL_STATUS = 0
    AND s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND s.rn = 1
 )
 
,teacher_courses AS (
  SELECT t.TEACHERNUMBER
        ,t.LAST_NAME
        ,t.FIRST_NAME
        ,LEFT(t.MIDDLE_NAME,1) AS middle_initial        
        ,CASE
          WHEN t.TEACHERLOGINID IS NULL THEN LOWER(LEFT(t.first_name,1) + KIPP_NJ.dbo.REMOVESPECIALCHARS(t.LAST_NAME))
          ELSE t.TEACHERLOGINID            
         END + '@kippnj.org' AS email_addr
        ,c.CREDITTYPE
        ,c.COURSE_NUMBER
        ,sec.SECTION_NUMBER
        ,cc.TERMID
        ,cc.STUDENTID
  FROM PS$CC#static cc
  JOIN PS$COURSES#static c
    ON cc.COURSE_NUMBER = c.COURSE_NUMBER
   AND ((c.CREDITTYPE IN ('MATH','ENG','SCI','RHET') AND cc.SCHOOLID IN (73252,73253,133570965,73258,179902)) -- MS/HS by course /*--UPDATE FOR NEW SCHOOLS--*/
           OR (c.COURSE_NAME = 'HR'  AND cc.SCHOOLID IN (73254,73255,73256,73257,179901))) -- ES only for HR teacher /*--UPDATE FOR NEW SCHOOLS--*/
  JOIN PS$SECTIONS#static sec
    ON CC.SECTIONID = sec.ID
  JOIN PS$TEACHERS#static t
    ON sec.TEACHER = t.ID  
  WHERE cc.TERMID >= KIPP_NJ.dbo.fn_Global_Term_Id()  
    AND cc.SECTIONID >= 0    
 )

SELECT DISTINCT
       r.school_name AS [School Name]
      ,tc.TEACHERNUMBER AS [Previous Instructor ID]
      ,tc.TEACHERNUMBER AS [Instructor ID]
      ,tc.LAST_NAME AS [Instructor Last Name]
      ,tc.FIRST_NAME AS [Instructor First Name]
      ,tc.middle_initial AS [Instructor Middle Initial]
      ,tc.EMAIL_ADDR AS [User Name]
      ,tc.EMAIL_ADDR AS [Email Address]
      ,CASE
        WHEN r.SCHOOLID IN (73252,133570965,73258,179902) THEN tc.CREDITTYPE + '_' + CONVERT(VARCHAR,r.GRADE_LEVEL) /*--UPDATE FOR NEW SCHOOLS--*/
        WHEN r.SCHOOLID IN (73254,73255,73256,73257,179901) THEN r.TEAM + '_' + CONVERT(VARCHAR,r.GRADE_LEVEL) /*--UPDATE FOR NEW SCHOOLS--*/
        WHEN r.SCHOOLID = 73253 THEN tc.COURSE_NUMBER + '_sect_' + tc.SECTION_NUMBER /*--UPDATE FOR NEW SCHOOLS--*/
       END AS [Class Name]
      ,r.STUDENT_NUMBER AS [Previous Student ID]
      ,r.STUDENT_NUMBER AS [Student ID]
      ,r.LAST_NAME AS [Student Last Name]
      ,r.FIRST_NAME AS [Student First Name]
      ,r.middle_initial AS [Student Middle Initial]
      ,r.DOB AS [Student Date of Birth]      
      ,r.GENDER AS [Student Gender]
      ,r.GRADE_LEVEL AS [Student Grade]
      ,r.ETHNICITY AS [Student Ethnic Group Name]
      ,CONVERT(VARCHAR,r.studentid) + '_' + ISNULL(tc.course_number,'HR') AS audit_hash
FROM roster r
JOIN teacher_courses tc
  ON r.studentid = tc.STUDENTID