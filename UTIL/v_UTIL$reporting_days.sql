USE KIPP_NJ
GO

ALTER VIEW UTIL$reporting_days AS

WITH calendar AS (
  SELECT DATEADD(DAY, n, '01-AUG-02') AS date
  FROM UTIL$row_generator WITH(NOLOCK)
  WHERE n < (365 * 40)
 )

SELECT sub.*
      ,CASE 
        WHEN week_part = '01' AND month_part = 12 THEN CAST((year_part + 1) AS NVARCHAR) + CAST(sub.week_part AS NVARCHAR)
        WHEN week_part = '53' AND month_part = 12 THEN CAST((year_part + 1) AS NVARCHAR) + '01'
        ELSE CAST(year_part AS NVARCHAR) + CAST(sub.week_part AS NVARCHAR)
       END AS reporting_hash
FROM
    (
     SELECT date
           ,DATENAME(DW, calendar.date) AS day_of_week
           ,DATEPART(DW, calendar.date) AS dw_numeric
           ,DATEPART(DD, calendar.date) AS day_part
           ,DATEPART(MM, calendar.date) AS month_part
           ,DATEPART(YYYY, calendar.date) AS year_part
           ,RIGHT('00' + CAST(DATEPART(WEEK, calendar.date) AS VARCHAR(2)), 2) AS week_part
     FROM calendar
    ) sub