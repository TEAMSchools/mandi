USE KIPP_NJ
GO

ALTER PROCEDURE sp_EMAIL$template (
  @email_recipients     AS NVARCHAR(4000)
 ,@email_subject        AS NVARCHAR(4000)
  --how many key stats?  max of 3
 ,@stat_count           AS INT = 0
  --queries for the key stats
 ,@stat_query1          AS NVARCHAR(MAX) = ''
 ,@stat_query2          AS NVARCHAR(MAX) = ''
 ,@stat_query3          AS NVARCHAR(MAX) = ''
 ,@stat_query4          AS NVARCHAR(MAX) = ''
  --labels for key stats
 ,@stat_label1          AS NVARCHAR(50) = 'impact' 
 ,@stat_label2          AS NVARCHAR(50) = 'freedom'
 ,@stat_label3          AS NVARCHAR(50) = 'fun'
 ,@stat_label4          AS NVARCHAR(50) = 'teamwork'      
  --main table and CSV
 ,@table_query          AS NVARCHAR(MAX) = ''
 ,@csv_toggle           AS VARCHAR(3) = 'On'
) AS


BEGIN

  DECLARE @stat1_value          NVARCHAR(MAX) = 'frrrt'
         ,@stat2_value          NVARCHAR(MAX) = '75%'
         ,@stat3_value          NVARCHAR(MAX) = '108'
         ,@stat4_value          NVARCHAR(MAX) = '0.53'
         ,@table_html           NVARCHAR(MAX)
          
          --reuse CSS across messages
         ,@email_css            NVARCHAR(MAX) = dbo.fn_Email_CSS()
          
          --holds dynamic SQL for constructing custom stat table
         ,@make_stat_table      NVARCHAR(MAX)
          --default value for stat table is nothing
         ,@email_stat_table     NVARCHAR(MAX) = ''           
         ,@email_body           NVARCHAR(MAX)

          --For CSV attachment
         ,@csv_attachment       NVARCHAR(500) = ''
         ,@sqlCommand           NVARCHAR(1000)
         ,@xx INT

  --prep stat queries for sp_executesql
  SET @stat_query1 = N'SET @X = (' + @stat_query1 + ')'
  SET @stat_query2 = N'SET @X = (' + @stat_query2 + ')'
  SET @stat_query3 = N'SET @X = (' + @stat_query3 + ')'
  SET @stat_query4 = N'SET @X = (' + @stat_query4 + ')'

  --use sp_executesql to set variables equal to results of these queries
  EXEC sp_executesql @stat_query1, N'@X NVARCHAR(MAX) OUT', @stat1_value OUT
  EXEC sp_executesql @stat_query2, N'@X NVARCHAR(MAX) OUT', @stat2_value OUT
  EXEC sp_executesql @stat_query3, N'@X NVARCHAR(MAX) OUT', @stat3_value OUT
  EXEC sp_executesql @stat_query4, N'@X NVARCHAR(MAX) OUT', @stat4_value OUT
  
  --SET @sqlCommand = 'SELECT @cnt=COUNT(*) FROM customers WHERE City = @city'
  --SET @stat1_value = (select 'qwerty')
  --SET @stat1_value = EVAL(@stat_query1)
  --EXECUTE sp_executesql @sqlCommand, N'@farts NVARCHAR(MAX) OUTPUT', @farts=@stat1_value OUTPUT

  --EXEC sp_executesql @stat_query1, N'@stat1_value NVARCHAR(MAX) OUT', @stat1_value OUT;
 
  
  --organize/build key stat table
  IF @stat_count = 4
    BEGIN
      SET @email_stat_table = 
       '<table width= "100%"  cellspacing="0" cellpadding="0">
				      <tr>
						      <th width="25%">
						        <div class="stat_label">' +  @stat_label1 + '</div>
						      </th>
     							
						      <th width="25%">
						        <div class="stat_label">' +  @stat_label2 + '</div>
						      </th>
     							
						      <th width="25%">
						        <div class="stat_label">' +  @stat_label3 + '</div>
						      </th>							

						      <th width="25%">
						        <div class="stat_label">' +  @stat_label4 + '</div>
						      </th>							
				      </tr>
     					
				      <tr>
						      <td>
						        <div class="stat">' + CAST(@stat1_value AS NVARCHAR) + '</div>
						      </td>
     							
						      <td>
						        <div class="stat">' + CAST(@stat2_value AS VARCHAR) + '</div>
						      </td>
     							
						      <td>
						        <div class="stat">' + CAST(@stat3_value AS VARCHAR) + '</div>
						      </td>					

						      <td>
						        <div class="stat">' + CAST(@stat4_value AS VARCHAR) + '</div>
						      </td>					
				      </tr>
        </table>'
    END

  IF @stat_count = 3
    BEGIN
      SET @email_stat_table = 
       '<table width= "100%"  cellspacing="0" cellpadding="0">
				      <tr>
						      <th width="34%">
						        <div class="stat_label">' +  @stat_label1 + '</div>
						      </th>
     							
						      <th width="33%">
						        <div class="stat_label">' +  @stat_label2 + '</div>
						      </th>
     							
						      <th width="34%">
						        <div class="stat_label">' +  @stat_label3 + '</div>
						      </th>							
				      </tr>
     					
				      <tr>
						      <td>
						        <div class="stat">' + CAST(@stat1_value AS VARCHAR) + '</div>
						      </td>
     							
						      <td>
						        <div class="stat">' + CAST(@stat2_value AS VARCHAR) + '</div>
						      </td>
     							
						      <td>
						        <div class="stat">' + CAST(@stat3_value AS VARCHAR) + '</div>
						      </td>					
				      </tr>
        </table>'
    END

  IF @stat_count = 2
    BEGIN
      SET @email_stat_table = 
       '<table width= "100%"  cellspacing="0" cellpadding="0">
				      <tr>
						      <th width="50%">
						        <div class="stat_label">' +  @stat_label1 + '</div>
						      </th>
     							
						      <th width="50%">
						        <div class="stat_label">' +  @stat_label2 + '</div>
						      </th>						
				      </tr>
     					
				      <tr>
						      <td>
						        <div class="stat">' + CAST(@stat1_value AS VARCHAR) + '</div>
						      </td>
     							
						      <td>
						        <div class="stat">' + CAST(@stat2_value AS VARCHAR) + '</div>
						      </td>	
				      </tr>
        </table>'
    END

  IF @stat_count = 1
    BEGIN
      SET @email_stat_table = 
       '<table width= "100%"  cellspacing="0" cellpadding="0">
				      <tr>
						      <th width="100%">
						        <div class="stat_label">' +  @stat_label1 + '</div>
						      </th>
				      </tr>
     					
				      <tr>
						      <td>
						        <div class="stat">' + CAST(@stat1_value AS VARCHAR) + '</div>
						      </td>
				      </tr>
        </table>'
    END
  
  --dump the table_query to html
  EXECUTE AlumniMirror.dbo.sp_TableToHTML @table_query, @table_html OUTPUT
  --EXECUTE AlumniMirror.dbo.sp_TableToHTML 'SELECT ID FROM KIPP_NJ..STUDENTS', @data_html OUTPUT

  --attach a CSV file with data from the main table_query, if csv_toggle is set to 'on' (the default)
  IF LOWER(@csv_toggle) = 'on'
    BEGIN
      --dump to file
      EXEC [dbo].[sp_UTIL$table_to_CSV]
		      @vcSqlQuery = @table_query,
		      @vcFilePath = N'C:\data_robot\raw_exports\',
		      @vcCsvFileLocation = @csv_attachment OUTPUT

      SELECT	@csv_attachment AS N'@vcCsvFileLocation'
    END

  SET @email_body = 

  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
   <html xmlns="http://www.w3.org/1999/xhtml">
   <head>
	   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	   <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
	   <title>Your Message Subject or Title</title>
   	<style type="text/css">' 
         + @email_css  + ' 
     </style>
   </head>

   <body>
   <!-- Wrapper/Container Table: Use a wrapper table to control the width and the background color consistently of your email. Use this approach instead of setting attributes on the body tag. -->
   <table cellpadding="0" cellspacing="0" border="0" id="backgroundTable">
	   <tr>
		   <td valign="top"> 

     <!-- START CONTENT HERE -->
      
       <span>
        ' + @email_stat_table + '
       </span> 
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
       + @table_html +
       '

     <!-- END CONTENT HERE -->

		   </td>
	   </tr>
   </table>  
   <!-- End of wrapper table -->

   </body>
   </html>'

--.5 ship it!
   EXEC [msdb].[dbo].sp_send_dbmail @profile_name = 'DataRobot'
								,@body = @email_body
								,@body_format ='HTML'
								,@recipients = @email_recipients
        ,@subject = @email_subject
        ,@file_attachments = @csv_attachment
END