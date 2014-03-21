/*
PURPOSE:
  Calculates merits bASed ON weeks without demerits (NCA Discipline)
  
MAINTENANCE:
  Maintenance Yearly: change RT weeks use 
                      SELECT TO_CHAR(to_date('04-SEP-12'), 'WW')
                      AS week_number FROM dual to determine exact weeks
                      
  Dependent ON DISC$DEMERITS#NCA
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  9/18
  created YYYYWW hash AND removed 'test if YYYY' logic
  
CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
*/

USE KIPP_NJ
GO

ALTER VIEW DISC$perfect_weeks#NCA AS
SELECT TOP (100) PERCENT *
FROM
    (
     SELECT perfect_student_number
           ,perfect_studentid
           ,lastfirst
           ,SUM(perfect_week_indicator) AS perfect_weeks 
           ,SUM(perfect_week_indicator_rt1) AS perfect_weeks_rt1
           ,SUM(perfect_week_indicator_rt2) AS perfect_weeks_rt2 
           ,SUM(perfect_week_indicator_rt3) AS perfect_weeks_rt3
           ,SUM(perfect_week_indicator_rt4) AS perfect_weeks_rt4
     FROM     
          (
           SELECT perfect_student_number
                 ,perfect_studentid
                 ,lastfirst
                 ,wk
                 ,wk_count
                 ,CASE 
                   WHEN future_test = 'past' AND wk_count = 0 THEN 1 
                   ELSE 0 
                  END AS perfect_week_indicator
                 ,CASE
                   WHEN future_test = 'past' AND perfect_rt = 'RT1' AND wk_count = 0 THEN 1 
                   ELSE 0
                  END AS perfect_week_indicator_rt1
                 ,CASE
                   WHEN future_test = 'past' AND perfect_rt = 'RT2' AND wk_count = 0 THEN 1 
                   ELSE 0
                  END AS perfect_week_indicator_rt2
                 ,CASE
                   WHEN future_test = 'past' AND perfect_rt = 'RT3' AND wk_count = 0 THEN 1 
                   ELSE 0
                  END AS perfect_week_indicator_rt3
                 ,CASE
                   WHEN future_test = 'past' AND perfect_rt = 'RT4' AND wk_count = 0 THEN 1 
                   ELSE 0
                  END AS perfect_week_indicator_rt4
           FROM     
                 (
                  SELECT perfect_student_number
                        ,perfect_studentid
                        ,lastfirst
                        ,wk
                        ,perfect_rt
                        ,entrydate
                        ,CASE
                          WHEN CONVERT(VARCHAR,YEAR(GETDATE())) + RIGHT('00' + CAST(DATEPART(iso_week, GETDATE()) AS VARCHAR(2)), 2) < wk THEN 'future'
                          WHEN CONVERT(VARCHAR,YEAR(GETDATE())) + RIGHT('00' + CAST(DATEPART(iso_week, GETDATE()) AS VARCHAR(2)), 2) >= wk THEN 'past'
                          ELSE NULL
                         END AS future_test                    
                        ,COUNT(demerits.rn) AS wk_count
                  FROM
                        (
                         SELECT perfect_student_number
                               ,perfect_studentid
                               ,lastfirst
                               ,entrydate
                               ,wk.reporting_hash AS wk
                               ,dates.time_per_name AS perfect_RT
                         FROM
                               (
                                SELECT s.student_number AS perfect_student_number
                                      ,s.id AS perfect_studentid
                                      ,s.lastfirst
                                      ,s.entrydate --student entry date so that kids dont get perfect weeks before they enrolled!
                                FROM STUDENTS s WITH(NOLOCK)
                                WHERE s.enroll_status = 0
                                  AND s.schoolid = 73253                                  
                               ) sub1                     
                         JOIN UTIL$reporting_weeks_days wk WITH(NOLOCK)
                           ON 1=1
                          AND wk.weekday_start >= '2013-08-01'
                          AND wk.weekday_end < '2014-07-01'
                          AND wk.reporting_hash NOT IN (201352, 201408, 201415) --exclude any weeks that are school breaks here
                         JOIN REPORTING$dates dates WITH(NOLOCK)
                           ON dates.identifier = 'RT'
                          AND dates.schoolid = 73253
                          AND wk.weekday_start >= dates.start_date
                          AND wk.weekday_end <= dates.end_date
                         ) sub2
                   LEFT OUTER JOIN DISC$log#static demerits WITH(NOLOCK)
                     ON perfect_studentid = demerits.studentid
                    AND wk = CONVERT(VARCHAR,YEAR(demerits.entry_date)) + RIGHT('00' + CONVERT(VARCHAR,DATEPART(iso_week, demerits.entry_date)), 2)
                    AND demerits.logtypeid = 3223
                    AND demerits.schoolid = 73253                
                   GROUP BY perfect_student_number, perfect_studentid, lastfirst, wk, perfect_rt, entrydate
                 ) sub3
    ) sub4
     GROUP BY perfect_student_number, perfect_studentid, lastfirst
) query
ORDER BY lastfirst