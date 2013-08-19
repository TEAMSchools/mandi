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

 ,@sql_audit           NVARCHAR(MAX)
 ,@html_roster	        NVARCHAR(MAX)
 ,@return_value        INT
	
  --run the view timing test
  EXEC	@return_value = [dbo].sp_QA$view_query_time

  --use the return value to get the results from the QA table
  SET @sql_audit = 'SELECT *
  FROM QA$response_time_results
  WHERE batch_id = @return_value'

  --sp_TableToHTML is a procedure that TAKES a SQL statement and returns HTML
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_audit, @html_roster OUTPUT
  

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
' +
	@html_roster +
'</body>
</html>
'

--.5 ship it!
EXEC [msdb].[dbo].sp_send_dbmail @profile_name = 'DataRobot'
								,@body = @email_body
								,@body_format ='HTML'
								--,@recipients = 'efisher@teamschools.org;kgarnes@teamschools.org;amartin@teamschools.org;ldesimon@teamschools.org;nmadigan@teamschools.org;vshastry@teamschools.org'
								,@recipients = 'amartin@teamschools.org'
								,@subject = 'Daily Audit'
END