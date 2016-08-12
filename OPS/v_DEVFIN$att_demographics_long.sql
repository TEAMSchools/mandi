USE KIPP_NJ
GO

ALTER VIEW DEVFIN$att_demographics_long AS

SELECT co.date
      ,co.YEAR AS academic_year
      ,co.SCHOOLID
      ,co.GRADE_LEVEL      
      ,co.STUDENTID
      ,co.ENROLL_STATUS
      ,CONVERT(INT,mem.membershipvalue) AS membershipvalue
      ,CONVERT(INT,mem.attendancevalue) AS attendancevalue
      ,CASE WHEN UPPER(co.spedlep) LIKE '%SPEECH%' THEN 'SPEECH' ELSE co.SPEDLEP END AS SPEDLEP
      ,CASE WHEN co.LEP_STATUS = 1 THEN 'LEP' ELSE 'Not LEP' END AS LEP
      ,co.lunchstatus
      ,co.ethnicity
      ,co.gender
FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)            
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
  ON co.studentid = mem.studentid
 AND co.date = mem.calendardate
 AND mem.calendardate <= CONVERT(DATE,GETDATE())
WHERE co.schoolid != 999999
  AND co.year >= 2013
  AND co.date BETWEEN co.entrydate AND co.exitdate