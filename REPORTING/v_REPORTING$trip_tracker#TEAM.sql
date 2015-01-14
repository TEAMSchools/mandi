USE KIPP_NJ
GO

ALTER VIEW REPORTING$trip_tracker#TEAM AS

SELECT s.student_number AS sn
      ,s.lastfirst AS stu_lastfirst
      ,s.first_name AS firstname 
      ,s.last_name AS lastname 
      ,s.grade_level AS stu_grade_level 
      ,s.team AS travel_group 
      ,s.ADVISOR
      ,ROUND(team_gpa.gpa_y1_all,2) AS gpa_y1_all 
      ,ROUND(team_gpa.gpa_y1_core,2) AS gpa_y1_core 
      ,promo.promo_att_team AS promo_status_att
      ,ROUND(hw.simple_avg,2) * 1 AS hy1_avg 
      ,counts.detentions 
      ,counts.silent_lunches 
      ,counts.choices 
      ,counts.bench 
      ,counts.bus_warnings 
      ,counts.bus_suspensions 
      ,counts.class_removal 
      ,counts.Bullying 
      ,counts.ISS 
      ,counts.OSS       
      ,ISNULL(CONVERT(VARCHAR, incidents.DISC_01_DATE_REPORTED, 101) + '_','') + ISNULL(incidents.DISC_01_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_02_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_02_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_03_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_03_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_04_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_04_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_05_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_05_SUBJECT, '')
        AS list_of_infractions
FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..DISC$counts_wide counts WITH(NOLOCK)
  ON s.studentid = counts.studentid
LEFT OUTER JOIN KIPP_NJ..DISC$recent_incidents_wide incidents WITH(NOLOCK)
  ON s.studentid = incidents.studentid
LEFT OUTER JOIN KIPP_NJ..REPORTING$promo_status#MS promo WITH(NOLOCK)
  ON s.studentid = promo.studentid  
LEFT OUTER JOIN KIPP_NJ..GPA$detail#MS team_gpa WITH(NOLOCK)
  ON s.studentid = team_gpa.studentid
LEFT OUTER JOIN KIPP_NJ..GRADES$ELEMENTS hw WITH(NOLOCK)
  ON s.studentid = hw.studentid
 AND hw.pgf_type = 'H'
 AND hw.course_number = 'all_courses'
 AND hw.yearid = LEFT(dbo.fn_Global_Term_Id(), 2)
WHERE s.year = dbo.fn_Global_Academic_Year()
  AND s.schoolid = 133570965  
  AND s.enroll_status = 0
  AND s.rn = 1