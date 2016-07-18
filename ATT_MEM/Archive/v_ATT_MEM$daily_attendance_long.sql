USE KIPP_NJ
GO

ALTER VIEW ATT_MEM$daily_attendance_long AS

SELECT co.school_name AS school
      ,mem.SCHOOLID
      ,co.GRADE_LEVEL      
      ,co.LASTFIRST      
      ,mem.STUDENTID
      ,CONVERT(DATE,mem.CALENDARDATE) AS calendardate
      ,mem.ATTENDANCEVALUE
      ,mem.MEMBERSHIPVALUE
FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON mem.STUDENTID = co.STUDENTID
 AND mem.CALENDARDATE >= co.ENTRYDATE 
 AND mem.CALENDARDATE <= co.EXITDATE
WHERE mem.MEMBERSHIPVALUE = 1