USE KIPP_NJ
GO

ALTER VIEW DEVFIN$att_demographics_long AS

WITH calendar AS(
  SELECT CONVERT(DATE,date) AS date
  FROM UTIL$reporting_days WITH(NOLOCK)
  WHERE date >= '2013-07-01' 
    AND date <= '2014-06-30'
)

,roster AS(
  SELECT DISTINCT         
         co.schoolid
        ,co.grade_level        
        ,co.studentid
        ,co.lastfirst
        ,s.lunchstatus
        ,CASE WHEN UPPER(cs.spedlep) LIKE '%SPEECH%' THEN 'SPEECH' ELSE cs.SPEDLEP END AS SPEDLEP
        ,s.ethnicity
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.id
  LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.studentid
  WHERE co.year = 2013
    AND co.schoolid != 999999
    AND co.grade_level != 99
)

,attendance AS(
  SELECT mem.studentid
        ,CONVERT(DATE,mem.calendardate) AS date
        ,mem.membershipvalue
        ,mem.attendancevalue      
  FROM MEMBERSHIP mem WITH(NOLOCK)
  WHERE mem.calendardate >= '2013-07-01'
    AND mem.calendardate <= '2014-06-30'
)

SELECT calendar.date
      ,roster.SCHOOLID
      ,roster.GRADE_LEVEL
      ,roster.STUDENTID
      ,roster.LASTFIRST
      ,CONVERT(FLOAT,ISNULL(attendance.membershipvalue,0)) AS membershipvalue
      ,CONVERT(FLOAT,ISNULL(attendance.attendancevalue,1)) AS attendancevalue
      ,roster.SPEDLEP
      ,roster.lunchstatus
      ,roster.ethnicity
FROM calendar
JOIN roster
  ON 1 = 1  
JOIN attendance
  ON calendar.date = attendance.date
 AND roster.studentid = attendance.studentid