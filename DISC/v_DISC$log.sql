USE KIPP_NJ
GO

ALTER VIEW DISC$log AS

WITH all_logs AS (
  SELECT DCID
        ,schoolid
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
        ,NULL AS point_value
        ,NULL AS period
  FROM KIPP_NJ..DISC$log_clean#static WITH(NOLOCK)  

  UNION ALL
  
  SELECT NULL AS DCID
        ,schoolid
        ,studentid
        ,entry_author        
        ,entry_date
        ,NULL AS consequence_date
        ,logtypeid
        ,subtypeid
        ,NULL AS n_days
        ,logtype
        ,subtype
        ,subject
        ,NULL AS entry
        ,discipline_details
        ,NULL AS actiontaken
        ,NULL AS followup
        ,NULL AS point_value
        ,NULL AS period
  FROM KIPP_NJ..DISC$tardy_demerits#static WITH(NOLOCK)
  
  UNION ALL

  SELECT NULL AS DCID
        ,73253 AS schoolid
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
        ,NULL AS point_value
        ,NULL AS period
  FROM KIPP_NJ..DISC$perfect_weeks#static WITH(NOLOCK)
  WHERE is_perfect = 1

  UNION ALL 

  SELECT NULL AS DCID
        ,schoolid
        ,studentid
        ,entry_author        
        ,entry_date
        ,NULL AS consequence_date
        ,NULL AS logtypeid
        ,NULL AS subtypeid
        ,NULL AS n_days
        ,logtype
        ,subtype
        ,subject
        ,NULL AS entry
        ,NULL AS discipline_details
        ,NULL AS actiontaken
        ,NULL AS followup
        ,point_value
        ,period
  FROM KIPP_NJ..DISC$kickboard_logs#static WITH(NOLOCK)
 )

SELECT DCID
      ,schoolid
      ,studentid
      ,entry_author
      ,academic_year
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
      ,point_value
      ,period
      ,RT
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year, logtypeid
           ORDER BY CONVERT(DATE,entry_date) DESC) AS rn
FROM
    (
     SELECT CONVERT(INT,all_logs.DCID) AS DCID
           ,CONVERT(INT,all_logs.schoolid) AS schoolid
           ,CONVERT(INT,all_logs.studentid) AS studentid
           ,all_logs.entry_author
           ,KIPP_NJ.dbo.fn_DateToSY(all_logs.entry_date) AS academic_year
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
           ,all_logs.point_value
           ,all_logs.period
           ,dates.time_per_name AS RT    
     FROM all_logs WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_REP_reporting_dates dates WITH(NOLOCK)
       ON all_logs.entry_date BETWEEN dates.start_date AND dates.end_date
      AND all_logs.schoolid = dates.schoolid
      AND dates.identifier = 'RT'
    ) sub