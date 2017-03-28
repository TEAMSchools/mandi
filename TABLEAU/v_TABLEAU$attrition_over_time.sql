USE KIPP_NJ
GO

ALTER VIEW TABLEAU$attrition_over_time AS

WITH enrolled_oct1 AS (
  SELECT STUDENT_NUMBER
        ,year
        ,reporting_schoolid
        ,grade_level
        ,entrydate
        ,exitdate
        ,exitcode
        ,enroll_status
  FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
  WHERE DATEFROMPARTS(year, 10, 01) BETWEEN entrydate AND exitdate
 )

,attrition_dates AS (
  SELECT date
        ,CASE 
          WHEN DATEPART(MONTH,date) >= 10 THEN DATEPART(YEAR,date)
          ELSE DATEPART(YEAR,date) - 1
         END AS attrition_year
  FROM KIPP_NJ..UTIL$reporting_days#static WITH(NOLOCK)
 )

SELECT y1.*
      ,y2.exitdate AS next_exitdate
      ,COALESCE(y2.exitdate, y1.exitdate) AS transferdate
      ,d.date
      ,CASE
         WHEN COALESCE(y2.exitdate, y1.exitdate) > d.date THEN 0
         WHEN COALESCE(y2.exitdate, y1.exitdate) <= d.date AND y1.exitcode = 'G1' THEN 0
         ELSE 1
       END AS is_attrition
      ,CASE
        WHEN COALESCE(y2.exitdate, y1.exitdate) > d.date THEN 0
        WHEN COALESCE(y2.exitdate, y1.exitdate) <= d.date AND y1.exitcode = 'G1' THEN 1
        ELSE 0
       END AS is_graduation
FROM enrolled_oct1 y1
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static y2 WITH(NOLOCK)
  ON y1.STUDENT_NUMBER = y2.STUDENT_NUMBER
 AND y1.year = (y2.year - 1)
 AND y2.rn = 1
JOIN attrition_dates d
  ON y1.year = d.attrition_year
 AND d.date <= CONVERT(DATE,GETDATE())