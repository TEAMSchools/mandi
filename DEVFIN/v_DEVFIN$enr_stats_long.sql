USE KIPP_NJ
GO

ALTER VIEW DEVFIN$enr_stats_long AS

SELECT dbo.fn_Global_Academic_Year() AS academic_year
      ,co.SCHOOLID
      ,co.GRADE_LEVEL
      ,'ENR' AS category
      ,'current' AS measure
      ,SUM(CASE WHEN co.EXITDATE >= GETDATE() THEN 1 ELSE 0 END) AS N -- replace with GETDATE() before going live
      ,ROUND(((SUM(CASE WHEN co.EXITDATE >= GETDATE() THEN 0.0 ELSE 1.0 END) + ISNULL(summer_loss.n,0)) / CONVERT(FLOAT,COUNT(co.STUDENTID) + ISNULL(summer_loss.n,0))) * 100,1) AS pct      
FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
LEFT OUTER JOIN (
                 SELECT CASE 
                         WHEN co_base.SCHOOLID = 73254 AND co_base.GRADE_LEVEL = 4 THEN 133570965 -- SPARK 4th graders go to TEAM
                         WHEN co_base.SCHOOLID IN (73252,133570965) AND co_base.GRADE_LEVEL = 8 THEN 73253 -- MS 8th graders go to NCA
                         ELSE co_base.SCHOOLID
                        END AS schoolid
                       ,co_base.GRADE_LEVEL + 1 AS grade_level
                       ,SUM(CASE WHEN co_cur.STUDENTID IS NULL THEN 1 ELSE 0 END) AS n
                 FROM COHORT$comprehensive_long#static co_base WITH(NOLOCK)
                 LEFT OUTER JOIN COHORT$comprehensive_long#static co_cur WITH(NOLOCK)
                   ON co_base.STUDENTID = co_cur.STUDENTID
                  AND co_base.YEAR = co_cur.YEAR - 1
                  AND co_cur.RN = 1
                 WHERE co_base.YEAR = 2013 --dbo.fn_fn_Global_Academic_Year() - 1
                   AND co_base.SCHOOLID != 999999
                   AND co_base.RN = 1
                 GROUP BY CASE 
                           WHEN co_base.SCHOOLID = 73254 AND co_base.GRADE_LEVEL = 4 THEN 133570965
                           WHEN co_base.SCHOOLID IN (73252,133570965) AND co_base.GRADE_LEVEL = 8 THEN 73253
                           ELSE co_base.SCHOOLID
                          END
                         ,co_base.GRADE_LEVEL + 1
                ) summer_loss
  ON co.SCHOOLID = summer_loss.SCHOOLID
 AND co.GRADE_LEVEL = summer_loss.GRADE_LEVEL
WHERE co.year = 2014 --dbo.fn_Global_Academic_Year() -- swap out for hard-coded year?
  AND co.rn = 1
  AND co.SCHOOLID != 999999
GROUP BY co.SCHOOLID
        ,co.GRADE_LEVEL
        ,summer_loss.n

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
     JOIN CUSTOM_STUDENTS cs
       ON s.id = cs.STUDENTID
      AND cs.SPEDLEP IS NOT NULL
     WHERE ENROLL_STATUS = 0
    ) sub
GROUP BY SCHOOLID
        ,GRADE_LEVEL
        ,category
        ,measure
        ,enr