USE KIPP_NJ
GO

ALTER VIEW DISC$log_counts_wide AS 

WITH disc_counts_long AS (
  SELECT student_number
        ,academic_year
        ,time_per_name        
        ,logtype
        ,logtypeid
        ,n_logs_term        
  FROM KIPP_NJ..DISC$log_counts_long#static WITH(NOLOCK)

  UNION ALL

  SELECT student_number
        ,academic_year
        ,rt AS time_per_name        
        ,'Perfect Weeks' AS logtype
        ,NULL AS logtypeid
        ,perfect_week_merits_term AS n_logs_term        
  FROM DISC$perfect_weeks_long#static WITH(NOLOCK)
 )

,counts_rollup AS (
  SELECT student_number
        ,academic_year        
        ,logtype
        ,logtypeid
        ,CONCAT('n_logs_', time_per_name) AS pivot_field
        ,n_logs_term AS value
  FROM disc_counts_long
       
  UNION ALL
       
  SELECT student_number
        ,academic_year        
        ,logtype
        ,logtypeid
        ,'n_logs_Y1' AS pivot_field
        ,SUM(n_logs_term) AS value
  FROM disc_counts_long
  GROUP BY student_number
          ,academic_year             
          ,logtype
          ,logtypeid
 )

SELECT *
FROM counts_rollup
PIVOT(
  MAX(value)
  FOR pivot_field IN ([n_logs_RT1]
                     ,[n_logs_RT2]
                     ,[n_logs_RT3]
                     ,[n_logs_RT4]
                     ,[n_logs_RT5]
                     ,[n_logs_Y1])
 ) u