USE KIPP_NJ
GO

ALTER VIEW REPORTING$trip_tracker#TEAM AS

SELECT s.student_number AS sn
      ,s.lastfirst AS stu_lastfirst
      ,s.first_name AS firstname 
      ,s.last_name AS lastname 
      ,s.grade_level AS stu_grade_level 
      ,s.team AS travel_group 
      ,cs.ADVISOR
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
      --,incidents.DISC_01_GIVEN_BY
      --,incidents.DISC_01_DATE_REPORTED
      --,incidents.DISC_01_SUBJECT
      --,incidents.DISC_01_SUBTYPE
      --,incidents.DISC_01_INCIDENT
      --,incidents.DISC_02_GIVEN_BY
      --,incidents.DISC_02_DATE_REPORTED
      --,incidents.DISC_02_SUBJECT
      --,incidents.DISC_02_SUBTYPE
      --,incidents.DISC_02_INCIDENT
      --,incidents.DISC_03_GIVEN_BY
      --,incidents.DISC_03_DATE_REPORTED
      --,incidents.DISC_03_SUBJECT
      --,incidents.DISC_03_SUBTYPE
      --,incidents.DISC_03_INCIDENT
      --,incidents.DISC_04_GIVEN_BY
      --,incidents.DISC_04_DATE_REPORTED
      --,incidents.DISC_04_SUBJECT
      --,incidents.DISC_04_SUBTYPE
      --,incidents.DISC_04_INCIDENT
      --,incidents.DISC_05_GIVEN_BY
      --,incidents.DISC_05_DATE_REPORTED
      --,incidents.DISC_05_SUBJECT
      --,incidents.DISC_05_SUBTYPE
      --,incidents.DISC_05_INCIDENT      
      ,ISNULL(CONVERT(VARCHAR, incidents.DISC_01_DATE_REPORTED, 101) + '_','') + ISNULL(incidents.DISC_01_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_02_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_02_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_03_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_03_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_04_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_04_SUBJECT, '') + ' '
        + ISNULL(CONVERT(VARCHAR, incidents.DISC_05_DATE_REPORTED, 101) + '_', '') + ISNULL(incidents.DISC_05_SUBJECT, '')
        AS list_of_infractions
FROM students s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.STUDENTID
LEFT OUTER JOIN DISC$counts_wide counts WITH(NOLOCK)
  ON s.id = counts.base_studentid
LEFT OUTER JOIN DISC$recent_incidents_wide incidents WITH(NOLOCK)
  ON s.id = incidents.studentid
LEFT OUTER JOIN REPORTING$promo_status#MS promo WITH(NOLOCK)
  ON s.id = promo.studentid  
LEFT OUTER JOIN GPA$detail#MS team_gpa WITH(NOLOCK)
  ON s.id = team_gpa.studentid
LEFT OUTER JOIN GRADES$ELEMENTS hw WITH(NOLOCK)
  ON s.id = hw.studentid
 AND hw.pgf_type = 'H'
 AND hw.course_number = 'all_courses'
WHERE s.schoolid = 133570965
  AND s.enroll_status = 0