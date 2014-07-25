USE KIPP_NJ
GO

ALTER VIEW DISC$recent_incidents_wide AS
SELECT s.id AS studentid
      --this logtypeid determines what type of log goes into the rest of the row, see JOIN for the logic
      ,CASE
        WHEN dlog01.logtypeid = 3023 THEN 'Merit'
        WHEN dlog01.logtypeid = 3223 THEN 'Demerit'
        WHEN dlog01.logtypeid = -100000 THEN 'Discipline'
       END AS log_type
      
      --DISC_01      
      ,SUBSTRING(dlog01.entry_author,1,CHARINDEX(',',dlog01.entry_author+',')-1) AS DISC_01_given_by
      ,CONVERT(DATE,dlog01.entry_date) AS DISC_01_date_reported
      ,dlog01.subject AS DISC_01_subject
      ,dlog01.subtype AS DISC_01_subtype
      ,dlog01.incident_decoded AS DISC_01_incident
      
      --DISC_02
      ,SUBSTRING(dlog02.entry_author,1,CHARINDEX(',',dlog02.entry_author+',')-1) AS DISC_02_given_by      
      ,CONVERT(DATE,dlog02.entry_date) AS DISC_02_date_reported
      ,dlog02.subject AS DISC_02_subject
      ,dlog02.subtype AS DISC_02_subtype
      ,dlog02.incident_decoded AS DISC_02_incident
      
      --DISC_03
      ,SUBSTRING(dlog03.entry_author,1,CHARINDEX(',',dlog03.entry_author+',')-1) AS DISC_03_given_by      
      ,CONVERT(DATE,dlog03.entry_date) AS DISC_03_date_reported
      ,dlog03.subject AS DISC_03_subject
      ,dlog03.subtype AS DISC_03_subtype
      ,dlog03.incident_decoded AS DISC_03_incident
      
      --DISC_04
      ,SUBSTRING(dlog04.entry_author,1,CHARINDEX(',',dlog04.entry_author+',')-1) AS DISC_04_given_by      
      ,CONVERT(DATE,dlog04.entry_date) AS DISC_04_date_reported
      ,dlog04.subject AS DISC_04_subject
      ,dlog04.subtype AS DISC_04_subtype
      ,dlog04.incident_decoded AS DISC_04_incident
      
      --DISC_05
      ,SUBSTRING(dlog05.entry_author,1,CHARINDEX(',',dlog05.entry_author+',')-1) AS DISC_05_given_by      
      ,CONVERT(DATE,dlog05.entry_date) AS DISC_05_date_reported
      ,dlog05.subject AS DISC_05_subject
      ,dlog05.subtype AS DISC_05_subtype
      ,dlog05.incident_decoded AS DISC_05_incident
      
FROM STUDENTS s WITH (NOLOCK)
LEFT OUTER JOIN DISC$log#static dlog01 WITH (NOLOCK)
  ON s.id = dlog01.studentid
 AND dlog01.rn = 1
LEFT OUTER JOIN DISC$log#static dlog02 WITH (NOLOCK)
  ON s.id = dlog02.studentid
 AND dlog02.rn = 2
 AND dlog01.logtypeid = dlog02.logtypeid
LEFT OUTER JOIN DISC$log#static dlog03 WITH (NOLOCK)
  ON s.id = dlog03.studentid
 AND dlog03.rn = 3
 AND dlog02.logtypeid = dlog03.logtypeid
LEFT OUTER JOIN DISC$log#static dlog04 WITH (NOLOCK)
  ON s.id = dlog04.studentid
 AND dlog04.rn = 4
 AND dlog03.logtypeid = dlog04.logtypeid
LEFT OUTER JOIN DISC$log#static dlog05 WITH (NOLOCK)
  ON s.id = dlog05.studentid
 AND dlog05.rn = 5
 AND dlog04.logtypeid = dlog05.logtypeid
WHERE s.enroll_status = 0