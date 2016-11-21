USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$NJASK_roster AS

SELECT co.school_name
      ,co.SID AS [SID (NJSMART)]
      ,co.grade_level AS Grade
      ,LEFT(LTRIM(RTRIM(KIPP_NJ.dbo.fn_StripCharacters(co.LAST_NAME,'^A-Z'))), 14) AS [Last Name]
      ,LEFT(LTRIM(RTRIM(KIPP_NJ.dbo.fn_StripCharacters(co.FIRST_NAME,'^A-Z'))), 9) AS [First Name]
      ,LEFT(co.MIDDLE_NAME,1) AS [Middle Initial]
      ,CONVERT(VARCHAR,co.DOB,1) AS [Date of Birth]
      ,co.GENDER AS [Sex]
      ,CASE WHEN co.ETHNICITY = 'W' THEN 'W' END AS [Ethnic Code W]
      ,CASE WHEN co.ETHNICITY = 'B' THEN 'B' END AS [Ethnic Code B]
      ,CASE WHEN co.ETHNICITY = 'A' THEN 'A' END AS [Ethnic Code A]
      ,CASE WHEN co.ETHNICITY = 'P' THEN 'P' END AS [Ethnic Code P]
      ,CASE WHEN co.ETHNICITY = 'H' THEN 'H' END AS [Ethnic Code H]
      ,CASE WHEN co.ETHNICITY = 'I' THEN 'I' END AS [Ethnic Code I]
      ,co.STUDENT_NUMBER AS [Local Student ID Number]
      ,CASE WHEN co.LUNCHSTATUS IN ('F','R') THEN co.LUNCHSTATUS END AS [ED]
      ,CASE WHEN cs.HOMELESS_CODE = 1 THEN 'Y' END AS [Homeless]
      ,CASE WHEN cs.NJ_MIGRANT = 1 THEN 'Y' END AS [MI]
      ,CASE WHEN co.LEP_STATUS IS NOT NULL THEN '!' END AS LEP
      ,CASE WHEN co.STATUS_504 = 1 THEN 'Y' END AS Sec504
      ,CASE        
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
      ,'!' AS [SE / 504 Accom A]
      ,'!' AS [SE / 504 Accom B]
      ,'!' AS [SE / 504 Accom C]
      ,'!' AS [SE / 504 Accom D]
      ,'!' AS APA
      ,CASE WHEN co.year_in_network = 1 THEN 'Y' END AS [TID < 1]
      ,CASE WHEN co.year_in_network = 1 THEN 'Y' END AS [TIS < 1]
      ,enr.teacher_name
      ,u.SIF_STATEPRID AS [Examiner SMID]
      ,NULL AS sending_CDS_code
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND ((co.grade_level = 4 AND enr.COURSE_NUMBER = 'HR') OR (co.grade_level = 8 AND enr.CREDITTYPE = 'SCI'))  
 AND enr.course_enr_status = 0
 AND enr.drop_flags = 0
LEFT OUTER JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
  ON enr.TEACHERNUMBER = u.TEACHERNUMBER
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.GRADE_LEVEL IN (4,8)
  AND co.ENROLL_STATUS = 0 