USE KIPP_NJ
GO

ALTER PROCEDURE EMAIL$walters_demo AS

BEGIN

  DECLARE @data_sql            NVARCHAR(MAX)
         ,@data_html           NVARCHAR(MAX)

         ,@email_body          NVARCHAR(MAX)
           --path of CSV file
         ,@vcCsvFileLocation   NVARCHAR(500)

  SET @data_sql = 
    'SELECT TOP (100) PERCENT s.first_name + '' '' + s.last_name AS name
          ,s.grade_level AS ''Grade''
          ,ar.time_period_name AS term
          ,CAST(CAST(ROUND(ar.points_goal, 1) AS FLOAT) AS NVARCHAR) AS points_goal
          ,CAST(CAST(ROUND(ar.points, 1) AS FLOAT) AS NVARCHAR) AS points_earned 
          ,CAST(CAST(ROUND(ar.ontrack_points, 1) AS FLOAT) AS NVARCHAR) AS ontrack_points
          ,ar.stu_status_points AS status
          ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words          
          ,ar.mastery
          ,ar.avg_lexile AS ''Avg Lexile''
          ,ar.n_passed
          ,ar.n_total
          ,ar.last_book
    FROM KIPP_NJ..AR$progress_to_goals_long#static ar
    JOIN KIPP_NJ..STUDENTS s
      ON ar.studentid = s.id
     AND s.GRADE_LEVEL = 12
    WHERE ar.schoolid = 73253
      AND yearid = 2300
      AND time_hierarchy = 2
      AND time_period_name = ''RT1''
    ORDER BY ar.points DESC'

  --dump to html
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @data_sql, @data_html OUTPUT
  --EXECUTE AlumniMirror.dbo.sp_TableToHTML 'SELECT ID FROM KIPP_NJ..STUDENTS', @data_html OUTPUT

  --dump to file
  EXEC [dbo].[sp_UTIL$table_to_CSV]
		  @vcSqlQuery = @data_sql,
		  @vcFilePath = N'C:\data_robot\raw_exports\',
		  @vcCsvFileLocation = @vcCsvFileLocation OUTPUT

  SELECT	@vcCsvFileLocation as N'@vcCsvFileLocation'

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
    <span style="med_text">
       Hey Walters here''s some m-f''ing AR data
       <br>
       <br>
       Sincerely,
       <br>
       -Data Robot
    </span> 
    <br>
  '
  + @data_html +
  '
  </body>
  </html>'

--.5 ship it!
   EXEC [msdb].[dbo].sp_send_dbmail @profile_name = 'DataRobot'
								,@body = @email_body
								,@body_format ='HTML'
								,@recipients = 'amartin@teamschools.org;ldesimon@teamschools.org;awalters@teamschools.org'
        --,@recipients = 'amartin@teamschools.org;ldesimon@teamschools.org;nmadigan@teamschools.org;cbini@teamschools.org;smircovich@teamschools.org;plebre@teamschools.org;kswearingen@teamschools.org;amilun@teamschools.org'
								,@subject = 'Accelerated Reader Progress Monitoring'
        ,@file_attachments = @vcCsvFileLocation
END