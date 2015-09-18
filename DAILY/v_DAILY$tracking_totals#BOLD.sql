USE KIPP_NJ
GO

ALTER VIEW DAILY$tracking_totals#BOLD AS

WITH tracking_long AS (
  SELECT dt.studentid            
        ,ROUND(AVG(CONVERT(FLOAT,dt.field1)) * 100,0) AS uniform_pct
        ,ROUND(AVG(CONVERT(FLOAT,CASE WHEN dt.field2 IS NULL THEN NULL WHEN dt.field2 = 0 THEN 1 ELSE 0 END)) * 100,0) AS hw_missing_pct
        ,ROUND(AVG(CONVERT(FLOAT,CASE WHEN dt.field2 IS NULL THEN NULL WHEN dt.field2 = 1 THEN 1 ELSE 0 END)) * 100,0) AS hw_half_pct
        ,ROUND(AVG(CONVERT(FLOAT,CASE WHEN dt.field2 IS NULL THEN NULL WHEN dt.field2 = 2 THEN 1 ELSE 0 END)) * 100,0) AS hw_full_pct
        ,SUM(CONVERT(FLOAT,dt.field3)) AS BOLD_points
        ,'Y1' AS term      
  FROM KIPP_NJ..DAILY$tracking_long#STAGING dt WITH(NOLOCK)    
  WHERE dt.schoolid = 73258
  GROUP BY dt.studentid

  UNION ALL

  SELECT dt.studentid            
        ,ROUND(AVG(CONVERT(FLOAT,dt.field1)) * 100,0) AS uniform_pct
        ,ROUND(AVG(CONVERT(FLOAT,CASE WHEN dt.field2 IS NULL THEN NULL WHEN dt.field2 = 0 THEN 1 ELSE 0 END)) * 100,0) AS hw_missing_pct
        ,ROUND(AVG(CONVERT(FLOAT,CASE WHEN dt.field2 IS NULL THEN NULL WHEN dt.field2 = 1 THEN 1 ELSE 0 END)) * 100,0) AS hw_half_pct
        ,ROUND(AVG(CONVERT(FLOAT,CASE WHEN dt.field2 IS NULL THEN NULL WHEN dt.field2 = 2 THEN 1 ELSE 0 END)) * 100,0) AS hw_full_pct
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
      ,[CUR_BOLD_points]
      ,[CUR_hw_full_pct]
      ,[CUR_hw_half_pct]
      ,[CUR_hw_missing_pct]
      ,[CUR_uniform_pct]
      ,[Y1_BOLD_points]
      ,[Y1_hw_full_pct]
      ,[Y1_hw_half_pct]
      ,[Y1_hw_missing_pct]
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
                    ,hw_missing_pct
                    ,hw_half_pct
                    ,hw_full_pct
                    ,BOLD_points)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([CUR_BOLD_points]
                     ,[CUR_hw_full_pct]
                     ,[CUR_hw_half_pct]
                     ,[CUR_hw_missing_pct]
                     ,[CUR_uniform_pct]
                     ,[Y1_BOLD_points]
                     ,[Y1_hw_full_pct]
                     ,[Y1_hw_half_pct]
                     ,[Y1_hw_missing_pct]
                     ,[Y1_uniform_pct])
 ) p