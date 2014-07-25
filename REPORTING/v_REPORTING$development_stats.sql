USE KIPP_NJ
GO

ALTER VIEW REPORTING$development_stats AS

SELECT 'Current Enrollment' AS statistic
      ,'Network' AS org_unit
      ,CAST(SUM(dummy) AS NVARCHAR) AS value
      ,NULL AS N
FROM
      (SELECT s.ID
             ,1 AS dummy
       FROM KIPP_NJ..STUDENTS s
       WHERE s.enroll_status = 0
       ) sub

UNION ALL

SELECT 'Current Enrollment' AS statistic
      ,sub.school AS org_unit
      ,CAST(SUM(dummy) AS NVARCHAR) AS value
      ,NULL AS N
FROM
      (SELECT s.ID
             ,sch.abbreviation AS school
             ,1 AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..SCHOOLS sch
         ON s.schoolid = sch.school_number
       WHERE s.enroll_status = 0
       ) sub
GROUP BY sub.school

UNION ALL

SELECT 'Attrition (Any Start Date)' AS statistic
      ,'Network' AS org_unit
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN s.exitcode = 'G1' THEN 0.0
                WHEN s.enroll_status > 0 THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       WHERE s.ENTRYDATE > '01-AUG-13'
         AND DATEDIFF(day,s.entrydate,s.exitdate) > 2
       ) sub

UNION ALL

SELECT 'Attrition (Any Start Date)' AS statistic
      ,sub.school AS org_unit
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,sch.abbreviation AS school
             ,CASE
                WHEN s.exitcode = 'G1' THEN 0.0
                WHEN s.enroll_status > 0 THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..SCHOOLS sch
         ON s.schoolid = sch.school_number
       WHERE s.ENTRYDATE > '01-AUG-13'
         AND DATEDIFF(day,s.entrydate,s.exitdate) > 2
       ) sub
GROUP BY sub.school

UNION ALL

SELECT 'Percent Free or Reduced' AS statistic
      ,'Network' AS org_unit
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN s.lunchstatus IN ('F', 'R') THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       WHERE s.enroll_status = 0
       ) sub

UNION ALL 

SELECT 'Percent Free' AS statistic
      ,'Network' AS org_unit
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN s.lunchstatus = 'F' THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       WHERE s.enroll_status = 0
       ) sub

UNION ALL

SELECT 'Percent Reduced'
      ,'Network'
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN s.lunchstatus = 'R' THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       WHERE s.enroll_status = 0
       ) sub

UNION ALL

SELECT 'Percent Paid'
      ,'Network'
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
              ,CASE
                 WHEN s.lunchstatus = 'P' THEN 1.0
                 ELSE 0.0
               END AS dummy
        FROM KIPP_NJ..STUDENTS s
        WHERE s.enroll_status = 0
        ) sub

UNION ALL

SELECT 'Percent Free or Reduced'
      ,sub.school
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,sch.abbreviation AS school
             ,CASE
                WHEN s.lunchstatus IN ('F','R') THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..SCHOOLS sch
         ON s.schoolid = sch.school_number
       WHERE s.enroll_status = 0
       ) sub
GROUP BY sub.school

UNION ALL

SELECT 'Percent IEP'
      ,'Network'
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN cust.spedlep LIKE '%SPED%' THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust
         ON s.id = cust.studentid
       WHERE s.enroll_status = 0
       ) sub

UNION ALL

SELECT 'Percent IEP'
      ,sub.school
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,sch.abbreviation AS school
             ,CASE
                WHEN cust.spedlep LIKE '%SPED%' THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust
         ON s.id = cust.studentid
       JOIN KIPP_NJ..SCHOOLS sch
         ON s.schoolid = sch.school_number
       WHERE s.enroll_status = 0
       ) sub
GROUP BY sub.school

UNION ALL

SELECT 'Percent IEP'
      ,'Network ES only'
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN cust.spedlep LIKE '%SPED%' THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust
         ON s.id = cust.studentid
       WHERE s.enroll_status = 0
         AND s.grade_level < 5
       ) sub


UNION ALL

SELECT 'Percent IEP'
      ,'Network MS only'
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN cust.spedlep LIKE '%SPED%' THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust
         ON s.id = cust.studentid
       WHERE s.enroll_status = 0
         AND s.grade_level >= 5
         AND s.grade_level <= 8
       ) sub


UNION ALL

SELECT 'Percent IEP'
      ,'Network HS only'
      ,CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
      ,CAST(SUM(dummy) AS INT) AS N
FROM
      (SELECT s.ID
             ,CASE
                WHEN cust.spedlep LIKE '%SPED%' THEN 1.0
                ELSE 0.0
              END AS dummy
       FROM KIPP_NJ..STUDENTS s
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust
         ON s.id = cust.studentid
       WHERE s.enroll_status = 0
         AND s.grade_level >= 9
       ) sub
