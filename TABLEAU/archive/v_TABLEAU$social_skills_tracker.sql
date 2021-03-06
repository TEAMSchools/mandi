USE KIPP_NJ
GO

ALTER VIEW TABLEAU$social_skills_tracker AS

SELECT co.year
      ,co.student_number      
      ,co.school_name
      ,co.lastfirst
      ,co.grade_level
      ,co.TEAM
      ,co.SPEDLEP
      ,soc.term
      ,soc.soc_skill
      ,soc.score
      ,supp.behavior_tier
      ,supp.plan_owner
      ,supp.admin_support
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..REPORTING$social_skills#ES soc WITH(NOLOCK)
  ON co.student_number = soc.student_number
LEFT OUTER JOIN AUTOLOAD$GDOCS_SUPPORT_Master_List supp WITH(NOLOCK)
  ON co.student_number = supp.SN
WHERE co.rn = 1
  AND co.grade_level < 5