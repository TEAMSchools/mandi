USE KIPP_NJ
GO

ALTER VIEW TABLEAU$attendance_dashboard_new AS

SELECT co.year
      ,co.schoolid
      ,co.studentid
      ,co.lastfirst
      ,co.grade_level
      ,co.school_level
      ,co.team
      ,co.enroll_status
      --,co.SPEDLEP
      
      ,dt.alt_name AS term

      ,mem.calendardate
      ,mem.membershipvalue
      ,mem.ATTENDANCEVALUE AS is_present
      ,ABS(mem.ATTENDANCEVALUE - 1) AS is_absent
      
      ,att.att_code
      ,CASE WHEN att.att_code IN ('T','T10','ET','TE') THEN 1 ELSE 0 END AS is_tardy
      ,CASE WHEN att.att_code IN ('OSS','ISS') THEN 1 ELSE 0 END AS suspension_all

      ,enr.SECTION_NUMBER
      ,enr.teacher_name

      ,CASE WHEN att.att_code = 'A' THEN 1 ELSE 0 END AS n_A
      ,CASE WHEN att.att_code = 'AD' THEN 1 ELSE 0 END AS n_AD
      ,CASE WHEN att.att_code = 'AE' THEN 1 ELSE 0 END AS n_AE
      ,CASE WHEN att.att_code = 'A-E' THEN 1 ELSE 0 END AS n_A_E
      ,CASE WHEN att.att_code = 'CR' THEN 1 ELSE 0 END AS n_CR
      ,CASE WHEN att.att_code = 'CS' THEN 1 ELSE 0 END AS n_CS
      ,CASE WHEN att.att_code = 'D' THEN 1 ELSE 0 END AS n_D
      ,CASE WHEN att.att_code = 'E' THEN 1 ELSE 0 END AS n_E
      ,CASE WHEN att.att_code = 'EA' THEN 1 ELSE 0 END AS n_EA
      ,CASE WHEN att.att_code = 'ET' THEN 1 ELSE 0 END AS n_ET
      ,CASE WHEN att.att_code = 'EV' THEN 1 ELSE 0 END AS n_EV
      ,CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END AS n_ISS
      ,CASE WHEN att.att_code = 'NM' THEN 1 ELSE 0 END AS n_NM
      ,CASE WHEN att.att_code = 'OS' THEN 1 ELSE 0 END AS n_OS
      ,CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END AS n_OSS
      ,CASE WHEN att.att_code = 'OSSP' THEN 1 ELSE 0 END AS n_OSSP
      ,CASE WHEN att.att_code = 'PLE' THEN 1 ELSE 0 END AS n_PLE
      ,CASE WHEN att.att_code = 'Q' THEN 1 ELSE 0 END AS n_Q
      ,CASE WHEN att.att_code = 'S' THEN 1 ELSE 0 END AS n_S
      ,CASE WHEN att.att_code = 'SE' THEN 1 ELSE 0 END AS n_SE
      ,CASE WHEN att.att_code = 'T' THEN 1 ELSE 0 END AS n_T
      ,CASE WHEN att.att_code = 'T10' THEN 1 ELSE 0 END AS n_T10
      ,CASE WHEN att.att_code = 'TE' THEN 1 ELSE 0 END AS n_TE
      ,CASE WHEN att.att_code = 'TLE' THEN 1 ELSE 0 END AS n_TLE
      ,CASE WHEN att.att_code = 'U' THEN 1 ELSE 0 END AS n_U
      ,CASE WHEN att.att_code = 'X' THEN 1 ELSE 0 END AS n_X      
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
  ON co.studentid = mem.studentid
 AND co.schoolid = mem.schoolid
 AND co.year = mem.academic_year
 AND mem.calendardate < CONVERT(DATE,GETDATE())
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
  ON co.studentid = att.studentid
 AND mem.CALENDARDATE = att.ATT_DATE
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK) 
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND mem.CALENDARDATE BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.drop_flags = 0
 AND enr.COURSE_NUMBER = 'HR'
WHERE co.rn = 1