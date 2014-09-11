USE KIPP_NJ
GO

ALTER VIEW DEVFIN$student_flags AS

WITH co_base AS (
  SELECT *
  FROM COHORT$comprehensive_long#static
  WHERE year = 2013
    AND entrydate <= '2013-10-01'
    AND rn = 1
 )

,co_cur AS (
  SELECT *
  FROM COHORT$comprehensive_long#static
  WHERE year = 2014
    AND rn = 1
    AND (entrydate != exitdate OR schoolid = 999999)
 )

SELECT SCHOOLID
      ,GRADE_LEVEL
      ,LASTFIRST
      ,'PAID' AS flag
FROM students s WITH(NOLOCK)
WHERE LUNCHSTATUS = 'P'
  AND ENROLL_STATUS = 0

UNION ALL

SELECT SCHOOLID
      ,GRADE_LEVEL
      ,LASTFIRST
      ,cs.SPEDLEP AS flag
FROM students s WITH(NOLOCK)
JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.STUDENTID
 AND cs.SPEDLEP LIKE '%SPED%' 
WHERE ENROLL_STATUS = 0

UNION ALL

SELECT co.SCHOOLID
      ,co.GRADE_LEVEL
      ,co.LASTFIRST
      ,'TRANSF' AS flag
FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
JOIN STUDENTS s
  ON co.STUDENTID = s.ID
 AND s.ENROLL_STATUS = 2
WHERE YEAR = 2014 --dbo.fn_Global_Academic_Year()
  AND rn = 1
  AND co.EXITDATE <= GETDATE()

UNION ALL

SELECT co_base.schoolid
      ,co_base.GRADE_LEVEL
      ,co_base.lastfirst
      ,'TRANSF_SUM' AS flag
FROM co_base
WHERE studentid NOT IN (SELECT studentid FROM co_cur)
AND exitdate >= '2014-06-27'