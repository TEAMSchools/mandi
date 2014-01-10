USE KIPP_NJ
GO

ALTER VIEW REPORTING$att_dashboard AS
SELECT 'KIPP NJ' AS Network
      ,CASE
        WHEN s.schoolid IN (73252,73253,73254,73255,73256,133570965) THEN 'Newark'
        ELSE NULL 
       END AS Region
      ,CASE
        WHEN s.schoolid IN (73254,73255,73256) THEN 'ES'
        WHEN s.schoolid IN (73252,133570965) THEN 'MS'
        WHEN s.schoolid IN (73253) THEN 'HS'
       END AS school_level      
      ,s.schoolid
      ,s.lastfirst
      ,s.grade_level
      ,s.team
      ,cs.SPEDLEP
      ,CONVERT(DATE,mem.calendardate) AS att_date
      ,mem.membershipvalue
      ,att.att_code
      ,CASE WHEN att.att_code IS NULL OR att.att_code IN ('PLE','T','TLE','T10','ET','S','SE','NM') THEN 1 ELSE 0 END AS present
      --tardies
      ,CASE WHEN att.att_code IN ('T','TLE','T10','ET') THEN 1 ELSE 0 END AS tardy
      ,CASE WHEN att.att_code IN ('T10') THEN 1 ELSE 0 END AS tardy_10
      --absences
      ,CASE WHEN att.att_code IN ('AD','A','OS','X','D','AE') THEN 1 ELSE 0 END AS absent
      ,CASE WHEN att.att_code IN ('AD','D','AE') THEN 1 ELSE 0 END AS absent_doc
      ,CASE WHEN att.att_code IN ('A','X') THEN 1 ELSE 0 END AS absent_undoc
      --suspensions
      ,CASE WHEN att.att_code IN ('OS','S') THEN 1 ELSE 0 END AS suspension
      ,CASE WHEN att.att_code = 'S' THEN 1 ELSE 0 END AS ISS
      ,CASE WHEN att.att_code = 'OS' THEN 1 ELSE 0 END AS OSS
      --other
      ,CASE WHEN att.att_code IN ('TLE','PLE') THEN 1 ELSE 0 END AS early_dismissal
FROM STUDENTS s WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.studentid
JOIN MEMBERSHIP mem WITH(NOLOCK)
  ON s.id = mem.studentid
 AND s.schoolid = mem.schoolid
LEFT OUTER JOIN ATTENDANCE att WITH(NOLOCK)
  ON s.id = att.studentid
 AND mem.CALENDARDATE = att.ATT_DATE 
WHERE s.enroll_status = 0