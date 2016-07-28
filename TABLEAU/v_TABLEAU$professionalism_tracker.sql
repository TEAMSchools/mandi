USE KIPP_NJ
GO

ALTER VIEW TABLEAU$professionalism_tracker AS

WITH prof_calendar AS (
  SELECT sub.*
        ,CASE           
          WHEN sub.schoolid = 179901 THEN 'Lanning Square Primary'
          WHEN sub.schoolid = 73257 THEN 'Life Academy'          
          WHEN sub.schoolid = 73256 THEN 'Seek Academy'
          WHEN sub.schoolid = 73254 THEN 'SPARK Academy'
          WHEN sub.schoolid = 73255 THEN 'THRIVE Academy'
         END AS school_name
        ,dt.alt_name AS term
  FROM 
      (
       SELECT schoolid
             ,academic_year
             ,date_value
       FROM KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
       WHERE cal.academic_year >= 2015
         AND cal.insession = 1
         AND cal.date_value <= CONVERT(DATE,GETDATE())
       UNION
       SELECT DISTINCT
              73254 AS schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_spark_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              73255 AS schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_thrive_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              73256 AS schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_seek_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              73257 AS schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_life_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              179901 AS schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_lsp_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT schoolid
             ,academic_year
             ,date_value
       FROM KIPP_NJ..PROF$additional_dates#archive WITH(NOLOCK)
      ) sub
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON sub.schoolid = dt.schoolid
   AND sub.date_value BETWEEN dt.start_date AND dt.end_date   
   AND dt.identifier = 'RT'   
 )

,staff_roster AS (
  SELECT associate_id
        ,CONCAT(preferred_last_name, ', ', preferred_first_name) AS preferred_lastfirst
        ,location
        ,job_title
        ,manager
        ,email_addr
        ,position_start_date
  FROM
      (
       SELECT adp.associate_id 
             ,adp.preferred_first AS preferred_first_name 
             ,adp.preferred_last AS preferred_last_name       
             ,adp.location
             ,adp.department
             ,adp.job_title
             ,adp.reports_to AS manager
             ,adp.position_start_date
             ,dir.mail AS email_addr       
       FROM KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK) 
       LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static dir 
         ON adp.position_id = dir.employeenumber 
       WHERE rn_curr = 1
         AND adp.position_status != 'Terminated'
      ) sub
 )

,clean_trackers AS (
  SELECT 73254 AS schoolid
        ,[staff_name]
        ,CONVERT(DATE,[date]) AS date
        ,CONVERT(VARCHAR,[present]) AS present
        ,CONVERT(VARCHAR,[on_time]) AS on_time
        ,CONVERT(VARCHAR,[attire]) AS attire
        ,CONVERT(VARCHAR,[lp]) AS lp
        ,CONVERT(VARCHAR,[gr_lp]) AS gr_lp
        ,CONVERT(VARCHAR(256),[notes_optional]) AS notes
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROF_spark_data_entry] WITH(NOLOCK)
  UNION ALL
  SELECT 73255 AS schoolid
        ,[staff_name]
        ,CONVERT(DATE,[date]) AS date
        ,CONVERT(VARCHAR,[present]) AS present
        ,CONVERT(VARCHAR,[on_time]) AS on_time
        ,CONVERT(VARCHAR,[attire]) AS attire
        ,CONVERT(VARCHAR,[lp]) AS lp
        ,CONVERT(VARCHAR,[gr_lp]) AS gr_lp
        ,CONVERT(VARCHAR(256),[notes_optional]) AS notes
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROF_thrive_data_entry] WITH(NOLOCK)
  UNION ALL
  SELECT 73256 AS schoolid
        ,[staff_name]
        ,CONVERT(DATE,[date]) AS date
        ,CONVERT(VARCHAR,[present]) AS present
        ,CONVERT(VARCHAR,[on_time]) AS on_time
        ,CONVERT(VARCHAR,[attire]) AS attire
        ,CONVERT(VARCHAR,[lp]) AS lp
        ,CONVERT(VARCHAR,[gr_lp]) AS gr_lp
        ,CONVERT(VARCHAR(256),[notes_optional]) AS notes
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROF_seek_data_entry] WITH(NOLOCK)
  UNION ALL
  --/*
  SELECT 73257 AS schoolid
        ,[staff_name]
        ,CONVERT(DATE,[date]) AS date
        ,CONVERT(VARCHAR,[present]) AS present
        ,CONVERT(VARCHAR,[on_time]) AS on_time
        ,CONVERT(VARCHAR,[attire]) AS attire
        ,CONVERT(VARCHAR,[lp]) AS lp
        ,CONVERT(VARCHAR,[gr_lp]) AS gr_lp
        ,CONVERT(VARCHAR(256),[notes_optional]) AS notes
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROF_life_data_entry] WITH(NOLOCK)
  UNION ALL
  --*/
  SELECT 179901 AS schoolid
        ,[staff_name]
        ,CONVERT(DATE,[date]) AS date
        ,CONVERT(VARCHAR,[present]) AS present
        ,CONVERT(VARCHAR,[on_time]) AS on_time
        ,CONVERT(VARCHAR,[attire]) AS attire
        ,CONVERT(VARCHAR,[lp]) AS lp
        ,CONVERT(VARCHAR,[gr_lp]) AS gr_lp
        ,CONVERT(VARCHAR(256),[notes_optional]) AS notes
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROF_lsp_data_entry] WITH(NOLOCK)
  UNION ALL
  SELECT schoolid
        ,staff_name
        ,date
        ,present
        ,on_time
        ,attire
        ,lp
        ,gr_lp
        ,notes
  FROM KIPP_NJ..PROF$data_entry#archive WITH(NOLOCK)
 )

,tracking_long AS (
  SELECT schoolid
        ,staff_name
        ,date
        ,notes
        ,field
        ,CASE WHEN value = '' THEN NULL ELSE value END AS value
  FROM
      (
       SELECT schoolid
             ,staff_name
             ,date
             ,notes
             ,ISNULL(present,'') AS present
             ,ISNULL(on_time,'') AS on_time
             ,ISNULL(attire,'') AS attire
             ,ISNULL(lp,'') AS lp
             ,ISNULL(gr_lp,'') AS gr_lp
       FROM clean_trackers
      ) sub
  UNPIVOT(
    value
    FOR field IN (present, on_time, attire, lp, gr_lp)
   ) u
 )

,tracker_fields AS (
 SELECT DISTINCT
        field
 FROM tracking_long
 )

 SELECT r.associate_id
       ,r.preferred_lastfirst      
       ,r.job_title
       ,r.manager
       ,r.email_addr
       ,cal.schoolid
       ,cal.school_name
       ,cal.academic_year
       ,cal.term
       ,cal.date_value            
       ,f.field
       ,pt.notes      
       ,pt.value
FROM staff_roster r
JOIN prof_calendar cal
  ON r.location = cal.school_name
 AND r.position_start_date <= cal.date_value
CROSS JOIN tracker_fields f
LEFT OUTER JOIN tracking_long pt
  ON r.preferred_lastfirst = pt.staff_name
 AND cal.schoolid = pt.schoolid
 AND cal.date_value = pt.date
 AND f.field = pt.field