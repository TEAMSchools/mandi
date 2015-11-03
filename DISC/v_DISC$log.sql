USE KIPP_NJ
GO

ALTER VIEW DISC$log AS

WITH disc_log AS (
  SELECT disc.schoolid
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
        ,consequence AS n_days
        ,subtype.logtype
        ,subtype.subtype
        ,disc.subject
        ,NULL AS [entry] -- for real, bro? this field adds on average 7 minutes to the query
        ,details.detail AS discipline_details
        ,action.detail AS actiontaken
        ,follow.detail AS followup  
  FROM KIPP_NJ..DISC$log#STAGING disc WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..DISC$logtypes#static subtype WITH(NOLOCK)
    ON disc.logtypeid = subtype.logtypeid
   AND disc.subtype = subtype.subtypeid
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
  FROM KIPP_NJ..ATT_MEM$PS_ATTENDANCE_MEETING att WITH(NOLOCK)
  JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
    ON att.sectionid = sec.ID
   AND att.schoolid = sec.SCHOOLID
  JOIN KIPP_NJ..PS$SCHOOLSTAFF#static ss WITH(NOLOCK)
    ON sec.TEACHER = ss.ID
  JOIN KIPP_NJ..PS$USERS#static t WITH(NOLOCK)
    ON ss.USERS_DCID = t.DCID
  WHERE att.att_code IN ('T','T10')
    AND att.schoolid = 73253    

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
  FROM KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
  JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
    ON att.STUDENTID = cc.STUDENTID
   AND att.SCHOOLID = cc.SCHOOLID
   AND att.ATT_DATE >= cc.DATEENROLLED
   AND att.ATT_DATE <= cc.DATELEFT
   AND cc.COURSE_NUMBER = 'HR' 
  JOIN KIPP_NJ..PS$SCHOOLSTAFF#static ss WITH(NOLOCK)
    ON cc.TEACHERID = ss.ID
  JOIN KIPP_NJ..PS$USERS#static t WITH(NOLOCK)
    ON ss.USERS_DCID = t.DCID
  WHERE att.att_code IN ('T','T10')
    AND att.schoolid = 73253    
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

  SELECT 73253 AS schoolid
        ,studentid
        ,'Data Robot' AS entry_author
        ,week_of AS entry_date
        ,week_of AS consequence_date
        ,3023 AS logtypeid
        ,99 AS subtypeid
        ,NULL AS n_days
        ,'Merits' AS logtype
        ,'Perfect Week' AS subtype
        ,'No Demerits' AS subject
        ,NULL AS entry
        ,NULL AS discipline_details
        ,NULL AS actiontaken
        ,NULL AS followup
  FROM KIPP_NJ..DISC$perfect_weeks#static WITH(NOLOCK)
  WHERE is_perfect = 1
 )

SELECT *
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year, logtypeid
           ORDER BY CONVERT(DATE,entry_date) DESC) AS rn
FROM
    (
     SELECT CONVERT(INT,all_logs.schoolid) AS schoolid
           ,CONVERT(INT,all_logs.studentid) AS studentid
           ,all_logs.entry_author
           ,dbo.fn_DateToSY(all_logs.entry_date) AS academic_year
           ,CONVERT(DATE,all_logs.entry_date) AS entry_date
           ,CONVERT(DATE,all_logs.consequence_date) AS consequence_date
           ,CONVERT(INT,all_logs.logtypeid) AS logtypeid
           ,CONVERT(INT,all_logs.subtypeid) AS subtypeid
           ,all_logs.n_days
           ,all_logs.logtype
           ,all_logs.subtype
           ,all_logs.subject
           ,all_logs.entry
           ,all_logs.discipline_details
           ,all_logs.actiontaken
           ,all_logs.followup
           ,dates.time_per_name AS RT    
     FROM all_logs WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dates WITH (NOLOCK)
       ON all_logs.entry_date BETWEEN dates.start_date AND dates.end_date
      AND all_logs.schoolid = dates.schoolid
      AND dates.identifier = 'RT'
    ) sub