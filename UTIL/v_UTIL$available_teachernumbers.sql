USE KIPP_NJ
GO

ALTER VIEW UTIL$available_teachernumbers AS

SELECT ROW_NUMBER() OVER (
              ORDER BY n) AS n
      ,n AS teachernumber
FROM UTIL$row_generator rn WITH(NOLOCK)
WHERE n >= 60000
  AND n <= 69999
  AND n NOT IN (
                SELECT teachernumber 
                FROM TEACHERS WITH(NOLOCK) 
                WHERE TEACHERNUMBER >= 60000 
                  AND TEACHERNUMBER <= 69999
               )