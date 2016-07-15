USE KIPP_NJ
GO

ALTER VIEW DISC$counts_wide AS

WITH curterm AS (
  SELECT schoolid
        ,time_per_name
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
    AND identifier = 'RT'    
 )

SELECT log.studentid

      --Year
      ,SUM(CASE WHEN log.subtype = 'Detention' THEN 1 ELSE NULL END) detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' THEN 1
                WHEN log.subtype = 'Silent Lunch (5 Day)' THEN 5
                ELSE NULL END) silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE '%Choices%' THEN 1 ELSE NULL END) choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' THEN 1 ELSE NULL END) bench
      ,SUM(CASE WHEN log.subtype = 'ISS' THEN 1 ELSE NULL END) ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' THEN 1 ELSE NULL END) OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' THEN 1 ELSE NULL END) bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' THEN 1 ELSE NULL END) bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' THEN 1 ELSE NULL END) class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' THEN 1 ELSE NULL END) Bullying      

      --RT1
      ,SUM(CASE WHEN log.subtype = 'Detention' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' AND log.rt = 'RT1' THEN 1 
                WHEN log.subtype = 'Silent Lunch (5 Day)' AND log.rt = 'RT1' THEN 5
                ELSE NULL END) rt1_silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_bench
      ,SUM(CASE WHEN log.subtype = 'ISS' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' AND log.rt = 'RT1' THEN 1 ELSE NULL END) rt1_bullying

      --RT2
      ,SUM(CASE WHEN log.subtype = 'Detention' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' AND log.rt = 'RT2' THEN 1 
                WHEN log.subtype = 'Silent Lunch (5 Day)' AND log.rt = 'RT2' THEN 5
                ELSE NULL END) rt2_silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_bench
      ,SUM(CASE WHEN log.subtype = 'ISS' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' AND log.rt = 'RT2' THEN 1 ELSE NULL END) rt2_bullying

      --RT3
      ,SUM(CASE WHEN log.subtype = 'Detention' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' AND log.rt = 'RT3' THEN 1
                WHEN log.subtype = 'Silent Lunch (5 Day)' AND log.rt = 'RT3' THEN 5
                ELSE NULL END) rt3_silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_bench
      ,SUM(CASE WHEN log.subtype = 'ISS' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' AND log.rt = 'RT3' THEN 1 ELSE NULL END) rt3_bullying

      --RT4
      ,SUM(CASE WHEN log.subtype = 'Detention' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' AND log.rt = 'RT4' THEN 1 
                WHEN log.subtype = 'Silent Lunch (5 Day)' AND log.rt = 'RT4' THEN 5
                ELSE NULL END) rt4_silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_bench
      ,SUM(CASE WHEN log.subtype = 'ISS' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' AND log.rt = 'RT4' THEN 1 ELSE NULL END) rt4_bullying

      --RT5
      ,SUM(CASE WHEN log.subtype = 'Detention' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' AND log.rt = 'RT5' THEN 1 
                WHEN log.subtype = 'Silent Lunch (5 Day)' AND log.rt = 'RT5' THEN 5
                ELSE NULL END) rt5_silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_bench
      ,SUM(CASE WHEN log.subtype = 'ISS' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' AND log.rt = 'RT5' THEN 1 ELSE NULL END) rt5_bullying

      --RT6
      ,SUM(CASE WHEN log.subtype = 'Detention' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' AND log.rt = 'RT6' THEN 1
                WHEN log.subtype = 'Silent Lunch (5 Day)' AND log.rt = 'RT6' THEN 5
                ELSE NULL END) rt6_silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_bench
      ,SUM(CASE WHEN log.subtype = 'ISS' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' AND log.rt = 'RT6' THEN 1 ELSE NULL END) rt6_bullying

      --CUR
      ,SUM(CASE WHEN log.subtype = 'Detention' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_detentions
      ,SUM(CASE WHEN log.subtype = 'Silent Lunch' AND log.rt = curterm.time_per_name THEN 1
                WHEN log.subtype = 'Silent Lunch (5 Day)' AND log.rt = curterm.time_per_name THEN 5
                ELSE NULL END) cur_silent_lunches
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_choices
      ,SUM(CASE WHEN log.subtype LIKE 'Bench%' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_bench
      ,SUM(CASE WHEN log.subtype = 'ISS' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_ISS
      ,SUM(CASE WHEN log.subtype = 'OSS' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_OSS
      ,SUM(CASE WHEN log.subtype = 'Bus Warning' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_bus_warnings
      ,SUM(CASE WHEN log.subtype = 'Bus Suspension' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_bus_suspensions
      ,SUM(CASE WHEN log.subtype = 'Class Removal' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_class_removal
      ,SUM(CASE WHEN log.subtype = 'Bullying' AND log.rt = curterm.time_per_name THEN 1 ELSE NULL END) cur_bullying
FROM KIPP_NJ..DISC$log#static log WITH(NOLOCK)
JOIN curterm WITH(NOLOCK)
  ON log.schoolid = curterm.schoolid
WHERE log.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
GROUP BY log.studentid