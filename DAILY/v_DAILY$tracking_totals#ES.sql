USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_totals#ES AS

WITH valid_dates AS (
  SELECT schoolid        
        ,academic_year
        ,term
        ,week_num        
        ,date_value
        ,is_curterm        
  FROM
      (
       SELECT daily.schoolid                          
             ,daily.academic_year
             ,daily.date_value
             ,dt.time_per_name AS week_num
             ,rt.time_per_name AS term
             ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN rt.start_date AND rt.end_date THEN 1 ELSE 0 END AS is_curterm
       FROM KIPP_NJ..PS$CALENDAR_DAY daily WITH(NOLOCK)            
       JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
         ON daily.schoolid = dt.schoolid
        AND daily.date_value BETWEEN dt.start_date AND dt.end_date
        AND dt.identifier = 'REP'
       JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
         ON daily.schoolid = rt.schoolid
        AND daily.date_value BETWEEN rt.start_date AND rt.end_date
        AND rt.identifier = 'RT'
       WHERE daily.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
 )

,tracking_long AS (
   SELECT valid_dates.academic_year
         ,valid_dates.term  
         ,valid_dates.date_value
         ,valid_dates.is_curterm         
         ,daily.schoolid
         ,daily.studentid      
         ,daily.week_num         
         ,hw
         ,has_hw         
         ,uniform
         ,has_uniform         
         ,color_day
         ,color_am
         ,color_mid
         ,color_pm
         ,purple_pink
         ,am_purple_pink
         ,mid_purple_pink
         ,pm_purple_pink
         ,green
         ,am_green
         ,mid_green
         ,pm_green
         ,yellow
         ,am_yellow
         ,mid_yellow
         ,pm_yellow
         ,orange
         ,am_orange
         ,mid_orange
         ,pm_orange
         ,red
         ,am_red
         ,mid_red
         ,pm_red
   FROM KIPP_NJ..DAILY$tracking_long#ES#static daily WITH(NOLOCK)
   JOIN valid_dates WITH(NOLOCK)
     ON daily.schoolid = valid_dates.schoolid
    AND daily.att_date = valid_dates.date_value   
 )

,long_totals AS (
  -- week totals
  SELECT 'wk' AS identifier 
        ,schoolid
        ,studentid
        ,academic_year
        ,week_num
        ,NULL AS month
        ,CONVERT(VARCHAR,n_hw) AS n_hw
        ,CONVERT(VARCHAR,hw_complete) AS hw_complete
        ,CONVERT(VARCHAR,hw_missing) AS hw_missing
        ,CONVERT(VARCHAR,hw_pct) AS hw_pct
        ,CONVERT(VARCHAR,n_uni) AS n_uni
        ,CONVERT(VARCHAR,uni_has) AS uni_has
        ,CONVERT(VARCHAR,uni_missing) AS uni_missing
        ,CONVERT(VARCHAR,uni_pct) AS uni_pct
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
             ,daily.academic_year
             ,daily.week_num
             --,DATENAME(MONTH,daily.att_date) AS month
             ,COUNT(hw) AS n_hw
             ,SUM(has_hw) AS hw_complete
             ,COUNT(hw) - SUM(has_hw) AS hw_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct
             ,COUNT(uniform) AS n_uni
             ,SUM(has_uniform) AS uni_has
             ,COUNT(uniform) - SUM(has_uniform) AS uni_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_uniform) / COUNT(uniform) * 100,0)) AS uni_pct
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
       FROM tracking_long daily
       GROUP BY daily.schoolid
               ,daily.studentid        
               ,daily.academic_year
               ,daily.week_num               
      ) sub  
 
  UNION ALL 
 
  -- month totals
  SELECT 'mth' AS identifier
        ,schoolid
        ,studentid        
        ,academic_year
        ,NULL AS week_num
        ,month
        ,CONVERT(VARCHAR,n_hw) AS n_hw
        ,CONVERT(VARCHAR,hw_complete) AS hw_complete
        ,CONVERT(VARCHAR,hw_missing) AS hw_missing
        ,CONVERT(VARCHAR,hw_pct) AS hw_pct
        ,CONVERT(VARCHAR,n_uni) AS n_uni
        ,CONVERT(VARCHAR,uni_has) AS uni_has
        ,CONVERT(VARCHAR,uni_missing) AS uni_missing
        ,CONVERT(VARCHAR,uni_pct) AS uni_pct
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
             ,daily.academic_year          
             ,DATENAME(MONTH,daily.date_value) AS month
             ,COUNT(hw) AS n_hw
             ,SUM(has_hw) AS hw_complete
             ,COUNT(hw) - SUM(has_hw) AS hw_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct
             ,COUNT(uniform) AS n_uni
             ,SUM(has_uniform) AS uni_has
             ,COUNT(uniform) - SUM(has_uniform) AS uni_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_uniform) / COUNT(uniform) * 100,0)) AS uni_pct
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
       FROM tracking_long daily
       GROUP BY daily.schoolid
               ,daily.studentid                       
               ,daily.academic_year
               ,DATENAME(MONTH,daily.date_value)
      ) sub  
 
  UNION ALL 
 
  -- year totals
  SELECT 'yr' AS identifier 
        ,schoolid
        ,studentid
        ,academic_year
        ,NULL AS week_num
        ,NULL AS month
        ,CONVERT(VARCHAR,n_hw) AS n_hw
        ,CONVERT(VARCHAR,hw_complete) AS hw_complete
        ,CONVERT(VARCHAR,hw_missing) AS hw_missing
        ,CONVERT(VARCHAR,hw_pct) AS hw_pct
        ,CONVERT(VARCHAR,n_uni) AS n_uni
        ,CONVERT(VARCHAR,uni_has) AS uni_has
        ,CONVERT(VARCHAR,uni_missing) AS uni_missing
        ,CONVERT(VARCHAR,uni_pct) AS uni_pct
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
             ,daily.academic_year
             ,COUNT(hw) AS n_hw
             ,SUM(has_hw) AS hw_complete
             ,COUNT(hw) - SUM(has_hw) AS hw_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct
             ,COUNT(uniform) AS n_uni
             ,SUM(has_uniform) AS uni_has
             ,COUNT(uniform) - SUM(has_uniform) AS uni_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_uniform) / COUNT(uniform) * 100,0)) AS uni_pct
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
       FROM tracking_long daily
       GROUP BY daily.schoolid
               ,daily.studentid                                    
               ,daily.academic_year
      ) sub  

  UNION ALL

  -- current trimester
  SELECT 'tri' AS identifier
        ,schoolid
        ,studentid       
        ,academic_year 
        ,NULL AS week_num
        ,NULL AS month
        ,CONVERT(VARCHAR,n_hw) AS n_hw
        ,CONVERT(VARCHAR,hw_complete) AS hw_complete
        ,CONVERT(VARCHAR,hw_missing) AS hw_missing
        ,CONVERT(VARCHAR,hw_pct) AS hw_pct
        ,CONVERT(VARCHAR,n_uni) AS n_uni
        ,CONVERT(VARCHAR,uni_has) AS uni_has
        ,CONVERT(VARCHAR,uni_missing) AS uni_missing
        ,CONVERT(VARCHAR,uni_pct) AS uni_pct
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
             ,daily.academic_year                              
             ,COUNT(hw) AS n_hw
             ,SUM(has_hw) AS hw_complete
             ,COUNT(hw) - SUM(has_hw) AS hw_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_hw) / COUNT(hw) * 100,0)) AS hw_pct
             ,COUNT(uniform) AS n_uni
             ,SUM(has_uniform) AS uni_has
             ,COUNT(uniform) - SUM(has_uniform) AS uni_missing
             ,CONVERT(FLOAT,ROUND(SUM(has_uniform) / COUNT(uniform) * 100,0)) AS uni_pct
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
       FROM tracking_long daily
       WHERE is_curterm = 1
       GROUP BY daily.schoolid
               ,daily.studentid        
               ,daily.academic_year                              
      ) sub  
 )

SELECT schoolid
      ,studentid      
      ,academic_year
      ,month
      ,week_num      
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
      ,[n_uni_mth]
      ,[uni_has_mth]
      ,[uni_missing_mth]
      ,[uni_pct_mth]
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
      ,[n_uni_yr]
      ,[uni_has_yr]
      ,[uni_missing_yr]
      ,[uni_pct_yr]
      ,[n_color_yr]
      ,[purple_pink_yr]
      ,[green_yr]
      ,[yellow_yr]
      ,[orange_yr]
      ,[red_yr]
      ,[pct_ontrack_yr]
      ,[status_yr]
      ,[n_hw_tri]
      ,[hw_complete_tri]
      ,[hw_missing_tri]
      ,[hw_pct_tri]
      ,[n_color_tri]
      ,[purple_pink_tri]
      ,[green_tri]
      ,[yellow_tri]
      ,[orange_tri]
      ,[red_tri]
      ,[pct_ontrack_tri]
      ,[status_tri]
FROM
    (
     SELECT schoolid
           ,studentid
           ,academic_year
           ,month
           ,week_num
           ,field + '_' + identifier AS field
           ,value
     FROM 
         (
          SELECT schoolid
                ,studentid
                ,academic_year
                ,month
                ,week_num
                ,identifier           
                ,n_hw
                ,hw_complete
                ,hw_missing
                ,hw_pct
                ,n_uni
                ,uni_has
                ,uni_missing
                ,uni_pct
                ,n_color
                ,purple_pink
                ,green
                ,yellow
                ,orange
                ,red
                ,CONVERT(VARCHAR,pct_ontrack) AS pct_ontrack
                ,CONVERT(VARCHAR,status) AS status
          FROM long_totals WITH(NOLOCK)
         ) sub      
     UNPIVOT (
       value
       FOR field IN (n_hw
                    ,hw_complete
                    ,hw_missing
                    ,hw_pct
                    ,n_uni
                    ,uni_has
                    ,uni_missing
                    ,uni_pct
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
               ,[n_uni_wk]
               ,[uni_has_wk]
               ,[uni_missing_wk]
               ,[uni_pct_wk]
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
               ,[n_uni_mth]
               ,[uni_has_mth]
               ,[uni_missing_mth]
               ,[uni_pct_mth]
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
               ,[n_uni_yr]
               ,[uni_has_yr]
               ,[uni_missing_yr]
               ,[uni_pct_yr]
               ,[n_color_yr]
               ,[purple_pink_yr]
               ,[green_yr]
               ,[yellow_yr]
               ,[orange_yr]
               ,[red_yr]
               ,[pct_ontrack_yr]
               ,[status_yr]
               ,[n_hw_tri]
               ,[hw_complete_tri]
               ,[hw_missing_tri]
               ,[hw_pct_tri]
               ,[n_uni_tri]
               ,[uni_has_tri]
               ,[uni_missing_tri]
               ,[uni_pct_tri]
               ,[n_color_tri]
               ,[purple_pink_tri]
               ,[green_tri]
               ,[yellow_tri]
               ,[orange_tri]
               ,[red_tri]
               ,[pct_ontrack_tri]
               ,[status_tri])
 ) p