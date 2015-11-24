USE KIPP_NJ
GO

ALTER VIEW TABLEAU$pathways_weekly_behavior_report AS

SELECT co.year
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
      ,trk.bip_ontrack      
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number, dt.time_per_name) AS week_BIP_ontrack
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number, DATEPART(MONTH,cal.date_value)) AS month_BIP_ontrack
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number, rt.alt_name) AS term_BIP_ontrack
      ,AVG(trk.bip_ontrack) OVER(PARTITION BY co.student_number) AS year_BIP_ontrack
      ,goals.goal AS behavior_goal_name
      ,goals.achieved AS behavior_goal_achieved
      ,skwk.social_skill
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
LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_long#ES#static trk WITH(NOLOCK)
  ON co.studentid = trk.studentid
 AND cal.date_value = trk.att_date
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PATHWAYS_goal_tracking goals WITH(NOLOCK)
  ON co.lastfirst = goals.student_name
 AND goals.achieved_date IS NULL
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PATHWAYS_social_skill_of_the_week skwk WITH(NOLOCK)
  ON DATEPART(MONTH,CONVERT(DATE,skwk.week_of)) = DATEPART(MONTH,cal.date_value)
WHERE co.rn = 1
  AND (co.grade_level <= 4 AND co.schoolid != 73252)
  AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.TEAM LIKE '%pathways%'