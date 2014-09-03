USE KIPP_NJ
GO

ALTER VIEW TABLEAU$office_referrals#ES AS

WITH roster AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,co.year
        ,co.schoolid
        ,co.grade_level
        ,s.TEAM
        ,cs.SPEDLEP
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.ID
  LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.STUDENTID
  WHERE co.grade_level < 5
    AND co.rn = 1
 )

SELECT r.*
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
FROM roster r
JOIN DISC$log#static disc WITH(NOLOCK)
  ON r.studentid = disc.studentid
 AND r.year = disc.academic_year
 AND disc.logtypeid = 3123