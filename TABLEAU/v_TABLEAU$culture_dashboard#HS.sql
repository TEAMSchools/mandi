USE KIPP_NJ
GO

ALTER VIEW TABLEAU$culture_dashboard#HS AS

SELECT s.LASTFIRST AS Name
      ,s.GRADE_LEVEL AS Gr
      ,s.TEAM
      ,s.gender
      ,s.Advisor      
      ,s.year AS academic_year
      ,dates.alt_name AS term
      ,CONVERT(VARCHAR,disc.entry_date,101) AS [Log Date]
      ,disc.entry_author AS [Log Author]
      ,CASE
        WHEN disc.logtypeid = -100000 THEN 'Discipline'
        WHEN disc.logtypeid = 3023 THEN 'Merit'
        WHEN disc.logtypeid = 3223 THEN 'Demerit'
       END AS [Type]
      ,disc.Subtype
      ,disc.rn AS [Count]
      ,s.schoolid
      ,(SELECT DISTINCT DATEADD(DAY,-1,MAX(CONVERT(DATE,CALENDARDATE))) FROM KIPP_NJ..ATT_MEM$MEMBERSHIP WITH(NOLOCK)) AS last_date
FROM COHORT$identifiers_long#static s WITH(NOLOCK)
JOIN DISC$log#static disc WITH (NOLOCK)
  ON s.studentid = disc.studentid
 AND s.schoolid = disc.schoolid
 AND s.year = disc.academic_year
JOIN REPORTING$dates dates WITH (NOLOCK)
  ON disc.entry_date >= dates.start_date
 AND disc.entry_date <= dates.end_date
 AND disc.academic_year = dates.academic_year
 AND dates.identifier = 'RT'
 AND s.SCHOOLID = dates.schoolid
WHERE s.SCHOOLID IN (73253,73252,133570965)
  --AND s.year = dbo.fn_Global_Academic_Year()
  AND s.ENROLL_STATUS = 0
  AND s.rn = 1