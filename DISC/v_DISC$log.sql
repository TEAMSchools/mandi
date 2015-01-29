USE KIPP_NJ
GO

ALTER VIEW DISC$log AS

WITH disc_log AS (
  SELECT disc.schoolid
        ,CAST(disc.studentid AS INT) AS studentid        
        ,disc.entry_author        
        ,CASE 
          WHEN CONVERT(DATE,disc.discipline_incidentdate) = '1900-01-01' THEN CONVERT(DATE,disc.entry_date) 
          WHEN disc.logtypeid IN (3023, 3223) OR schoolid = 73253 THEN CONVERT(DATE,disc.entry_date) 
          ELSE CONVERT(DATE,disc.discipline_incidentdate) 
         END AS entry_date
        ,CONVERT(DATE,disc.entry_date) AS consequence_date
        ,disc.logtypeid      
        ,disc.subtype AS subtypeid
        ,consequence AS n_days
        ,subtype.logtype
        ,subtype.subtype
        ,disc.subject
        ,disc.entry
        ,details.detail AS discipline_details
        ,action.detail AS actiontaken
        ,follow.detail AS followup
  FROM OPENQUERY(PS_TEAM,'
    SELECT studentid
          ,schoolid
          ,entry_author
          ,entry_date
          ,discipline_incidentdate
          ,logtypeid
          ,subtype
          ,subject
          ,entry
          ,discipline_incidenttype
          ,Discipline_ActionTaken
          ,Discipline_ActionTakendetail
          ,consequence
    FROM log
    WHERE (log.entry_date >= TO_DATE(''2014-08-01'',''YYYY-MM-DD'') OR log.discipline_incidentdate >= TO_DATE(''2014-08-01'',''YYYY-MM-DD''))
      AND log.entry_date <= TRUNC(SYSDATE)
      AND log.logtypeid NOT IN (1423, 2724, 3124, 3964)
  ') disc /*-- UPDATE QUERY FOR CURRENT SCHOOL YEAR --*/
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
 )

,tardy_demerits AS (
  SELECT att.schoolid
        ,att.studentid
        ,t.LASTFIRST AS entry_author                
        ,CONVERT(DATE,att_date) AS entry_date
        ,NULL AS consequence_date
        ,3223 AS logtypeid
        ,06 AS subtypeid
        ,NULL AS n_days
        ,'Demerits' AS logtype
        ,'Tardy' AS subtype
        ,'Late to Class' AS subject
        ,NULL AS entry
        ,'Late to Class' AS discipline_details
        ,NULL AS actiontaken
        ,NULL AS followup      
  FROM ATT_MEM$meeting_attendance#static att WITH(NOLOCK)
  JOIN sections sec WITH(NOLOCK)
    ON att.sectionid = sec.ID
  JOIN teachers t WITH(NOLOCK)
    ON sec.TEACHER = t.ID
  WHERE att.att_code IN ('T','T10')
    AND att.schoolid = 73253
    AND att.ATT_DATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01')

  UNION ALL

  SELECT att.schoolid
        ,att.studentid
        ,t.LASTFIRST AS entry_author        
        ,CONVERT(DATE,att_date) AS entry_date
        ,NULL AS consequence_date
        ,3223 AS logtypeid
        ,06 AS subtypeid
        ,NULL AS n_days
        ,'Demerits' AS logtype
        ,'Tardy' AS subtype
        ,'Late to School' AS subject
        ,NULL AS entry
        ,'Late to School' AS discipline_details
        ,NULL AS actiontaken
        ,NULL AS followup      
  FROM ATTENDANCE att WITH(NOLOCK)
  JOIN CC WITH(NOLOCK)
    ON att.STUDENTID = cc.STUDENTID
   AND att.ATT_DATE >= cc.DATEENROLLED
   AND att.ATT_DATE <= cc.DATELEFT
   AND cc.COURSE_NUMBER = 'HR' 
  JOIN teachers t WITH(NOLOCK)
    ON cc.TEACHERID = t.ID
  WHERE att.att_code IN ('T','T10')
    AND att.schoolid = 73253
    AND att.ATT_DATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01')
 )

,TEAM_bench AS (
  SELECT 133570965 AS schoolid
        ,CONVERT(INT,[student_number]) AS studentid
        ,CONVERT(VARCHAR,[Teacher]) AS entry_author        
        ,CASE WHEN ISDATE([Date]) = 1 THEN CONVERT(DATE,[Date]) ELSE NULL END AS entry_date
        ,NULL AS consequence_date
        ,-100000 AS logtypeid
        ,CASE 
          WHEN [Bench/ISS/OSS] = 'OSS' THEN 6
          WHEN [Bench/ISS/OSS] = 'ISS' THEN 5
          WHEN [Bench/ISS/OSS] = 'Bench' THEN 4
         END AS subtypeid
        ,CONVERT(VARCHAR,[Days on ]) AS n_days
        ,'Discipline (MS/HS)' AS logtype
        ,CONVERT(VARCHAR,[Bench/ISS/OSS]) AS subtype
        ,CONVERT(VARCHAR,[Bench/ISS/OSS]) AS subject        
        ,CONVERT(VARCHAR,ISNULL('Approved with: ' + CONVERT(VARCHAR,[Approved With] + CHAR(10) + CHAR(13)), '')
          + ISNULL('Location: ' + CONVERT(VARCHAR,[Class and Time of Day] + CHAR(10) + CHAR(13)), '')
          + ISNULL('Descr: ' + CONVERT(VARCHAR,[Description] + CHAR(10) + CHAR(13)), '')
          + ISNULL('Parent Contact: ' + CONVERT(VARCHAR,[Parent Contact] + CHAR(10) + CHAR(13)), '')
          + ISNULL('Off Bench: ' + CONVERT(VARCHAR,[Date off the Bench],101), ''))
          AS entry
        ,NULL AS discipline_details
        ,NULL AS actiontaken
        ,NULL AS followup      
  FROM [dbo].[AUTOLOAD$GDOCS_MISC_TEAM_Bench_Log] log WITH(NOLOCK)
  WHERE student_number IS NOT NULL
 )

,all_logs AS (
  SELECT schoolid
        ,studentid
        ,entry_author        
        ,entry_date
        ,consequence_date
        ,logtypeid
        ,subtypeid
        ,n_days
        ,logtype
        ,subtype
        ,subject
        ,entry
        ,discipline_details
        ,actiontaken
        ,followup
  FROM disc_log WITH(NOLOCK)  
  UNION ALL
  SELECT schoolid
        ,studentid
        ,entry_author        
        ,entry_date
        ,consequence_date
        ,logtypeid
        ,subtypeid
        ,n_days
        ,logtype
        ,subtype
        ,subject
        ,entry
        ,discipline_details
        ,actiontaken
        ,followup
  FROM tardy_demerits WITH(NOLOCK)
  UNION ALL
  SELECT schoolid
        ,studentid
        ,entry_author
        ,entry_date
        ,consequence_date
        ,logtypeid
        ,subtypeid
        ,n_days
        ,logtype
        ,subtype
        ,subject
        ,entry
        ,discipline_details
        ,actiontaken
        ,followup
  FROM TEAM_bench WITH(NOLOCK)
 )

SELECT all_logs.schoolid
      ,all_logs.studentid
      ,all_logs.entry_author
      ,dbo.fn_DateToSY(all_logs.entry_date) AS academic_year
      ,all_logs.entry_date
      ,all_logs.consequence_date
      ,all_logs.logtypeid
      ,all_logs.subtypeid
      ,all_logs.n_days
      ,all_logs.logtype
      ,all_logs.subtype
      ,all_logs.subject
      ,all_logs.entry
      ,all_logs.discipline_details
      ,all_logs.actiontaken
      ,all_logs.followup
      ,dates.time_per_name AS RT
      ,ROW_NUMBER() OVER(
          PARTITION BY studentid, logtypeid
              ORDER BY entry_date DESC) AS rn
FROM all_logs WITH(NOLOCK)
LEFT OUTER JOIN REPORTING$dates dates WITH (NOLOCK)
  ON all_logs.entry_date >= dates.start_date
 AND all_logs.entry_date <= dates.end_date
 AND all_logs.schoolid = dates.schoolid
 AND dates.identifier = 'RT'