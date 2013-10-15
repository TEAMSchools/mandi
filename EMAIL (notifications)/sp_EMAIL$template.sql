USE KIPP_NJ
GO

ALTER PROCEDURE sp_EMAIL$template (
  --MANDATORY FIELDS
  @email_recipients     AS NVARCHAR(4000)
 ,@email_subject        AS NVARCHAR(4000)
  --how many key stats?  max of 4
 ,@stat_count           AS TINYINT = 0
  --queries for the key stats
 ,@stat_query1          AS NVARCHAR(MAX) = ' '
 ,@stat_query2          AS NVARCHAR(MAX) = ' '
 ,@stat_query3          AS NVARCHAR(MAX) = ' '
 ,@stat_query4          AS NVARCHAR(MAX) = ' '
  --labels for key stats
 ,@stat_label1          AS NVARCHAR(50) = ' ' 
 ,@stat_label2          AS NVARCHAR(50) = ' '
 ,@stat_label3          AS NVARCHAR(50) = ' '
 ,@stat_label4          AS NVARCHAR(50) = ' '
  --image stuff
 ,@image_count          AS TINYINT = 0
 ,@image_path1          AS NVARCHAR(200) = ''
 ,@image_path2          AS NVARCHAR(200) = ''
  --text
 ,@explanatory_text1    AS NVARCHAR(MAX) = ' '
 ,@explanatory_text2    AS NVARCHAR(MAX) = ' '
 ,@explanatory_text3    AS NVARCHAR(MAX) = ' '
 ,@explanatory_text4    AS NVARCHAR(MAX) = ' '

  --table queries
 ,@table_query1         AS NVARCHAR(MAX) = ' '
 ,@table_query2         AS NVARCHAR(MAX) = ' '
 ,@table_query3         AS NVARCHAR(MAX) = ' '

 ,@table_style1         AS NVARCHAR(20) = 'CSS_small'
 ,@table_style2         AS NVARCHAR(20) = 'CSS_medium'
 ,@table_style3         AS NVARCHAR(20) = 'CSS_medium'
 
 ,@csv_toggle           AS VARCHAR(3) = 'On'
 ,@csv_query            AS NVARCHAR(MAX) = ' '
) AS


BEGIN

  DECLARE @stat1_value          NVARCHAR(MAX) = '-'
         ,@stat2_value          NVARCHAR(MAX) = '-%'
         ,@stat3_value          NVARCHAR(MAX) = '-'
         ,@stat4_value          NVARCHAR(MAX) = '-'

         ,@table1_html          NVARCHAR(MAX) = ''
         ,@table2_html          NVARCHAR(MAX) = ''
         ,@table3_html          NVARCHAR(MAX) = ''
          
          --reuse CSS across messages
         ,@email_css            NVARCHAR(MAX) = dbo.fn_Email_CSS()
          
          --default value for supplementary tables is nothing
         ,@email_stat_table     NVARCHAR(MAX) = ''           
         ,@email_image_table    NVARCHAR(MAX) = ''
         
         ,@email_body           NVARCHAR(MAX)

          --For CSV attachment
         ,@csv_attachment       NVARCHAR(500) = ''

  --prep stat queries for sp_executesql
  SET @stat_query1 = N'SET @X = (' + @stat_query1 + ')'
  SET @stat_query2 = N'SET @X = (' + @stat_query2 + ')'
  SET @stat_query3 = N'SET @X = (' + @stat_query3 + ')'
  SET @stat_query4 = N'SET @X = (' + @stat_query4 + ')'
  
  --organize/build key stat table
  IF @stat_count = 4
    BEGIN
      --use sp_executesql to set variables equal to results of these queries
      EXEC sp_executesql @stat_query1, N'@X NVARCHAR(MAX) OUT', @stat1_value OUT
      EXEC sp_executesql @stat_query2, N'@X NVARCHAR(MAX) OUT', @stat2_value OUT
      EXEC sp_executesql @stat_query3, N'@X NVARCHAR(MAX) OUT', @stat3_value OUT
      EXEC sp_executesql @stat_query4, N'@X NVARCHAR(MAX) OUT', @stat4_value OUT 

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
      --use sp_executesql to set variables equal to results of these queries
      EXEC sp_executesql @stat_query1, N'@X NVARCHAR(MAX) OUT', @stat1_value OUT
      EXEC sp_executesql @stat_query2, N'@X NVARCHAR(MAX) OUT', @stat2_value OUT
      EXEC sp_executesql @stat_query3, N'@X NVARCHAR(MAX) OUT', @stat3_value OUT

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
      --use sp_executesql to set variables equal to results of these queries
      EXEC sp_executesql @stat_query1, N'@X NVARCHAR(MAX) OUT', @stat1_value OUT
      EXEC sp_executesql @stat_query2, N'@X NVARCHAR(MAX) OUT', @stat2_value OUT

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
      --use sp_executesql to set variables equal to results of these queries
      EXEC sp_executesql @stat_query1, N'@X NVARCHAR(MAX) OUT', @stat1_value OUT

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
  
  IF (@image_count = 2 AND @image_path2 != '')
    BEGIN
      SET @email_image_table =
        '<table width= "100%"  cellspacing="0" cellpadding="0">
           <tr>
             <td colspan="2">
               <div class="annotation"><i><center>Images contain student data 
                 and are only visible while signed on to the TEAM domain (or on VPN).</center></i></div>
             </td>
           </tr>
           <tr>
             <td width= "50%">
               <div style=display: block; margin:0 auto;">
                 <center><img src="' + @image_path1 + '" width="500"></center>
               </div>
             </td>
             <td width= "50%">
               <div style=display: block; margin:0 auto;">
                 <center><img src="' + @image_path2 + '" width="500"></center>
               </div>
             </td>
           </tr>
         </table>'
    END

  IF (@image_count = 1 AND @image_path1 = '')
    BEGIN
      SET @email_image_table =
        '<table width= "100%"  cellspacing="0" cellpadding="0">
           <tr>
             <td>
               <div class="annotation"><i><center>Images contain student data 
                 and are only visible while signed on to the TEAM domain (or on VPN).</center></i></div>
             </td>
           </tr>
           <tr>
             <td width= "100%">
               <div style=display: block; margin:0 auto;">
                 <center><img src="' + @image_path1 + '" width="500"></center>
               </div>
             </td>
           </tr>
         </table>'
    END

  --dump table_query1 to html
  IF @table_query1 != ' '
    BEGIN
      EXECUTE AlumniMirror.dbo.sp_TableToHTML @table_query1, @table1_html OUTPUT, @table_style1
    END

  --table_query2 to html, IF present
  IF @table_query2 != ' '
    BEGIN
      EXECUTE AlumniMirror.dbo.sp_TableToHTML @table_query2, @table2_html OUTPUT, @table_style2
    END

  --table_query2 to html, IF present
  IF @table_query3 != ' '
    BEGIN
      EXECUTE AlumniMirror.dbo.sp_TableToHTML @table_query3, @table3_html OUTPUT, @table_style3
    END

  --attach a CSV file with data from the main table_query, if csv_toggle is set to 'on' (the default)
  IF LOWER(@csv_toggle) = 'on'
    --SELECT 'pushing CSV'
    BEGIN
      --dump to file
      EXEC [dbo].[sp_UTIL$table_to_CSV]
		      @vcSqlQuery = @csv_query,
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
       <br>
       <span>
        ' + @email_image_table + '
       </span>
       <br>
       <span style="med_text"> 
        ' + @explanatory_text1 + '
       </span> 
       <br>
       <br>
       '
       + @table1_html +
       '
       <br>
       <span style="med_text"> 
        ' + @explanatory_text2 + '
       </span> 
       <br>
       <br>
       '
       + @table2_html +
       '
       <br>
       <span style="med_text"> 
        ' + @explanatory_text3 + '
       </span> 
       <br>
       <br>
       '
       + @table3_html +
       '
       <br>
       <span style="med_text"> 
        ' + @explanatory_text4 + '

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
        ,@blind_copy_recipients = 'amartin@teamschools.org;ldesimon@teamschools.org'
        ,@subject = @email_subject
        ,@file_attachments = @csv_attachment
END