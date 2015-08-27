USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_wide#ES AS

WITH valid_dates AS (
  SELECT *
        ,ROW_NUMBER() OVER(
            PARTITION BY schoolid, week_num
                ORDER BY att_date) AS day_number
  FROM
      (
       SELECT DISTINCT 
              daily.schoolid
             ,daily.att_date                                            
             ,dates.time_per_name AS week_num
       FROM DAILY$tracking_long#ES#static daily WITH(NOLOCK)
       JOIN REPORTING$dates dates WITH(NOLOCK)
         ON dates.school_level = 'ES'
        AND daily.att_date >= dates.start_date
        AND daily.att_date <= dates.end_date
        AND dates.identifier = 'REP'
       ) sub
 )      

SELECT schoolid
      ,studentid
      ,week_num
      ,MAX([1]) AS day_1
      ,MAX([2]) AS day_2
      ,MAX([3]) AS day_3
      ,MAX([4]) AS day_4
      ,MAX([5]) AS day_5
      ,MAX([hw_1]) AS [hw_1]
      ,MAX([hw_2]) AS [hw_2]
      ,MAX([hw_3]) AS [hw_3]
      ,MAX([hw_4]) AS [hw_4]
      ,MAX([hw_5]) AS [hw_5]
      ,CASE WHEN MAX(hw_1) = 'No' THEN LEFT(MAX([1]),3) + ' ' ELSE '' END
        + CASE WHEN MAX(hw_2) = 'No' THEN LEFT(MAX([2]),3) + ' ' ELSE '' END
        + CASE WHEN MAX(hw_3) = 'No' THEN LEFT(MAX([3]),3) + ' ' ELSE '' END 
        + CASE WHEN MAX(hw_4) = 'No' THEN LEFT(MAX([4]),3) + ' ' ELSE '' END
        + CASE WHEN MAX(hw_5) = 'No' THEN LEFT(MAX([5]),3) + ' ' ELSE '' END
        AS hw_missing_days
      ,MAX([color_day_1]) AS [color_day_1]
      ,MAX([color_day_2]) AS [color_day_2]
      ,MAX([color_day_3]) AS [color_day_3]
      ,MAX([color_day_4]) AS [color_day_4]
      ,MAX([color_day_5]) AS [color_day_5]
      ,MAX([color_am_1]) AS [color_am_1]
      ,MAX([color_am_2]) AS [color_am_2]
      ,MAX([color_am_3]) AS [color_am_3]
      ,MAX([color_am_4]) AS [color_am_4]
      ,MAX([color_am_5]) AS [color_am_5]      
      ,MAX([color_mid_1]) AS [color_mid_1]
      ,MAX([color_mid_2]) AS [color_mid_2]
      ,MAX([color_mid_3]) AS [color_mid_3]
      ,MAX([color_mid_4]) AS [color_mid_4]
      ,MAX([color_mid_5]) AS [color_mid_5]
      ,MAX([color_pm_1]) AS [color_pm_1]
      ,MAX([color_pm_2]) AS [color_pm_2]
      ,MAX([color_pm_3]) AS [color_pm_3]
      ,MAX([color_pm_4]) AS [color_pm_4]
      ,MAX([color_pm_5]) AS [color_pm_5]      
FROM 
    (
     SELECT schoolid
           ,studentid
           ,week_num
           ,day
           ,day_number
           ,identifier + '_' + CONVERT(VARCHAR,day_number) AS identifier
           ,value
     FROM
         (
          SELECT daily.schoolid
                ,daily.studentid
                ,daily.week_num
                ,daily.att_date
                ,DATENAME(WEEKDAY,daily.att_date) AS day
                ,valid_dates.day_number        
                ,daily.hw
                ,CASE WHEN daily.schoolid IN (73255, 179901) THEN COALESCE(daily.color_pm, daily.color_mid, daily.color_am) ELSE daily.color_day END AS color_day
                ,daily.color_am
                ,daily.color_mid
                ,daily.color_pm
               FROM DAILY$tracking_long#ES#static daily WITH(NOLOCK)
               JOIN valid_dates WITH(NOLOCK)
                 ON daily.schoolid = valid_dates.schoolid
                AND daily.att_date = valid_dates.att_date
         ) sub

     UNPIVOT (
       value
       FOR identifier IN ([hw]
                         ,[color_day]
                         ,[color_am]
                         ,[color_mid]
                         ,[color_pm])
      ) unpiv
    ) sub2

PIVOT (
  MAX(value)
  FOR identifier IN ([color_am_1]
                    ,[color_am_2]
                    ,[color_am_3]
                    ,[color_am_4]
                    ,[color_am_5]
                    ,[color_day_1]
                    ,[color_day_2]
                    ,[color_day_3]
                    ,[color_day_4]
                    ,[color_day_5]
                    ,[color_mid_1]
                    ,[color_mid_2]
                    ,[color_mid_3]
                    ,[color_mid_4]
                    ,[color_mid_5]
                    ,[color_pm_1]
                    ,[color_pm_2]
                    ,[color_pm_3]
                    ,[color_pm_4]
                    ,[color_pm_5]
                    ,[hw_1]
                    ,[hw_2]
                    ,[hw_3]
                    ,[hw_4]
                    ,[hw_5])  
 ) piv1
 
PIVOT (  
  MAX(day)
  FOR day_number IN ([1],[2],[3],[4],[5])
 ) piv2
 
GROUP BY schoolid
        ,studentid
        ,week_num
