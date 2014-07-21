USE KIPP_NJ
GO

ALTER VIEW UTIL$reporting_weeks AS
WITH weeks AS (
  SELECT RIGHT('00' + CAST(n AS VARCHAR(2)), 2) AS week
  FROM UTIL$row_generator WITH(NOLOCK)
  WHERE n > 0 
    AND n <= 52
 )
    
,years AS (
  SELECT 2002 + n AS year
  FROM UTIL$row_generator WITH(NOLOCK)
  WHERE n < 40
 )

SELECT TOP 100000000
       years.year
      ,weeks.week
      ,CAST(CAST(years.year AS NVARCHAR) + CAST(weeks.week AS NVARCHAR) AS INT) AS reporting_hash
FROM weeks
JOIN years 
  ON 1=1
ORDER BY year
        ,week