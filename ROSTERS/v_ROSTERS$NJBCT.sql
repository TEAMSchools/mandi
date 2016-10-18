USE KIPP_NJ
GO

ALTER VIEW ROSTERS$NJBCT AS

WITH bio_courses AS (
  SELECT COURSE_NUMBER
  FROM KIPP_NJ..PS$COURSES#static WITH(NOLOCK)
  WHERE (course_name LIKE '%Bio%' OR course_name LIKE '%Life%Sci%')
    AND course_name NOT LIKE '%ICS%'
    AND COURSE_NUMBER NOT LIKE 'SCHED%'
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
    AND cc.sectionid > 0
    AND cc.termid >= dbo.fn_Global_Term_ID()
 )

SELECT co.SID
      ,CASE         
        WHEN co.GRADE_LEVEL = 11 AND co.retained_yr_flag = 1 THEN 'R11'
        WHEN co.GRADE_LEVEL = 12 AND co.retained_yr_flag = 1 THEN 'R12'
        ELSE CONVERT(VARCHAR,co.grade_level)
       END AS grade_level      
      ,LEFT(KIPP_NJ.dbo.fn_StripCharacters(co.LAST_NAME,'^A-Z '),14) AS last_name
      ,LEFT(KIPP_NJ.dbo.fn_StripCharacters(co.FIRST_NAME,'^A-Z '), 9) AS first_name      
      ,LEFT(co.MIDDLE_NAME,1) AS MiddleInitial
      ,CONVERT(VARCHAR,co.DOB,1) AS DOB
      ,co.GENDER AS sex
      ,CASE WHEN co.ETHNICITY = 'W' THEN co.ETHNICITY END AS ethnic_code_w
      ,CASE WHEN co.ETHNICITY = 'B' THEN co.ETHNICITY END AS ethnic_code_b
      ,CASE WHEN co.ETHNICITY = 'A' THEN co.ETHNICITY END AS ethnic_code_a
      ,CASE WHEN co.ETHNICITY = 'P' THEN co.ETHNICITY END AS ethnic_code_p
      ,CASE WHEN co.ETHNICITY = 'H' THEN co.ETHNICITY END AS ethnic_code_h
      ,CASE WHEN co.ETHNICITY = 'I' THEN co.ETHNICITY END AS ethnic_code_i
      ,co.STUDENT_NUMBER AS DistrictSchool_StudentID      
      ,'B' AS TitleIBio
      ,CASE WHEN co.LUNCHSTATUS IN ('F','R') THEN 'Y' END AS EconDis_Flag
      ,NULL AS homeless
      ,NULL AS migrant
      ,co.LEP_STATUS
      ,CASE WHEN co.STATUS_504 = 1 THEN 'Y' END AS Sec504
      ,CASE
        WHEN co.SPED_code IS NULL THEN NULL
        WHEN co.sped_code = 'AI' THEN '01'
        WHEN co.sped_code = 'AUT' THEN '02'
        WHEN co.sped_code = 'CMI' THEN '03'
        WHEN co.sped_code = 'CMO' THEN '04'
        WHEN co.sped_code = 'CSE' THEN '05'
        WHEN co.sped_code = 'CI' THEN '06'
        WHEN co.sped_code = 'ED' THEN '07'
        WHEN co.sped_code = 'MD' THEN '08'
        WHEN co.sped_code = 'DB' THEN '09'
        WHEN co.sped_code = 'OI' THEN '10'
        WHEN co.sped_code = 'OHI' THEN '11'
        WHEN co.sped_code = 'PSD' THEN '12'
        WHEN co.sped_code = 'SM' THEN '13' /* no longer valid */
        WHEN co.sped_code = 'SLD' THEN '14'
        WHEN co.sped_code = 'TBI' THEN '15'
        WHEN co.sped_code = 'VI' THEN '16'
        WHEN co.sped_code = 'ESLS' THEN '17'
        ELSE RIGHT(CONCAT('0',co.sped_code),2)
       END AS SE
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
       END AS course      
      ,CASE 
        WHEN bio.termid = KIPP_NJ.dbo.fn_Global_Term_ID() THEN 'F'
        WHEN bio.termid = KIPP_NJ.dbo.fn_Global_Term_ID() + 1 THEN 'P'
        WHEN bio.termid = KIPP_NJ.dbo.fn_Global_Term_ID() + 2 THEN 'C'
       END AS schedule      
      ,CASE WHEN co.ENTRYDATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-07-01') THEN 'Y' ELSE 'N' END AS TimeInDistrict_Flag
      ,CASE WHEN co.entry_schoolid != 73253 OR co.entry_schoolid IS NULL THEN 'Y' ELSE 'N' END AS TimeInSchool_Flag
      ,NULL AS SES
      ,NULL AS sending_CDS_code
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN bio_enrollments bio WITH(NOLOCK)
  ON co.studentid = bio.studentid
 AND bio.rn = 1
WHERE co.ENROLL_STATUS = 0  
  AND co.SCHOOLID = 73253
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1