USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$tracking_long AS

SELECT daily.studentid
      ,daily.schoolid
      ,dbo.fn_DateToSY(daily.att_date) AS academic_year
      ,CONVERT(DATE,daily.att_date) AS att_date
      ,daily.hw
      ,CASE
        WHEN (daily.schoolid = 73255 AND daily.att_date <= '2014-09-30') THEN NULL
        ELSE daily.uniform
       END AS uniform
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN NULL ELSE daily.color END AS color_day
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color ELSE NULL END AS color_am
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color_mid ELSE NULL END AS color_mid
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color_pm ELSE NULL END AS color_pm
      ,CASE 
        WHEN daily.hw = 'Yes' THEN 1.0 
        WHEN daily.hw = 'No' THEN 0.0
        ELSE NULL 
       END AS has_hw
      -- FML -- THRIVE told teachers to log uniform infractions the opposite of what it should have been
      -- delete this next year and #planbetter
      ,CASE         
        WHEN (daily.schoolid = 73255 AND daily.att_date <= '2014-09-30') THEN NULL
        WHEN daily.uniform = 'Yes' THEN 1.0 
        WHEN daily.uniform = 'No' THEN 0.0
        ELSE NULL 
       END AS has_uniform
      ,CASE WHEN daily.schoolid NOT IN (73255, 179901) AND daily.color IN ('purple','pink') THEN 1.0 ELSE NULL END AS purple_pink
      ,CASE WHEN daily.schoolid NOT IN (73255, 179901) AND daily.color = 'green' THEN 1.0 ELSE NULL END AS green
      ,CASE WHEN daily.schoolid NOT IN (73255, 179901) AND daily.color = 'yellow' THEN 1.0 ELSE NULL END AS yellow
      ,CASE WHEN daily.schoolid NOT IN (73255, 179901) AND daily.color = 'orange' THEN 1.0 ELSE NULL END AS orange
      ,CASE WHEN daily.schoolid NOT IN (73255, 179901) AND daily.color = 'red' THEN 1.0 ELSE NULL END AS red
      ,CASE WHEN daily.schoolid IN (73255, 179901) AND daily.color IN ('purple','pink') THEN 1.0 ELSE NULL END AS am_purple_pink
      ,CASE WHEN daily.schoolid IN (73255, 179901) AND daily.color = 'green' THEN 1.0 ELSE NULL END AS am_green
      ,CASE WHEN daily.schoolid IN (73255, 179901) AND daily.color = 'yellow' THEN 1.0 ELSE NULL END AS am_yellow
      ,CASE WHEN daily.schoolid IN (73255, 179901) AND daily.color = 'orange' THEN 1.0 ELSE NULL END AS am_orange
      ,CASE WHEN daily.schoolid IN (73255, 179901) AND daily.color = 'red' THEN 1.0 ELSE NULL END AS am_red
      ,CASE WHEN daily.color_mid IN ('purple','pink') THEN 1.0 ELSE NULL END AS mid_purple_pink
      ,CASE WHEN daily.color_mid = 'green' THEN 1.0 ELSE NULL END AS mid_green
      ,CASE WHEN daily.color_mid = 'yellow' THEN 1.0 ELSE NULL END AS mid_yellow
      ,CASE WHEN daily.color_mid = 'orange' THEN 1.0 ELSE NULL END AS mid_orange
      ,CASE WHEN daily.color_mid = 'red' THEN 1.0 ELSE NULL END AS mid_red
      ,CASE WHEN daily.color_pm IN ('purple','pink') THEN 1.0 ELSE NULL END AS pm_purple_pink
      ,CASE WHEN daily.color_pm = 'green' THEN 1.0 ELSE NULL END AS pm_green
      ,CASE WHEN daily.color_pm = 'yellow' THEN 1.0 ELSE NULL END AS pm_yellow
      ,CASE WHEN daily.color_pm = 'orange' THEN 1.0 ELSE NULL END AS pm_orange
      ,CASE WHEN daily.color_pm = 'red' THEN 1.0 ELSE NULL END AS pm_red  
      ,dates.time_per_name AS week_num
FROM 
    (
     SELECT CONVERT(DATE,att_date) AS att_date
           ,studentid
           ,schoolid
           ,field1 AS hw
           ,field2 AS color
           ,field3 AS color_mid
           ,field4 AS color_pm        
           ,field5 AS uniform           
           ,field6
           ,field7
           ,field8
           ,field9
           ,field10
     FROM KIPP_NJ..DAILY$tracking_long#staging WITH(NOLOCK)
     WHERE schoolid IN (73254, 73255, 73256, 73257, 179901)       
    ) daily
LEFT OUTER JOIN REPORTING$dates dates WITH(NOLOCK)
  ON daily.att_date >= dates.start_date
 AND daily.att_date <= dates.end_date
 AND daily.schoolid = dates.schoolid
 AND dates.identifier = 'REP'