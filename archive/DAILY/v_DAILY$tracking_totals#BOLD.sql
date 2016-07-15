USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_totals#BOLD AS

WITH rc_term AS (
  SELECT time_per_name
        ,ROW_NUMBER() OVER(
          ORDER BY end_date DESC) AS rn
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND schoolid = 73258
    AND end_date <= CONVERT(DATE,GETDATE())
 )

,tracking_long AS (
  SELECT dt.studentid            
        ,ROUND(AVG(CONVERT(FLOAT,dt.field1)) * 100,0) AS uniform_pct
        ,ROUND((SUM(CONVERT(FLOAT,dt.field2)) / SUM(CONVERT(FLOAT,CASE WHEN dt.field2 IS NOT NULL THEN 2 ELSE NULL END))) * 100,0) AS hw_pct
        ,SUM(CONVERT(FLOAT,dt.field3)) AS BOLD_points
        ,'RC' AS term      
  FROM KIPP_NJ..DAILY$tracking_long#STAGING dt WITH(NOLOCK)  
  JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON dt.schoolid = d.schoolid
   AND CONVERT(DATE,dt.att_date) BETWEEN d.start_date AND d.end_date      
   AND d.identifier = 'RT'
   AND d.time_per_name = (SELECT time_per_name FROM rc_term WHERE rn = 1)
  WHERE dt.schoolid = 73258
  GROUP BY dt.studentid, d.time_per_name
  
  UNION ALL

  SELECT dt.studentid            
        ,ROUND(AVG(CONVERT(FLOAT,dt.field1)) * 100,0) AS uniform_pct
        ,ROUND((SUM(CONVERT(FLOAT,dt.field2)) / SUM(CONVERT(FLOAT,CASE WHEN dt.field2 IS NOT NULL THEN 2 ELSE 0 END))) * 100,0) AS hw_pct
        ,SUM(CONVERT(FLOAT,dt.field3)) AS BOLD_points
        ,'Y1' AS term      
  FROM KIPP_NJ..DAILY$tracking_long#STAGING dt WITH(NOLOCK)    
  WHERE dt.schoolid = 73258
  GROUP BY dt.studentid

  UNION ALL

  SELECT dt.studentid            
        ,ROUND(AVG(CONVERT(FLOAT,dt.field1)) * 100,0) AS uniform_pct
        ,ROUND((SUM(CONVERT(FLOAT,dt.field2)) / SUM(CONVERT(FLOAT,CASE WHEN dt.field2 IS NOT NULL THEN 2 ELSE NULL END))) * 100,0) AS hw_pct
        ,SUM(CONVERT(FLOAT,dt.field3)) AS BOLD_points
        ,'CUR' AS term      
  FROM KIPP_NJ..DAILY$tracking_long#STAGING dt WITH(NOLOCK)  
  JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON dt.schoolid = d.schoolid
   AND CONVERT(DATE,dt.att_date) BETWEEN d.start_date AND d.end_date
   AND CONVERT(DATE,GETDATE())  BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'RT'
  WHERE dt.schoolid = 73258
  GROUP BY dt.studentid                          
 )

SELECT STUDENTID
      ,[RC_BOLD_points]
      ,[RC_hw_pct] AS RC_hw_comp_pct
      ,100 - [RC_hw_pct] AS RC_hw_inc_pct
      ,[RC_uniform_pct]
      ,[CUR_BOLD_points]
      ,[CUR_hw_pct] AS CUR_hw_comp_pct
      ,100 - [CUR_hw_pct] AS CUR_hw_inc_pct
      ,[CUR_uniform_pct]
      ,[Y1_BOLD_points]
      ,[Y1_hw_pct] AS Y1_hw_comp_pct
      ,100 - [Y1_hw_pct] AS Y1_hw_inc_pct
      ,[Y1_uniform_pct]
FROM
    (
     SELECT studentid
           ,CONCAT(term, '_', field) AS pivot_field
           ,value
     FROM tracking_long
     UNPIVOT(
       value
       FOR field IN (uniform_pct
                    ,hw_pct
                    ,BOLD_points)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([RC_BOLD_points]
                     ,[RC_hw_pct]                     
                     ,[RC_uniform_pct]
                     ,[CUR_BOLD_points]
                     ,[CUR_hw_pct]                     
                     ,[CUR_uniform_pct]
                     ,[Y1_BOLD_points]
                     ,[Y1_hw_pct]                     
                     ,[Y1_uniform_pct])
 ) p