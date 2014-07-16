USE KIPP_NJ
GO

ALTER VIEW DISC$log AS

SELECT disc.schoolid
      ,CAST(studentid AS INT) AS studentid
      ,entry_author
      ,CONVERT(DATE,entry_date) AS entry_date
      ,CONVERT(DATE,discipline_incidentdate) AS consequence_date
      ,disc.logtypeid      
      ,consequence
      ,subtype.subtype
      ,details.detail AS discipline_details
      ,action.detail AS actiontaken
      ,follow.detail AS followup
      ,dates.time_per_name AS RT
      ,ROW_NUMBER() OVER(
          PARTITION BY studentid, disc.logtypeid
              ORDER BY entry_date DESC) AS rn
FROM OPENQUERY(PS_TEAM,'
  SELECT studentid
        ,schoolid
        ,entry_author
        ,entry_date
        ,discipline_incidentdate
        ,logtypeid
        ,subtype
        ,discipline_incidenttype
        ,Discipline_ActionTaken
        ,Discipline_ActionTakendetail
        ,consequence
  FROM log
  WHERE log.entry_date >= TO_DATE(CASE
                                   WHEN TO_CHAR(SYSDATE,''MON'') IN (''JAN'',''FEB'',''MAR'',''APR'',''MAY'',''JUN'',''JUL'')
                                   THEN TO_CHAR(TO_CHAR(SYSDATE,''YYYY'') - 1)
                                   ELSE TO_CHAR(SYSDATE,''YYYY'')
                                  END || ''-08-01'',''YYYY-MM-DD'')
    AND log.entry_date <= TRUNC(SYSDATE)
    AND logtypeid NOT IN (1423, 2724, 3124, 3953)
') disc
LEFT OUTER JOIN DISC$logtypes#static subtype WITH(NOLOCK)
  ON disc.logtypeid = subtype.logtypeid
 AND disc.subtype = subtype.subtypeid
LEFT OUTER JOIN DISC$entrycodes#static details WITH(NOLOCK)
  ON disc.discipline_incidenttype = details.code
 AND details.field = 'discipline_incidenttype'
LEFT OUTER JOIN DISC$entrycodes#static action WITH(NOLOCK)
  ON disc.discipline_incidenttype = action.code
 AND action.field = 'discipline_actiontaken'
LEFT OUTER JOIN DISC$entrycodes#static follow WITH(NOLOCK)
  ON disc.discipline_incidenttype = follow.code
 AND follow.field = 'discipline_actiontakendetail'
LEFT OUTER JOIN REPORTING$dates dates WITH (NOLOCK)
  ON disc.entry_date >= dates.start_date
 AND disc.entry_date <= dates.end_date
 AND disc.schoolid = dates.schoolid
 AND dates.identifier = 'RT'