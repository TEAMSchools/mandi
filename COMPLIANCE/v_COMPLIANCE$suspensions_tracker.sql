USE KIPP_NJ
GO

ALTER VIEW TABLEAU$compliance_suspensions AS

SELECT co.SID
      ,co.student_number
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.enroll_status
      ,co.ETHNICITY
      ,co.GENDER
      ,co.SPEDLEP
      ,co.SPED_code
      
      ,att.streak_id 
      ,att.att_code
      ,att.streak_length_membership
      ,att.streak_start
      ,att.streak_end
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ATT_MEM$attendance_streak att WITH(NOLOCK)
  ON co.studentid = att.studentid
 AND co.year = att.academic_year
 AND att.att_code IN ('ISS','OSS')
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1