USE KIPP_NJ
GO

ALTER VIEW REPORTING$choices_feed#NCA AS

SELECT s.LASTFIRST AS Name
      ,s.GRADE_LEVEL AS Gr
      ,s.Advisor      
      ,dates.alt_name AS Term
      ,DATENAME(MONTH,disc.entry_date) AS [Demerit Cycle]
      ,CONVERT(VARCHAR,disc.entry_date,101) AS [Log Date]
      ,disc.entry_author AS [Log Author]
      ,disc.logtype AS [Type]
      ,disc.Subtype
      ,disc.subject
      ,disc.rn AS [Count]
FROM KIPP_NJ..COHORT$identifiers_long#static s WITH (NOLOCK)
JOIN KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
  ON s.studentid = disc.studentid
 --AND disc.logtype IS NOT NULL
 AND s.year = disc.academic_year
JOIN KIPP_NJ..REPORTING$dates dates WITH(NOLOCK)
  ON disc.entry_date >= dates.start_date
 AND disc.entry_date <= dates.end_date
 AND dates.identifier = 'RT'
 AND s.SCHOOLID = dates.schoolid
WHERE s.SCHOOLID = 73253
  AND s.ENROLL_STATUS = 0
  AND s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND s.rn = 1