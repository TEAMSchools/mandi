USE KIPP_NJ
GO

ALTER VIEW DEVFIN$att_demographics_long AS

WITH calendar AS(
  SELECT CONVERT(DATE,date) AS date
  FROM UTIL$reporting_days#static WITH(NOLOCK)
  WHERE date >= '2013-07-01'
    AND date <= GETDATE()
 )

,roster AS(
  SELECT co.schoolid
        ,co.grade_level
        ,co.cohort
        ,co.studentid
        ,co.lastfirst
        ,co.lunchstatus
        ,CASE WHEN UPPER(co.spedlep) LIKE '%SPEECH%' THEN 'SPEECH' ELSE co.SPEDLEP END AS SPEDLEP
        ,co.ethnicity
        ,co.gender
        ,co.year
        ,co.entrydate
        ,co.exitdate
        ,co.ENROLL_STATUS
        ,co.rn
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)  
  WHERE co.schoolid != 999999    
 )

,attendance AS(
  SELECT mem.studentid
        ,CONVERT(DATE,mem.calendardate) AS date
        ,mem.membershipvalue
        ,mem.attendancevalue      
  FROM MEMBERSHIP mem WITH(NOLOCK)
  WHERE mem.calendardate >= '2013-07-01'
    AND mem.calendardate <= GETDATE()
)

SELECT calendar.date
      ,roster.YEAR AS academic_year
      ,roster.SCHOOLID
      ,roster.GRADE_LEVEL
      ,roster.COHORT
      ,roster.STUDENTID      
      ,roster.ENTRYDATE
      ,roster.EXITDATE
      ,roster.ENROLL_STATUS
      ,CONVERT(INT,attendance.membershipvalue) AS membershipvalue
      ,CONVERT(INT,attendance.attendancevalue) AS attendancevalue
      ,roster.SPEDLEP
      ,roster.lunchstatus
      ,roster.ethnicity
      ,roster.gender
FROM calendar WITH(NOLOCK)
JOIN roster WITH(NOLOCK)
  ON calendar.date >= roster.ENTRYDATE
 AND calendar.date <= roster.EXITDATE
LEFT OUTER JOIN attendance WITH(NOLOCK)
  ON calendar.date = attendance.date
 AND roster.studentid = attendance.studentid