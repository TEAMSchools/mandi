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
      ,co.STUDENT_NUMBER
      ,co.FIRST_NAME
      ,co.MIDDLE_NAME
      ,co.LAST_NAME
      ,co.ETHNICITY
      ,co.GENDER
      ,CONVERT(DATE,co.DOB) AS DOB
      ,co.spedlep        
      ,CASE 
        WHEN co.spedlep LIKE '%SPED%' THEN 'Y'
        WHEN co.spedlep = 'No IEP' THEN 'N'
        ELSE 'U'
       END AS special_needs
      ,CONVERT(DATE,denom.entrydate) AS entrydate
      ,CONVERT(DATE,denom.exitdate) AS exitdate
      ,CASE WHEN raw_numer.schoolid = 999999 THEN 1 ELSE 0 END AS grad_flag
      ,co.EXITCOMMENT
      ,CASE 
        WHEN denom.year < KIPP_NJ.dbo.fn_Global_Academic_Year() AND raw_numer.studentid IS NULL THEN 1 
        WHEN denom.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 
             AND DATEPART(MONTH,GETDATE()) = 7 -- accounts for weird intersession in July
             AND denom.exitdate < CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year() + 1,'-06-30')) 
             THEN 1 
        WHEN denom.year = KIPP_NJ.dbo.fn_Global_Academic_Year() 
             AND DATEPART(MONTH,GETDATE()) != 7
             AND denom.exitdate <= CONVERT(DATE,GETDATE()) 
             THEN 1 
        ELSE 0 
       END AS attr_flag            
FROM denom WITH(NOLOCK)
LEFT OUTER JOIN raw_numer WITH(NOLOCK)
  ON denom.STUDENTID = raw_numer.STUDENTID
 AND denom.YEAR = (raw_numer.YEAR - 1)
LEFT OUTER JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON denom.studentid = co.studentid
 AND denom.year = co.year
 AND co.rn = 1