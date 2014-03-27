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
  WHERE ENTRYDATE <= CONVERT(VARCHAR,YEAR) + '-10-01'
    AND EXITDATE > CONVERT(VARCHAR,YEAR) + '-10-01'
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
  --these statements allow graduates to match on the denom set
  WHERE (EXITDATE > CONVERT(VARCHAR,YEAR) + '-10-01' OR EXITDATE IS NULL)       
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

--/*
SELECT denom.YEAR
      ,denom.COHORT
      ,denom.EXITCODE
      ,'Newark' AS region
      ,denom.SCHOOLID AS d_schoolid
      ,denom.GRADE_LEVEL AS d_grade_level
      ,denom.studentid AS d_studentid
      ,raw_numer.schoolid AS n_schoolid
      ,raw_numer.GRADE_LEVEL AS n_grade_level
      ,raw_numer.studentid AS n_studentid      
FROM denom
LEFT OUTER JOIN raw_numer
  ON denom.STUDENTID = raw_numer.STUDENTID
 AND denom.YEAR = (raw_numer.YEAR - 1)
--*/