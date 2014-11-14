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
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN DISC$log#static disc WITH(NOLOCK)
  ON co.studentid = disc.studentid
 AND co.year = disc.academic_year
 AND disc.logtypeid = 3123
WHERE co.grade_level < 5
  AND co.rn = 1