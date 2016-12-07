USE KIPP_NJ
GO

--ALTER VIEW TABLEAU$tc_dashboard AS

SELECT co.student_number
      ,co.lastfirst
      ,co.year
      ,co.reporting_schoolid
      ,co.schoolid
      ,co.grade_level
      ,co.cohort
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
WHERE co.rn = 1
