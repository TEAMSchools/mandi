USE KIPP_NJ
GO

ALTER VIEW REPORTING$daily_tracking_totals AS

WITH valid_dates AS (
  SELECT *
        ,ROW_NUMBER() OVER(
            PARTITION BY schoolid, week_num
                ORDER BY att_date) AS day_number
  FROM
      (
       SELECT DISTINCT daily.schoolid
                      ,daily.att_date
                      ,DATENAME(MONTH,daily.att_date) AS month                      
                      ,dates.time_per_name AS week_num
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)
       JOIN REPORTING$dates dates WITH(NOLOCK)
         ON dates.school_level = 'ES'
        AND daily.att_date >= dates.start_date
        AND daily.att_date <= dates.end_date
        AND dates.identifier = 'FSA'
       ) sub
 )

,week_total AS (
  SELECT schoolid
        ,studentid
        ,week_num
        ,month
        ,n_hw_wk
        ,CONVERT(INT,hw_complete_wk) AS hw_complete_wk
        ,CONVERT(INT,hw_missing_wk) AS hw_missing_wk
        ,hw_pct_wk
        ,n_color_wk
        ,CONVERT(INT,purple_pink_wk) AS purple_pink_wk
        ,CONVERT(INT,green_wk) AS green_wk
        ,CONVERT(INT,yellow_wk) AS yellow_wk
        ,CONVERT(INT,orange_wk) AS orange_wk
        ,CONVERT(INT,red_wk) AS red_wk
        ,CONVERT(FLOAT,ROUND((purple_pink_wk + green_wk) / CASE WHEN n_color_wk = 0 THEN NULL ELSE n_color_wk END * 100,0)) AS pct_ontrack_wk
        ,CASE
          WHEN CONVERT(FLOAT,ROUND((purple_pink_wk + green_wk) / CASE WHEN n_color_wk = 0 THEN NULL ELSE n_color_wk END * 100,0)) >= 80 THEN 'On Track' 
          ELSE 'Off Track'
         END AS status_wk
  FROM
      (
       SELECT daily.schoolid
             ,daily.studentid      
             ,valid_dates.week_num
             ,valid_dates.month
             ,COUNT(hw) AS n_hw_wk
             ,SUM(has_hw) AS hw_complete_wk
             ,COUNT(hw) - SUM(has_hw) AS hw_missing_wk
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct_wk
             ,ISNULL(COUNT(color_day),0)
               + ISNULL(COUNT(color_am),0)
               + ISNULL(COUNT(color_mid),0)
               + ISNULL(COUNT(color_pm),0)
               AS n_color_wk
             ,ISNULL(SUM(purple_pink),0)
               + ISNULL(SUM(am_purple_pink),0)
               + ISNULL(SUM(mid_purple_pink),0)
               + ISNULL(SUM(pm_purple_pink),0) AS purple_pink_wk
             ,ISNULL(SUM(green),0)
               + ISNULL(SUM(am_green),0)
               + ISNULL(SUM(mid_green),0)
               + ISNULL(SUM(pm_green),0) AS green_wk
             ,ISNULL(SUM(yellow),0)
               + ISNULL(SUM(am_yellow),0)
               + ISNULL(SUM(mid_yellow),0)
               + ISNULL(SUM(pm_yellow),0) AS yellow_wk
             ,ISNULL(SUM(orange),0)
               + ISNULL(SUM(am_orange),0)
               + ISNULL(SUM(mid_orange),0)
               + ISNULL(SUM(pm_orange),0) AS orange_wk
             ,ISNULL(SUM(red),0)
               + ISNULL(SUM(am_red),0)
               + ISNULL(SUM(mid_red),0)
               + ISNULL(SUM(pm_red),0) AS red_wk        
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)
       JOIN valid_dates
         ON daily.schoolid = valid_dates.schoolid
        AND daily.att_date = valid_dates.att_date
       GROUP BY daily.schoolid
               ,daily.studentid        
               ,valid_dates.week_num
               ,valid_dates.month
      ) sub  
 )
 
,month_total AS (
  SELECT schoolid
        ,studentid        
        ,month
        ,n_hw_mth
        ,CONVERT(INT,hw_complete_mth) AS hw_complete_mth
        ,CONVERT(INT,hw_missing_mth) AS hw_missing_mth
        ,hw_pct_mth
        ,n_color_mth
        ,CONVERT(INT,purple_pink_mth) AS purple_pink_mth
        ,CONVERT(INT,green_mth) AS green_mth
        ,CONVERT(INT,yellow_mth) AS yellow_mth
        ,CONVERT(INT,orange_mth) AS orange_mth
        ,CONVERT(INT,red_mth) AS red_mth
        ,CONVERT(FLOAT,ROUND((purple_pink_mth + green_mth) / CASE WHEN n_color_mth = 0 THEN NULL ELSE n_color_mth END * 100,0)) AS pct_ontrack_mth
        ,CASE
          WHEN CONVERT(FLOAT,ROUND((purple_pink_mth + green_mth) / CASE WHEN n_color_mth = 0 THEN NULL ELSE n_color_mth END * 100,0)) >= 80 THEN 'On Track' 
          ELSE 'Off Track'
         END AS status_mth
  FROM
      (
       SELECT daily.schoolid
             ,daily.studentid                   
             ,valid_dates.month
             ,COUNT(hw) AS n_hw_mth
             ,SUM(has_hw) AS hw_complete_mth
             ,COUNT(hw) - SUM(has_hw) AS hw_missing_mth
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct_mth
             ,ISNULL(COUNT(color_day),0)
               + ISNULL(COUNT(color_am),0)
               + ISNULL(COUNT(color_mid),0)
               + ISNULL(COUNT(color_pm),0)
               AS n_color_mth
             ,ISNULL(SUM(purple_pink),0)
               + ISNULL(SUM(am_purple_pink),0)
               + ISNULL(SUM(mid_purple_pink),0)
               + ISNULL(SUM(pm_purple_pink),0) AS purple_pink_mth
             ,ISNULL(SUM(green),0)
               + ISNULL(SUM(am_green),0)
               + ISNULL(SUM(mid_green),0)
               + ISNULL(SUM(pm_green),0) AS green_mth
             ,ISNULL(SUM(yellow),0)
               + ISNULL(SUM(am_yellow),0)
               + ISNULL(SUM(mid_yellow),0)
               + ISNULL(SUM(pm_yellow),0) AS yellow_mth
             ,ISNULL(SUM(orange),0)
               + ISNULL(SUM(am_orange),0)
               + ISNULL(SUM(mid_orange),0)
               + ISNULL(SUM(pm_orange),0) AS orange_mth
             ,ISNULL(SUM(red),0)
               + ISNULL(SUM(am_red),0)
               + ISNULL(SUM(mid_red),0)
               + ISNULL(SUM(pm_red),0) AS red_mth        
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)
       JOIN valid_dates
         ON daily.schoolid = valid_dates.schoolid
        AND daily.att_date = valid_dates.att_date
       GROUP BY daily.schoolid
               ,daily.studentid                       
               ,valid_dates.month
      ) sub  
 )
 
,year_total AS (
  SELECT schoolid
        ,studentid
        ,n_hw_yr
        ,CONVERT(INT,hw_complete_yr) AS hw_complete_yr
        ,CONVERT(INT,hw_missing_yr) AS hw_missing_yr
        ,hw_pct_yr
        ,n_color_yr
        ,CONVERT(INT,purple_pink_yr) AS purple_pink_yr
        ,CONVERT(INT,green_yr) AS green_yr
        ,CONVERT(INT,yellow_yr) AS yellow_yr
        ,CONVERT(INT,orange_yr) AS orange_yr
        ,CONVERT(INT,red_yr) AS red_yr
        ,CONVERT(FLOAT,ROUND((purple_pink_yr + green_yr) / CASE WHEN n_color_yr = 0 THEN NULL ELSE n_color_yr END * 100,0)) AS pct_ontrack_yr
        ,CASE
          WHEN CONVERT(FLOAT,ROUND((purple_pink_yr + green_yr) / CASE WHEN n_color_yr = 0 THEN NULL ELSE n_color_yr END * 100,0)) >= 80 THEN 'On Track' 
          ELSE 'Off Track'
         END AS status_yr
  FROM
      (
       SELECT daily.schoolid
             ,daily.studentid                                
             ,COUNT(hw) AS n_hw_yr
             ,SUM(has_hw) AS hw_complete_yr
             ,COUNT(hw) - SUM(has_hw) AS hw_missing_yr
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct_yr
             ,ISNULL(COUNT(color_day),0)
               + ISNULL(COUNT(color_am),0)
               + ISNULL(COUNT(color_mid),0)
               + ISNULL(COUNT(color_pm),0)
               AS n_color_yr
             ,ISNULL(SUM(purple_pink),0)
               + ISNULL(SUM(am_purple_pink),0)
               + ISNULL(SUM(mid_purple_pink),0)
               + ISNULL(SUM(pm_purple_pink),0) AS purple_pink_yr
             ,ISNULL(SUM(green),0)
               + ISNULL(SUM(am_green),0)
               + ISNULL(SUM(mid_green),0)
               + ISNULL(SUM(pm_green),0) AS green_yr
             ,ISNULL(SUM(yellow),0)
               + ISNULL(SUM(am_yellow),0)
               + ISNULL(SUM(mid_yellow),0)
               + ISNULL(SUM(pm_yellow),0) AS yellow_yr
             ,ISNULL(SUM(orange),0)
               + ISNULL(SUM(am_orange),0)
               + ISNULL(SUM(mid_orange),0)
               + ISNULL(SUM(pm_orange),0) AS orange_yr
             ,ISNULL(SUM(red),0)
               + ISNULL(SUM(am_red),0)
               + ISNULL(SUM(mid_red),0)
               + ISNULL(SUM(pm_red),0) AS red_yr        
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)
       JOIN valid_dates
         ON daily.schoolid = valid_dates.schoolid
        AND daily.att_date = valid_dates.att_date
       GROUP BY daily.schoolid
               ,daily.studentid                                    
      ) sub  
 )
 
SELECT w.schoolid
      ,w.studentid
      ,w.week_num
      ,w.month
      ,n_hw_wk
      ,hw_complete_wk
      ,hw_missing_wk
      ,hw_pct_wk
      --,n_color_wk
      --,purple_pink_wk
      --,green_wk
      --,yellow_wk
      --,orange_wk
      --,red_wk
      --,pct_ontrack_wk
      --,status_wk
      --,n_hw_mth
      --,hw_complete_mth
      --,hw_missing_mth
      --,hw_pct_mth
      --,n_color_mth
      ,purple_pink_mth
      ,green_mth
      ,yellow_mth
      ,orange_mth
      ,red_mth
      ,pct_ontrack_mth
      ,status_mth
      ,n_hw_yr
      ,hw_complete_yr
      ,hw_missing_yr
      ,hw_pct_yr
      ,n_color_yr
      ,purple_pink_yr
      ,green_yr
      ,yellow_yr
      ,orange_yr
      ,red_yr
      --,pct_ontrack_yr
      --,status_yr
FROM week_total w
JOIN month_total m
  ON w.studentid = m.studentid
 AND w.month = m.month
 AND w.schoolid = m.schoolid
JOIN year_total y
  ON w.studentid = y.studentid
 AND w.schoolid = y.schoolid