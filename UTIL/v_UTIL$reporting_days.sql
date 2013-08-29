USE KIPP_NJ
GO

ALTER VIEW UTIL$reporting_days AS
WITH calendar AS
    (SELECT DATEADD(DAY, n, '01-AUG-02') AS date
     FROM UTIL$row_generator
     WHERE n < (365 * 40)
    )

SELECT sub.*
      ,CAST(sub.year_part AS NVARCHAR) + CAST(sub.week_part AS NVARCHAR) AS reporting_hash
FROM
   (SELECT date
         ,DATENAME(dw, calendar.date) AS day_of_week
         ,DATEPART(yyyy, calendar.date) AS year_part
         ,RIGHT('00' + CAST(DATEPART(iso_week, calendar.date) AS VARCHAR(2)), 2) AS week_part
   FROM calendar
   ) sub