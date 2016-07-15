USE KIPP_NJ
GO

ALTER VIEW ROSTERS$NJASK AS

WITH entrydate AS (
  SELECT co.STUDENTID
        ,co.ENTRYDATE
        ,co.ENTRYCODE
        ,co.year
        ,prev.grade_level AS prev_grade
        ,prev.schoolid AS prev_school
  FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..COHORT$comprehensive_long#static prev WITH(NOLOCK)
    ON co.studentid = prev.studentid
   AND prev.year = (KIPP_NJ.dbo.fn_Global_Academic_Year() - 1)   
   AND prev.rn = 1
  WHERE co.YEAR_IN_NETWORK = 1
    AND co.RN = 1    
 )

SELECT cs.SID
      ,s.grade_level      
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
      ,s.STUDENT_NUMBER            
      ,CASE WHEN s.LUNCHSTATUS IN ('F','R') THEN s.LUNCHSTATUS ELSE NULL END AS EconDis_Flag
      ,NULL AS homeless_flag
      ,NULL AS migrant_flag
      ,NULL AS LEP
      ,CASE WHEN cs.STATUS_504 = 1 THEN 'Y' END AS Sec504
      ,CASE WHEN cs.SPEDLEP LIKE '%SPED%' THEN LEFT(cs.SPEDLEP_CODE,2) ELSE NULL END AS SE_code
      ,NULL AS SE_A_Setting
      ,NULL AS SE_B_Sched
      ,NULL AS SE_C_Materials
      ,NULL AS SE_D_Procedures
      ,NULL AS APA
      ,CASE WHEN entrydate.ENTRYDATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-07-01') THEN 'Y' ELSE NULL END AS TimeInDistrict_Flag
      ,CASE WHEN entrydate.prev_school IS NULL THEN 'Y' ELSE NULL END AS TimeInSchool_Flag
      ,CASE
        WHEN s.SCHOOLID = 73252 THEN 83815084 --Rise
        WHEN s.SCHOOLID = 133570965 THEN 32173288 --TEAM
        WHEN s.SCHOOLID = 73254 THEN 47676960 --SPARK
        WHEN s.SCHOOLID = 73257 THEN 82800517 --Life        
       END AS SMID
      ,NULL AS sending_CDS_code
FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$CUSTOM_STUDENTS#static cs WITH(NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN entrydate WITH(NOLOCK)
  ON s.ID = entrydate.STUDENTID  
WHERE s.ENROLL_STATUS = 0  
  AND s.GRADE_LEVEL IN (4,8)