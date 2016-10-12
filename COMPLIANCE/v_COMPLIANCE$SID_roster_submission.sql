USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$SID_roster_submission AS

WITH attendance AS (
  SELECT STUDENTID
        ,academic_year
        ,SUM(CONVERT(INT,MEMBERSHIPVALUE)) AS N_membership
        ,SUM(CONVERT(INT,ATTENDANCEVALUE)) AS N_present
        ,CASE
          WHEN SUM(CONVERT(INT,MEMBERSHIPVALUE)) - SUM(CONVERT(INT,ATTENDANCEVALUE)) - 10 < 0 THEN 0
          ELSE SUM(CONVERT(INT,MEMBERSHIPVALUE)) - SUM(CONVERT(INT,ATTENDANCEVALUE)) - 10 
         END AS N_daystruant
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)
  WHERE MEMBERSHIPVALUE = 1
    AND academic_year = (KIPP_NJ.dbo.fn_Global_Academic_Year() - 1)
  GROUP BY STUDENTID
          ,academic_year
 )

SELECT s.student_number AS LocalIdentificationNumber
      ,s.STATE_STUDENTNUMBER AS StateIdentificationNumber
      ,s.first_name AS FirstName
      ,cs.MIDDLE_NAME_CUSTOM AS MiddleName /* use custom field */
      ,s.last_name AS LastName
      ,NULL AS GenerationCodeSuffix
      ,s.Gender
      ,CASE
        WHEN s.DOB = '1900-01-01' THEN NULL
        ELSE REPLACE(CONVERT(DATE,s.dob),'-','') 
       END AS DateOfBirth
      ,cs.NJ_CityofBirth AS CityOfBirth      
      ,CASE
        WHEN cs.NJ_STATEOFBIRTH IS NULL THEN NULL
        WHEN CHARINDEX(' ',cs.NJ_StateOfBirth) = 0 THEN UPPER(LEFT(cs.NJ_StateOfBirth,2))
        ELSE CONCAT(LEFT(cs.NJ_StateOfBirth,1) , SUBSTRING(cs.NJ_StateOfBirth, CHARINDEX(' ',cs.NJ_StateOfBirth) + 1, 1))
       END AS StateOfBirth
      ,CASE WHEN cs.NJ_CountryOfBirth = 'UNITED STATES' THEN '2330' END AS CountryOfBirth
      ,CASE WHEN s.ethnicity = 'H' THEN 'Y' ELSE 'N' END AS Ethnicity
      ,CASE WHEN s.ethnicity = 'I' THEN 'Y' ELSE 'N' END AS RaceAmericanIndian
      ,CASE WHEN s.ethnicity = 'A' THEN 'Y' ELSE 'N' END AS RaceAsian
      ,CASE WHEN s.ethnicity = 'B' THEN 'Y' ELSE 'N' END AS RaceBlack
      ,CASE WHEN s.ethnicity = 'P' THEN 'Y' ELSE 'N' END AS RacePacific
      ,CASE WHEN s.ethnicity = 'W' THEN 'Y' ELSE 'N' END AS RaceWhite
      ,CASE WHEN s.enroll_status = 0 THEN 'A' ELSE 'I' END AS Status /* we need to know which students are active in NJSMART but inactive on PS */
      ,'F' AS EnrollmentType
      
      /* home district */
      ,s.CITY AS CITY_NOIMPORT
      ,CASE WHEN s.CITY = 'Newark' THEN '13' WHEN s.CITY = 'Camden' THEN '07' END AS CountyCodeResident
      ,CASE WHEN s.CITY = 'Newark' THEN '3570' WHEN s.CITY = 'Camden' THEN '0680' END AS DistrictCodeResident
      ,NULL AS SchoolCodeResident /* 050 for Newark, ? for Camden */
      
      /* always us */
      ,CASE
        WHEN s.DISTRICTENTRYDATE = '1900-01-01' THEN NULL
        ELSE REPLACE(CONVERT(DATE,s.DistrictEntryDate),'-','') 
       END AS DistrictEntryDate /* compare PS vs NJSMART and choose one */
      ,CASE WHEN s.schoolid LIKE '1799%' THEN '07' ELSE '80' END AS CountyCodeReceiving      
      ,CASE WHEN s.schoolid LIKE '1799%' THEN '1799' ELSE '7325' END AS DistrictCodeReceiving
      ,CASE WHEN s.schoolid LIKE '1799%' THEN '111' ELSE '965' END AS SchoolCodeReceiving
      
      /* manual updates needed for out of district placements -- ASK KERRY, FIND BETTER SYSTEM OF TRACKING */
      ,CASE WHEN s.schoolid LIKE '1799%' THEN '07' ELSE '80' END AS CountyCodeAttending      
      ,CASE WHEN s.schoolid LIKE '1799%' THEN '1799' ELSE '7325' END AS DistrictCodeAttending
      ,CASE WHEN s.schoolid LIKE '1799%' THEN '111' ELSE '965' END AS SchoolCodeAttending
      
      ,CASE 
        WHEN s.GRADE_LEVEL = 99 THEN NULL
        ELSE (KIPP_NJ.dbo.fn_Global_Academic_Year() + 1) + (12 - s.grade_level) 
       END AS YearOfGraduation
      ,CASE
        WHEN s.DISTRICTENTRYDATE = '1900-01-01' THEN NULL
        ELSE REPLACE(CONVERT(DATE,s.DistrictEntryDate),'-','') 
       END AS SchoolEntryDate
      ,CASE WHEN s.enroll_status != 0 THEN REPLACE(CONVERT(DATE,s.exitdate),'-','') END AS SchoolExitDate
      ,CASE WHEN s.enroll_status != 0 THEN s.exitcode END AS SchoolExitWithdrawalCode /* only for inactive students -- watch out for T2's */
      
      /* SID = inactive; State Submission = active */
      ,CASE WHEN s.enroll_status != 0 THEN att.N_membership END AS CumulativeDaysInMembership
      ,CASE WHEN s.enroll_status != 0 THEN att.N_present END AS CumulativeDaysPresent
      ,CASE WHEN s.enroll_status != 0 THEN att.N_daystruant END AS CumulativeDaysTowardsTruancy      
      
      ,NULL AS Tuitioncode
      ,CASE WHEN s.lunchstatus IN ('F','R') THEN s.lunchstatus ELSE 'N' END AS FreeAndReducedRateLunchStatus      
      ,CASE 
        WHEN s.GRADE_LEVEL = 99 THEN NULL
        WHEN s.GRADE_LEVEL = 0 THEN 'KF' 
        ELSE RIGHT(CONCAT('0',CONVERT(VARCHAR,s.GRADE_LEVEL)),2) 
       END AS GradeLevel
      ,CASE 
        WHEN s.GRADE_LEVEL = 99 THEN NULL
        WHEN s.GRADE_LEVEL = 0 THEN 'KF' 
        ELSE RIGHT(CONCAT('0',CONVERT(VARCHAR,s.GRADE_LEVEL)),2) 
       END AS ProgramTypeCode /* do we have the special ed classes? SPED code? */
      ,CASE WHEN co.retained_yr_flag = 1 THEN 'Y' ELSE 'N' END AS Retained
      ,CASE
        WHEN iep.SPECIAL_EDUCATION = 'AI' THEN '01'
        WHEN iep.SPECIAL_EDUCATION = 'AUT' THEN '02'
        WHEN iep.SPECIAL_EDUCATION = 'CMI' THEN '03'
        WHEN iep.SPECIAL_EDUCATION = 'CMO' THEN '04'
        WHEN iep.SPECIAL_EDUCATION = 'CSE' THEN '05'
        WHEN iep.SPECIAL_EDUCATION = 'CI' THEN '06'
        WHEN iep.SPECIAL_EDUCATION = 'ED' THEN '07'
        WHEN iep.SPECIAL_EDUCATION = 'MD' THEN '08'
        WHEN iep.SPECIAL_EDUCATION = 'DB' THEN '09'
        WHEN iep.SPECIAL_EDUCATION = 'OI' THEN '10'
        WHEN iep.SPECIAL_EDUCATION = 'OHI' THEN '11'
        WHEN iep.SPECIAL_EDUCATION = 'PSD' THEN '12'
        WHEN iep.SPECIAL_EDUCATION = 'SM' THEN '13' /* no longer valid */
        WHEN iep.SPECIAL_EDUCATION = 'SLD' THEN '14'
        WHEN iep.SPECIAL_EDUCATION = 'TBI' THEN '15'
        WHEN iep.SPECIAL_EDUCATION = 'VI' THEN '16'
        WHEN iep.SPECIAL_EDUCATION = 'ESLS' THEN '17'
        ELSE iep.SPECIAL_EDUCATION
       END AS SpecialEducationClassification /* audit 00, 99, 12 (PSD) students */
      ,CASE WHEN cs.LEP_STATUS IS NOT NULL THEN '!' END AS LEPProgramStartDate /* hand entry -- SPED follow up */
      ,CASE WHEN cs.LEP_STATUS IS NOT NULL THEN '!' END AS LEPProgramCompletionDate /* hand entry -- SPED follow up */
      ,NULL AS NonPublic /* out-of-district placements? SPED follow up */
      ,CASE 
        WHEN s.city = 'Newark' THEN '0714'
        WHEN s.city = 'Camden' THEN '0408'
       END AS ResidentMunicipalCode
      ,4 AS MilitaryConnectedStudentIndicator
      ,s.SCHOOLID
      ,CASE WHEN s.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region
FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)  
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
  ON s.id = cs.STUDENTID
LEFT OUTER JOIN KIPP_NJ..PS$IEP_details#static iep
  ON s.id = iep.STUDENTID
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON s.ID = co.studentid
 AND co.all_years_rn = 1
LEFT OUTER JOIN attendance att
  ON s.id = att.STUDENTID