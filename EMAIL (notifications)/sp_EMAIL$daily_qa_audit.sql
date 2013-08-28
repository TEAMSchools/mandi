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
 ,@sql_failed_jobs     NVARCHAR(MAX)
 ,@sql_views           NVARCHAR(MAX)
 
 --variables that catch the output of those queries in HTML format
 ,@html_failed_jobs	   NVARCHAR(MAX)
 ,@html_views	         NVARCHAR(MAX)
 
 --needed for querying view refresh stats
 ,@return_value        INT
	

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
  EXEC	@return_value = [dbo].sp_QA$view_query_time

  SET @sql_views = '
    SELECT object_name AS "non-cached views"
          ,CAST(CAST(refresh_time / 1000.0 AS NUMERIC(4,2)) AS NVARCHAR(MAX)) AS "seconds to refresh"
    FROM KIPP_NJ.dbo.QA$response_time_results
    WHERE batch_id =' + CAST(@return_value AS VARCHAR)

  --sp_TableToHTML is a procedure that TAKES a SQL statement and returns HTML
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
  <span style="med_text">Failed SQL Server Agent Jobs (past 24 hours)</span>
'
+ @html_failed_jobs + 
'
  <br>
  <span style="med_text">Refresh time for non-cached views</span>
' 
 --non cached view refresh time
 + @html_views +
'
</body>
</html>
'

--.5 ship it!
EXEC [msdb].[dbo].sp_send_dbmail @profile_name = 'DataRobot'
								,@body = @email_body
								,@body_format ='HTML'
								,@recipients = 'amartin@teamschools.org;ldesimon@teamschools.org;nmadigan@teamschools.org;cbini@teamschools.org;smircovich@teamschools.org;plebre@teamschools.org;kswearingen@teamschools.org'
								,@subject = 'SQL Server: Audit/QA Results'
END