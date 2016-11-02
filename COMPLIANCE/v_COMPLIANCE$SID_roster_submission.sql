USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$SID_roster_submission AS

WITH attendance AS (
  SELECT STUDENTID
        ,academic_year
        ,MIN(CASE WHEN ATTENDANCEVALUE = 1 THEN CONVERT(DATE,CALENDARDATE) END) AS min_attendance_date
        ,SUM(CONVERT(INT,MEMBERSHIPVALUE)) AS N_membership
        ,SUM(CONVERT(INT,ATTENDANCEVALUE)) AS N_present
        ,CASE
          WHEN SUM(CONVERT(INT,MEMBERSHIPVALUE)) - SUM(CONVERT(INT,ATTENDANCEVALUE)) - 10 < 0 THEN 0
          ELSE SUM(CONVERT(INT,MEMBERSHIPVALUE)) - SUM(CONVERT(INT,ATTENDANCEVALUE)) - 10 
         END AS N_daystruant
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)
  WHERE MEMBERSHIPVALUE = 1    
  GROUP BY STUDENTID
          ,academic_year
 )

SELECT co.student_number AS LocalIdentificationNumber
      ,co.SID AS StateIdentificationNumber
      ,ISNULL(nj.FirstName,co.first_name) AS FirstName
      ,ISNULL(nj.MiddleName,cs.MIDDLE_NAME_CUSTOM) AS MiddleName /* use custom field */
      ,ISNULL(nj.LastName,co.last_name) AS LastName
      ,nj.GenerationCodeSuffix
      ,co.Gender
      ,REPLACE(CONVERT(DATE,co.dob),'-','') AS DateOfBirth
      ,CASE WHEN nj.stateidentificationnumber IS NULL THEN cs.NJ_CITYOFBIRTH ELSE nj.CityOfBirth END AS CityOfBirth
      ,CASE WHEN nj.stateidentificationnumber IS NULL THEN cs.NJ_STATEOFBIRTH ELSE nj.StateOfBirth END AS StateOfBirth
      ,CASE 
        WHEN nj.stateidentificationnumber IS NULL AND cs.NJ_COUNTRYOFBIRTH = 'UNITED STATES' THEN 2230
        ELSE nj.CountryOfBirth 
       END AS CountryOfBirth
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN nj.ethnicity
        WHEN co.ethnicity = 'H' THEN 'Y' 
        ELSE 'N' 
       END AS Ethnicity
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN nj.raceamericanindian
        WHEN co.ethnicity = 'I' THEN 'Y' 
        ELSE 'N' 
       END AS RaceAmericanIndian
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN nj.raceasian
        WHEN co.ethnicity = 'A' THEN 'Y' 
        ELSE 'N' 
       END AS RaceAsian
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN nj.raceblack
        WHEN co.ethnicity = 'B' THEN 'Y' 
        ELSE 'N' 
       END AS RaceBlack
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN nj.racepacific
        WHEN co.ethnicity = 'P' THEN 'Y' 
        ELSE 'N' 
       END AS RacePacific
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN nj.racewhite
        WHEN co.ethnicity = 'W' THEN 'Y' 
        ELSE 'N' 
       END AS RaceWhite
      ,'A' AS Status /* we need to know which students are active in NJSMART but inactive on PS */
      ,'F' AS EnrollmentType
      
      /* home district */      
      ,CASE 
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid LIKE '1799%' THEN '07'
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid NOT LIKE '1799%' THEN '13'
        ELSE RIGHT(CONCAT('0',nj.CountyCodeResident),2) 
       END AS CountyCodeResident
      ,CASE 
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid LIKE '1799%' THEN '0680'
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid NOT LIKE '1799%' THEN '3570'
        ELSE RIGHT(CONCAT('0',nj.DistrictCodeResident),4) 
       END AS DistrictCodeResident
      ,CASE 
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid LIKE '1799%' THEN '165'
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid NOT LIKE '1799%' THEN '965'
        ELSE RIGHT(CONCAT('0',nj.SchoolCodeResident),3) 
       END AS SchoolCodeResident
            
      /* 1st attendance date for new students */
      ,CASE WHEN nj.stateidentificationnumber IS NULL THEN REPLACE(att.min_attendance_date,'-','') ELSE nj.DistrictEntryDate END AS DistrictEntryDate
      
      /* always us */
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN RIGHT(CONCAT('0',nj.CountyCodeReceiving),2) 
        WHEN co.schoolid LIKE '1799%' THEN '07'
        ELSE '80'
       END AS CountyCodeReceiving
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN RIGHT(CONCAT('0',nj.DistrictCodeReceiving),4) 
        WHEN co.schoolid LIKE '1799%' THEN '1799'
        ELSE '7325'
       END AS DistrictCodeReceiving
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN RIGHT(CONCAT('0',nj.SchoolCodeReceiving),3) 
        WHEN co.schoolid LIKE '1799%' THEN '111'
        ELSE '965'
       END AS SchoolCodeReceiving
      
      /* manual updates needed for out of district placements -- ASK KERRY, FIND BETTER SYSTEM OF TRACKING */
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN RIGHT(CONCAT('0',nj.CountyCodeAttending),2) 
        WHEN co.schoolid LIKE '1799%' THEN '07'
        ELSE '80'
       END AS CountyCodeAttending
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN RIGHT(CONCAT('0',nj.DistrictCodeAttending),4) 
        WHEN co.schoolid LIKE '1799%' THEN '1799'
        ELSE '7325'
       END AS DistrictCodeAttending
      ,CASE 
        WHEN nj.stateidentificationnumber IS NOT NULL THEN RIGHT(CONCAT('0',nj.SchoolCodeAttending),3) 
        WHEN co.schoolid LIKE '1799%' THEN '165'
        ELSE '965'
       END AS SchoolCodeAttending
      
      ,CASE 
        WHEN co.highest_achieved = 99 THEN co.cohort
        ELSE (KIPP_NJ.dbo.fn_Global_Academic_Year() + 1) + (12 - co.grade_level) 
       END AS YearOfGraduation
      ,CASE WHEN nj.stateidentificationnumber IS NULL THEN REPLACE(att.min_attendance_date,'-','') ELSE nj.SchoolEntryDate END AS SchoolEntryDate
      ,nj.schoolexitdate AS SchoolExitDate
      ,nj.SchoolExitWithdrawalCode /* only for inactive students -- watch out for T2's */
      
      /* SID = inactive; State Submission = active */
      ,nj.CumulativeDaysInMembership
      ,nj.CumulativeDaysPresent
      ,nj.CumulativeDaysTowardsTruancy      
      
      ,nj.Tuitioncode
      ,CASE WHEN co.lunchstatus IN ('F','R') THEN co.lunchstatus ELSE 'N' END AS FreeAndReducedRateLunchStatus      
      ,CASE 
        WHEN co.GRADE_LEVEL = 0 THEN 'KF' 
        ELSE RIGHT(CONCAT('0',CONVERT(VARCHAR,co.GRADE_LEVEL)),2) 
       END AS GradeLevel
      ,CASE         
        WHEN co.GRADE_LEVEL = 0 THEN 'KF' 
        ELSE RIGHT(CONCAT('0',CONVERT(VARCHAR,co.GRADE_LEVEL)),2) 
       END AS ProgramTypeCode /* do we have the special ed classes? SPED code? */
      ,CASE WHEN co.retained_yr_flag = 1 THEN 'Y' ELSE 'N' END AS Retained
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
       END AS SpecialEducationClassification
      ,CASE
        WHEN co.LEP_STATUS IS NOT NULL AND nj.LEPProgramStartDate IS NULL THEN '!'
        ELSE CONVERT(VARCHAR,nj.LEPProgramStartDate)
       END AS LEPProgramStartDate /* hand entry -- SPED follow up */
      ,CASE
        WHEN co.LEP_STATUS IS NOT NULL AND nj.LEPProgramCompletionDate IS NULL THEN '!'
        ELSE CONVERT(VARCHAR,nj.LEPProgramCompletionDate)
       END AS LEPProgramCompletionDate  /* hand entry -- SPED follow up */
      ,nj.NonPublic /* out-of-district placements -- SPED follow up */
      ,CASE       
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid LIKE '1799%' THEN '0408'
        WHEN nj.stateidentificationnumber IS NULL AND co.schoolid NOT LIKE '1799%' THEN '0714'        
        ELSE RIGHT(CONCAT('0',nj.ResidentMunicipalCode),4) 
       END AS ResidentMunicipalCode
      ,COALESCE(nj.MilitaryConnectedStudentIndicator, 4) AS MilitaryConnectedStudentIndicator
      ,CASE WHEN co.schoolid LIKE '1799%' THEN 'Camden' ELSE 'Newark' END AS region
      ,co.schoolid
      ,co.school_name      
      ,co.CITY AS PS_CITY_NOIMPORT
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)  
  ON co.studentid = s.ID
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS_custom#static cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
LEFT OUTER JOIN attendance att
  ON co.studentid = att.STUDENTID
 AND co.year = att.academic_year
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_NJSMART_sid_export nj
  ON co.SID = nj.stateidentificationnumber 
 AND co.student_number = nj.localidentificationnumber
WHERE CONVERT(DATE,GETDATE()) BETWEEN co.entrydate AND co.exitdate