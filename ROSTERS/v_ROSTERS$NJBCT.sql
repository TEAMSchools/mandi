USE KIPP_NJ
GO

ALTER VIEW ROSTERS$NJBCT AS

WITH bio_enrollments AS (
  SELECT cc.STUDENTID
        ,cc.COURSE_NUMBER
        ,cc.termid
        ,ROW_NUMBER() OVER(
           PARTITION BY cc.studentid, cc.termid
             ORDER BY cc.dateenrolled DESC) AS rn
  FROM PS$CC#static cc WITH(NOLOCK)
  WHERE cc.COURSE_NUMBER IN ('SCI73','SCI12','SCI47')  
    AND cc.sectionid > 0 
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
      ,'B' AS TitleIBio /* ? */
      ,CASE WHEN co.LUNCHSTATUS IN ('F','R') THEN 'Y' END AS EconomicallyDisadvantaged /* ? */
      ,cs.HOMELESS_CODE
      ,cs.NJ_MIGRANT
      ,CASE
        WHEN CONVERT(DATE,cs.NJ_LEPENDDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year() - 1,'-07-01')) THEN 'F1'
        WHEN CONVERT(DATE,cs.NJ_LEPENDDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year() - 2,'-07-01')) THEN 'F2'
        WHEN CONVERT(DATE,cs.NJ_LEPENDDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year() - 3,'-07-01')) THEN NULL
        WHEN CONVERT(DATE,cs.NJ_LEPBEGINDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(),'-07-01')) THEN '<'
        WHEN CONVERT(DATE,cs.NJ_LEPBEGINDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year() - 1,'-07-01')) THEN '1'
        WHEN CONVERT(DATE,cs.NJ_LEPBEGINDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year() - 2,'-07-01')) THEN '2'
        WHEN CONVERT(DATE,cs.NJ_LEPBEGINDATE) >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year() - 3,'-07-01')) THEN '3'
       END AS LEP
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
       END AS SE
      ,NULL AS SE_A_Setting
      ,NULL AS SE_B_Sched
      ,NULL AS SE_C_Materials
      ,NULL AS SE_D_Procedures
      ,NULL AS IEP_exempt_taking
      ,NULL AS IEP_exempt_passing
      ,CASE       
        WHEN bio.COURSE_NUMBER = 'SCI12' THEN '22'
        WHEN bio.COURSE_NUMBER = 'SCI73' THEN '11'
        WHEN bio.COURSE_NUMBER = 'SCI47' THEN '!'
       END AS course
      ,CASE 
        WHEN bio.termid = KIPP_NJ.dbo.fn_Global_Term_ID() THEN 'F'
        WHEN bio.termid = KIPP_NJ.dbo.fn_Global_Term_ID() + 1 THEN 'P'
        WHEN bio.termid = KIPP_NJ.dbo.fn_Global_Term_ID() + 2 THEN 'C'
       END AS schedule      
      ,CASE WHEN s.DISTRICTENTRYDATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-07-01') THEN 'Y' ELSE 'N' END AS TimeInDistrict_Flag
      ,CASE WHEN s.DISTRICTENTRYDATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-07-01') THEN 'Y' ELSE 'N' END AS TimeInSchool_Flag
      ,NULL AS SES
      ,NULL AS sending_CDS_code
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON co.studentid = s.ID
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
JOIN bio_enrollments bio WITH(NOLOCK)
  ON co.studentid = bio.studentid
WHERE co.ENROLL_STATUS = 0  
  AND co.SCHOOLID = 73253
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1