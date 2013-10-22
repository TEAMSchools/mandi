USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_EMAIL$daily_qa_audit', 'P') IS NOT NULL
    DROP PROCEDURE sp_EMAIL$daily_qa_audit;
GO

CREATE PROCEDURE sp_EMAIL$daily_qa_audit
AS
BEGIN
  
  DECLARE
	 --global, entire email
	 @email_body										NVARCHAR(MAX)

 --variables that store various queries as text
 ,@sql_demog_audits      NVARCHAR(MAX)
 ,@sql_psconfig_audits   NVARCHAR(MAX)
 ,@sql_warehouse_audits  NVARCHAR(MAX)
 ,@sql_illuminate_audits NVARCHAR(MAX)
 ,@sql_integ_audits      NVARCHAR(MAX)
 ,@sql_last_refresh      NVARCHAR(MAX)
 ,@sql_failed_jobs       NVARCHAR(MAX)
 ,@sql_views             NVARCHAR(MAX)
 
 --variables that catch the output of those queries in HTML format
 ,@html_demog_audits     NVARCHAR(MAX)
 ,@html_psconfig_audits  NVARCHAR(MAX)
 ,@html_warehouse_audits NVARCHAR(MAX)
 ,@html_illuminate_audits NVARCHAR(MAX)
 ,@html_integ_audits     NVARCHAR(MAX)
 ,@html_last_refresh     NVARCHAR(MAX)
 ,@html_failed_jobs	     NVARCHAR(MAX)
 ,@html_views	           NVARCHAR(MAX)
 
 --needed for querying view refresh stats
 ,@return_value          INT

 --disk available
 ,@free_disk             INT

 --disk space ish
	 IF OBJECT_ID(N'tempdb..#UTIL$free_space') IS NOT NULL
	 BEGIN
					 DROP TABLE [#UTIL$free_space]
	 END
		
  CREATE TABLE #UTIL$free_space(
    Drive char(1)
   ,MB_Free int
  )

  INSERT INTO #UTIL$free_space exec xp_fixeddrives

  SELECT @free_disk = MB_free FROM #UTIL$free_space WHERE Drive = 'C'
	
  SET @sql_demog_audits = '
    SELECT audit_type
          ,result
    FROM KIPP_NJ..QA$data_audit
    WHERE audit_category = ''Demographic''
    '

  SET @sql_psconfig_audits = '
    SELECT audit_type
          ,result
    FROM KIPP_NJ..QA$data_audit
    WHERE audit_category = ''PS Config''
    '                

  SET @sql_warehouse_audits = '
    SELECT audit_type
          ,result
    FROM KIPP_NJ..QA$data_audit
    WHERE audit_category = ''Data Warehouse Config''
    '                

  SET @sql_illuminate_audits = '
    SELECT audit_type
          ,result
    FROM KIPP_NJ..QA$data_audit
    WHERE audit_category = ''Illuminate''
  '

  SET @sql_integ_audits = '
    SELECT audit_type
          ,result
    FROM KIPP_NJ..QA$data_audit
    WHERE audit_category = ''Data Integration''
    '                

  SET @sql_last_refresh = '
    SELECT TOP (100) PERCENT job_name
         ,run_date_format AS last_run
         ,CAST(CAST(ROUND((minutes_old + 0.0) / 60, 1) AS NUMERIC(5,1)) AS NVARCHAR) AS hours_old
         ,CASE 
            WHEN SUBSTRING(run_duration, 1, 2) = ''00'' THEN STUFF(SUBSTRING(run_duration, 3, 8),3,0,'':'')
            ELSE STUFF(STUFF(run_duration,3,0,'':''),6,0,'':'') 
          END AS run_time
   FROM master..QA$successful_job_history
   WHERE rn = 1
     AND (job_name LIKE ''KIPP_NJ%''
      OR job_name LIKE ''PS%''
      OR job_name LIKE ''SPI%''
      OR job_name IN (''Khan | Load Data'', ''NWEA | Load Data''))
   ORDER BY minutes_old DESC
  '

  --use the return value to get the results from the QA table
  SET @sql_failed_jobs = '
    SELECT job_name
          ,COUNT(*) AS failure_count
    FROM
          (SELECT j.name AS job_name
                ,msdb.dbo.agent_datetime(run_date, run_time) AS run_date_format
                ,h.*
          FROM msdb.dbo.sysjobs j 
          JOIN msdb.dbo.sysjobhistory h 
           ON j.job_id = h.job_id 
          WHERE j.enabled = 1 
            AND msdb.dbo.agent_datetime(run_date, run_time) >= DATEADD(day, -1, GETDATE())
            AND h.step_id = 0
            AND h.run_status = 0 
          ) sub
    GROUP BY job_name'

  --run the view timing test
  --SET @return_value = 139 --testing
  EXEC	@return_value = [dbo].sp_QA$view_query_time

  SET @sql_views = '
    SELECT object_name AS "non-cached views"
          ,CAST(CAST(refresh_time / 1000.0 AS NUMERIC(8,2)) AS NVARCHAR(MAX)) AS "seconds to refresh"
    FROM KIPP_NJ.dbo.QA$response_time_results
    WHERE batch_id =' + CAST(@return_value AS VARCHAR)

  --sp_TableToHTML is a procedure that TAKES a SQL statement and returns HTML
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_demog_audits, @html_demog_audits OUTPUT  
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_psconfig_audits, @html_psconfig_audits OUTPUT
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_integ_audits, @html_integ_audits OUTPUT
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_illuminate_audits, @html_illuminate_audits OUTPUT
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_warehouse_audits, @html_warehouse_audits OUTPUT  
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_last_refresh, @html_last_refresh OUTPUT
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_views, @html_views OUTPUT
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_failed_jobs, @html_failed_jobs OUTPUT
  
SET @email_body = 
'<html>
<head>
		<style type="text/css">
			.med_text {
				font-size: 18px;
				font-family: "Helvetica", Verdana, sans-serif;
				margin: 0;
				padding: 0;
		}
		.big_text {
				font-size: 36px;
				font-family: "Helvetica", Verdana, sans-serif;
				font-weight: bold;
				text-align: center;
				margin: 0;
				padding: 0;
		}
		.big_number {
				font-size: 64pt;
				font-family: "Helvetica", Verdana, sans-serif;
				font-weight: bold;
				text-align: center;
				margin: 0;
				padding: 0;
		}
		</style>
</head>

<body> 
  
		<br>
		<br>
  <span style="med_text">Demographic Data Audits</span> 
'
+ @html_demog_audits +
'
		<br>
  <span style="med_text">PowerSchool Configuration Audits</span> 
'
+ @html_psconfig_audits +
'
<br>
  <span style="med_text">Data Warehouse Config Audits</span> 
'
+ @html_warehouse_audits +
'
<br>
  <span style="med_text">Illuminate Data Audits</span> 
'
+ @html_illuminate_audits +
'
		<br>
  <span style="med_text">Data Integration Audits</span> 
'
+ @html_integ_audits +
'
  <br>
  Disk Space: There are ' + replace(convert(varchar,convert(Money, @free_disk),1),'.00','') + ' megs free on WINSQL 01.
  
  <br>
		<br>
  <span style="med_text">Data Refresh Fresh-ness</span> 
'
+ @html_last_refresh +
'
  <br>
  <span style="med_text">Failed SQL Server Agent Jobs (past 24 hours)</span>
'
+ @html_failed_jobs + 
'
  <br>
  <span style="med_text">Refresh time for non-cached views</span>
'
 --non cached view refresh time
 +  @html_views  + '
</body>
</html>
'

--.5 ship it!
EXEC [msdb].[dbo].sp_send_dbmail @profile_name = 'DataRobot'
								,@body = @email_body
								,@body_format ='HTML'
								--,@recipients = 'amartin@teamschools.org'
        ,@recipients = 'amartin@teamschools.org;ldesimon@teamschools.org;nmadigan@teamschools.org;cbini@teamschools.org;smircovich@teamschools.org;plebre@teamschools.org;kswearingen@teamschools.org;amilun@teamschools.org'
								,@subject = 'SQL Server: Audit/QA Results'
END