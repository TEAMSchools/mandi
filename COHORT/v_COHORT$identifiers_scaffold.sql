USE KIPP_NJ
GO

ALTER VIEW COHORT$identifiers_scaffold AS

SELECT co.year
      ,co.schoolid
      ,CONVERT(BIGINT,co.reporting_schoolid) AS reporting_schoolid
      ,co.school_name
      ,co.grade_level
      ,co.studentid
      ,co.student_number
      ,co.lastfirst
      ,co.team
      ,co.advisor
      ,co.GENDER
      ,co.ETHNICITY
      ,co.LUNCHSTATUS
      ,co.SPEDLEP
      ,co.lep_status
      ,co.enroll_status
      ,co.entrydate
      ,co.exitdate
      ,CONVERT(DATE,rd.date) AS date
      ,rd.reporting_hash
      ,dt.alt_name AS term
      ,CASE WHEN CONVERT(DATE,rd.date) BETWEEN co.entrydate AND co.exitdate THEN 1 ELSE 0 END AS is_enrolled
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..UTIL$reporting_days#static rd WITH(NOLOCK)
  ON co.year = rd.academic_year
 AND co.exitdate >= rd.date
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
 AND rd.date BETWEEN dt.start_date AND dt.end_date
WHERE co.schoolid != 999999
  AND co.rn = 1