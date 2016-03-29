USE KIPP_NJ
GO

ALTER VIEW DISC$log_clean AS 

SELECT disc.DCID
      ,disc.schoolid
      ,CAST(disc.studentid AS INT) AS studentid        
      ,disc.entry_author        
      ,CASE
        WHEN disc.entry_date = '0000-00-00' THEN CONVERT(DATE,disc.discipline_incidentdate)
        WHEN CONVERT(DATE,disc.discipline_incidentdate) = '1900-01-01' THEN CONVERT(DATE,disc.entry_date) 
        WHEN disc.logtypeid IN (3023, 3223) OR disc.schoolid = 73253 THEN CONVERT(DATE,disc.entry_date) 
        WHEN CONVERT(DATE,disc.discipline_incidentdate) >= CONVERT(DATE,GETDATE()) THEN CONVERT(DATE,disc.entry_date)
        ELSE CONVERT(DATE,disc.discipline_incidentdate) 
       END AS entry_date
      ,CASE 
        WHEN disc.entry_date = '0000-00-00' THEN NULL
        WHEN disc.SCHOOLID = 73253 THEN CONVERT(DATE,disc.discipline_incidentdate) 
        ELSE CONVERT(DATE,disc.entry_date) 
       END AS consequence_date
      ,disc.logtypeid      
      ,disc.subtype AS subtypeid
      ,CASE WHEN ISNUMERIC(consequence) = 0 THEN NULL ELSE CONSEQUENCE END AS n_days
      ,logtype.logtype
      ,subtype.subtype
      ,disc.subject
      ,NULL AS [entry] -- for real, bro? this field adds on average 7 minutes to the query
      ,details.detail AS discipline_details
      ,action.detail AS actiontaken
      ,follow.detail AS followup  
FROM KIPP_NJ..DISC$log#STAGING disc WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..DISC$logtypes#static logtype WITH(NOLOCK)
  ON disc.logtypeid = logtype.logtypeid   
LEFT OUTER JOIN KIPP_NJ..DISC$subtypes#static subtype WITH(NOLOCK)
  ON disc.logtypeid = subtype.logtypeid   
 AND disc.SUBTYPE = subtype.subtypeid   
LEFT OUTER JOIN KIPP_NJ..DISC$entrycodes#static details WITH(NOLOCK)
  ON disc.discipline_incidenttype = details.code
 AND details.field = 'discipline_incidenttype'
LEFT OUTER JOIN KIPP_NJ..DISC$entrycodes#static action WITH(NOLOCK)
  ON disc.discipline_incidenttype = action.code
 AND action.field = 'discipline_actiontaken'
LEFT OUTER JOIN KIPP_NJ..DISC$entrycodes#static follow WITH(NOLOCK)
  ON disc.discipline_incidenttype = follow.code
 AND follow.field = 'discipline_actiontakendetail'
WHERE (ISDATE(disc.ENTRY_DATE) = 1 OR ISDATE(disc.discipline_incidentdate) = 1)