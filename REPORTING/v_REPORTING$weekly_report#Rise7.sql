USE KIPP_NJ
GO

ALTER VIEW REPORTING$weekly_report#Rise7 AS

WITH roster AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst
        ,co.team        
        ,co.advisor
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.schoolid = 73252
    AND co.grade_level >= 7
    AND co.enroll_status = 0
    AND co.rn = 1
 )  

,disc_counts AS (
  SELECT studentid
        ,[Bench / Choices] AS choices
        ,[Detention]
        ,[ISS]
        ,[OSS]
        ,[Silent Lunch]
  FROM
      (
       SELECT studentid
             ,subtype
             ,COUNT(subtype) AS N
       FROM
           (
            SELECT disc.studentid
                  ,disc.entry_date
                  ,disc.subtype
            FROM KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
            WHERE disc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
              AND disc.logtypeid = -100000
              AND disc.subtypeid IN (01,02,04)
              AND disc.schoolid = 73252
              AND disc.entry_date IN (SELECT date FROM KIPP_NJ..REPORTING$Rise_weekly_dates#static dt WITH(NOLOCK))

            UNION ALL

            SELECT att.studentid
                  ,att.att_date
                  ,att.att_code
            FROM KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
            WHERE att.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
              AND att.schoolid = 73252
              AND att.ATT_CODE IN ('ISS','OSS')
              AND att.att_date IN (SELECT date FROM KIPP_NJ..REPORTING$Rise_weekly_dates#static dt WITH(NOLOCK))
           ) sub
       GROUP BY studentid, subtype
      ) sub
  PIVOT(
    MAX(N)
    FOR subtype IN ([Bench / Choices]
                   ,[Detention]
                   ,[ISS]
                   ,[OSS]
                   ,[Silent Lunch])
   ) p
 )

,grades AS (
  SELECT student_number        
        ,date
        ,gpa
        ,LAG(gpa) OVER(PARTITION BY student_number ORDER BY date) AS prev_gpa
        ,CASE
          WHEN gpa IS NULL THEN NULL
          WHEN gpa >= 2.0 THEN 'Met'
          WHEN gpa > LAG(gpa) OVER(PARTITION BY student_number ORDER BY date) THEN 'Improving'
          ELSE 'Not Improving'
         END AS gpa_status
        ,hwc_avg
        ,LAG(hwc_avg) OVER(PARTITION BY student_number ORDER BY date) AS prev_hwc_avg
        ,CASE
          WHEN hwc_avg IS NULL THEN NULL
          WHEN hwc_avg >= 65 THEN 'Met'
          WHEN hwc_avg > LAG(hwc_avg) OVER(PARTITION BY student_number ORDER BY date) THEN 'Improving'
          ELSE 'Not Improving'
         END AS hwc_status
  FROM
      (
       SELECT ts.student_number
             ,ts.date
             ,ROUND(AVG(CASE WHEN ts.finalgradename = 'Y1' THEN scl.grade_points ELSE NULL END),2) AS gpa
             ,ROUND(AVG(CASE WHEN ts.finalgradename = 'HY' THEN ts.moving_average ELSE NULL END),0) AS hwc_avg
       FROM KIPP_NJ..GRADES$time_series ts WITH(NOLOCK)
       JOIN KIPP_NJ..GRADES$grade_scales#static scl WITH(NOLOCK)
         ON (ts.moving_average >= scl.low_cut AND ts.moving_average < scl.high_cut)
        AND scl.scale_id = 1
       WHERE (ts.finalgradename = 'Y1' OR ts.finalgradename LIKE 'HY')
         AND (DATEPART(DW,ts.date) = 4 /* as of Wednesday */ OR (DATEPART(DW,ts.date) < 4 AND ts.date = CONVERT(DATE,GETDATE())))                  
         AND ts.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND ts.schoolid = 73252
       GROUP BY ts.student_number
               ,ts.date
      ) sub  
 )

,att_pts AS (
  SELECT *
        ,LAG(att_pts_pct) OVER(PARTITION BY student_number ORDER BY date) AS prev_att_pts_pct
        ,CASE          
          WHEN ISNULL(att_pts_pct, 90) >= 90  THEN 'Met'
          WHEN att_pts_pct > LAG(att_pts_pct) OVER(PARTITION BY student_number ORDER BY date) THEN 'Improving'
          ELSE 'Not Improving'
         END AS att_pts_status
  FROM
      (
       SELECT student_number        
             ,date
             ,att_pts
             ,CONVERT(FLOAT,ROUND(((mem - att_pts) / mem) * 100,1)) AS att_pts_pct        
       FROM
           (
            SELECT co.student_number
                  ,co.date      
                  ,SUM(CONVERT(FLOAT,mem.membershipvalue)) OVER(PARTITION BY co.student_number
                                                                  ORDER BY co.date
                                                                  ROWS UNBOUNDED PRECEDING) AS mem
                  ,FLOOR(SUM(CASE
                              WHEN att.ATT_CODE IN ('TE','AE') THEN 0.0
                              WHEN att.PRESENCE_STATUS_CD = 'Absent' THEN 1.0
                              WHEN att.ATT_CODE IN ('T','T10') THEN (1.0/3.0) + 0.000001 /* pushes the 3rd tardy over te edge from .999... */
                              ELSE 0.0
                             END) OVER(PARTITION BY co.student_number
                                         ORDER BY co.date
                                         ROWS UNBOUNDED PRECEDING)) AS att_pts
            FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
            LEFT OUTER JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
              ON co.studentid = mem.STUDENTID
             AND co.date = mem.CALENDARDATE
            LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
              ON co.studentid = att.STUDENTID
             AND co.date = att.ATT_DATE
            WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
              AND co.schoolid = 73252
              AND co.grade_level >= 7
              AND co.date <= CONVERT(DATE,GETDATE())
           ) sub
      ) sub
  WHERE (DATEPART(DW,date) = 4 OR date = CONVERT(DATE,GETDATE()))
 )

SELECT *
      ,CASE WHEN CONCAT(ff_conduct_status,ff_promo_status) LIKE '%No%' THEN 'No' ELSE 'Yes' END AS ff_overall_status
FROM
    (
     SELECT r.lastfirst
           ,r.team
           ,r.advisor
           ,(SELECT FORMAT(MIN(date),'M/dd/yyy') FROM KIPP_NJ..REPORTING$Rise_weekly_dates#static dt WITH(NOLOCK)) AS wk_start_date
           ,(SELECT FORMAT(MAX(date),'M/dd/yyy') FROM KIPP_NJ..REPORTING$Rise_weekly_dates#static dt WITH(NOLOCK)) AS wk_end_date
           ,ISNULL(d.choices,0) AS choices
           ,ISNULL(d.detention,0) AS detention
           ,ISNULL(d.ISS,0) AS ISS
           ,ISNULL(d.OSS,0) AS OSS
           ,ISNULL(d.[Silent Lunch],0) AS silent_lunch           
           ,g.gpa
           ,g.prev_gpa
           ,g.gpa_status
           ,g.hwc_avg
           ,g.prev_hwc_avg
           ,g.hwc_status
           ,a.att_pts
           ,a.att_pts_pct
           ,a.prev_att_pts_pct
           ,a.att_pts_status
           ,CASE
             WHEN ISNULL(d.choices,0) + ISNULL(d.ISS,0) + ISNULL(d.OSS,0) > 0 THEN 'No'
             WHEN ISNULL(d.detention,0) + ISNULL(d.[Silent Lunch],0) >= 4 THEN 'No'
             ELSE 'Yes'
            END AS ff_conduct_status
           ,CASE 
             WHEN CONCAT(g.gpa_status, g.hwc_status, a.att_pts_status) LIKE '%Not%' THEN 'No'
             ELSE 'Yes'
            END AS ff_promo_status
     FROM roster r     
     LEFT OUTER JOIN disc_counts d
       ON r.studentid = d.studentid
     LEFT OUTER JOIN grades g
       ON r.student_number = g.student_number
      AND g.date IN (SELECT date FROM KIPP_NJ..REPORTING$Rise_weekly_dates#static dt WITH(NOLOCK))
     LEFT OUTER JOIN att_pts a
       ON r.student_number = a.student_number
      AND a.date IN (SELECT date FROM KIPP_NJ..REPORTING$Rise_weekly_dates#static dt WITH(NOLOCK))
    ) sub