USE KIPP_NJ
GO

ALTER VIEW DEVFIN$att_demographics_long AS

WITH calendar AS(
  SELECT CONVERT(DATE,date) AS date
  FROM UTIL$reporting_days WITH(NOLOCK)
  WHERE date >= '2004-07-01'
    AND date <= GETDATE()
 )

,roster AS(
  SELECT co.schoolid
        ,co.grade_level
        ,co.cohort
        ,co.studentid
        ,co.lastfirst
        ,CASE WHEN dbo.fn_Global_Academic_Year() = co.YEAR THEN s.lunchstatus ELSE lunch.lunch_status END AS lunchstatus
        ,CASE WHEN UPPER(cs.spedlep) LIKE '%SPEECH%' THEN 'SPEECH' ELSE cs.SPEDLEP END AS SPEDLEP
        ,s.ethnicity
        ,s.gender
        ,co.year
        ,co.entrydate
        ,co.exitdate
        ,s.ENROLL_STATUS
        ,co.rn
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.id
  LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.studentid
  LEFT OUTER JOIN PS$lunch_status_long lunch WITH(NOLOCK)
    ON co.studentid = lunch.studentid
   AND co.YEAR = lunch.year
  WHERE co.schoolid != 999999
    AND co.grade_level != 99
 )

,attendance AS(
  SELECT mem.studentid
        ,CONVERT(DATE,mem.calendardate) AS date
        ,mem.membershipvalue
        ,mem.attendancevalue      
  FROM MEMBERSHIP mem WITH(NOLOCK)
  WHERE mem.calendardate >= '2004-07-01'
    AND mem.calendardate <= GETDATE()
)

SELECT calendar.date
      ,roster.YEAR AS academic_year
      ,roster.SCHOOLID
      ,roster.GRADE_LEVEL
      ,roster.COHORT
      ,roster.STUDENTID
      --,roster.LASTFIRST
      ,roster.ENTRYDATE
      ,roster.EXITDATE
      ,roster.ENROLL_STATUS
      ,CONVERT(INT,attendance.membershipvalue) AS membershipvalue
      ,CONVERT(INT,attendance.attendancevalue) AS attendancevalue
      ,roster.SPEDLEP
      ,roster.lunchstatus
      ,roster.ethnicity
      ,roster.gender
FROM calendar
JOIN roster
  ON calendar.date >= roster.ENTRYDATE
 AND calendar.date <= roster.EXITDATE
LEFT OUTER JOIN attendance
  ON calendar.date = attendance.date
 AND roster.studentid = attendance.studentid