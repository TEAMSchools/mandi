USE KIPP_NJ
GO
ALTER VIEW UTIL$reporting_weeks_days AS
SELECT reporting_hash
      ,year
      ,week
       --weeks can cross years; need to disambiguate
      ,MAX(weekday_start) AS weekday_start
      ,MAX(weekday_end) AS weekday_end
      ,max(weekday_sun) AS weekday_sun
FROM
    (SELECT w.reporting_hash
           ,w.year
           ,w.week
           ,d_start.date AS weekday_start
           ,d_end.date AS weekday_end
           ,d_sun.date AS weekday_sun
     FROM UTIL$reporting_weeks w
     --last day of week
     JOIN UTIL$reporting_days d_start
       ON w.reporting_hash = d_start.reporting_hash
      AND d_start.day_of_week = 'Monday'
     JOIN UTIL$reporting_days d_end
       ON w.reporting_hash = d_end.reporting_hash
      AND d_end.day_of_week = 'Friday'
     JOIN UTIL$reporting_days d_sun
       ON w.reporting_hash = d_sun.reporting_hash
      AND d_sun.day_of_week = 'Sunday'
     ) sub
GROUP BY reporting_hash
        ,year
        ,week
