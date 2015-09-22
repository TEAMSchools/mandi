USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_long#ES AS

SELECT daily.studentid
      ,daily.schoolid
      ,dbo.fn_DateToSY(daily.att_date) AS academic_year
      ,CONVERT(DATE,daily.att_date) AS att_date
      ,daily.hw
      ,daily.uniform       
      ,daily.bip_status
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN NULL ELSE daily.color END AS color_day
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color ELSE NULL END AS color_am
      ,CASE WHEN daily.schoolid IN (73255, 179901) AND daily.grade_level <= 2 THEN daily.color_mid ELSE NULL END AS color_mid
      ,CASE WHEN daily.schoolid IN (73255, 179901) THEN daily.color_pm ELSE NULL END AS color_pm
      ,CASE WHEN daily.bip_status = 'On Track' THEN 1.0 WHEN daily.bip_status = 'Off Track' THEN 0.0 ELSE NULL END AS bip_ontrack
      ,CASE WHEN daily.hw = 'Yes' THEN 1.0 WHEN daily.hw = 'No' THEN 0.0 ELSE NULL END AS has_hw      
      ,CASE WHEN daily.uniform = 'Yes' THEN 1.0 WHEN daily.uniform = 'No' THEN 0.0 ELSE NULL END AS has_uniform
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
      ,terms.alt_name AS term
FROM 
    (
     SELECT CONVERT(DATE,d.att_date) AS att_date
           ,d.studentid
           ,d.schoolid
           ,co.grade_level
           ,d.field1 AS hw
           ,d.field2 AS color
           ,d.field3 AS color_mid
           ,d.field4 AS color_pm        
           ,d.field5 AS uniform           
           ,d.field6
           ,d.field7
           ,d.field8
           ,d.field9
           ,d.field10 AS bip_status
           ,ROW_NUMBER() OVER(
              PARTITION BY d.studentid, d.att_date
                ORDER BY d.unique_id DESC) AS rn
     FROM KIPP_NJ..DAILY$tracking_long#STAGING d WITH(NOLOCK)
     JOIN KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
       ON d.STUDENTID = co.studentid
      AND CONVERT(DATE,d.ATT_DATE) BETWEEN co.entrydate AND co.exitdate
     WHERE d.SCHOOLID IN (73254, 73255, 73256, 73257, 179901)       
    ) daily
LEFT OUTER JOIN REPORTING$dates dates WITH(NOLOCK)
  ON daily.att_date BETWEEN dates.start_date AND dates.end_date
 AND daily.schoolid = dates.schoolid
 AND dates.identifier = 'REP'
LEFT OUTER JOIN REPORTING$dates terms WITH(NOLOCK)
  ON daily.att_date BETWEEN terms.start_date AND terms.end_date
 AND daily.schoolid = terms.schoolid
 AND terms.identifier = 'RT'
WHERE daily.rn = 1