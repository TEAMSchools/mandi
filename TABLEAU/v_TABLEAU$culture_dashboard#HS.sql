USE KIPP_NJ
GO

ALTER VIEW TABLEAU$culture_dashboard#HS AS

SELECT s.LASTFIRST AS Name
      ,s.GRADE_LEVEL AS Gr
      ,cs.Advisor      
      ,CASE
        WHEN dates.time_per_name = 'RT1' THEN 'Q1'
        WHEN dates.time_per_name = 'RT2' THEN 'Q2'
        WHEN dates.time_per_name = 'RT3' THEN 'Q3'        
        WHEN dates.time_per_name = 'RT4' THEN 'Q4'
       END AS Term
      ,CONVERT(VARCHAR,disc.entry_date,101) AS [Log Date]
      ,disc.entry_author AS [Log Author]
      ,CASE
        WHEN disc.logtypeid = -100000 THEN 'Discipline'
        WHEN disc.logtypeid = 3023 THEN 'Merit'
        WHEN disc.logtypeid = 3223 THEN 'Demerit'
       END AS [Type]
      ,disc.Subtype
      ,disc.rn AS [Count]
FROM STUDENTS s WITH (NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
  ON s.ID = cs.STUDENTID
JOIN DISC$log#static disc WITH (NOLOCK)
  ON s.ID = disc.studentid
JOIN REPORTING$dates dates WITH (NOLOCK)
  ON disc.entry_date >= dates.start_date
AND disc.entry_date <= dates.end_date
AND dates.identifier = 'RT'
AND s.SCHOOLID = dates.schoolid
WHERE s.SCHOOLID = 73253
  AND s.ENROLL_STATUS = 0