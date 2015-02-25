USE KIPP_NJ
GO

ALTER VIEW UTIL$reporting_weeks_days AS

SELECT reporting_hash
      ,year
      ,academic_year
      ,week
       --weeks can cross years; need to disambiguate
      ,MAX(weekday_sun) AS weekday_sun
      ,MAX(weekday_start) AS weekday_start
      ,MAX(weekday_end) AS weekday_end      
      ,MAX(weekday_sat) AS weekday_sat
FROM
    (
     SELECT w.reporting_hash
           ,w.year
           ,CASE
              WHEN w.week <= 29 THEN w.year - 1
              ELSE w.year
            END AS academic_year
           ,w.week
           ,d_start.date AS weekday_start
           ,d_end.date AS weekday_end
           ,d_sun.date AS weekday_sun
           ,d_sat.date AS weekday_sat
     FROM KIPP_NJ..UTIL$reporting_weeks w WITH(NOLOCK)
     --last day of week
     JOIN KIPP_NJ..UTIL$reporting_days#static d_start WITH(NOLOCK)
       ON w.reporting_hash = d_start.reporting_hash
      AND d_start.day_of_week = 'Monday'
     JOIN KIPP_NJ..UTIL$reporting_days#static d_end WITH(NOLOCK)
       ON w.reporting_hash = d_end.reporting_hash
      AND d_end.day_of_week = 'Friday'
     JOIN KIPP_NJ..UTIL$reporting_days#static d_sun WITH(NOLOCK)
       ON w.reporting_hash = d_sun.reporting_hash
      AND d_sun.day_of_week = 'Sunday'
     JOIN KIPP_NJ..UTIL$reporting_days#static d_sat WITH(NOLOCK)
       ON w.reporting_hash = d_sat.reporting_hash
      AND d_sat.day_of_week = 'Saturday'
     ) sub
GROUP BY reporting_hash
        ,year
        ,academic_year
        ,week