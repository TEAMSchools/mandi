USE KIPP_NJ
GO

ALTER VIEW DEVFIN$mobility_long#KIPP AS

WITH denom AS (
--previous year's set
  SELECT STUDENTID
        ,GRADE_LEVEL
        ,SCHOOLID
        ,EXITCODE
        ,MIN(ENTRYDATE) AS entrydate
        ,MAX(EXITDATE) AS exitdate
        ,YEAR
        ,COHORT
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE ENTRYDATE <= CONVERT(DATE,CONVERT(VARCHAR,YEAR) + '-10-01')
    AND EXITDATE > CONVERT(DATE,CONVERT(VARCHAR,YEAR) + '-10-01')
  GROUP BY STUDENTID
        ,GRADE_LEVEL
        ,SCHOOLID
        ,EXITCODE
        ,YEAR
        ,COHORT
 )

,raw_numer AS (
--current year's set
--includes graduated students
  SELECT STUDENTID
        ,GRADE_LEVEL
        ,SCHOOLID
        ,EXITCODE
        ,MIN(ENTRYDATE) AS entrydate
        ,MAX(EXITDATE) AS exitdate
        ,YEAR
        ,COHORT
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  --graduated students do not have an exitdate  
  WHERE (ENTRYDATE <= CONVERT(DATE,CONVERT(VARCHAR,YEAR) + '-10-01') OR ENTRYDATE IS NULL)       
    AND (EXITDATE > CONVERT(DATE,CONVERT(VARCHAR,YEAR) + '-10-01') OR EXITDATE IS NULL)       
  GROUP BY STUDENTID
          ,GRADE_LEVEL
          ,SCHOOLID
          ,EXITCODE
          ,YEAR
          ,COHORT
 )

/*
--for the rollup
SELECT denom.YEAR
      ,COUNT(denom.studentid) AS denom
      ,SUM(CASE WHEN raw_numer.studentid IS NULL THEN 1 ELSE 0 END) AS n_transf --match on JOIN = currently enrolled or graduated; no match = transferred
      ,ROUND(CONVERT(FLOAT,SUM(CASE WHEN raw_numer.studentid IS NULL THEN 1 ELSE 0 END)) / CONVERT(FLOAT,COUNT(denom.studentid)) * 100,1) AS attrition
FROM denom
LEFT OUTER JOIN raw_numer
  ON denom.STUDENTID = raw_numer.STUDENTID
 AND denom.YEAR = (raw_numer.YEAR - 1)
GROUP BY denom.YEAR 
--*/

SELECT denom.YEAR
      ,denom.COHORT
      ,denom.EXITCODE      
      ,denom.SCHOOLID AS d_schoolid
      ,denom.GRADE_LEVEL AS d_grade_level
      ,denom.studentid AS d_studentid
      ,raw_numer.schoolid AS n_schoolid
      ,raw_numer.GRADE_LEVEL AS n_grade_level
      ,raw_numer.studentid AS n_studentid    
      ,s.STUDENT_NUMBER
      ,s.FIRST_NAME
      ,s.MIDDLE_NAME
      ,s.LAST_NAME
      ,s.ETHNICITY
      ,s.GENDER
      ,CONVERT(DATE,s.DOB) AS DOB
      ,cs.spedlep        
      ,CASE 
        WHEN cs.spedlep LIKE '%SPED%' THEN 'Y'
        WHEN cs.spedlep = 'No IEP' THEN 'N'
        ELSE 'U'
       END AS special_needs
      ,CONVERT(DATE,denom.entrydate) AS entrydate
      ,CONVERT(DATE,denom.exitdate) AS exitdate
      ,CASE WHEN raw_numer.schoolid = 999999 THEN 1 ELSE 0 END AS grad_flag
      ,blobs.EXITCOMMENT
      ,CASE WHEN raw_numer.studentid IS NULL THEN 1 ELSE 0 END AS attr_flag      
FROM denom WITH(NOLOCK)
LEFT OUTER JOIN raw_numer WITH(NOLOCK)
  ON denom.STUDENTID = raw_numer.STUDENTID
 AND denom.YEAR = (raw_numer.YEAR - 1)
LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)
  ON denom.studentid = s.ID
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON denom.studentid = cs.STUDENTID
LEFT OUTER JOIN PS$student_BLObs#static blobs WITH(NOLOCK)
  ON denom.studentid = blobs.STUDENTID