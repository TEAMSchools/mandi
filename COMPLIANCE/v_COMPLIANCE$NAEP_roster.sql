USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$NAEP_roster AS

SELECT reporting_schoolid
      ,student_number AS [State Unique Student ID]
      ,first_name AS [Student First Name]
      ,MIDDLE_NAME AS [Student Middle Name]
      ,last_name AS [Student Last Name]
      ,grade_level AS [Grade]
      ,team AS [Homeroom or Other Locator]
      ,RIGHT(CONCAT('0', DATEPART(MONTH, DOB)),2) AS [Month of Birth]
      ,DATEPART(YEAR, DOB) AS [Year of Birth]
      ,GENDER AS [Sex]
      ,CASE WHEN SPEDLEP LIKE '%SPED%' THEN 'Yes' ELSE 'No' END AS [Student with a Disability]
      ,CASE WHEN ethnicity = 'H' THEN 'Yes' ELSE 'No' END AS [Hispanic]
      ,CASE WHEN ethnicity = 'W' THEN 'Yes' ELSE 'No' END AS [White]
      ,CASE WHEN ethnicity = 'B' THEN 'Yes' ELSE 'No' END AS [Black or African American]
      ,CASE WHEN ethnicity = 'A' THEN 'Yes' ELSE 'No' END AS [Asian]
      ,CASE WHEN ethnicity = 'I' THEN 'Yes' ELSE 'No' END AS [American Indian or AK Native]
      ,CASE WHEN ethnicity = 'P' THEN 'Yes' ELSE 'No' END AS [Native Hawaiian or Pac Islander]
      ,'No' AS [English Language Learner]
      ,CASE 
        WHEN lunchstatus = 'F' THEN 'Yes'
        WHEN lunchstatus = 'R' THEN 'Reduced'
        ELSE 'No' 
       END AS [School Lunch]
      ,NULL AS [On-Break Indicator]
      ,ZIP AS [ZIP Code]
FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND grade_level IN (4, 8, 12)  
  AND enroll_status = 0
  AND rn = 1