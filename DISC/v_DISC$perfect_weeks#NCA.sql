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
  
  8/21/14
  Dude...just tore this apart
  
CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
*/

USE KIPP_NJ
GO

--ALTER VIEW DISC$perfect_weeks#NCA AS

WITH roster AS (
  SELECT co.student_number
        ,co.studentid        
        ,co.entrydate        
        ,co.exitdate        
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE co.schoolid = 73253
    AND co.rn = 1
    AND co.year = dbo.fn_Global_Academic_Year()
 )

,weeks AS (
  SELECT DISTINCT
         mem.calendardate
        ,DATEPART(WEEK,mem.calendardate) AS wk
        ,dt.time_per_name AS rt
        ,CONVERT(INT,CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) + CONVERT(VARCHAR,DATEPART(WEEK,GETDATE()))) AS cur_wkhash
        ,CONVERT(INT,CONVERT(VARCHAR,DATEPART(YEAR,mem.calendardate)) + CONVERT(VARCHAR,DATEPART(WEEK,mem.calendardate))) AS mem_wkhash
        ,CASE 
          WHEN CONVERT(INT,CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) + CONVERT(VARCHAR,DATEPART(WEEK,GETDATE()))) > CONVERT(INT,CONVERT(VARCHAR,DATEPART(YEAR,mem.calendardate)) + CONVERT(VARCHAR,DATEPART(WEEK,mem.calendardate))) THEN 1
          ELSE 0
         END AS is_past
  FROM MEMBERSHIP mem WITH(NOLOCK)
  JOIN REPORTING$dates dt WITH(NOLOCK)
    ON mem.schoolid = dt.schoolid
   AND mem.calendardate >= dt.start_date
   AND mem.calendardate <= dt.end_date 
   AND dt.identifier = 'RT'
   AND dt.academic_year = dbo.fn_Global_Academic_Year()
  WHERE mem.schoolid = 73253
    AND mem.calendardate >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01')
 )

,demerits AS (
  SELECT demerits.studentid
        ,DATEPART(WEEK,demerits.entry_date) AS wk
        ,CASE WHEN COUNT(*) > 0 THEN 0 ELSE 1 END AS is_perfect
  FROM DISC$log#static demerits WITH(NOLOCK)
  WHERE demerits.logtypeid = 3223
    AND demerits.schoolid = 73253
  GROUP BY demerits.studentid
          ,DATEPART(WEEK,demerits.entry_date)
 )

SELECT sub.studentid
      ,sub.student_number
      ,SUM(is_perfect) AS perfect_wks_y1
      ,SUM(is_perfect_rt1) AS perfect_wks_rt1
      ,SUM(is_perfect_rt2) AS perfect_wks_rt2
      ,SUM(is_perfect_rt3) AS perfect_wks_rt3
      ,SUM(is_perfect_rt4) AS perfect_wks_rt4
FROM
    (
     SELECT DISTINCT
            r.student_number
           ,r.studentid
           ,w.wk           
           ,ISNULL(d.is_perfect, 1) AS is_perfect
           ,CASE WHEN w.rt = 'RT1' AND w.is_past = 1 THEN ISNULL(d.is_perfect, 1) ELSE NULL END AS is_perfect_rt1
           ,CASE WHEN w.rt = 'RT2' AND w.is_past = 1 THEN ISNULL(d.is_perfect, 1) ELSE NULL END AS is_perfect_rt2
           ,CASE WHEN w.rt = 'RT3' AND w.is_past = 1 THEN ISNULL(d.is_perfect, 1) ELSE NULL END AS is_perfect_rt3
           ,CASE WHEN w.rt = 'RT4' AND w.is_past = 1 THEN ISNULL(d.is_perfect, 1) ELSE NULL END AS is_perfect_rt4
     FROM roster r
     JOIN weeks w
       ON r.entrydate <= w.calendardate
      AND r.exitdate >= w.calendardate
     LEFT OUTER JOIN demerits d
       ON r.studentid = d.studentid
      AND w.wk = d.wk
    ) sub
GROUP BY sub.studentid
        ,sub.student_number