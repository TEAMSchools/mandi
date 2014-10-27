USE KIPP_NJ
GO

--ALTER VIEW TABLEAU$attendance_dashboard AS

SELECT 'KIPP NJ' AS Network
      ,CASE
        WHEN co.schoolid != 179901 THEN 'Newark'
        ELSE 'Camden'
       END AS Region
      ,CASE
        WHEN co.schoolid IN (73254,73255,73256,73257,179901) THEN 'ES'
        WHEN co.schoolid IN (73252,133570965) THEN 'MS'
        WHEN co.schoolid IN (73253) THEN 'HS'
       END AS school_level      
      ,co.schoolid
      ,co.lastfirst
      ,co.grade_level
      ,s.team
      ,cs.SPEDLEP
      ,CONVERT(DATE,mem.calendardate) AS att_date
      ,mem.membershipvalue
      ,att.att_code
      ,CASE WHEN att.PRESENCE_STATUS_CD = 'Present' THEN 1 ELSE 0 END AS present
      --tardies
      ,CASE WHEN att.att_code IN ('T','T10','ET') THEN 1 ELSE 0 END AS tardy_all
      ,CASE WHEN att.att_code = 'T' THEN 1 ELSE 0 END AS tardy
      ,CASE WHEN att.att_code = 'T10' THEN 1 ELSE 0 END AS tardy_10
      ,CASE WHEN att.att_code = 'TE' THEN 1 ELSE 0 END AS tardy_excused
      --absences
      ,CASE WHEN att.PRESENCE_STATUS_CD = 'Absent' THEN 1 ELSE 0 END AS absent_all
      ,CASE WHEN att.att_code IN ('AD','AE') THEN 1 ELSE 0 END AS absent_doc
      ,CASE WHEN att.att_code = 'A' THEN 1 ELSE 0 END AS absent_undoc
      ,CASE WHEN att.att_code = 'AE' THEN 1 ELSE 0 END AS absent_excused
      --suspensions
      ,CASE WHEN att.att_code IN ('OSS','ISS') THEN 1 ELSE 0 END AS suspension_all
      ,CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END AS ISS
      ,CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END AS OSS
      --other
      ,CASE WHEN ed.subtype = '01' THEN 1 ELSE 0 END AS early_dismissal
FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)
  ON co.studentid = s.id
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON co.studentid = cs.studentid
JOIN MEMBERSHIP mem WITH(NOLOCK)
  ON co.studentid = mem.studentid
 AND co.schoolid = mem.schoolid
 AND mem.CALENDARDATE >= CONVERT(DATE,CONVERT(VARCHAR,co.year) + '-08-01')
LEFT OUTER JOIN ATTENDANCE att WITH(NOLOCK)
  ON co.studentid = att.studentid
 AND mem.CALENDARDATE = att.ATT_DATE 
LEFT OUTER JOIN DISC$log#static ed WITH(NOLOCK)
  ON co.studentid = ed.studentid
 AND mem.CALENDARDATE = ed.entry_date
 AND ed.logtypeid = 3953
WHERE co.year = 2014 --dbo.fn_Global_Academic_Year()
  AND co.rn = 1