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
LEFT OUTER JOIN REPORTING$dates dates WITH (NOLOCK)
  ON s.SCHOOLID = dates.schoolid
 AND disc.entry_date BETWEEN dates.start_date AND dates.end_date
 AND disc.academic_year = dates.academic_year
 AND dates.identifier = 'RT' 
WHERE s.rn = 1