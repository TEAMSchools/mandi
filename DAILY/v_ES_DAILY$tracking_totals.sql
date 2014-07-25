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
                      ,daily.week_num
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)       
       ) sub
 )

,longs_totals AS (
  SELECT 'wk' AS identifier 
        ,schoolid
        ,studentid
        ,week_num
        ,month
        ,CONVERT(VARCHAR,n_hw) AS n_hw
        ,CONVERT(VARCHAR,hw_complete) AS hw_complete
        ,CONVERT(VARCHAR,hw_missing) AS hw_missing
        ,CONVERT(VARCHAR,hw_pct) AS hw_pct
        ,CONVERT(VARCHAR,n_color) AS n_color
        ,CONVERT(VARCHAR,purple_pink) AS purple_pink
        ,CONVERT(VARCHAR,green) AS green
        ,CONVERT(VARCHAR,yellow) AS yellow
        ,CONVERT(VARCHAR,orange) AS orange
        ,CONVERT(VARCHAR,red) AS red
        ,CONVERT(FLOAT,ROUND((purple_pink + green) / CASE WHEN n_color = 0 THEN NULL ELSE n_color END * 100,0)) AS pct_ontrack
        ,CASE
          WHEN CONVERT(FLOAT,ROUND((purple_pink + green) / CASE WHEN n_color = 0 THEN NULL ELSE n_color END * 100,0)) >= 80 THEN 'On Track' 
          ELSE 'Off Track'
         END AS status
  FROM
      (
       SELECT daily.schoolid
             ,daily.studentid      
             ,daily.week_num
             ,DATENAME(MONTH,daily.att_date) AS month
             ,COUNT(hw) AS n_hw
             ,SUM(has_hw) AS hw_complete
             ,COUNT(hw) - SUM(has_hw) AS hw_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct
             ,ISNULL(COUNT(color_day),0)
               + ISNULL(COUNT(color_am),0)
               + ISNULL(COUNT(color_mid),0)
               + ISNULL(COUNT(color_pm),0)
               AS n_color
             ,ISNULL(SUM(purple_pink),0)
               + ISNULL(SUM(am_purple_pink),0)
               + ISNULL(SUM(mid_purple_pink),0)
               + ISNULL(SUM(pm_purple_pink),0) AS purple_pink
             ,ISNULL(SUM(green),0)
               + ISNULL(SUM(am_green),0)
               + ISNULL(SUM(mid_green),0)
               + ISNULL(SUM(pm_green),0) AS green
             ,ISNULL(SUM(yellow),0)
               + ISNULL(SUM(am_yellow),0)
               + ISNULL(SUM(mid_yellow),0)
               + ISNULL(SUM(pm_yellow),0) AS yellow
             ,ISNULL(SUM(orange),0)
               + ISNULL(SUM(am_orange),0)
               + ISNULL(SUM(mid_orange),0)
               + ISNULL(SUM(pm_orange),0) AS orange
             ,ISNULL(SUM(red),0)
               + ISNULL(SUM(am_red),0)
               + ISNULL(SUM(mid_red),0)
               + ISNULL(SUM(pm_red),0) AS red        
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)
       JOIN valid_dates
         ON daily.schoolid = valid_dates.schoolid
        AND daily.att_date = valid_dates.att_date
       GROUP BY daily.schoolid
               ,daily.studentid        
               ,daily.week_num
               ,DATENAME(MONTH,daily.att_date)
      ) sub  
 
UNION ALL 
 
  SELECT 'mth' AS identifier
        ,schoolid
        ,studentid        
        ,NULL AS week_num
        ,month
        ,CONVERT(VARCHAR,n_hw) AS n_hw
        ,CONVERT(VARCHAR,hw_complete) AS hw_complete
        ,CONVERT(VARCHAR,hw_missing) AS hw_missing
        ,CONVERT(VARCHAR,hw_pct) AS hw_pct
        ,CONVERT(VARCHAR,n_color) AS n_color
        ,CONVERT(VARCHAR,purple_pink) AS purple_pink
        ,CONVERT(VARCHAR,green) AS green
        ,CONVERT(VARCHAR,yellow) AS yellow
        ,CONVERT(VARCHAR,orange) AS orange
        ,CONVERT(VARCHAR,red) AS red
        ,CONVERT(FLOAT,ROUND((purple_pink + green) / CASE WHEN n_color = 0 THEN NULL ELSE n_color END * 100,0)) AS pct_ontrack
        ,CASE
          WHEN CONVERT(FLOAT,ROUND((purple_pink + green) / CASE WHEN n_color = 0 THEN NULL ELSE n_color END * 100,0)) >= 80 THEN 'On Track' 
          ELSE 'Off Track'
         END AS status
  FROM
      (
       SELECT daily.schoolid
             ,daily.studentid                   
             ,DATENAME(MONTH,daily.att_date) AS month
             ,COUNT(hw) AS n_hw
             ,SUM(has_hw) AS hw_complete
             ,COUNT(hw) - SUM(has_hw) AS hw_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct
             ,ISNULL(COUNT(color_day),0)
               + ISNULL(COUNT(color_am),0)
               + ISNULL(COUNT(color_mid),0)
               + ISNULL(COUNT(color_pm),0)
               AS n_color
             ,ISNULL(SUM(purple_pink),0)
               + ISNULL(SUM(am_purple_pink),0)
               + ISNULL(SUM(mid_purple_pink),0)
               + ISNULL(SUM(pm_purple_pink),0) AS purple_pink
             ,ISNULL(SUM(green),0)
               + ISNULL(SUM(am_green),0)
               + ISNULL(SUM(mid_green),0)
               + ISNULL(SUM(pm_green),0) AS green
             ,ISNULL(SUM(yellow),0)
               + ISNULL(SUM(am_yellow),0)
               + ISNULL(SUM(mid_yellow),0)
               + ISNULL(SUM(pm_yellow),0) AS yellow
             ,ISNULL(SUM(orange),0)
               + ISNULL(SUM(am_orange),0)
               + ISNULL(SUM(mid_orange),0)
               + ISNULL(SUM(pm_orange),0) AS orange
             ,ISNULL(SUM(red),0)
               + ISNULL(SUM(am_red),0)
               + ISNULL(SUM(mid_red),0)
               + ISNULL(SUM(pm_red),0) AS red        
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)
       JOIN valid_dates
         ON daily.schoolid = valid_dates.schoolid
        AND daily.att_date = valid_dates.att_date
       GROUP BY daily.schoolid
               ,daily.studentid                       
               ,DATENAME(MONTH,daily.att_date)
      ) sub  
 
UNION ALL 
 
  SELECT 'yr' AS identifier 
        ,schoolid
        ,studentid
        ,NULL AS week_num
        ,NULL AS month
        ,CONVERT(VARCHAR,n_hw) AS n_hw
        ,CONVERT(VARCHAR,hw_complete) AS hw_complete
        ,CONVERT(VARCHAR,hw_missing) AS hw_missing
        ,CONVERT(VARCHAR,hw_pct) AS hw_pct
        ,CONVERT(VARCHAR,n_color) AS n_color
        ,CONVERT(VARCHAR,purple_pink) AS purple_pink
        ,CONVERT(VARCHAR,green) AS green
        ,CONVERT(VARCHAR,yellow) AS yellow
        ,CONVERT(VARCHAR,orange) AS orange
        ,CONVERT(VARCHAR,red) AS red
        ,CONVERT(FLOAT,ROUND((purple_pink + green) / CASE WHEN n_color = 0 THEN NULL ELSE n_color END * 100,0)) AS pct_ontrack
        ,CASE
          WHEN CONVERT(FLOAT,ROUND((purple_pink + green) / CASE WHEN n_color = 0 THEN NULL ELSE n_color END * 100,0)) >= 80 THEN 'On Track' 
          ELSE 'Off Track'
         END AS status
  FROM
      (
       SELECT daily.schoolid
             ,daily.studentid                                
             ,COUNT(hw) AS n_hw
             ,SUM(has_hw) AS hw_complete
             ,COUNT(hw) - SUM(has_hw) AS hw_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct
             ,ISNULL(COUNT(color_day),0)
               + ISNULL(COUNT(color_am),0)
               + ISNULL(COUNT(color_mid),0)
               + ISNULL(COUNT(color_pm),0)
               AS n_color
             ,ISNULL(SUM(purple_pink),0)
               + ISNULL(SUM(am_purple_pink),0)
               + ISNULL(SUM(mid_purple_pink),0)
               + ISNULL(SUM(pm_purple_pink),0) AS purple_pink
             ,ISNULL(SUM(green),0)
               + ISNULL(SUM(am_green),0)
               + ISNULL(SUM(mid_green),0)
               + ISNULL(SUM(pm_green),0) AS green
             ,ISNULL(SUM(yellow),0)
               + ISNULL(SUM(am_yellow),0)
               + ISNULL(SUM(mid_yellow),0)
               + ISNULL(SUM(pm_yellow),0) AS yellow
             ,ISNULL(SUM(orange),0)
               + ISNULL(SUM(am_orange),0)
               + ISNULL(SUM(mid_orange),0)
               + ISNULL(SUM(pm_orange),0) AS orange
             ,ISNULL(SUM(red),0)
               + ISNULL(SUM(am_red),0)
               + ISNULL(SUM(mid_red),0)
               + ISNULL(SUM(pm_red),0) AS red        
       FROM ES_DAILY$tracking_long#static daily WITH(NOLOCK)
       JOIN valid_dates
         ON daily.schoolid = valid_dates.schoolid
        AND daily.att_date = valid_dates.att_date
       GROUP BY daily.schoolid
               ,daily.studentid                                    
      ) sub  
 )

SELECT schoolid
      ,studentid      
      ,week_num
      ,month
      ,[n_hw_wk]
      ,[hw_complete_wk]
      ,[hw_missing_wk]
      ,[hw_pct_wk]
      ,[n_color_wk]
      ,[purple_pink_wk]
      ,[green_wk]
      ,[yellow_wk]
      ,[orange_wk]
      ,[red_wk]
      ,[pct_ontrack_wk]
      ,[status_wk]
      ,[n_hw_mth]
      ,[hw_complete_mth]
      ,[hw_missing_mth]
      ,[hw_pct_mth]
      ,[n_color_mth]
      ,[purple_pink_mth]
      ,[green_mth]
      ,[yellow_mth]
      ,[orange_mth]
      ,[red_mth]
      ,[pct_ontrack_mth]
      ,[status_mth]
      ,[n_hw_yr]
      ,[hw_complete_yr]
      ,[hw_missing_yr]
      ,[hw_pct_yr]
      ,[n_color_yr]
      ,[purple_pink_yr]
      ,[green_yr]
      ,[yellow_yr]
      ,[orange_yr]
      ,[red_yr]
      ,[pct_ontrack_yr]
      ,[status_yr]
FROM
    (
     SELECT schoolid
           ,studentid
           ,month
           ,week_num
           ,field + '_' + identifier AS field
           ,value
     FROM 
         (
          SELECT schoolid
                ,studentid
                ,month
                ,week_num
                ,identifier           
                ,n_hw
                ,hw_complete
                ,hw_missing
                ,hw_pct
                ,n_color
                ,purple_pink
                ,green
                ,yellow
                ,orange
                ,red
                ,CONVERT(VARCHAR,pct_ontrack) AS pct_ontrack
                ,CONVERT(VARCHAR,status) AS status
          FROM longs_totals
         ) sub 

     
     UNPIVOT (
       value
       FOR field IN (n_hw
                    ,hw_complete
                    ,hw_missing
                    ,hw_pct
                    ,n_color
                    ,purple_pink
                    ,green
                    ,yellow
                    ,orange
                    ,red
                    ,pct_ontrack
                    ,status)
      ) unpiv 
    ) sub2

PIVOT (
  MAX(value)
  FOR field IN ([n_hw_wk]
               ,[hw_complete_wk]
               ,[hw_missing_wk]
               ,[hw_pct_wk]
               ,[n_color_wk]
               ,[purple_pink_wk]
               ,[green_wk]
               ,[yellow_wk]
               ,[orange_wk]
               ,[red_wk]
               ,[pct_ontrack_wk]
               ,[status_wk]
               ,[n_hw_mth]
               ,[hw_complete_mth]
               ,[hw_missing_mth]
               ,[hw_pct_mth]
               ,[n_color_mth]
               ,[purple_pink_mth]
               ,[green_mth]
               ,[yellow_mth]
               ,[orange_mth]
               ,[red_mth]
               ,[pct_ontrack_mth]
               ,[status_mth]
               ,[n_hw_yr]
               ,[hw_complete_yr]
               ,[hw_missing_yr]
               ,[hw_pct_yr]
               ,[n_color_yr]
               ,[purple_pink_yr]
               ,[green_yr]
               ,[yellow_yr]
               ,[orange_yr]
               ,[red_yr]
               ,[pct_ontrack_yr]
               ,[status_yr])
 ) piv               
