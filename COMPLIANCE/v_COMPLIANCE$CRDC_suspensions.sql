USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$CRDC_suspensions AS

SELECT att.academic_year
      ,att.schoolid      
      ,att.streak_id
      ,att.att_code
      ,att.streak_length_membership
      ,co.student_number
      ,co.GENDER
      ,co.ETHNICITY
      ,co.SPEDLEP
      ,co.SPED_code
      ,co.STATUS_504
      ,co.LEP_STATUS
FROM KIPP_NJ..ATT_MEM$attendance_streak att WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON att.studentid = co.studentid
 AND att.streak_start BETWEEN co.entrydate AND co.exitdate
WHERE att_code IN ('OSS','ISS')