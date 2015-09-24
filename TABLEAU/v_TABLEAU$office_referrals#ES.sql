USE KIPP_NJ
GO

ALTER VIEW TABLEAU$office_referrals#ES AS

SELECT co.studentid
      ,co.STUDENT_NUMBER
      ,co.lastfirst
      ,co.year
      ,co.schoolid
      ,co.grade_level
      ,co.TEAM
      ,co.SPEDLEP
      ,co.GENDER
      ,disc.entry_author
      ,disc.entry_date
      ,disc.consequence_date
      ,disc.logtype
      ,disc.subtype
      ,disc.n_days
      ,disc.subject
      ,disc.entry      
      ,disc.discipline_details
      ,disc.actiontaken
      ,disc.followup
      ,disc.RT
      ,supp.behavior_tier
      ,supp.plan_owner
      ,supp.admin_support
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
  ON co.studentid = disc.studentid
 AND co.year = disc.academic_year
 AND disc.logtypeid = 3123
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_SUPPORT_Master_List supp WITH(NOLOCK)
  ON co.student_number = supp.SN
 AND co.year = supp.academic_year
WHERE co.grade_level < 5  
  AND co.rn = 1  