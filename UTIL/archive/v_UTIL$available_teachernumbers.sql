USE KIPP_NJ
GO

ALTER VIEW UTIL$available_teachernumbers AS

WITH ps_numbers AS (  
  SELECT teachernumber
  FROM OPENQUERY(PS_TEAM,'
    SELECT teachernumber 
    FROM TEACHERS              
    WHERE teachernumber != ''ASDF1234''    
  ')         
 )

SELECT ROW_NUMBER() OVER(ORDER BY n) AS n
      ,n AS teachernumber
FROM UTIL$row_generator rn WITH(NOLOCK)
WHERE n >= 60000
  AND n <= 69999
  AND n NOT IN (SELECT teachernumber FROM ps_numbers)