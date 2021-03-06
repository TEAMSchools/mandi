USE KIPP_NJ
GO

ALTER VIEW TABLEAU$professionalism_tracker AS

WITH prof_calendar AS (
  SELECT sub.reporting_schoolid AS schoolid
        ,sub.academic_year
        ,sub.date_value
        ,CASE           
          WHEN sub.reporting_schoolid = 1799015075 THEN 'Whittier ES'
          WHEN sub.reporting_schoolid = 179901 THEN 'Lanning Square Primary'
          WHEN sub.reporting_schoolid = 73257 THEN 'Life Academy'          
          WHEN sub.reporting_schoolid = 73256 THEN 'Seek Academy'
          WHEN sub.reporting_schoolid = 73254 THEN 'SPARK Academy'
          WHEN sub.reporting_schoolid = 73255 THEN 'THRIVE Academy'
         END AS school_name
        ,dt.alt_name AS term
  FROM 
      (
       SELECT schoolid
             ,schoolid AS reporting_schoolid
             ,academic_year
             ,date_value
       FROM KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
       WHERE cal.academic_year >= 2015
         AND cal.insession = 1
         AND cal.date_value <= CONVERT(DATE,GETDATE())
       UNION
       SELECT schoolid
             ,1799015075 AS reporting_schoolid
             ,academic_year
             ,date_value
       FROM KIPP_NJ..PS$CALENDAR_DAY cal WITH(NOLOCK)
       WHERE cal.academic_year >= 2016
         AND cal.insession = 1
         AND cal.date_value <= CONVERT(DATE,GETDATE())
         AND cal.schoolid = 179901
       UNION
       SELECT DISTINCT
              73254 AS schoolid
             ,73254 AS reporting_schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_spark_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              73255 AS schoolid
             ,73255 AS reporting_schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_thrive_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              73256 AS schoolid
             ,73256 AS reporting_schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_seek_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              73257 AS schoolid
             ,73257 AS reporting_schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_life_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT DISTINCT
              179901 AS schoolid
             ,179901 AS reporting_schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
             ,CONVERT(DATE,date) AS additional_date
       FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_lsp_additional_dates] WITH(NOLOCK)
       --UNION ALL
       --SELECT DISTINCT
       --       1799015075 AS schoolid
       --      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,date)) AS academic_year
       --      ,CONVERT(DATE,date) AS additional_date
       --FROM KIPP_NJ..[AUTOLOAD$GDOCS_PROF_wek_additional_dates] WITH(NOLOCK)
       UNION ALL
       SELECT schoolid
             ,schoolid AS reporting_schoolid
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
        ,CASE
          WHEN reporting_location = '18th Avenue Campus' THEN 73255
          WHEN reporting_location = 'Bold Academy' THEN 73258
          WHEN reporting_location = 'KIPP NJ' THEN 7325
          WHEN reporting_location = 'Lanning Square Campus' THEN 1799
          WHEN reporting_location = 'Lanning Square MS' THEN 179902
          WHEN reporting_location = 'Lanning Square Primary' THEN 179901
          WHEN reporting_location = 'Life Academy' THEN 73257
          WHEN reporting_location = 'Newark Collegiate Academy' THEN 73253
          WHEN reporting_location = 'Pathways' THEN 73257
          WHEN reporting_location = 'Rise Academy' THEN 73252
          WHEN reporting_location = 'Seek Academy' THEN 73256
          WHEN reporting_location = 'SPARK Academy' THEN 73254
          WHEN reporting_location = 'TEAM Academy' THEN 133570965
          WHEN reporting_location = 'THRIVE Academy' THEN 73255
          WHEN reporting_location = 'Whittier Elementary' THEN 1799015075
          WHEN reporting_location = 'Whittier Middle' THEN 179902
         END AS schoolid
  FROM
      (
       SELECT DISTINCT 
              adp.associate_id 
             ,adp.preferred_first AS preferred_first_name 
             ,adp.preferred_last AS preferred_last_name       
             ,adp.location
             ,adp.department
             ,adp.job_title
             ,adp.reports_to AS manager
             ,adp.position_start_date
             ,dir.mail AS email_addr                    
             ,COALESCE(reporting_location, adp.location) AS reporting_location             
       FROM KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)        
       LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static dir WITH(NOLOCK)
         ON adp.position_id = dir.employeenumber 
       LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_survey_roster r WITH(NOLOCK)
         ON adp.associate_id = r.associate_id
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
  WHERE ISDATE([date]) = 1
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
  WHERE ISDATE([date]) = 1
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
  WHERE ISDATE([date]) = 1
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
  WHERE ISDATE([date]) = 1
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
  WHERE ISDATE([date]) = 1
  UNION ALL
  SELECT 1799015075 AS schoolid
        ,[staff_name]
        ,CONVERT(DATE,[date]) AS date
        ,CONVERT(VARCHAR,[present]) AS present
        ,CONVERT(VARCHAR,[on_time]) AS on_time
        ,CONVERT(VARCHAR,[attire]) AS attire
        ,CONVERT(VARCHAR,[lp]) AS lp
        ,CONVERT(VARCHAR,[gr_lp]) AS gr_lp
        ,CONVERT(VARCHAR(256),[notes_optional]) AS notes
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROF_wek_data_entry] WITH(NOLOCK)
  WHERE ISDATE([date]) = 1
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
  ON r.schoolid = cal.schoolid
 AND r.position_start_date <= cal.date_value
CROSS JOIN tracker_fields f
LEFT OUTER JOIN tracking_long pt
  ON r.preferred_lastfirst = pt.staff_name
 AND cal.schoolid = pt.schoolid
 AND cal.date_value = pt.date
 AND f.field = pt.field