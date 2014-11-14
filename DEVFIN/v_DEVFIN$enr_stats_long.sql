USE KIPP_NJ
GO

ALTER VIEW DEVFIN$enr_stats_long AS

WITH co_base AS (
  SELECT *        
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE year = 2013
    AND entrydate <= '2013-10-01'
    AND exitdate >= '2013-10-01'
    AND rn = 1
 )

,co_cur AS (
  SELECT *        
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE year = 2014
    AND rn = 1
    AND (exitdate >= '2014-10-01' OR schoolid = 999999)
 )

SELECT dbo.fn_Global_Academic_Year() AS academic_year
      ,co.SCHOOLID
      ,co.GRADE_LEVEL
      ,'ENR' AS category
      ,'current' AS measure
      ,SUM(CASE WHEN co.EXITDATE >= GETDATE() THEN 1 ELSE 0 END) AS N
      ,transf.pct      
FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
LEFT OUTER JOIN (
                 SELECT co_base.schoolid
                       ,co_base.grade_level      
                       ,ROUND(SUM(CASE WHEN co_cur.studentid IS NULL THEN 1.0 ELSE 0.0 END) / CONVERT(FLOAT,COUNT(co_base.studentid)) * 100,1) AS pct      
                 FROM co_base WITH(NOLOCK)
                 LEFT OUTER JOIN co_cur WITH(NOLOCK)
                   ON co_base.studentid = co_cur.studentid
                 GROUP BY co_base.schoolid
                         ,co_base.GRADE_LEVEL
                ) transf
  ON co.schoolid = transf.schoolid
 AND co.grade_level = transf.grade_level
WHERE co.year = dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.SCHOOLID != 999999
GROUP BY co.SCHOOLID
        ,co.GRADE_LEVEL        
        ,transf.pct

UNION ALL

-- lunch status counts and %
SELECT dbo.fn_Global_Academic_Year() AS academic_year
      ,SCHOOLID
      ,GRADE_LEVEL
      ,category
      ,measure
      ,COUNT(measure) AS N
      ,ROUND(CONVERT(FLOAT,COUNT(measure)) / CONVERT(FLOAT,enr) * 100,1) AS pct
FROM
    (
     SELECT SCHOOLID
           ,GRADE_LEVEL
           ,'LUNCH' AS category
           ,LUNCHSTATUS AS measure
           ,COUNT(ID) OVER(PARTITION BY SCHOOLID, GRADE_LEVEL) AS enr      
     FROM students s WITH(NOLOCK)
     WHERE ENROLL_STATUS = 0
    ) sub
GROUP BY SCHOOLID
        ,GRADE_LEVEL
        ,category
        ,measure
        ,enr

UNION ALL

-- SPED numbers
SELECT dbo.fn_Global_Academic_Year() AS academic_year
      ,SCHOOLID
      ,GRADE_LEVEL
      ,category
      ,measure
      ,COUNT(measure) AS N
      ,ROUND(CONVERT(FLOAT,COUNT(measure)) / CONVERT(FLOAT,enr) * 100,1) AS pct
FROM
    (
     SELECT SCHOOLID
           ,GRADE_LEVEL
           ,'SPED' AS category           
           ,cs.SPEDLEP AS measure
           ,COUNT(ID) OVER(PARTITION BY SCHOOLID, GRADE_LEVEL) AS enr
     FROM students s WITH(NOLOCK)
     JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
       ON s.id = cs.STUDENTID
      AND cs.SPEDLEP IS NOT NULL
     WHERE ENROLL_STATUS = 0
    ) sub
GROUP BY SCHOOLID
        ,GRADE_LEVEL
        ,category
        ,measure
        ,enr