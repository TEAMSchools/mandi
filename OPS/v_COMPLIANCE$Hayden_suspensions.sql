USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$Hayden_suspensions AS

SELECT co.reporting_schoolid AS schoolid
      ,co.grade_level
      ,co.gender
      ,co.ETHNICITY
      ,co.spedlep
      ,ISNULL(co.lep_status,'No LEP') AS lep_status
      ,co.year_in_network
      ,co.year      
      ,strk.att_code
      ,strk.studentid
      ,strk.streak_length_membership
FROM ATT_MEM$attendance_streak strk WITH(NOLOCK)
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON strk.studentid = co.studentid
 AND strk.academic_year = co.year
 AND co.rn = 1
WHERE strk.att_code IN ('ISS','OSS','S','OS')