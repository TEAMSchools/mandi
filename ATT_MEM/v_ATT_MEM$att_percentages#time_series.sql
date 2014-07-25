USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$att_percentages#time_series AS
SELECT CAST(studentid AS int) AS studentid
      ,CAST(date_value AS date) AS date_value
      ,CAST(running_mem AS int) AS running_mem
      ,CAST(running_present AS int) AS running_present
      ,CAST(running_tardy AS int) AS running_tardy
      ,CAST(att_points AS int) AS att_points
      ,CAST(att_pct AS float) AS att_pct
      ,CAST(att_points_pct AS float) AS att_points_pct
FROM OPENQUERY(PS_TEAM, '
WITH date_scaffold AS
 (SELECT CAST(cd.date_value AS date) AS date_value
        ,cd.schoolid
        ,cd.membershipvalue
        ,cd.insession
        ,t.firstday
        ,t.lastday
  FROM calendar_day cd
  JOIN terms t
    ON cd.schoolid = t.schoolid
   AND t.yearid = 23
   AND cd.date_value >= t.firstday
   AND cd.date_value <= t.lastday
  WHERE cd.membershipvalue = 1
    AND cd.insession = 1
    AND cd.schoolid != 999999
    AND cd.schoolid != 0
    AND cd.date_value <= TRUNC(SYSDATE)
 )
 
SELECT sub.*
      ,(sub.running_mem - sub.running_present) + FLOOR(running_tardy/3) AS att_points
      ,ROUND((sub.running_present / sub.running_mem) * 100, 1) AS att_pct
      ,ROUND(
         ((sub.running_present - FLOOR(running_tardy/3)) / sub.running_mem) * 100
         ,1
       ) AS att_points_pct
FROM
      (SELECT sub.studentid
             ,sub.date_value
             ,SUM(
                SUM(membershipvalue)
              ) OVER (PARTITION BY studentid 
                      ORDER BY date_value ASC
                      ROWS UNBOUNDED PRECEDING
              ) AS running_mem
             ,SUM(
                SUM(att_value)
              ) OVER (PARTITION BY studentid 
                      ORDER BY date_value ASC
                      ROWS UNBOUNDED PRECEDING
              ) AS running_present
             ,SUM(
                SUM(tardy_value)
              ) OVER (PARTITION BY studentid 
                      ORDER BY date_value ASC
                      ROWS UNBOUNDED PRECEDING
              ) AS running_tardy
       FROM
             (SELECT s.id AS studentid
                    ,date_scaffold.date_value
                    ,date_scaffold.membershipvalue
                    ,CASE 
                       WHEN att_d.presence_status_cd IS NULL THEN 1
                       WHEN att_d.presence_status_cd = ''Present'' THEN 1
                       WHEN att_d.presence_status_cd = ''Absent'' THEN 0
                     END AS att_value
                   ,CASE 
                      WHEN att_d.att_code = ''T'' THEN 1
                      WHEN att_d.att_code = ''T10'' THEN 1
                      ELSE 0
                    END AS tardy_value
              FROM date_scaffold
              JOIN STUDENTS s
                ON date_scaffold.schoolid = s.schoolid
               AND s.enroll_status = 0
               --AND s.id = 2859
              LEFT OUTER JOIN PS_ATTENDANCE_DAILY ATT_D
                ON s.id = att_d.studentid
               AND att_d.att_date = date_scaffold.date_value
              ) sub
       GROUP BY  sub.studentid
                ,sub.date_value
       ) sub
       WHERE sub.running_mem > 0
')