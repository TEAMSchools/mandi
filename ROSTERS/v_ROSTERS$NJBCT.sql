USE KIPP_NJ
GO

ALTER VIEW ROSTERS$NJBCT AS

WITH entrydate AS (
  SELECT co.STUDENTID
        ,co.ENTRYDATE
        ,co.ENTRYCODE
        ,co.year
        ,prev.grade_level AS prev_grade
        ,prev.schoolid AS prev_school
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN COHORT$comprehensive_long#static prev WITH(NOLOCK)
    ON co.studentid = prev.studentid
   AND prev.year = (dbo.fn_Global_Academic_Year() - 1)   
   AND prev.rn = 1
  WHERE co.YEAR_IN_NETWORK = 1
    AND co.RN = 1    
 )

,bio_courses AS (
  SELECT COURSE_NUMBER
  FROM KIPP_NJ..PS$COURSES#static WITH(NOLOCK)
  WHERE (course_name LIKE '%Bio%' OR course_name LIKE '%Life%Sci%')
    AND course_name NOT LIKE '%ICS%'
    AND COURSE_NUMBER NOT LIKE 'SCHED%'
 )

,hs_students AS (
  SELECT studentid
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE year = dbo.fn_Global_Academic_Year()
    AND grade_level >= 9
    AND rn = 1
 )

,bio_enrollments AS (
  SELECT cc.STUDENTID
        ,cc.COURSE_NUMBER
        ,cc.termid
        ,cc.schoolid
        ,cou.course_name      
        ,ROW_NUMBER() OVER(
           PARTITION BY cc.studentid
             ORDER BY cc.dateenrolled DESC) AS rn
  FROM PS$CC#static cc WITH(NOLOCK)
  JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
    ON cc.COURSE_NUMBER = cou.COURSE_NUMBER   
  WHERE cc.SCHOOLID IN (73252,73253,133570965)
    AND cc.COURSE_NUMBER IN (SELECT COURSE_NUMBER FROM bio_courses WITH(NOLOCK))
    AND cc.studentid IN (SELECT studentid FROM hs_students WITH(NOLOCK))
    AND cc.sectionid > 0
    AND cc.termid >= dbo.fn_Global_Term_ID()
 )

SELECT cs.SID
      ,CASE 
        WHEN s.GRADE_LEVEL > entrydate.prev_grade OR entrydate.prev_grade IS NULL THEN CONVERT(VARCHAR,s.grade_level)
        WHEN s.GRADE_LEVEL = 11 AND s.grade_level = entrydate.prev_grade THEN 'R11'
        WHEN s.GRADE_LEVEL = 11 AND s.grade_level = entrydate.prev_grade THEN 'R12'
        ELSE CONVERT(VARCHAR,s.grade_level)
       END AS grade_level      
      ,LEFT(LTRIM(RTRIM(dbo.fn_StripCharacters(REPLACE(s.LAST_NAME,'Jr',''),'^A-Z'))), 14) AS last_name
      ,LEFT(LTRIM(RTRIM(dbo.fn_StripCharacters(s.FIRST_NAME,'^A-Z'))), 9) AS first_name      
      ,LEFT(s.MIDDLE_NAME,1) AS MiddleInitial            
      ,CONVERT(VARCHAR,s.DOB,1) AS DOB
      ,s.GENDER
      ,CASE WHEN s.ETHNICITY = 'W' THEN s.ETHNICITY END AS ethnic_code_white
      ,CASE WHEN s.ETHNICITY IN ('B','T') THEN 'B' END AS ethnic_code_black
      ,CASE WHEN s.ETHNICITY = 'A' THEN s.ETHNICITY END AS ethnic_code_asian
      ,CASE WHEN s.ETHNICITY = 'P' THEN s.ETHNICITY END AS ethnic_code_hawaiian
      ,CASE WHEN s.ETHNICITY = 'H' THEN s.ETHNICITY END AS ethnic_code_hispanic
      ,CASE WHEN s.ETHNICITY = 'I' THEN s.ETHNICITY END AS ethnic_code_amerindian
      ,s.STUDENT_NUMBER AS DistrictSchool_StudentID      
      ,'B' AS TitleIBio
      ,CASE WHEN s.LUNCHSTATUS IN ('F','R') THEN 'Y' END AS EconDis_Flag
      ,NULL AS homeless_flag
      ,NULL AS migrant_flag
      ,CASE WHEN cs.SPEDLEP = 'LEP' THEN 'Y' END AS LEP
      ,CASE WHEN cs.STATUS_504 = 1 THEN 'Y' END AS Sec504
      ,CASE WHEN cs.SPEDLEP LIKE '%SPED%' THEN LEFT(cs.SPEDLEP_CODE,2) ELSE NULL END AS SE_code
      ,NULL AS SE_A_Setting
      ,NULL AS SE_B_Sched
      ,NULL AS SE_C_Materials
      ,NULL AS SE_D_Procedures
      ,NULL AS IEP_exempt_taking
      ,NULL AS IEP_exempt_passing
      ,CASE 
        WHEN bio.course_name IS NULL THEN NULL
        WHEN bio.course_name = 'AP Biology' THEN 41
        WHEN bio.course_name IN ('Honors Biology', 'Sci II Biology Honors') THEN 32        
        WHEN bio.course_name IN ('Sci II Biology','Biology') THEN 31
        WHEN bio.course_name LIKE '%Life %Science%' THEN 23
        WHEN bio.course_name IS NOT NULL THEN 53        
        ELSE 0
       END AS course      
      ,CASE 
        WHEN bio.termid IS NULL THEN NULL
        WHEN bio.termid = dbo.fn_Global_Term_ID() THEN 'F'
        WHEN bio.termid = dbo.fn_Global_Term_ID() + 1 THEN 'P'
        WHEN bio.termid = dbo.fn_Global_Term_ID() + 2 THEN 'C'
        ELSE '0'
       END AS schedule      
      ,CASE WHEN entrydate.ENTRYDATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-07-01') THEN 'Y' ELSE 'N' END AS TimeInDistrict_Flag
      ,CASE WHEN entrydate.prev_school != 73253 OR entrydate.prev_school IS NULL THEN 'Y' ELSE 'N' END AS TimeInSchool_Flag
      ,NULL AS SES
      ,NULL AS sending_CDS_code
FROM PS$STUDENTS#static s WITH(NOLOCK)
LEFT OUTER JOIN PS$CUSTOM_STUDENTS#static cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN entrydate WITH(NOLOCK)
  ON s.ID = entrydate.STUDENTID  
JOIN bio_enrollments bio WITH(NOLOCK)
  ON s.id = bio.studentid
 AND bio.rn = 1
WHERE s.ENROLL_STATUS = 0  
  AND s.SCHOOLID = 73253