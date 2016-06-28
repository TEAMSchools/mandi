USE KIPP_NJ
GO

ALTER VIEW TABLEAU$attendance_dashboard AS

SELECT co.year
      ,co.schoolid
      ,co.studentid
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.SPEDLEP
      ,CONVERT(DATE,mem.calendardate) AS att_date
      ,dt.alt_name AS term
      ,mem.membershipvalue
      ,mem.ATTENDANCEVALUE AS present
      ,att.att_code
      --tardies
      ,CASE WHEN att.att_code IN ('T','T10','ET') THEN 1 ELSE 0 END AS tardy_all
      ,CASE WHEN att.att_code = 'T' THEN 1 ELSE 0 END AS tardy
      ,CASE WHEN att.att_code = 'T10' THEN 1 ELSE 0 END AS tardy_10
      ,CASE WHEN att.att_code = 'TE' THEN 1 ELSE 0 END AS tardy_excused
      --absences
      ,CASE WHEN att.PRESENCE_STATUS_CD = 'Absent' THEN 1 ELSE 0 END AS absent_all
      ,CASE WHEN att.att_code = 'AD' THEN 1 ELSE 0 END AS absent_doc
      ,CASE WHEN att.att_code = 'A' THEN 1 ELSE 0 END AS absent_undoc
      ,CASE WHEN att.att_code = 'AE' THEN 1 ELSE 0 END AS absent_excused
      --suspensions
      ,CASE WHEN att.att_code IN ('OSS','ISS') THEN 1 ELSE 0 END AS suspension_all
      ,CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END AS ISS
      ,CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END AS OSS
      --other
      ,CASE WHEN ed.logtypeid IS NOT NULL THEN 1 ELSE 0 END AS early_dismissal
      ,supp.behavior_tier
      ,supp.plan_owner
      ,supp.admin_support
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
  ON co.studentid = mem.studentid
 AND co.schoolid = mem.schoolid
 AND co.year = mem.academic_year
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK) 
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND mem.CALENDARDATE BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
  ON co.studentid = att.studentid
 AND mem.CALENDARDATE = att.ATT_DATE 
LEFT OUTER JOIN DISC$log#static ed WITH(NOLOCK)
  ON co.studentid = ed.studentid
 AND mem.CALENDARDATE = ed.entry_date
 AND ed.logtypeid = 3953
LEFT OUTER JOIN AUTOLOAD$GDOCS_SUPPORT_Master_List supp WITH(NOLOCK)
  ON co.student_number = supp.SN
 AND co.year = supp.academic_year
WHERE co.rn = 1