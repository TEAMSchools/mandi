/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
WHERE job_name LIKE '%ST Math%'
ORDER BY ID DESC


SELECT *
FROM KIPP_NJ..email$template_jobs
WHERE job_name LIKE '%ST Math%'
ORDER BY ID DESC

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('ST Math Progress Monitoring Rev Gr 0'
 ,'auto'
 ,'2015-01-26 6:45:00.000')

--to delete from the queue
BEGIN TRANSACTION
--COMMIT TRANSACTION
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 14687


--to send a job as a test
USE KIPP_NJ
GO
DECLARE @fake NVARCHAR(4000)
BEGIN
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'ST Math Progress Monitoring Rev Gr 0'
   ,@send_again = @fake OUTPUT
END

--many jobs
DECLARE @fake NVARCHAR(4000)
BEGIN
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'ST Math Progress Monitoring Life Gr 0'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'ST Math Progress Monitoring Life Gr 1'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'ST Math Progress Monitoring Life Gr 2'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'ST Math Progress Monitoring Life Gr 3'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'ST Math Progress Monitoring Life Gr 4'
   ,@send_again = @fake OUTPUT

END

*/
USE KIPP_NJ
GO

DECLARE @helper_grade_level INT
       ,@helper_schoolid    INT
       ,@helper_school      NVARCHAR(10)
       ,@helper_term        VARCHAR(5)
       ,@helper_term_long   VARCHAR(20)
       ,@job_name_text      NVARCHAR(100)
       ,@email_list         VARCHAR(500)
       ,@standard_time      VARCHAR(1000)
       ,@send_again         VARCHAR(1000)
       ,@this_job_name      NCHAR(100)
       ,@num_stats          INT
       ,@stat1              VARCHAR(20)
       ,@stat2              VARCHAR(20)
       ,@stat3              VARCHAR(20)
       ,@stat4              VARCHAR(20)
       ,@gr_A               VARCHAR(20)
       ,@gr_B               VARCHAR(20)
       ,@gr_C               VARCHAR(20)
       ,@gr_D               VARCHAR(20)

SET @standard_time = 'DATEADD(DAY, 7, 
             DateAdd(mi, 10, DateAdd(hh, 9,
                --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
               (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                --SETS THE MONTH AND DAY PART TO TODAY
                  DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
               ))
             )'

DECLARE db_cursor CURSOR FOR  
  SELECT grade_level
        ,schoolid
        ,school
        ,job_name_text
         --override:
        --,'amartin@teamschools.org' AS email_list
        ,email_list
        ,send_again
        ,num_stats
        ,stat_label_1
        ,stat_label_2
        ,stat_label_3
        ,stat_label_4
        ,gr_A
        ,gr_B
        ,gr_C
        ,gr_D
  FROM
     (SELECT 5 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'mjoseph@teamschools.org;jbrooks@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4 AS num_stats
            ,'Gr 2' AS stat_label_1
            ,'Gr 3' AS stat_label_2
            ,'Gr 4' AS stat_label_3
            ,'Gr 5' AS stat_label_4
            ,'lib_2nd' AS gr_A
            ,'lib_3rd' AS gr_B
            ,'lib_4th' AS gr_C
            ,'lib_5th' AS gr_D
      UNION
     
      SELECT 6 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'tdempsey@teamschools.org;rthomas@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time
            ,4
            ,'Gr 3'
            ,'Gr 4'
            ,'Gr 5'
            ,'Gr 6'
            ,'lib_3rd'
            ,'lib_4th'
            ,'lib_5th'
            ,'lib_6th'
     UNION
     SELECT 5 AS grade_level
            ,133570965 AS schoolid
            ,'TEAM' AS school
            ,'' AS job_name_text
            ,'oguy@teamschools.org;edunn@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr 2' AS stat_label_1
            ,'Gr 3' AS stat_label_2
            ,'Gr 4' AS stat_label_3
            ,'Gr 5' AS stat_label_4
            ,'lib_2nd' AS gr_A
            ,'lib_3rd' AS gr_B
            ,'lib_4th' AS gr_C
            ,'lib_5th' AS gr_D
     UNION
     SELECT 0 AS grade_level
            ,73255 AS schoolid
            ,'THRIVE' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,2
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,' ' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_foo' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 1 AS grade_level
            ,73255 AS schoolid
            ,'THRIVE' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,3
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 2 AS grade_level
            ,73255 AS schoolid
            ,'THRIVE' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,'Gr 3' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_3rd' AS gr_D
     UNION
     SELECT 0 AS grade_level
            ,73256 AS schoolid
            ,'Seek' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,2
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,' ' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_foo' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 1 AS grade_level
            ,73256 AS schoolid
            ,'Seek' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,3
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 0 AS grade_level
            ,73254 AS schoolid
            ,'SPARK' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,2
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,' ' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_foo' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 1 AS grade_level
            ,73254 AS schoolid
            ,'SPARK' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,3
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 2 AS grade_level
            ,73254 AS schoolid
            ,'SPARK' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,'Gr 3' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_3rd' AS gr_D
     UNION
     SELECT 3 AS grade_level
            ,73254 AS schoolid
            ,'SPARK' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr 1' AS stat_label_1
            ,'Gr 2' AS stat_label_2
            ,'Gr 3' AS stat_label_3
            ,'Gr 4' AS stat_label_4
            ,'lib_1st' AS gr_A
            ,'lib_2nd' AS gr_B
            ,'lib_3rd' AS gr_C
            ,'lib_4th' AS gr_D
     UNION
     SELECT 4 AS grade_level
            ,73254 AS schoolid
            ,'SPARK' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr 1' AS stat_label_1
            ,'Gr 2' AS stat_label_2
            ,'Gr 3' AS stat_label_3
            ,'Gr 4' AS stat_label_4
            ,'lib_1st' AS gr_A
            ,'lib_2nd' AS gr_B
            ,'lib_3rd' AS gr_C
            ,'lib_4th' AS gr_D
     UNION
     SELECT 0 AS grade_level
            ,73257 AS schoolid
            ,'Life' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,2
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,' ' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_foo' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 1 AS grade_level
            ,73257 AS schoolid
            ,'Life' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,3
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,' ' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_foo' AS gr_D
     UNION
     SELECT 2 AS grade_level
            ,73257 AS schoolid
            ,'Life' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,'Gr 3' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_3rd' AS gr_D
     UNION
     SELECT 3 AS grade_level
            ,73257 AS schoolid
            ,'Life' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr 1' AS stat_label_1
            ,'Gr 2' AS stat_label_2
            ,'Gr 3' AS stat_label_3
            ,'Gr 4' AS stat_label_4
            ,'lib_1st' AS gr_A
            ,'lib_2nd' AS gr_B
            ,'lib_3rd' AS gr_C
            ,'lib_4th' AS gr_D
     UNION
     SELECT 4 AS grade_level
            ,73257 AS schoolid
            ,'Life' AS school
            ,'' AS job_name_text
            ,'amartin@teamschools.org;lepstein@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,4
            ,'Gr 1' AS stat_label_1
            ,'Gr 2' AS stat_label_2
            ,'Gr 3' AS stat_label_3
            ,'Gr 4' AS stat_label_4
            ,'lib_1st' AS gr_A
            ,'lib_2nd' AS gr_B
            ,'lib_3rd' AS gr_C
            ,'lib_4th' AS gr_D
     UNION
     
	 SELECT 0 AS grade_level
            ,179901 AS schoolid
            ,'Rev' AS school
            ,'' AS job_name_text
            ,'akadowaki@teamschools.org;ldesimon@teamschools.org;lrong@kippnj.org;amartin@teamschools.org;lepstein@teamschools.org;avernon@kippnj.org;bdunn@kippnj.org;csheppard@kippnj.org;dsweetman@kippnj.org;JMyers@kippnj.org;kortiz@kippnj.org;kcalemmo@kippnj.org;nstokelin@kippnj.org;smartin@kippnj.org;SSuk@kippnj.org;sbranch@kippnj.org' AS email_list
            ,@standard_time AS send_again
            ,4 AS num_stats
            ,'Gr K' AS stat_label_1
            ,'Gr 1' AS stat_label_2
            ,'Gr 2' AS stat_label_3
            ,'Gr 3' AS stat_label_4
            ,'lib_K' AS gr_A
            ,'lib_1st' AS gr_B
            ,'lib_2nd' AS gr_C
            ,'lib_3rd' AS gr_D
     ) sub
OPEN db_cursor
WHILE 1=1
  BEGIN

   FETCH NEXT FROM db_cursor INTO @helper_grade_level, @helper_schoolid, @helper_school, @job_name_text, @email_list, @send_again, 
     @num_stats, @stat1, @stat2, @stat3, @stat4,
     @gr_A, @gr_B, @gr_C, @gr_D
        
   --basically, when you are done with things to fetch, break.
   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   SET @this_job_name = 'ST Math Progress Monitoring ' + CAST(@helper_school AS NVARCHAR) + ' Gr ' + CAST(@helper_grade_level AS NVARCHAR)

   --poor man's print
   DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
   DECLARE @msg nvarchar(200) = '''%s'''
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT
   SET @msg_value = RTRIM(@email_list)
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT


MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     (  --email recipients
        @email_list
        --email subject
       ,@this_job_name
        --send again
       ,'DATEADD(DAY, 7, GETDATE())'
        --stat count
       ,@num_stats
        --stat query 1
       ,'SELECT CAST(CAST(AVG(ISNULL(' + @gr_A + ', 0)) AS INT) AS VARCHAR) + ''%''
         FROM KIPP_NJ..REPORTING$st_math_tracker st
         WHERE st.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          AND st.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
        '
        --stat query 2
       ,'SELECT CAST(CAST(AVG(ISNULL(' + @gr_B + ', 0)) AS INT) AS VARCHAR) + ''%''
         FROM KIPP_NJ..REPORTING$st_math_tracker st
         WHERE st.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          AND st.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
        '
         --stat query 3
       ,'SELECT CAST(CAST(AVG(ISNULL(' + @gr_C + ', 0)) AS INT) AS VARCHAR) + ''%''
         FROM KIPP_NJ..REPORTING$st_math_tracker st
         WHERE st.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          AND st.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
        '
         --stat query 4
       ,'SELECT CAST(CAST(AVG(ISNULL(' + @gr_D + ', 0)) AS INT) AS VARCHAR) + ''%''
         FROM KIPP_NJ..REPORTING$st_math_tracker st
         WHERE st.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          AND st.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
        '
         --stat labels 1-4
        ,@stat1
        ,@stat2
        ,@stat3
        ,@stat4
        --image count
        ,0
        --image paths
        ,' '
        ,' '
        --explanatory text (use single space for nulls)
        ,'<center>
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
            <img src="http://www.mindresearch.net/i/icon-jiji.png" width="90">
         '
        ,'The bold numbers above show ST Math grade level library percentage completion averages 
          for all students listed below.  
          (Students are presumed to have ''completed'' all libraries below their starting placement.)
          <br><br>The chart below shows average ST math completion, by with averages for each relevant
          section or homeroom.'
        ,' '
        ,' '
        ,'</center>'
        --csv toggle on/off
        ,'On'
        --csv query
        ,'SELECT TOP 10000000 st.Student
                ,st.section AS Section
                ,st.cur_lib
                ,CAST(st.total_completion AS VARCHAR) AS completion
                ,CAST(st.change AS VARCHAR) AS change
                ,CAST(st.sch_gr_completion_rank AS VARCHAR) AS rank
                ,CAST(st.sch_gr_change_rank AS VARCHAR) AS change_rank
          FROM STMath..summary_by_enrollment st
          WHERE st.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
            AND st.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
          ORDER BY st.total_completion DESC'
        --additional attachment
        ,' '
        --table query 1
        ,' '
          --table query 2
         ,'SELECT TOP 1000000 
                 CASE GROUPING(st.section) WHEN 1 THEN ''All'' ELSE st.section END AS Section
                ,CAST(CAST(AVG(ISNULL(st.total_completion, 0)) AS NUMERIC(4,1)) AS VARCHAR) + ''%'' AS [Avg Completion]
          FROM STMath..summary_by_enrollment st
          WHERE st.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
            AND st.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
          GROUP BY CUBE(st.section)
          ORDER BY GROUPING(st.section) DESC, st.section'
         --table query 3
         ,'SELECT TOP 10000000 st.Student
                ,st.section AS Section
                ,st.cur_lib AS [Current Library]
                ,CAST(st.total_completion AS VARCHAR) AS [Completion]
                ,CAST(st.change AS VARCHAR) AS [Change]
                ,CAST(st.sch_gr_completion_rank AS VARCHAR) AS [Rank]
                ,CAST(st.sch_gr_change_rank AS VARCHAR) AS [Change Rank]
          FROM STMath..summary_by_enrollment st
          WHERE st.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
            AND st.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
          ORDER BY st.total_completion DESC'
         --table query 4
         ,' '
          --table style 1
         ,''
          --table style 2
         ,'CSS_medium'
          --table style 3
         ,'CSS_medium'
          --table style 4
         ,' '
     )
  ) AS SOURCE
  (  [email_recipients]
    ,[email_subject]
    ,[send_again]
    ,[stat_count]
    ,[stat_query1]
    ,[stat_query2]
    ,[stat_query3]
    ,[stat_query4]
    ,[stat_label1]
    ,[stat_label2]
    ,[stat_label3]
    ,[stat_label4]
    ,[image_count]
    ,[image_path1]
    ,[image_path2]
    ,[explanatory_text1]
    ,[explanatory_text2]
    ,[explanatory_text3]
    ,[explanatory_text4]
    ,[explanatory_text5]
    ,[csv_toggle]
    ,[csv_query]
    ,[additional_attachment]
    ,[table_query1]
    ,[table_query2]
    ,[table_query3]
    ,[table_query4]
    ,[table_style1]
    ,[table_style2]
    ,[table_style3]
    ,[table_style4]
  )
  ON target.job_name = @this_job_name

WHEN MATCHED THEN
  UPDATE
    SET target.email_recipients = source.email_recipients
       ,target.email_subject    = source.email_subject
       ,target.send_again =  source.send_again
       ,target.stat_count =  source.stat_count
       ,target.stat_query1 =  source.stat_query1
       ,target.stat_query2 =  source.stat_query2
       ,target.stat_query3 =  source.stat_query3
       ,target.stat_query4 =  source.stat_query4
       ,target.stat_label1 =  source.stat_label1
       ,target.stat_label2 =  source.stat_label2
       ,target.stat_label3 =  source.stat_label3
       ,target.stat_label4 =  source.stat_label4
       ,target.image_count =  source.image_count
       ,target.image_path1 =  source.image_path1
       ,target.image_path2 =  source.image_path2
       ,target.explanatory_text1 =  source.explanatory_text1
       ,target.explanatory_text2 =  source.explanatory_text2
       ,target.explanatory_text3 =  source.explanatory_text3
       ,target.explanatory_text4 =  source.explanatory_text4
       ,target.explanatory_text5 =  source.explanatory_text5
       ,target.csv_toggle =  source.csv_toggle
       ,target.csv_query =  source.csv_query
       ,target.additional_attachment = source.additional_attachment
       ,target.table_query1 =  source.table_query1
       ,target.table_query2 =  source.table_query2
       ,target.table_query3 =  source.table_query3
       ,target.table_query4 =  source.table_query4
       ,target.table_style1 =  source.table_style1
       ,target.table_style2 =  source.table_style2
       ,target.table_style3 =  source.table_style3
       ,target.table_style4 =  source.table_style4
--ie, the first time you push into this table
WHEN NOT MATCHED THEN
   INSERT
   (  [job_name]
     ,[email_recipients]
     ,[email_subject]
     ,[send_again]
     ,[stat_count]
     ,[stat_query1]
     ,[stat_query2]
     ,[stat_query3]
     ,[stat_query4]
     ,[stat_label1]
     ,[stat_label2]
     ,[stat_label3]
     ,[stat_label4]
     ,[image_count]
     ,[image_path1]
     ,[image_path2]
     ,[explanatory_text1]
     ,[explanatory_text2]
     ,[explanatory_text3]
     ,[explanatory_text4]
     ,[explanatory_text5]
     ,[csv_toggle]
     ,[csv_query]
     ,[additional_attachment]
     ,[table_query1]
     ,[table_query2]
     ,[table_query3]
     ,[table_query4]
     ,[table_style1]
     ,[table_style2]
     ,[table_style3]
     ,[table_style4]
   )
   VALUES
   (  @this_job_name
     ,source.email_recipients
     ,source.email_subject
     ,source.send_again
     ,source.stat_count
     ,source.stat_query1
     ,source.stat_query2
     ,source.stat_query3
     ,source.stat_query4
     ,source.stat_label1
     ,source.stat_label2
     ,source.stat_label3
     ,source.stat_label4
     ,source.image_count
     ,source.image_path1
     ,source.image_path2
     ,source.explanatory_text1
     ,source.explanatory_text2
     ,source.explanatory_text3
     ,source.explanatory_text4
     ,source.explanatory_text5
     ,source.csv_toggle
     ,source.csv_query
     ,source.additional_attachment
     ,source.table_query1
     ,source.table_query2
     ,source.table_query3
     ,source.table_query4
     ,source.table_style1
     ,source.table_style2
     ,source.table_style3
     ,source.table_style4
   );

END

CLOSE db_cursor
DEALLOCATE db_cursor
