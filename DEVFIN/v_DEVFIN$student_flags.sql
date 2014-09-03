USE KIPP_NJ
GO

ALTER VIEW DEVFIN$student_flags AS

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

SELECT CASE 
        WHEN co_base.SCHOOLID = 73254 AND co_base.GRADE_LEVEL = 4 THEN 133570965
        WHEN co_base.SCHOOLID IN (73252,133570965) AND co_base.GRADE_LEVEL = 8 THEN 73253
        ELSE co_base.SCHOOLID
       END AS schoolid
      ,co_base.GRADE_LEVEL + 1 AS grade_level
      ,co_base.lastfirst
      ,'TRANSF_SUM' AS flag
FROM COHORT$comprehensive_long#static co_base WITH(NOLOCK)
LEFT OUTER JOIN COHORT$comprehensive_long#static co_cur WITH(NOLOCK)
  ON co_base.STUDENTID = co_cur.STUDENTID
 AND co_base.YEAR = co_cur.YEAR - 1
 AND co_cur.RN = 1
WHERE co_base.YEAR = 2013 --dbo.fn_fn_Global_Academic_Year() - 1
  AND co_base.SCHOOLID != 999999
  AND co_base.RN = 1
  AND co_cur.STUDENTID IS NULL