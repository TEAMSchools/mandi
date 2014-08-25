USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$tracking_long AS

SELECT daily.studentid
      ,daily.schoolid
      ,CONVERT(DATE,daily.att_date) AS att_date
      ,daily.hw
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN NULL ELSE daily.color END AS color_day
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color ELSE NULL END AS color_am
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color_mid ELSE NULL END AS color_mid
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color_pm ELSE NULL END AS color_pm
      ,CASE 
        WHEN daily.hw = 'Yes' THEN 1.0 
        WHEN daily.hw = 'No' THEN 0.0
        ELSE NULL 
       END AS has_hw
      ,CASE 
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
FROM OPENQUERY(PS_TEAM,'
  SELECT user_defined_date AS att_date
        ,foreignkey AS studentid
        ,schoolid
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field1'') AS hw
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field2'') AS color
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field3'') AS color_mid
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field4'') AS color_pm        
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field5'') AS uniform
        /*
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field6
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field7'') field7
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field8'') field8
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field9'') field9
        ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field10'') field10
        */
  FROM virtualtablesdata2
  WHERE related_to_table = ''dailytracking''
    AND schoolid IN (73254, 73255, 73256, 73257, 179901)
    AND user_defined_date >= ''2014-08-01''
 ') daily
LEFT OUTER JOIN REPORTING$dates dates WITH(NOLOCK)
  ON daily.att_date >= dates.start_date
 AND daily.att_date <= dates.end_date
 AND dates.school_level = 'ES'
 AND dates.identifier = 'REP'