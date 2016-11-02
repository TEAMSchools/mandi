USE KIPP_NJ
GO

ALTER VIEW ROSTERS$PARCC AS

WITH students AS (
	 SELECT co.student_number
        ,co.SID
        ,co.last_name
	       ,co.first_name	       
	       ,co.school_level
        ,co.reporting_schoolid AS schoolid
	       ,co.school_name	       
        ,co.grade_level        
	       ,co.DOB
        ,co.SPEDLEP	   
        ,co.SPED_code
        ,co.STATUS_504
        ,co.gender
	       ,co.ethnicity	       
        ,co.lunchstatus
        ,co.year_in_network    
        ,subjects.subject
	FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
	CROSS JOIN (
   SELECT 'ENG' UNION
   SELECT 'MATH'
  ) subjects (subject)
 WHERE co.grade_level BETWEEN 3 AND 11
	  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
	  AND co.enroll_status = 0
	  AND co.rn = 1
	)

,courses AS (
  SELECT enr.student_number
        ,'ES' AS school_level
        ,'ENG' AS credittype
        ,CONCAT('ELA', RIGHT(CONCAT('0',enr.grade_level),2)) AS testcode
        ,enr.COURSE_NAME
        ,enr.SECTION_NUMBER
        ,enr.dateenrolled
        ,enr.dateleft      
        ,u.SIF_STATEPRID SMID
        ,ROW_NUMBER() OVER(
          PARTITION BY enr.student_number, enr.credittype
            ORDER BY enr.dateenrolled DESC) AS rn
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
    ON enr.TEACHERNUMBER = u.TEACHERNUMBER
  WHERE enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND enr.COURSE_NUMBER = 'HR'
    AND enr.course_enr_status = 0
    AND enr.drop_flags = 0
  UNION ALL
  SELECT enr.student_number
        ,'ES' AS school_level
        ,'MATH' AS credittype
        ,CONCAT('MAT', RIGHT(CONCAT('0',enr.grade_level),2)) AS testcode
        ,enr.COURSE_NAME
        ,enr.SECTION_NUMBER
        ,enr.dateenrolled
        ,enr.dateleft      
        ,u.SIF_STATEPRID SMID
        ,ROW_NUMBER() OVER(
          PARTITION BY enr.student_number, enr.credittype
            ORDER BY enr.dateenrolled DESC) AS rn
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
    ON enr.TEACHERNUMBER = u.TEACHERNUMBER
  WHERE enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND enr.COURSE_NUMBER = 'HR'
    AND enr.course_enr_status = 0
    AND enr.drop_flags = 0
 )

SELECT 'NJ' AS StateNameAbbreviation
      ,CASE
        WHEN s.schoolid = 5173 THEN NULL /* out of district */
        WHEN s.schoolid LIKE '1799%' THEN '071799'
        ELSE '807325'
       END AS StateAssessmentTestingSiteDistrict
      ,CASE
        WHEN s.schoolid = 5173 THEN NULL /* out of district */
        WHEN s.schoolid LIKE '1799%' THEN '111'
        ELSE '965'
       END AS StateAssessmentTestingSiteSchool
      ,CASE
        WHEN s.schoolid = 5173 THEN NULL /* out of district */
        WHEN s.schoolid LIKE '1799%' THEN '071799'
        ELSE '807325'
       END AS StateAssessmentAccountableDistrict
      ,CASE
        WHEN s.schoolid = 5173 THEN NULL /* out of district */
        WHEN s.schoolid LIKE '1799%' THEN '111'
        ELSE '965'
       END AS StateAssessmentAccountableSchool
      ,s.SID AS StateIdentificationNumber
      ,s.student_number AS LocalIdentificationNumber
      ,NULL AS PARCCStudentIdentifier
      ,s.last_name AS LastName
      ,s.first_name AS FirstName
      ,NULL AS MiddleName
      ,CONVERT(DATE,s.DOB) AS DateOfBirth
      ,s.Gender
      
      ,NULL AS ELLExemptFromTakingLAL /*?*/
      
      ,CASE
        WHEN s.grade_level = 0 THEN 'KF'
        ELSE RIGHT(CONCAT('0', s.grade_level),2)
       END AS GradeLevel
      ,CASE WHEN s.ETHNICITY = 'H' THEN 'Y' ELSE 'N' END AS Ethnicity
      ,CASE WHEN s.ETHNICITY = 'I' THEN 'Y' ELSE 'N' END AS RaceAmericanIndian
      ,CASE WHEN s.ETHNICITY = 'A' THEN 'Y' ELSE 'N' END AS RaceAsian
      ,CASE WHEN s.ETHNICITY = 'B' THEN 'Y' ELSE 'N' END AS RaceBlack
      ,CASE WHEN s.ETHNICITY = 'P' THEN 'Y' ELSE 'N' END AS RacePacific
      ,CASE WHEN s.ETHNICITY = 'W' THEN 'Y' ELSE 'N' END AS RaceWhite
      ,NULL AS FillerField1
      ,CASE WHEN s.ETHNICITY = 'Y' THEN 'Y' ELSE 'N' END AS RaceMulti
      
      ,NULL AS EnglishLearner /*?*/
      ,NULL AS TitleIIIELLSTatus /*?*/
      ,'N' AS GiftedAndTalented
      ,NULL AS MigrantStatus /*?*/

      ,CASE WHEN s.lunchstatus IN ('F','R') THEN 'Y' ELSE 'N' END AS EconomicDisadvantageStatus      ,CASE        WHEN s.SPEDLEP LIKE '%SPEd%' THEN 'IEP'        WHEN s.STATUS_504 = 1 THEN '504'        ELSE 'N'       END AS StudentsWithDisabilities504Eligibility      ,CASE
        WHEN s.SPED_code IS NULL THEN NULL
        WHEN s.SPED_code IN ('00','99') THEN NULL
        WHEN s.sped_code = 'AI' THEN 'HI'        
        WHEN s.sped_code = 'CMI' THEN 'ID'
        WHEN s.sped_code = 'CMO' THEN 'ID'
        WHEN s.sped_code = 'CSE' THEN 'ID'
        WHEN s.sped_code = 'CI' THEN 'SLI'
        WHEN s.sped_code = 'ED' THEN 'EMN'
        WHEN s.sped_code = 'PSD' THEN 'DD'
        WHEN s.sped_code = 'ESLS' THEN 'SLI'        ELSE s.SPED_code       END AS PrimaryDisabilityType      ,CASE WHEN s.year_in_network = 1 THEN 'Y' ELSE 'N' END AS TimeInSchoolLessThanOneYear      
      ,NULL AS HomelessStatus /*?*/
      ,NULL AS ExemptFromPassing /*?*/
      ,NULL AS NJELLStatus /*?*/
      
      ,CASE
        WHEN s.SPED_code IS NULL THEN NULL
        WHEN s.sped_code = 'AI' THEN '01'
        WHEN s.sped_code = 'AUT' THEN '02'
        WHEN s.sped_code = 'CMI' THEN '03'
        WHEN s.sped_code = 'CMO' THEN '04'
        WHEN s.sped_code = 'CSE' THEN '05'
        WHEN s.sped_code = 'CI' THEN '06'
        WHEN s.sped_code = 'ED' THEN '07'
        WHEN s.sped_code = 'MD' THEN '08'
        WHEN s.sped_code = 'DB' THEN '09'
        WHEN s.sped_code = 'OI' THEN '10'
        WHEN s.sped_code = 'OHI' THEN '11'
        WHEN s.sped_code = 'PSD' THEN '12'
        WHEN s.sped_code = 'SM' THEN '13' /* no longer valid */
        WHEN s.sped_code = 'SLD' THEN '14'
        WHEN s.sped_code = 'TBI' THEN '15'
        WHEN s.sped_code = 'VI' THEN '16'
        WHEN s.sped_code = 'ESLS' THEN '17'
        ELSE RIGHT(CONCAT('0',s.sped_code),2)
       END AS SpecialEducationClassification
      
      ,NULL AS SpecialEducationPlacement /*?*/      
      ,1 AS StateAssessmentName
      ,NULL AS DateFirstEnrolledInUSSchool /*?*/      ,NULL AS ELLAccommodation /*?*/
      ,NULL AS PaperTier /*?*/
      ,NULL AS AlternateACCESSTester /*?*/
      
      /* test assignments */
      ,NULL AS SessionName /* {SCHOOL} - {TESTCODE} */
      ,NULL AS ClassName /* {SCHOOL} - {TESTCODE} */
      ,NULL AS TestAdministrator /* course teacher SMID */      ,NULL AS StaffMemberAssigned /* course teacher SMID */      ,NULL AS TestCode /* based on course */      ,'O' AS TestFormat
      ,NULL AS PARCCRetest /*?*/      ,NULL AS FillerField2

      /* accommodations */
      ,NULL AS FrequentBreaks
      ,NULL AS AlternateLocation
      ,NULL AS SmallTestingGroup
      ,NULL AS SpecializedEquipment      ,NULL AS SpecifiedAreaOrSetting
      ,NULL AS TimeOfDay
      ,NULL AS AnswerMasking
      ,NULL AS ReadAssessmentAloud
      ,NULL AS ColorContrast
      ,NULL AS ASLVideo
      ,NULL AS ScreenReader
      ,NULL AS NonScreenReader
      ,NULL AS ClosedCaptioningELA
      ,NULL AS RefreshableBrailleDisplayELA
      ,NULL AS AlternateRepresentationPaper
      ,NULL AS LargePrintPaper      ,NULL AS BrailleWithTactileGraphicsPaper      ,NULL AS FillerField3      ,NULL AS HumanSigner      ,NULL AS AnswersRecordedPaper      ,NULL AS BrailleResponse      ,NULL AS CalculationDeviceAndMathematicsTools      ,NULL AS ConstructedResponseELA
      ,NULL AS SelectedResponseELA
      ,NULL AS ResponseMath
      ,NULL AS MonitorTestResponse
      ,NULL AS WordPrediction
      ,NULL AS DirectionsClarifiedInNativeLanguage
      ,NULL AS DirectionsReadAloudInNativeLanguage
      ,NULL AS ResponseMathEL
      ,NULL AS TranslationOfMath
      ,NULL AS WordToWordDictionary
      ,NULL AS TextToSpeech
      ,NULL AS HumanReaderOrSigner
      ,NULL AS UniqueAccommodation
      ,NULL AS EmergencyAccommodation
      ,NULL AS ExtendedTime
      ,NULL AS EndOfRecord
      
	     --,courses.credittype AS subject
	     --,courses.course_name AS ps_course_name
	     --,CASE 
      --  WHEN courses.course_number IN ('MATH10','MATH71','MATH15','M415','M400') THEN 'ALG01'
			   --  WHEN courses.course_number IN ('MATH25','MATH20') THEN 'GEO01'
			   --  WHEN courses.course_number IN ('MATH32','MATH35') THEN 'ALG02'
			   --  WHEN courses.credittype = 'MAT' AND s.grade_level <9 THEN courses.credittype + CONVERT(VARCHAR(20),0) + CONVERT(VARCHAR(20),s.grade_level)
			   --  WHEN courses.course_number IN ('MATH13',',MATH72','MATH43','MATH40','MATH44')THEN 'No Test'
			   --  WHEN courses.credittype = 'ELA' AND s.grade_level < 10 THEN courses.credittype + CONVERT(VARCHAR(20),0) + CONVERT(VARCHAR(20),s.grade_level)
			   --  WHEN courses.credittype = 'ELA' AND s.grade_level >= 10 THEN courses.credittype + CONVERT(VARCHAR(20),s.grade_level)
			   --  ELSE 'No Test' 
			   -- END AS PARCC_testcode
	     --,CASE 
      --  WHEN ROW_NUMBER() OVER(
				  --         PARTITION BY s.student_number, courses.credittype
					 --           ORDER BY courses.dateenrolled DESC) > 1 THEN 'Multiple Enrollments' 
			   --  WHEN courses.credittype IS NULL THEN 'Not Enrolled in Courses'
			   --  ELSE NULL 
      -- END AS 'Flag Enrollment'
	     --,courses.teachernumber
	     --,courses.teacher_name
FROM students s
--LEFT OUTER JOIN courses
--  ON s.student_number = courses.student_number
--WHERE s.grade_level <= 8 AND courses.rn = 1
--   OR s.grade_level >= 9