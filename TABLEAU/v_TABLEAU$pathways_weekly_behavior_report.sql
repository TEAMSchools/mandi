USE KIPP_NJ
GO

ALTER VIEW TABLEAU$pathways_weekly_behavior_report AS

WITH social_skills AS (
  SELECT CONVERT(DATE,week_of) AS week_of
        ,DATEPART(MONTH,CONVERT(DATE,week_of)) AS month_of
        ,social_skill
        ,ROW_NUMBER() OVER(
           PARTITION BY DATEPART(MONTH,CONVERT(DATE,week_of))
             ORDER BY CONVERT(DATE,week_of) DESC) AS rn
  FROM KIPP_NJ..AUTOLOAD$GDOCS_PATHWAYS_social_skill_of_the_week WITH(NOLOCK)
 )

,behavior_comments AS (
  SELECT studentid
        ,month_of
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(DISTINCT entry_text, CHAR(10)) AS behavior_comments_grouped
  FROM
      (
       SELECT d.studentid
             ,DATEPART(MONTH,d.entry_date) AS month_of
             ,CONCAT(FORMAT(d.entry_date,'MM/dd/yy'), ' - ', t.entry) AS entry_text
       FROM KIPP_NJ..DISC$log#static d WITH(NOLOCK)
       JOIN KIPP_NJ..DISC$log_entry_text#static t WITH(NOLOCK)
         ON d.DCID = t.DCID
       WHERE d.logtypeid = 4578
         AND d.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  GROUP BY studentid
          ,month_of
)

SELECT co.year
      ,co.studentid
      ,co.student_number      
      ,co.lastfirst            
      ,CASE WHEN co.team LIKE '%pathways%' THEN 732570 ELSE co.schoolid END AS schoolid
      ,co.grade_level
      ,co.TEAM
      ,co.SPEDLEP
      ,rt.alt_name AS term
      ,REPLACE(dt.time_per_name, '_', ' ') AS time_per_name
      ,dt.start_date
      ,dt.end_date      
      ,cal.date_value
      
      ,CONVERT(FLOAT,mem.ATTENDANCEVALUE) AS daily_attendancevalue
      ,AVG(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) OVER(PARTITION BY co.student_number, dt.time_per_name) AS week_attendancevalue
      ,AVG(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) OVER(PARTITION BY co.student_number, DATEPART(MONTH,cal.date_value)) AS month_attendancevalue
      ,AVG(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) OVER(PARTITION BY co.student_number, rt.alt_name) AS term_attendancevalue
      ,AVG(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) OVER(PARTITION BY co.student_number) AS year_attendancevalue      
      ,SUM(CONVERT(FLOAT,mem.MEMBERSHIPVALUE)) OVER(PARTITION BY co.student_number) AS year_membershipvalue
      
      ,att.ATT_CODE
      ,SUM(CASE WHEN att.ATT_CODE LIKE 'T%' THEN 1 ELSE 0 END) OVER(PARTITION BY co.student_number) AS year_n_tardy
      ,1 - (SUM(CASE WHEN att.ATT_CODE LIKE 'T%' THEN 1 ELSE 0 END) OVER(PARTITION BY co.student_number)
         / SUM(CONVERT(FLOAT,mem.MEMBERSHIPVALUE)) OVER(PARTITION BY co.student_number)) AS year_pct_ontime
      
      ,trk.hw
      ,AVG(trk.has_hw) OVER(PARTITION BY co.student_number, dt.time_per_name) AS week_hw
      ,AVG(trk.has_hw) OVER(PARTITION BY co.student_number, DATEPART(MONTH,cal.date_value)) AS month_hw
      ,AVG(trk.has_hw) OVER(PARTITION BY co.student_number, rt.alt_name) AS term_hw
      ,AVG(trk.has_hw) OVER(PARTITION BY co.student_number) AS year_hw
      
      ,trk.bip_ontrack            
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number, dt.time_per_name) AS week_BIP_ontrack
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number, DATEPART(MONTH,cal.date_value)) AS month_BIP_ontrack
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number, rt.alt_name) AS term_BIP_ontrack
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number) AS year_BIP_ontrack
      
      ,goals.goal AS behavior_goal_name
      ,goals.achieved AS behavior_goal_achieved
      ,skwk.social_skill
      ,comm.behavior_comments_grouped
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
  ON co.schoolid = cal.schoolid
 AND co.year = cal.academic_year 
 AND cal.insession = 1
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND cal.date_value BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'REP'
JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
  ON co.schoolid = rt.schoolid
 AND co.year = rt.academic_year
 AND cal.date_value BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
  ON co.studentid = mem.STUDENTID
 AND cal.date_value = mem.CALENDARDATE
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
  ON co.studentid = att.STUDENTID
 AND cal.date_value = att.ATT_DATE
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_long#ES#static trk WITH(NOLOCK)
  ON co.studentid = trk.studentid
 AND cal.date_value = trk.att_date
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PATHWAYS_goal_tracking goals WITH(NOLOCK)
  ON co.lastfirst = goals.student_name
 AND goals.achieved_date IS NULL
LEFT OUTER JOIN social_skills skwk WITH(NOLOCK)
  ON DATEPART(MONTH,cal.date_value) = skwk.month_of
 AND skwk.rn = 1
LEFT OUTER JOIN behavior_comments comm WITH(NOLOCK)
  ON co.studentid = comm.studentid
 AND DATEPART(MONTH,cal.date_value) = comm.month_of
WHERE co.rn = 1
  AND (co.grade_level <= 4 AND co.schoolid != 73252)
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.TEAM LIKE '%pathways%'
  AND co.enroll_status = 0