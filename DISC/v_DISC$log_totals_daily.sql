USE KIPP_NJ
GO

ALTER VIEW DISC$log_totals_daily AS

WITH log_totals AS (
  SELECT studentid
        ,entry_date
        ,logtype
        ,COUNT(entry_date) AS n_logs
  FROM
      (
       SELECT studentid
             ,entry_date
             ,logtypeid             
             ,CASE
               WHEN logtypeid = 3023 THEN 'merits'
               WHEN logtypeid = 3223 THEN 'demerits'
               WHEN logtypeid = -100000 THEN subtype
               ELSE NULL
              END AS logtype
       FROM DISC$log#static disc WITH(NOLOCK)
       WHERE (disc.logtypeid IN (3023, 3223) OR disc.logtypeid = -100000 AND subtype IN ('ISS','OSS','Detention'))
         AND disc.schoolid = 73253
         AND disc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
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
        ,merits
        ,demerits
        ,detention
        ,ISS
        ,OSS
        ,ROW_NUMBER() OVER(
          PARTITION BY studentid
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
             ,SUM(disc.n_logs) OVER(PARTITION BY co.studentid, co.term, disc.logtype ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS running_total                        
       FROM COHORT$identifiers_scaffold#static co WITH(NOLOCK)
       LEFT OUTER JOIN log_totals disc WITH(NOLOCK)
         ON co.studentid = disc.studentid
        AND co.date = disc.entry_date
       WHERE co.year = dbo.fn_Global_Academic_Year()
         AND co.schoolid = 73253
         AND co.term IS NOT NULL
         AND co.date IN (SELECT calendardate FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK) WHERE schoolid = 73253 AND academic_year = dbo.fn_Global_Academic_Year() AND DATEPART(WEEKDAY,calendardate) NOT IN (1,7))
         --AND co.date < CONVERT(DATE,GETDATE())         
      ) sub
  PIVOT(
    MAX(running_total)
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
        ELSE NULL
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
      
FROM
    (
     SELECT academic_year
           ,term
           ,studentid
           ,student_number
           ,lastfirst
           ,date           
           ,day_order
           ,COALESCE(MAX(merits), MAX(prev_merits)) AS merits
           ,COALESCE(MAX(demerits), MAX(prev_demerits)) AS demerits
           ,COALESCE(MAX(detention), MAX(prev_detention)) AS detention
           ,COALESCE(MAX(ISS), MAX(prev_ISS)) AS ISS
           ,COALESCE(MAX(OSS), MAX(prev_OSS)) AS OSS
           ,MAX(prev_demerits) AS prev_demerits
     FROM
         (
          SELECT a.academic_year
                ,a.term
                ,a.studentid
                ,a.student_number
                ,a.lastfirst
                ,a.date                
                ,a.merits
                ,a.demerits      
                ,a.detention
                ,a.ISS
                ,a.OSS
                ,ISNULL(b.demerits,0) AS prev_demerits
                ,ISNULL(b.merits,0) AS prev_merits
                ,ISNULL(b.detention,0) AS prev_detention
                ,ISNULL(b.ISS,0) AS prev_ISS
                ,ISNULL(b.OSS,0) AS prev_OSS
                ,a.day_order
          FROM log_scaffold a WITH(NOLOCK) 
          LEFT OUTER JOIN log_scaffold b WITH(NOLOCK)
            ON a.studentid = b.studentid
           AND a.term = b.term
           AND a.day_order > b.day_order      
         ) sub
     GROUP BY academic_year
             ,term
             ,studentid
             ,student_number
             ,lastfirst
             ,date             
             ,day_order     
    ) sub