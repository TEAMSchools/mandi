USE KIPP_NJ
GO

ALTER VIEW REPORTING$dates AS

SELECT CONVERT(INT,academic_year) AS academic_year
      ,CONVERT(INT,yearid) AS yearid
      ,CONVERT(INT,termid) AS termid
      ,CONVERT(VARCHAR(32),identifier) AS identifier
      ,CONVERT(VARCHAR(8),school_level) AS school_level
      ,CONVERT(INT,schoolid) AS schoolid
      ,CONVERT(VARCHAR(64),time_per_name) AS time_per_name
      ,CONVERT(VARCHAR(64),alt_name) AS alt_name
      ,CONVERT(DATE,start_date) AS start_date
      ,CONVERT(DATE,end_date) AS end_date
      ,CONVERT(INT,time_hierarchy) AS time_hierarchy
      ,CONVERT(VARCHAR(256),report_name_long) AS report_name_long
      ,CONVERT(VARCHAR(128),report_name_short) AS report_name_short
      ,CONVERT(DATE,report_issued) AS report_issued
      ,CONVERT(DATE,CONVERT(VARCHAR,next_report)) AS next_report
      ,custom
      ,CONVERT(INT,reporting_hash) AS reporting_hash
FROM KIPP_NJ..AUTOLOAD$GDOCS_REP_reporting_dates WITH(NOLOCK)