USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$daily_tracking_totals AS
WITH dt_long AS
      (
       SELECT dt.schoolid
             ,studentid
             ,student_number
             ,CONVERT(DATE,att_date) AS att_date
             ,hw
             ,color_day
             ,thrive_am
             ,thrive_mid
             ,thrive_pm      
             ,dates.time_per_name AS RT
             ,dates.alt_name
       FROM ES_DAILY$daily_tracking_long#static dt WITH(NOLOCK)
       JOIN REPORTING$dates dates WITH(NOLOCK)
         ON dt.att_date >= dates.start_date
        AND dt.att_date <= dates.end_date
        AND dt.schoolid = dates.schoolid
        AND dates.identifier = 'RT'
      )
      
    ,curterm AS
      (
       SELECT schoolid
             ,time_per_name AS RT
             ,alt_name
             ,start_date
             ,end_date
       FROM REPORTING$dates WITH(NOLOCK)
       WHERE identifier = 'RT'
         AND GETDATE() >= start_date
         AND GETDATE() <= end_date
      )

SELECT schoolid
      ,studentid
      ,student_number
     /*--Y1--*/
      ,att_days
      ,hw_days
      ,total_days
      ,am_days
      ,mid_days
      ,pm_days
      ,hw
      ,CAST(ROUND(hw / hw_days,2,1) * 100 AS FLOAT) AS hw_pct
      ,purple_total
      ,pink_total
      ,green_total
      ,yellow_total
      ,orange_total
      ,red_total
      ,CAST(ROUND(purple_total / total_days,2,1) * 100 AS FLOAT) AS purple_pct
      ,CAST(ROUND(pink_total / total_days,2,1) * 100 AS FLOAT) AS pink_pct
      ,CAST(ROUND(green_total / total_days,2,1) * 100	AS FLOAT) AS green_pct
      ,CAST(ROUND(yellow_total / total_days,2,1) * 100 AS FLOAT) AS yellow_pct
      ,CAST(ROUND(orange_total / total_days,2,1) * 100 AS FLOAT) AS orange_pct
      ,CAST(ROUND(red_total / total_days,2,1) * 100	AS FLOAT) AS red_pct
     /*--RT1--*/ 
      ,rt1_att_days
      ,rt1_hw_days
      ,rt1_behavior_days
      ,rt1_am_days
      ,rt1_mid_days
      ,rt1_pm_days
      ,rt1_hw
      ,CAST(ROUND(rt1_hw / rt1_hw_days,2,1) * 100 AS FLOAT) AS rt1_hw_pct
      ,rt1_purple_total
      ,rt1_pink_total
      ,rt1_green_total
      ,rt1_yellow_total
      ,rt1_orange_total
      ,rt1_red_total
      ,CAST(ROUND(rt1_purple_total / rt1_total_days,2,1) * 100 AS FLOAT) AS rt1_purple_pct
      ,CAST(ROUND(rt1_pink_total / rt1_total_days,2,1) * 100 AS FLOAT) AS rt1_pink_pct
      ,CAST(ROUND(rt1_green_total / rt1_total_days,2,1) * 100	AS FLOAT) AS rt1_green_pct
      ,CAST(ROUND(rt1_yellow_total / rt1_total_days,2,1) * 100 AS FLOAT) AS rt1_yellow_pct
      ,CAST(ROUND(rt1_orange_total / rt1_total_days,2,1) * 100 AS FLOAT) AS rt1_orange_pct
      ,CAST(ROUND(rt1_red_total / rt1_total_days,2,1) * 100	AS FLOAT) AS rt1_red_pct
     /*--rt2--*/ 
      ,rt2_att_days
      ,rt2_hw_days
      ,rt2_behavior_days
      ,rt2_am_days
      ,rt2_mid_days
      ,rt2_pm_days
      ,rt2_hw
      ,CAST(ROUND(rt2_hw / rt2_hw_days,2,1) * 100 AS FLOAT) AS rt2_hw_pct
      ,rt2_purple_total
      ,rt2_pink_total
      ,rt2_green_total
      ,rt2_yellow_total
      ,rt2_orange_total
      ,rt2_red_total
      ,CAST(ROUND(rt2_purple_total / rt2_total_days,2,1) * 100 AS FLOAT) AS rt2_purple_pct
      ,CAST(ROUND(rt2_pink_total / rt2_total_days,2,1) * 100 AS FLOAT) AS rt2_pink_pct
      ,CAST(ROUND(rt2_green_total / rt2_total_days,2,1) * 100	AS FLOAT) AS rt2_green_pct
      ,CAST(ROUND(rt2_yellow_total / rt2_total_days,2,1) * 100 AS FLOAT) AS rt2_yellow_pct
      ,CAST(ROUND(rt2_orange_total / rt2_total_days,2,1) * 100 AS FLOAT) AS rt2_orange_pct
      ,CAST(ROUND(rt2_red_total / rt2_total_days,2,1) * 100	AS FLOAT) AS rt2_red_pct      
     /*--rt3--*/ 
      ,rt3_att_days
      ,rt3_hw_days
      ,rt3_behavior_days
      ,rt3_am_days
      ,rt3_mid_days
      ,rt3_pm_days
      ,rt3_hw
      ,CAST(ROUND(rt3_hw / rt3_hw_days,2,1) * 100 AS FLOAT) AS rt3_hw_pct
      ,rt3_purple_total
      ,rt3_pink_total
      ,rt3_green_total
      ,rt3_yellow_total
      ,rt3_orange_total
      ,rt3_red_total
      ,CAST(ROUND(rt3_purple_total / rt3_total_days,2,1) * 100 AS FLOAT) AS rt3_purple_pct
      ,CAST(ROUND(rt3_pink_total / rt3_total_days,2,1) * 100 AS FLOAT) AS rt3_pink_pct
      ,CAST(ROUND(rt3_green_total / rt3_total_days,2,1) * 100	AS FLOAT) AS rt3_green_pct
      ,CAST(ROUND(rt3_yellow_total / rt3_total_days,2,1) * 100 AS FLOAT) AS rt3_yellow_pct
      ,CAST(ROUND(rt3_orange_total / rt3_total_days,2,1) * 100 AS FLOAT) AS rt3_orange_pct
      ,CAST(ROUND(rt3_red_total / rt3_total_days,2,1) * 100	AS FLOAT) AS rt3_red_pct    
     /*--rt4--*/ 
      ,rt4_att_days
      ,rt4_hw_days
      ,rt4_behavior_days
      ,rt4_am_days
      ,rt4_mid_days
      ,rt4_pm_days
      ,rt4_hw
      ,CAST(ROUND(rt4_hw / rt4_hw_days,2,1) * 100 AS FLOAT) AS rt4_hw_pct
      ,rt4_purple_total
      ,rt4_pink_total
      ,rt4_green_total
      ,rt4_yellow_total
      ,rt4_orange_total
      ,rt4_red_total
      ,CAST(ROUND(rt4_purple_total / rt4_total_days,2,1) * 100 AS FLOAT) AS rt4_purple_pct
      ,CAST(ROUND(rt4_pink_total / rt4_total_days,2,1) * 100 AS FLOAT) AS rt4_pink_pct
      ,CAST(ROUND(rt4_green_total / rt4_total_days,2,1) * 100	AS FLOAT) AS rt4_green_pct
      ,CAST(ROUND(rt4_yellow_total / rt4_total_days,2,1) * 100 AS FLOAT) AS rt4_yellow_pct
      ,CAST(ROUND(rt4_orange_total / rt4_total_days,2,1) * 100 AS FLOAT) AS rt4_orange_pct
      ,CAST(ROUND(rt4_red_total / rt4_total_days,2,1) * 100	AS FLOAT) AS rt4_red_pct     
     /*--rt5--*/ 
      ,rt5_att_days
      ,rt5_hw_days
      ,rt5_behavior_days
      ,rt5_am_days
      ,rt5_mid_days
      ,rt5_pm_days
      ,rt5_hw
      ,CAST(ROUND(rt5_hw / rt5_hw_days,2,1) * 100 AS FLOAT) AS rt5_hw_pct
      ,rt5_purple_total
      ,rt5_pink_total
      ,rt5_green_total
      ,rt5_yellow_total
      ,rt5_orange_total
      ,rt5_red_total
      ,CAST(ROUND(rt5_purple_total / rt5_total_days,2,1) * 100 AS FLOAT) AS rt5_purple_pct
      ,CAST(ROUND(rt5_pink_total / rt5_total_days,2,1) * 100 AS FLOAT) AS rt5_pink_pct
      ,CAST(ROUND(rt5_green_total / rt5_total_days,2,1) * 100	AS FLOAT) AS rt5_green_pct
      ,CAST(ROUND(rt5_yellow_total / rt5_total_days,2,1) * 100 AS FLOAT) AS rt5_yellow_pct
      ,CAST(ROUND(rt5_orange_total / rt5_total_days,2,1) * 100 AS FLOAT) AS rt5_orange_pct
      ,CAST(ROUND(rt5_red_total / rt5_total_days,2,1) * 100	AS FLOAT) AS rt5_red_pct         
     /*--rt6--*/ 
      ,rt6_att_days
      ,rt6_hw_days
      ,rt6_behavior_days
      ,rt6_am_days
      ,rt6_mid_days
      ,rt6_pm_days
      ,rt6_hw
      ,CAST(ROUND(rt6_hw / rt6_hw_days,2,1) * 100 AS FLOAT) AS rt6_hw_pct
      ,rt6_purple_total
      ,rt6_pink_total
      ,rt6_green_total
      ,rt6_yellow_total
      ,rt6_orange_total
      ,rt6_red_total
      ,CAST(ROUND(rt6_purple_total / rt6_total_days,2,1) * 100 AS FLOAT) AS rt6_purple_pct
      ,CAST(ROUND(rt6_pink_total / rt6_total_days,2,1) * 100 AS FLOAT) AS rt6_pink_pct
      ,CAST(ROUND(rt6_green_total / rt6_total_days,2,1) * 100	AS FLOAT) AS rt6_green_pct
      ,CAST(ROUND(rt6_yellow_total / rt6_total_days,2,1) * 100 AS FLOAT) AS rt6_yellow_pct
      ,CAST(ROUND(rt6_orange_total / rt6_total_days,2,1) * 100 AS FLOAT) AS rt6_orange_pct
      ,CAST(ROUND(rt6_red_total / rt6_total_days,2,1) * 100	AS FLOAT) AS rt6_red_pct      
     /*--cur--*/ 
      ,cur_att_days
      ,cur_hw_days
      ,cur_behavior_days
      ,cur_am_days
      ,cur_mid_days
      ,cur_pm_days
      ,cur_hw
      ,CAST(ROUND(cur_hw / cur_hw_days,2,1) * 100 AS FLOAT) AS cur_hw_pct
      ,cur_purple_total
      ,cur_pink_total
      ,cur_green_total
      ,cur_yellow_total
      ,cur_orange_total
      ,cur_red_total
      ,CAST(ROUND(cur_purple_total / cur_total_days,2,1) * 100 AS FLOAT) AS cur_purple_pct
      ,CAST(ROUND(cur_pink_total / cur_total_days,2,1) * 100 AS FLOAT) AS cur_pink_pct
      ,CAST(ROUND(cur_green_total / cur_total_days,2,1) * 100	AS FLOAT) AS cur_green_pct
      ,CAST(ROUND(cur_yellow_total / cur_total_days,2,1) * 100 AS FLOAT) AS cur_yellow_pct
      ,CAST(ROUND(cur_orange_total / cur_total_days,2,1) * 100 AS FLOAT) AS cur_orange_pct
      ,CAST(ROUND(cur_red_total / cur_total_days,2,1) * 100	AS FLOAT) AS cur_red_pct        
FROM
     (
      SELECT schoolid
            ,studentid
            ,student_number
           /*--Y1--*/
            ,att_days
            ,hw_days
            ,CASE
              WHEN ISNULL(behavior_days,0) + ISNULL(am_days,0) + ISNULL(mid_days,0) + ISNULL(pm_days,0) = 0 THEN NULL 
              ELSE ISNULL(behavior_days,0) + ISNULL(am_days,0) + ISNULL(mid_days,0) + ISNULL(pm_days,0) 
             END AS total_days
            ,behavior_days
            ,am_days 
            ,mid_days
            ,pm_days
            ,hw
            ,purple + purple_am + purple_mid + purple_pm AS purple_total
            ,pink + pink_am + pink_mid + pink_pm AS pink_total
            ,green + green_am + green_mid + green_pm AS green_total
            ,yellow + yellow_am + yellow_mid + yellow_pm AS yellow_total
            ,orange + orange_am + orange_mid + orange_pm AS orange_total
            ,red + red_am + red_mid + red_pm AS red_total
           /*--RT1--*/
            ,rt1_att_days
            ,rt1_hw_days
            ,CASE
              WHEN ISNULL(rt1_behavior_days,0) + ISNULL(rt1_am_days,0) + ISNULL(rt1_mid_days,0) + ISNULL(rt1_pm_days,0) = 0 THEN NULL
              ELSE ISNULL(rt1_behavior_days,0) + ISNULL(rt1_am_days,0) + ISNULL(rt1_mid_days,0) + ISNULL(rt1_pm_days,0)
             END AS rt1_total_days
            ,rt1_behavior_days
            ,rt1_am_days
            ,rt1_mid_days
            ,rt1_pm_days
            ,rt1_hw
            ,rt1_purple + rt1_purple_am + rt1_purple_mid + rt1_purple_pm AS rt1_purple_total
            ,rt1_pink + rt1_pink_am + rt1_pink_mid + rt1_pink_pm AS rt1_pink_total
            ,rt1_green + rt1_green_am + rt1_green_mid + rt1_green_pm AS rt1_green_total
            ,rt1_yellow + rt1_yellow_am + rt1_yellow_mid + rt1_yellow_pm AS rt1_yellow_total
            ,rt1_orange + rt1_orange_am + rt1_orange_mid + rt1_orange_pm AS rt1_orange_total
            ,rt1_red + rt1_red_am + rt1_red_mid + rt1_red_pm AS rt1_red_total
           /*--rt2--*/
            ,rt2_att_days
            ,rt2_hw_days
            ,CASE
              WHEN ISNULL(rt2_behavior_days,0) + ISNULL(rt2_am_days,0) + ISNULL(rt2_mid_days,0) + ISNULL(rt2_pm_days,0) = 0 THEN NULL
              ELSE ISNULL(rt2_behavior_days,0) + ISNULL(rt2_am_days,0) + ISNULL(rt2_mid_days,0) + ISNULL(rt2_pm_days,0)
             END AS rt2_total_days
            ,rt2_behavior_days
            ,rt2_am_days
            ,rt2_mid_days
            ,rt2_pm_days
            ,rt2_hw
            ,rt2_purple + rt2_purple_am + rt2_purple_mid + rt2_purple_pm AS rt2_purple_total
            ,rt2_pink + rt2_pink_am + rt2_pink_mid + rt2_pink_pm AS rt2_pink_total
            ,rt2_green + rt2_green_am + rt2_green_mid + rt2_green_pm AS rt2_green_total
            ,rt2_yellow + rt2_yellow_am + rt2_yellow_mid + rt2_yellow_pm AS rt2_yellow_total
            ,rt2_orange + rt2_orange_am + rt2_orange_mid + rt2_orange_pm AS rt2_orange_total
            ,rt2_red + rt2_red_am + rt2_red_mid + rt2_red_pm AS rt2_red_total      
           /*--rt3--*/
            ,rt3_att_days
            ,rt3_hw_days
            ,CASE
              WHEN ISNULL(rt3_behavior_days,0) + ISNULL(rt3_am_days,0) + ISNULL(rt3_mid_days,0) + ISNULL(rt3_pm_days,0) = 0 THEN NULL
              ELSE ISNULL(rt3_behavior_days,0) + ISNULL(rt3_am_days,0) + ISNULL(rt3_mid_days,0) + ISNULL(rt3_pm_days,0)
             END AS rt3_total_days
            ,rt3_behavior_days
            ,rt3_am_days
            ,rt3_mid_days
            ,rt3_pm_days
            ,rt3_hw
            ,rt3_purple + rt3_purple_am + rt3_purple_mid + rt3_purple_pm AS rt3_purple_total
            ,rt3_pink + rt3_pink_am + rt3_pink_mid + rt3_pink_pm AS rt3_pink_total
            ,rt3_green + rt3_green_am + rt3_green_mid + rt3_green_pm AS rt3_green_total
            ,rt3_yellow + rt3_yellow_am + rt3_yellow_mid + rt3_yellow_pm AS rt3_yellow_total
            ,rt3_orange + rt3_orange_am + rt3_orange_mid + rt3_orange_pm AS rt3_orange_total
            ,rt3_red + rt3_red_am + rt3_red_mid + rt3_red_pm AS rt3_red_total          
           /*--rt4--*/
            ,rt4_att_days
            ,rt4_hw_days
            ,CASE
              WHEN ISNULL(rt4_behavior_days,0) + ISNULL(rt4_am_days,0) + ISNULL(rt4_mid_days,0) + ISNULL(rt4_pm_days,0) = 0 THEN NULL
              ELSE ISNULL(rt4_behavior_days,0) + ISNULL(rt4_am_days,0) + ISNULL(rt4_mid_days,0) + ISNULL(rt4_pm_days,0)
             END AS rt4_total_days
            ,rt4_behavior_days
            ,rt4_am_days
            ,rt4_mid_days
            ,rt4_pm_days
            ,rt4_hw
            ,rt4_purple + rt4_purple_am + rt4_purple_mid + rt4_purple_pm AS rt4_purple_total
            ,rt4_pink + rt4_pink_am + rt4_pink_mid + rt4_pink_pm AS rt4_pink_total
            ,rt4_green + rt4_green_am + rt4_green_mid + rt4_green_pm AS rt4_green_total
            ,rt4_yellow + rt4_yellow_am + rt4_yellow_mid + rt4_yellow_pm AS rt4_yellow_total
            ,rt4_orange + rt4_orange_am + rt4_orange_mid + rt4_orange_pm AS rt4_orange_total
            ,rt4_red + rt4_red_am + rt4_red_mid + rt4_red_pm AS rt4_red_total  
           /*--rt5--*/
            ,rt5_att_days
            ,rt5_hw_days
            ,CASE
              WHEN ISNULL(rt5_behavior_days,0) + ISNULL(rt5_am_days,0) + ISNULL(rt5_mid_days,0) + ISNULL(rt5_pm_days,0) = 0 THEN NULL
              ELSE ISNULL(rt5_behavior_days,0) + ISNULL(rt5_am_days,0) + ISNULL(rt5_mid_days,0) + ISNULL(rt5_pm_days,0)
             END AS rt5_total_days
            ,rt5_behavior_days
            ,rt5_am_days
            ,rt5_mid_days
            ,rt5_pm_days
            ,rt5_hw
            ,rt5_purple + rt5_purple_am + rt5_purple_mid + rt5_purple_pm AS rt5_purple_total
            ,rt5_pink + rt5_pink_am + rt5_pink_mid + rt5_pink_pm AS rt5_pink_total
            ,rt5_green + rt5_green_am + rt5_green_mid + rt5_green_pm AS rt5_green_total
            ,rt5_yellow + rt5_yellow_am + rt5_yellow_mid + rt5_yellow_pm AS rt5_yellow_total
            ,rt5_orange + rt5_orange_am + rt5_orange_mid + rt5_orange_pm AS rt5_orange_total
            ,rt5_red + rt5_red_am + rt5_red_mid + rt5_red_pm AS rt5_red_total                  
           /*--rt6--*/
            ,rt6_att_days
            ,rt6_hw_days
            ,CASE
              WHEN ISNULL(rt6_behavior_days,0) + ISNULL(rt6_am_days,0) + ISNULL(rt6_mid_days,0) + ISNULL(rt6_pm_days,0) = 0 THEN NULL
              ELSE ISNULL(rt6_behavior_days,0) + ISNULL(rt6_am_days,0) + ISNULL(rt6_mid_days,0) + ISNULL(rt6_pm_days,0)
             END AS rt6_total_days
            ,rt6_behavior_days
            ,rt6_am_days
            ,rt6_mid_days
            ,rt6_pm_days
            ,rt6_hw
            ,rt6_purple + rt6_purple_am + rt6_purple_mid + rt6_purple_pm AS rt6_purple_total
            ,rt6_pink + rt6_pink_am + rt6_pink_mid + rt6_pink_pm AS rt6_pink_total
            ,rt6_green + rt6_green_am + rt6_green_mid + rt6_green_pm AS rt6_green_total
            ,rt6_yellow + rt6_yellow_am + rt6_yellow_mid + rt6_yellow_pm AS rt6_yellow_total
            ,rt6_orange + rt6_orange_am + rt6_orange_mid + rt6_orange_pm AS rt6_orange_total
            ,rt6_red + rt6_red_am + rt6_red_mid + rt6_red_pm AS rt6_red_total          
           /*--cur--*/
            ,cur_att_days
            ,cur_hw_days
            ,CASE
              WHEN ISNULL(cur_behavior_days,0) + ISNULL(cur_am_days,0) + ISNULL(cur_mid_days,0) + ISNULL(cur_pm_days,0) = 0 THEN NULL
              ELSE ISNULL(cur_behavior_days,0) + ISNULL(cur_am_days,0) + ISNULL(cur_mid_days,0) + ISNULL(cur_pm_days,0)
             END AS cur_total_days
            ,cur_behavior_days
            ,cur_am_days
            ,cur_mid_days
            ,cur_pm_days
            ,cur_hw
            ,cur_purple + cur_purple_am + cur_purple_mid + cur_purple_pm AS cur_purple_total
            ,cur_pink + cur_pink_am + cur_pink_mid + cur_pink_pm AS cur_pink_total
            ,cur_green + cur_green_am + cur_green_mid + cur_green_pm AS cur_green_total
            ,cur_yellow + cur_yellow_am + cur_yellow_mid + cur_yellow_pm AS cur_yellow_total
            ,cur_orange + cur_orange_am + cur_orange_mid + cur_orange_pm AS cur_orange_total
            ,cur_red + cur_red_am + cur_red_mid + cur_red_pm AS cur_red_total                
      FROM
           (
            SELECT schoolid
                  ,studentid
                  ,student_number      
                 /*--Y1--*/
                  ,SUM(CASE WHEN att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS att_days
                  ,SUM(CASE WHEN hw IS NOT NULL THEN 1.0 ELSE NULL END) AS hw_days
                  ,SUM(CASE WHEN color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS behavior_days
                  ,SUM(CASE WHEN thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS am_days
                  ,SUM(CASE WHEN thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS mid_days
                  ,SUM(CASE WHEN thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS pm_days
                  --HW
                  ,SUM(CASE WHEN hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS hw                  
                  --Purple
                  ,SUM(CASE WHEN color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS purple
                  ,SUM(CASE WHEN thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS purple_am
                  ,SUM(CASE WHEN thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS purple_mid
                  ,SUM(CASE WHEN thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS purple_pm
                  --Pink
                  ,SUM(CASE WHEN color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS pink
                  ,SUM(CASE WHEN thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS pink_am
                  ,SUM(CASE WHEN thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS pink_mid
                  ,SUM(CASE WHEN thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS pink_pm
                  --Green
                  ,SUM(CASE WHEN color_day = 'green' THEN 1.0 ELSE 0.0 END) AS green
                  ,SUM(CASE WHEN thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS green_am
                  ,SUM(CASE WHEN thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS green_mid
                  ,SUM(CASE WHEN thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS green_pm
                  --Yellow
                  ,SUM(CASE WHEN color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS yellow
                  ,SUM(CASE WHEN thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS yellow_am
                  ,SUM(CASE WHEN thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS yellow_mid
                  ,SUM(CASE WHEN thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS yellow_pm
                  --Orange
                  ,SUM(CASE WHEN color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS orange
                  ,SUM(CASE WHEN thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS orange_am
                  ,SUM(CASE WHEN thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS orange_mid
                  ,SUM(CASE WHEN thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS orange_pm
                  --Red
                  ,SUM(CASE WHEN color_day = 'red' THEN 1.0 ELSE 0.0 END) AS red
                  ,SUM(CASE WHEN thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS red_am
                  ,SUM(CASE WHEN thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS red_mid
                  ,SUM(CASE WHEN thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS red_pm
                  
                /*--RT1--*/
                  ,SUM(CASE WHEN rt = 'RT1' AND att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS rt1_att_days
                  ,SUM(CASE WHEN rt = 'RT1' AND hw IS NOT NULL THEN 1.0 ELSE NULL END) AS rt1_hw_days
                  ,SUM(CASE WHEN rt = 'RT1' AND color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS rt1_behavior_days
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS rt1_am_days
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS rt1_mid_days
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS rt1_pm_days
                  --HW
                  ,SUM(CASE WHEN rt = 'RT1' AND hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS rt1_hw
                  --Purple
                  ,SUM(CASE WHEN rt = 'RT1' AND color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS rt1_purple
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS rt1_purple_am
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS rt1_purple_mid
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS rt1_purple_pm
                  --Pink
                  ,SUM(CASE WHEN rt = 'RT1' AND color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS rt1_pink
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS rt1_pink_am
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS rt1_pink_mid
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS rt1_pink_pm
                  --Green
                  ,SUM(CASE WHEN rt = 'RT1' AND color_day = 'green' THEN 1.0 ELSE 0.0 END) AS rt1_green
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS rt1_green_am
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS rt1_green_mid
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS rt1_green_pm
                  --Yellow
                  ,SUM(CASE WHEN rt = 'RT1' AND color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS rt1_yellow
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS rt1_yellow_am
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS rt1_yellow_mid
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS rt1_yellow_pm
                  --Orange
                  ,SUM(CASE WHEN rt = 'RT1' AND color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS rt1_orange
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS rt1_orange_am
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS rt1_orange_mid
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS rt1_orange_pm
                  --Red
                  ,SUM(CASE WHEN rt = 'RT1' AND color_day = 'red' THEN 1.0 ELSE 0.0 END) AS rt1_red
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS rt1_red_am
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS rt1_red_mid
                  ,SUM(CASE WHEN rt = 'RT1' AND thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS rt1_red_pm

                /*--RT2--*/
                  ,SUM(CASE WHEN rt = 'RT2' AND att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS RT2_att_days
                  ,SUM(CASE WHEN rt = 'RT2' AND hw IS NOT NULL THEN 1.0 ELSE NULL END) AS rt2_hw_days
                  ,SUM(CASE WHEN rt = 'RT2' AND color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS rt2_behavior_days
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS rt2_am_days
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS rt2_mid_days
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS rt2_pm_days
                  ,SUM(CASE WHEN rt = 'RT2' AND hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS RT2_hw
                  --Purple
                  ,SUM(CASE WHEN rt = 'RT2' AND color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS RT2_purple
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS RT2_purple_am
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS RT2_purple_mid
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS RT2_purple_pm
                  --Pink
                  ,SUM(CASE WHEN rt = 'RT2' AND color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS RT2_pink
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS RT2_pink_am
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS RT2_pink_mid
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS RT2_pink_pm
                  --Green
                  ,SUM(CASE WHEN rt = 'RT2' AND color_day = 'green' THEN 1.0 ELSE 0.0 END) AS RT2_green
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS RT2_green_am
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS RT2_green_mid
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS RT2_green_pm
                  --Yellow
                  ,SUM(CASE WHEN rt = 'RT2' AND color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT2_yellow
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT2_yellow_am
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT2_yellow_mid
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT2_yellow_pm
                  --Orange
                  ,SUM(CASE WHEN rt = 'RT2' AND color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS RT2_orange
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS RT2_orange_am
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS RT2_orange_mid
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS RT2_orange_pm
                  --Red
                  ,SUM(CASE WHEN rt = 'RT2' AND color_day = 'red' THEN 1.0 ELSE 0.0 END) AS RT2_red
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS RT2_red_am
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS RT2_red_mid
                  ,SUM(CASE WHEN rt = 'RT2' AND thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS RT2_red_pm      
                  
                /*--RT3--*/
                  ,SUM(CASE WHEN rt = 'RT3' AND att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS RT3_att_days
                  ,SUM(CASE WHEN rt = 'RT3' AND hw IS NOT NULL THEN 1.0 ELSE NULL END) AS rt3_hw_days
                  ,SUM(CASE WHEN rt = 'RT3' AND color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS rt3_behavior_days
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS rt3_am_days
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS rt3_mid_days
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS rt3_pm_days
                  ,SUM(CASE WHEN rt = 'RT3' AND hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS RT3_hw
                  --Purple
                  ,SUM(CASE WHEN rt = 'RT3' AND color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS RT3_purple
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS RT3_purple_am
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS RT3_purple_mid
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS RT3_purple_pm
                  --Pink
                  ,SUM(CASE WHEN rt = 'RT3' AND color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS RT3_pink
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS RT3_pink_am
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS RT3_pink_mid
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS RT3_pink_pm
                  --Green
                  ,SUM(CASE WHEN rt = 'RT3' AND color_day = 'green' THEN 1.0 ELSE 0.0 END) AS RT3_green
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS RT3_green_am
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS RT3_green_mid
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS RT3_green_pm
                  --Yellow
                  ,SUM(CASE WHEN rt = 'RT3' AND color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT3_yellow
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT3_yellow_am
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT3_yellow_mid
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT3_yellow_pm
                  --Orange
                  ,SUM(CASE WHEN rt = 'RT3' AND color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS RT3_orange
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS RT3_orange_am
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS RT3_orange_mid
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS RT3_orange_pm
                  --Red
                  ,SUM(CASE WHEN rt = 'RT3' AND color_day = 'red' THEN 1.0 ELSE 0.0 END) AS RT3_red
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS RT3_red_am
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS RT3_red_mid
                  ,SUM(CASE WHEN rt = 'RT3' AND thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS RT3_red_pm      
                  
                /*--RT4--*/
                  ,SUM(CASE WHEN rt = 'RT4' AND att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS RT4_att_days
                  ,SUM(CASE WHEN rt = 'RT4' AND hw IS NOT NULL THEN 1.0 ELSE NULL END) AS rt4_hw_days
                  ,SUM(CASE WHEN rt = 'RT4' AND color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS rt4_behavior_days
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS rt4_am_days
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS rt4_mid_days
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS rt4_pm_days
                  ,SUM(CASE WHEN rt = 'RT4' AND hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS RT4_hw
                  --Purple
                  ,SUM(CASE WHEN rt = 'RT4' AND color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS RT4_purple
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS RT4_purple_am
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS RT4_purple_mid
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS RT4_purple_pm
                  --Pink
                  ,SUM(CASE WHEN rt = 'RT4' AND color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS RT4_pink
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS RT4_pink_am
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS RT4_pink_mid
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS RT4_pink_pm
                  --Green
                  ,SUM(CASE WHEN rt = 'RT4' AND color_day = 'green' THEN 1.0 ELSE 0.0 END) AS RT4_green
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS RT4_green_am
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS RT4_green_mid
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS RT4_green_pm
                  --Yellow
                  ,SUM(CASE WHEN rt = 'RT4' AND color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT4_yellow
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT4_yellow_am
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT4_yellow_mid
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT4_yellow_pm
                  --Orange
                  ,SUM(CASE WHEN rt = 'RT4' AND color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS RT4_orange
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS RT4_orange_am
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS RT4_orange_mid
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS RT4_orange_pm
                  --Red
                  ,SUM(CASE WHEN rt = 'RT4' AND color_day = 'red' THEN 1.0 ELSE 0.0 END) AS RT4_red
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS RT4_red_am
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS RT4_red_mid
                  ,SUM(CASE WHEN rt = 'RT4' AND thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS RT4_red_pm
                  
                /*--RT5--*/
                  ,SUM(CASE WHEN rt = 'RT5' AND att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS RT5_att_days
                  ,SUM(CASE WHEN rt = 'RT5' AND hw IS NOT NULL THEN 1.0 ELSE NULL END) AS rt5_hw_days
                  ,SUM(CASE WHEN rt = 'RT5' AND color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS rt5_behavior_days
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS rt5_am_days
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS rt5_mid_days
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS rt5_pm_days
                  ,SUM(CASE WHEN rt = 'RT5' AND hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS RT5_hw
                  --Purple
                  ,SUM(CASE WHEN rt = 'RT5' AND color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS RT5_purple
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS RT5_purple_am
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS RT5_purple_mid
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS RT5_purple_pm
                  --Pink
                  ,SUM(CASE WHEN rt = 'RT5' AND color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS RT5_pink
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS RT5_pink_am
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS RT5_pink_mid
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS RT5_pink_pm
                  --Green
                  ,SUM(CASE WHEN rt = 'RT5' AND color_day = 'green' THEN 1.0 ELSE 0.0 END) AS RT5_green
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS RT5_green_am
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS RT5_green_mid
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS RT5_green_pm
                  --Yellow
                  ,SUM(CASE WHEN rt = 'RT5' AND color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT5_yellow
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT5_yellow_am
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT5_yellow_mid
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT5_yellow_pm
                  --Orange
                  ,SUM(CASE WHEN rt = 'RT5' AND color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS RT5_orange
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS RT5_orange_am
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS RT5_orange_mid
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS RT5_orange_pm
                  --Red
                  ,SUM(CASE WHEN rt = 'RT5' AND color_day = 'red' THEN 1.0 ELSE 0.0 END) AS RT5_red
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS RT5_red_am
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS RT5_red_mid
                  ,SUM(CASE WHEN rt = 'RT5' AND thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS RT5_red_pm    
                  
                /*--RT6--*/
                  ,SUM(CASE WHEN rt = 'RT6' AND att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS RT6_att_days
                  ,SUM(CASE WHEN rt = 'RT6' AND hw IS NOT NULL THEN 1.0 ELSE NULL END) AS rt6_hw_days
                  ,SUM(CASE WHEN rt = 'RT6' AND color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS rt6_behavior_days
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS rt6_am_days
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS rt6_mid_days
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS rt6_pm_days
                  ,SUM(CASE WHEN rt = 'RT6' AND hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS RT6_hw
                  --Purple
                  ,SUM(CASE WHEN rt = 'RT6' AND color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS RT6_purple
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS RT6_purple_am
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS RT6_purple_mid
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS RT6_purple_pm
                  --Pink
                  ,SUM(CASE WHEN rt = 'RT6' AND color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS RT6_pink
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS RT6_pink_am
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS RT6_pink_mid
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS RT6_pink_pm
                  --Green
                  ,SUM(CASE WHEN rt = 'RT6' AND color_day = 'green' THEN 1.0 ELSE 0.0 END) AS RT6_green
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS RT6_green_am
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS RT6_green_mid
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS RT6_green_pm
                  --Yellow
                  ,SUM(CASE WHEN rt = 'RT6' AND color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT6_yellow
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT6_yellow_am
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT6_yellow_mid
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS RT6_yellow_pm
                  --Orange
                  ,SUM(CASE WHEN rt = 'RT6' AND color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS RT6_orange
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS RT6_orange_am
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS RT6_orange_mid
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS RT6_orange_pm
                  --Red
                  ,SUM(CASE WHEN rt = 'RT6' AND color_day = 'red' THEN 1.0 ELSE 0.0 END) AS RT6_red
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS RT6_red_am
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS RT6_red_mid
                  ,SUM(CASE WHEN rt = 'RT6' AND thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS RT6_red_pm

                /*--CUR--*/
                  ,SUM(CASE WHEN rt = 'CUR' AND att_date IS NOT NULL THEN 1.0 ELSE NULL END) AS CUR_att_days
                  ,SUM(CASE WHEN rt = 'CUR' AND hw IS NOT NULL THEN 1.0 ELSE NULL END) AS cur_hw_days
                  ,SUM(CASE WHEN rt = 'CUR' AND color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS cur_behavior_days
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS cur_am_days
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS cur_mid_days
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS cur_pm_days
                  ,SUM(CASE WHEN rt = 'CUR' AND hw = 'Yes' THEN 1.0 ELSE 0.0 END) AS CUR_hw
                  --Purple
                  ,SUM(CASE WHEN rt = 'CUR' AND color_day = 'purple' THEN 1.0 ELSE 0.0 END) AS CUR_purple
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_am = 'purple' THEN 1.0 ELSE 0.0 END) AS CUR_purple_am
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_mid = 'purple' THEN 1.0 ELSE 0.0 END) AS CUR_purple_mid
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_pm = 'purple' THEN 1.0 ELSE 0.0 END) AS CUR_purple_pm
                  --Pink
                  ,SUM(CASE WHEN rt = 'CUR' AND color_day = 'pink' THEN 1.0 ELSE 0.0 END) AS CUR_pink
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_am = 'pink' THEN 1.0 ELSE 0.0 END) AS CUR_pink_am
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_mid = 'pink' THEN 1.0 ELSE 0.0 END) AS CUR_pink_mid
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_pm = 'pink' THEN 1.0 ELSE 0.0 END) AS CUR_pink_pm
                  --Green
                  ,SUM(CASE WHEN rt = 'CUR' AND color_day = 'green' THEN 1.0 ELSE 0.0 END) AS CUR_green
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_am = 'green' THEN 1.0 ELSE 0.0 END) AS CUR_green_am
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_mid = 'green' THEN 1.0 ELSE 0.0 END) AS CUR_green_mid
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_pm = 'green' THEN 1.0 ELSE 0.0 END) AS CUR_green_pm
                  --Yellow
                  ,SUM(CASE WHEN rt = 'CUR' AND color_day = 'yellow' THEN 1.0 ELSE 0.0 END) AS CUR_yellow
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_am = 'yellow' THEN 1.0 ELSE 0.0 END) AS CUR_yellow_am
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_mid = 'yellow' THEN 1.0 ELSE 0.0 END) AS CUR_yellow_mid
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_pm = 'yellow' THEN 1.0 ELSE 0.0 END) AS CUR_yellow_pm
                  --Orange
                  ,SUM(CASE WHEN rt = 'CUR' AND color_day = 'orange' THEN 1.0 ELSE 0.0 END) AS CUR_orange
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_am = 'orange' THEN 1.0 ELSE 0.0 END) AS CUR_orange_am
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_mid = 'orange' THEN 1.0 ELSE 0.0 END) AS CUR_orange_mid
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_pm = 'orange' THEN 1.0 ELSE 0.0 END) AS CUR_orange_pm
                  --Red
                  ,SUM(CASE WHEN rt = 'CUR' AND color_day = 'red' THEN 1.0 ELSE 0.0 END) AS CUR_red
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_am = 'red' THEN 1.0 ELSE 0.0 END) AS CUR_red_am
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_mid = 'red' THEN 1.0 ELSE 0.0 END) AS CUR_red_mid
                  ,SUM(CASE WHEN rt = 'CUR' AND thrive_pm = 'red' THEN 1.0 ELSE 0.0 END) AS CUR_red_pm              
            FROM
                 (      
                  SELECT *
                  FROM dt_long WITH(NOLOCK)

                  UNION ALL 

                  SELECT dt_long.schoolid
                        ,dt_long.studentid
                        ,dt_long.student_number
                        ,dt_long.att_date
                        ,dt_long.hw
                        ,dt_long.color_day
                        ,dt_long.thrive_am
                        ,dt_long.thrive_mid
                        ,dt_long.thrive_pm
                        ,'CUR' AS RT
                        ,dt_long.alt_name
                  FROM dt_long WITH(NOLOCK)
                  JOIN curterm WITH(NOLOCK)
                    ON dt_long.att_date >= curterm.start_date
                   AND dt_long.att_date <= curterm.end_date
                   AND dt_long.schoolid = curterm.schoolid                  
                 ) sub            
            GROUP BY schoolid, studentid, student_number            
           ) sub2      
     ) sub3      