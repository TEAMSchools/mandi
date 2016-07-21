USE KIPP_NJ
GO

ALTER VIEW ROSTERS$HSPA AS

WITH entrydate AS (
  SELECT STUDENTID
        ,ENTRYDATE
        ,ENTRYCODE
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE YEAR_IN_NETWORK = 1
    AND RN = 1
 )

SELECT s.FIRST_NAME
      ,s.LAST_NAME
      ,LEFT(s.MIDDLE_NAME,1) AS MiddleInitial      
      ,DATENAME(MONTH,s.DOB) AS DOB_Month
      ,DATEPART(DD,s.DOB) AS DOB_Day
      ,RIGHT(DATEPART(YY,s.DOB),2) AS DOB_Year
      --,REPLACE(CONVERT(DATE,s.DOB),'-','') AS DOB
      ,s.ETHNICITY
      ,s.GENDER
      ,s.STUDENT_NUMBER AS DistrictSchool_StudentID
      ,cs.SID
      ,80 AS CountyCode
      ,7325 AS DistrictCode
      ,965 AS SchoolCode      
      ,CASE WHEN entrydate.ENTRYDATE >= CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-07-01' THEN 'Y' ELSE 'N' END AS EntryDate      
      ,'Y' AS TitleI      
      ,CASE WHEN s.LUNCHSTATUS IN ('F','R') THEN 'Y' WHEN s.LUNCHSTATUS = 'P' THEN 'N' END AS Econ_Disadv
      ,CASE WHEN cs.SPEDLEP = 'LEP' THEN 'Y' ELSE 'N' END AS LEP
      ,CASE WHEN cs.STATUS_504 = 1 THEN 'Y' ELSE 'N' END AS Section504
      ,cs.SPEDLEP_CODE AS SPED
      ,NULL AS SPED504_Accomodations
      ,NULL AS IEP_Exempt
      ,NULL AS Homeless
      ,NULL AS Migrant
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN entrydate WITH(NOLOCK)
  ON s.ID = entrydate.STUDENTID  
WHERE s.ENROLL_STATUS = 0  
  AND s.SCHOOLID = 73253
