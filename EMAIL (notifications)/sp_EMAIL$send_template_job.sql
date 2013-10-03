USE KIPP_NJ
GO

ALTER PROCEDURE sp_EMAIL$send_template_job (
  @job_name             NCHAR(100)
 ,@send_again           NVARCHAR(4000) OUTPUT
) AS

DECLARE
  @email_recipients     NVARCHAR(4000)
 ,@email_subject        NVARCHAR(4000)
  --how many key stats?  max of 4
 ,@stat_count           TINYINT = 0
  --queries for the key stats
 ,@stat_query1          NVARCHAR(MAX)
 ,@stat_query2          NVARCHAR(MAX)
 ,@stat_query3          NVARCHAR(MAX)
 ,@stat_query4          NVARCHAR(MAX)
  --labels for key stats
 ,@stat_label1          NVARCHAR(50) 
 ,@stat_label2          NVARCHAR(50)
 ,@stat_label3          NVARCHAR(50)
 ,@stat_label4          NVARCHAR(50)
  --image stuff
 ,@image_toggle         VARCHAR(3)
 ,@image_path1          NVARCHAR(4000)
 ,@image_path2          NVARCHAR(4000)
  --text
 ,@explanatory_text1    NVARCHAR(MAX)
 ,@explanatory_text2    NVARCHAR(MAX)
 ,@explanatory_text3    NVARCHAR(MAX)

  --main table and CSV
 ,@table_query1         NVARCHAR(MAX)
 ,@table_query2         NVARCHAR(MAX)
 ,@table_style1         NVARCHAR(20)
 ,@table_style2         NVARCHAR(20)
 ,@csv_toggle           VARCHAR(3)
 ,@which_csv            INT

  --IMAGE PATHS ARE DYNAMIC!
 ,@datepath_helper      NVARCHAR(50)

  --1. load in parameters from the EMAIL$template_jobs table, given a job name
SELECT 
  @email_recipients = email_recipients
 ,@email_subject = email_subject
 ,@send_again = send_again
 ,@stat_count = stat_count
 ,@stat_query1 = stat_query1
 ,@stat_query2 = stat_query2
 ,@stat_query3 = stat_query3
 ,@stat_query4 = stat_query4
 ,@stat_label1 = stat_label1
 ,@stat_label2 = stat_label2
 ,@stat_label3 = stat_label3
 ,@stat_label4 = stat_label4
 ,@image_toggle = image_toggle
 ,@image_path1 = image_path1
 ,@image_path2 = image_path2
 ,@explanatory_text1 = explanatory_text1
 ,@explanatory_text2 = explanatory_text2
 ,@explanatory_text3 = explanatory_text3
 ,@csv_toggle = csv_toggle
 ,@which_csv = which_csv
 ,@table_query1 = table_query1
 ,@table_query2 = table_query2
 ,@table_style1 = table_style1
 ,@table_style2 = table_style2
FROM KIPP_NJ..EMAIL$template_jobs
WHERE job_name = @job_name

--build dynamic datepaths
SELECT @datepath_helper = CAST(DATEPART(MONTH,GETDATE()) AS VARCHAR) + '_' +
         RIGHT('0' + DATENAME(DAY, GETDATE()), 2) + '_' + 
         RIGHT(CAST(DATEPART(YY,GETDATE()) AS VARCHAR),2)

SET @image_path1 = REPLACE(@image_path1, 'DATEKEY', @datepath_helper)
SET @image_path2 = REPLACE(@image_path2, 'DATEKEY', @datepath_helper)
        
EXECUTE dbo.sp_EMAIL$template
  @email_recipients = @email_recipients
 ,@email_subject = @email_subject
 ,@stat_count = @stat_count
 ,@stat_query1 = @stat_query1
 ,@stat_query2 = @stat_query2
 ,@stat_query3 = @stat_query3
 ,@stat_query4 = @stat_query4
 ,@stat_label1 = @stat_label1
 ,@stat_label2 = @stat_label2
 ,@stat_label3 = @stat_label3
 ,@stat_label4 = @stat_label4
 
 ,@image_toggle = @image_toggle
 ,@image_path1 = @image_path1
 ,@image_path2 = @image_path2

 ,@csv_toggle = @csv_toggle
 ,@which_csv = @which_csv

 ,@explanatory_text1 = @explanatory_text1
 ,@explanatory_text2 = @explanatory_text2
 ,@explanatory_text3 = @explanatory_text3

 ,@table_query1 = @table_query1
 ,@table_query2 = @table_query2
 
 ,@table_style1 = @table_style1
 ,@table_style2 = @table_style2;