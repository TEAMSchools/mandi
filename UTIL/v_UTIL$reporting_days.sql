USE KIPP_NJ
GO

--ALTER VIEW UTIL$reporting_days AS
WITH calendar AS
    (SELECT DATEADD(DAY, n, '01-AUG-02') AS date
     FROM UTIL$row_generator
     WHERE n < (365 * 40)
    )

SELECT TOP 10000000000 sub.*
      ,CAST(sub.year_part AS NVARCHAR) + CAST(sub.week_part AS NVARCHAR) AS reporting_hash
FROM
   (SELECT date
         ,DATENAME(DW, calendar.date) AS day_of_week
         ,DATEPART(DW, calendar.date) AS dw_numeric
         ,DATEPART(DD, calendar.date) AS day_part
         ,DATEPART(MM, calendar.date) AS month_part         
         ,DATEPART(YYYY, calendar.date) AS year_part
         ,RIGHT('00' + CAST(DATEPART(iso_week, calendar.date) AS VARCHAR(2)), 2) AS week_part
   FROM calendar
   ) sub
ORDER BY date ASC