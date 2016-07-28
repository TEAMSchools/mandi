WITH clean_trackers AS (
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
 )

SELECT *
--INTO KIPP_NJ..PROF$data_entry#archive
FROM clean_trackers
WHERE staff_name IS NOT NULL
AND date IS NOT NULL
AND CONCAT(present,	on_time,	attire,	lp,	gr_lp,	notes) != ''
