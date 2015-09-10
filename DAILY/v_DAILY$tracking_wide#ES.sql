USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_wide#ES AS

WITH extern AS (
  SELECT co.schoolid                
        ,co.year AS academic_year                
        ,co.studentid                                
        ,cd.date_value
        ,FORMAT(cd.date_value,'ddd') AS day                
        ,dt.time_per_name AS week_num                
        ,CASE
          WHEN co.schoolid NOT IN (73255, 179901) THEN CONCAT(daily.color_day, CHAR(9), daily.hw)
          ELSE CONCAT(daily.color_am, CHAR(9), daily.color_mid, CHAR(9), daily.color_pm, CHAR(9), daily.hw)
         END AS color_hw_data                
        ,ROW_NUMBER() OVER(
           PARTITION BY co.studentid, co.year, dt.time_per_name
             ORDER BY cd.date_value) AS rn
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..PS$CALENDAR_DAY cd WITH(NOLOCK)
    ON co.year = cd.academic_year
   AND co.schoolid = cd.schoolid
   AND cd.date_value BETWEEN co.entrydate AND co.exitdate
   AND cd.insession = 1
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON co.year = dt.academic_year
   AND co.schoolid = dt.schoolid
   AND cd.date_value BETWEEN dt.start_date AND dt.end_date
   AND dt.identifier = 'REP'
  LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_long#ES#static daily WITH(NOLOCK)
    ON co.studentid = daily.studentid
   AND cd.date_value = daily.att_date             
 )

SELECT schoolid
      ,academic_year
      ,studentid      
      ,week_num
      ,CASE 
        WHEN schoolid NOT IN (73255, 179901) THEN CONCAT(CHAR(9), 'Color', CHAR(9), 'HW')
        ELSE CONCAT(CHAR(9), 'AM', CHAR(9), 'Mid', CHAR(9), 'PM', CHAR(9), 'HW')
       END AS color_hw_header
      ,LEFT(y.color_hw_data, LEN(y.color_hw_data) - 2) AS color_hw_data
FROM extern
CROSS APPLY (
             SELECT CONCAT(day, ':', CHAR(9), color_hw_data, CHAR(10)+CHAR(13))
             FROM extern daily WITH(NOLOCK)           
             WHERE extern.studentid = daily.studentid
               AND extern.academic_year = daily.academic_year
               AND extern.week_num = daily.week_num               
             ORDER BY date_value
             FOR XML PATH(''), TYPE
            ) x (color_hw_data)
CROSS APPLY (SELECT x.color_hw_data.value('.', 'NVARCHAR(MAX)')) y (color_hw_data)
WHERE extern.rn = 1