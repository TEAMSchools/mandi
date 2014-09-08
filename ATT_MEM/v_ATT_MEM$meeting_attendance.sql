USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$meeting_attendance AS

SELECT schoolid
      ,studentid
      ,sectionid
      ,CONVERT(DATE,att_date) AS att_date
      ,att_code      
      ,period_abbreviation
FROM OPENQUERY(PS_TEAM,'
  SELECT att.studentid
        ,att.schoolid
        ,att.att_date
        ,att.att_code
        ,att.sectionid
        ,att.period_abbreviation
  FROM PS_ATTENDANCE_meeting att
  JOIN terms
    ON terms.firstday <= att.att_date
   AND terms.lastday >= att.att_date
   AND terms.yearid >= 24
   AND terms.schoolid = att.schoolid
   AND terms.portion = 1
  WHERE att.att_date <= TRUNC(SYSDATE)
    AND att.period_abbreviation NOT IN (''HRA'',''HR'',''P0'')
')