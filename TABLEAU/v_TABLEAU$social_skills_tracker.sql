USE KIPP_NJ
GO

ALTER VIEW TABLEAU$social_skills_tracker AS

SELECT co.student_number      
      ,co.school_name
      ,co.lastfirst
      ,co.grade_level
      ,co.TEAM
      ,co.SPEDLEP
      ,soc.term
      ,soc.soc_skill
      ,soc.score
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN ILLUMINATE$social_skills#ES soc WITH(NOLOCK)
  ON co.student_number = soc.student_number
WHERE co.year = dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.grade_level < 5