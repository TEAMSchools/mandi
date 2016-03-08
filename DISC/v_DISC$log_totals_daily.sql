USE KIPP_NJ
GO

ALTER VIEW DISC$log_totals_daily AS

WITH logtypes AS (
  SELECT studentid
        ,entry_date
        ,logtype
        ,COUNT(entry_date) AS n_logs
  FROM
      (
       SELECT studentid
             ,rt
             ,entry_date             
             ,LOWER(CASE WHEN logtypeid = -100000 THEN subtype ELSE logtype END) AS logtype
       FROM KIPP_NJ..DISC$log#static disc WITH(NOLOCK)       
       WHERE ((disc.logtypeid IN (3023, 3223) OR (disc.logtypeid = -100000 AND subtype IN ('ISS','OSS','Detention'))))
         AND disc.schoolid = 73253
         AND disc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  GROUP BY studentid
          ,entry_date
          ,logtype
 )

,perfect_weeks AS (
  SELECT pw.studentid
        ,pw.perfect_week_merits_term AS n_logs      
        ,dt.alt_name AS term      
        ,CASE WHEN dt.end_date <= CONVERT(DATE,GETDATE()) THEN MAX(CONVERT(DATE,cd.date_value)) ELSE CONVERT(DATE,GETDATE()) END AS entry_date            
        ,'merits' AS logtype
  FROM KIPP_NJ..PS$CALENDAR_DAY cd WITH(NOLOCK) 
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON cd.schoolid = dt.schoolid
   AND cd.academic_year = dt.academic_year
   AND cd.date_value BETWEEN dt.start_date AND dt.end_date
   AND dt.identifier = 'RT'
  JOIN KIPP_NJ..DISC$perfect_weeks_long#static pw WITH(NOLOCK)
    ON cd.academic_year = pw.academic_year
   AND dt.alt_name = pw.term
  WHERE cd.schoolid = 73253 
    AND cd.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()   
    AND cd.insession = 1
  GROUP BY pw.studentid, pw.perfect_week_merits_term, dt.alt_name, dt.end_date
 )

,log_totals AS (
  SELECT studentid
        ,entry_date
        ,logtype
        ,SUM(n_logs) AS n_logs
  FROM
      (
       SELECT studentid
             ,entry_date
             ,logtype
             ,n_logs
       FROM logtypes WITH(NOLOCK)
       UNION ALL 
       SELECT studentid
             ,entry_date
             ,logtype
             ,n_logs
       FROM perfect_weeks WITH(NOLOCK)
      ) sub
  GROUP BY studentid
          ,entry_date
          ,logtype
 )

,log_scaffold AS (
  SELECT academic_year
        ,term
        ,studentid
        ,student_number
        ,lastfirst
        ,date              
        ,SUM(ISNULL(merits,0)) OVER(PARTITION BY studentid, academic_year, term ORDER BY date ASC) AS merits
        ,SUM(ISNULL(demerits,0)) OVER(PARTITION BY studentid, academic_year, term ORDER BY date ASC) AS demerits
        ,SUM(ISNULL(detention,0)) OVER(PARTITION BY studentid, academic_year, term ORDER BY date ASC) AS detention
        ,SUM(ISNULL(ISS,0)) OVER(PARTITION BY studentid, academic_year, term ORDER BY date ASC) AS ISS
        ,SUM(ISNULL(OSS,0)) OVER(PARTITION BY studentid, academic_year, term ORDER BY date ASC) AS OSS
        ,ROW_NUMBER() OVER(
          PARTITION BY studentid, academic_year
            ORDER BY date ASC) AS day_order
  FROM
      (
       SELECT co.year AS academic_year
             ,co.term
             ,co.studentid
             ,co.student_number
             ,co.lastfirst
             ,co.date      
             ,disc.logtype
             ,disc.n_logs             
       FROM COHORT$identifiers_scaffold#static co WITH(NOLOCK)
       LEFT OUTER JOIN log_totals disc WITH(NOLOCK)
         ON co.studentid = disc.studentid
        AND co.date = disc.entry_date
       WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND co.schoolid = 73253
         AND co.term IS NOT NULL
         AND co.date IN (
                         SELECT CONVERT(DATE,date_value) AS calendardate
                         FROM KIPP_NJ..PS$CALENDAR_DAY WITH(NOLOCK) 
                         WHERE schoolid = 73253 
                           AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()                            
                           --AND insession = 1
                        )
         AND co.date <= CONVERT(DATE,GETDATE())         
      ) sub
  PIVOT(
    MAX(n_logs)
    FOR logtype IN ([merits]
                   ,[demerits]
                   ,[detention]
                   ,[ISS]
                   ,[OSS])
   ) p  
 )

SELECT academic_year
      ,term
      ,studentid      
      ,student_number
      ,lastfirst
      ,date      
      ,day_order
      ,merits
      ,demerits      
      ,detention
      ,ISS
      ,OSS
      ,CASE
        WHEN merits >= 35 AND demerits <= 8 AND detention <= 2 AND ISS = 0 AND OSS = 0 THEN 3
        WHEN merits >= 30 AND demerits <= 12 AND detention <= 4 AND ISS <= 1 AND OSS = 0 THEN 2
        WHEN merits >= 25 THEN 1        
       END AS merit_bucket
      ,CASE
        WHEN demerits >= 50 THEN 5
        WHEN demerits >= 35 THEN 4
        WHEN demerits >= 25 THEN 3
        WHEN demerits >= 15 THEN 2
        WHEN demerits >= 10 THEN 1
        ELSE NULL
       END AS demerit_bucket
      ,CASE
        WHEN demerits >= 10 AND prev_demerits < 10 THEN 1
        WHEN demerits >= 15 AND prev_demerits < 15 THEN 1
        WHEN demerits >= 25 AND prev_demerits < 25 THEN 1
        WHEN demerits >= 35 AND prev_demerits < 35 THEN 1
        WHEN demerits >= 50 AND prev_demerits < 50 THEN 1
        ELSE NULL
       END AS moved_demerit_bucket
      ,prev_demerits
      ,CASE WHEN day_order = MAX(day_order) OVER(PARTITION BY academic_year, studentid) - 1 THEN 1 ELSE NULL END AS prev_date_flag
      ,DATEADD(DAY, -1, MAX(date) OVER(PARTITION BY academic_year)) AS prev_date      
      ,ROW_NUMBER() OVER(PARTITION BY student_number, academic_year, term ORDER BY date DESC) AS rn_term_date_curr
FROM
    (
     SELECT a.academic_year
           ,a.term
           ,a.studentid
           ,a.student_number
           ,a.lastfirst
           ,a.date                
           ,a.day_order
           
           ,a.demerits
           ,a.merits           
           ,a.detention
           ,a.ISS
           ,a.OSS
                           
           ,LAG(a.demerits, 1, 0) OVER(PARTITION BY a.studentid, a.academic_year, a.term ORDER BY a.date ASC) AS prev_demerits                
           --,LAG(a.merits, 1, 0) OVER(PARTITION BY a.studentid, a.academic_year, a.term ORDER BY a.date ASC) AS prev_merits
           --,LAG(a.detention, 1, 0) OVER(PARTITION BY a.studentid, a.academic_year, a.term ORDER BY a.date ASC) AS prev_detention           
           --,LAG(a.ISS, 1, 0) OVER(PARTITION BY a.studentid, a.academic_year, a.term ORDER BY a.date ASC) AS prev_ISS                
           --,LAG(a.OSS, 1, 0) OVER(PARTITION BY a.studentid, a.academic_year, a.term ORDER BY a.date ASC) AS prev_OSS
     FROM log_scaffold a WITH(NOLOCK) 
    ) sub