USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$daily_absentee_report AS

SELECT CONVERT(DATE,att.att_date) AS att_date
      ,s.SCHOOLID
      ,s.GRADE_LEVEL
      ,s.Team
      ,s.LASTFIRST
      ,att.Att_Code
FROM OPENQUERY(PS_TEAM,'
  SELECT studentid        
        ,att_code
        ,att_date
  FROM PS_ATTENDANCE_DAILY
  WHERE att_date = TRUNC(SYSDATE)
    AND att_mode_code = ''ATT_ModeDaily''    
') att
JOIN STUDENTS s WITH(NOLOCK)
  ON att.studentid = s.ID