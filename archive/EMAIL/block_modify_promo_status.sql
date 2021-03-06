/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id

SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY ID

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('Development: Current Network Stats'
 ,'auto'
 ,'2013-10-07 11:59:30.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 22


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Promo Status: Rise Gr. 6'
   ,@send_again = @fake OUTPUT
END

*/

USE KIPP_NJ
GO

DECLARE @this_grade         VARCHAR(2) = '6'
       ,@this_schoolid      VARCHAR(10) = '73252'
       ,@this_school_name   VARCHAR(10) = 'Rise'
       ,@this_job_name      VARCHAR(100)  
BEGIN

  SET @this_job_name = 'Promo Status: ' + @this_school_name + ' Gr. ' + @this_grade


MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     ( 'cbini@teamschools.org'
       ,@this_job_name
       --figure out SEND AGAIN
       ,'DATEADD(DAY, 7, GETDATE())'
       --number of stats to display at top, update to match number of stats used
       ,2
        --stat query 1
       ,'SELECT CAST(SUM(
                  CASE
                    WHEN promo.promo_status_att = ''Off Track'' THEN 1
                    ELSE 0
                  END) AS NCHAR) AS num_off
           FROM KIPP_NJ..[REPORTING$promo_status#Rise] promo
           JOIN KIPP_NJ..STUDENTS s
             ON promo.studentid = s.id
            AND s.grade_level = ' + @this_grade + '
            AND s.enroll_status = 0
            AND s.schoolid = ' + @this_schoolid + ''
        --stat query 2
       ,'SELECT CAST(SUM(
                  CASE
                    WHEN promo.promo_status_hw = ''Off Track'' THEN 1
                    ELSE 0
                  END) AS NCHAR) AS num_off
           FROM KIPP_NJ..[REPORTING$promo_status#Rise] promo
           JOIN KIPP_NJ..STUDENTS s
             ON promo.studentid = s.id
            AND s.grade_level = ' + @this_grade + '
            AND s.enroll_status = 0
            AND s.schoolid = ' + @this_schoolid + ''
        --stat query 3
       ,' '
        --stat query 4
       ,' '
        --stat labels 1-4
       ,'Off Track: Att'
       ,'Off Track: HW'
       ,' '
       ,' '
       --image stuff
       ,0
       --dynamic filepath
       ,' '
       ,' '
       --regular text (use single space for nulls)
       ,'The following students are Off Track or Warning for Attendance.'
       ,'The following students are Off Track or Warning for Homework.'
       ,'The following students are Off Track or Warning for Grades'
       ,' '
       --csv stuff
       ,'Off'
       ,' '
       --table query 1
       ,'SELECT TOP 10000000 s.last_name
               ,s.first_name
               ,cust.advisor
               ,promo.promo_status_hw AS status
               ,CAST(prog.days_to_perfect AS VARCHAR) AS num_days
               ,CAST(prog.Y1_tardies_total AS VARCHAR) AS tardies
               ,CAST(prog.Y1_absences_total AS VARCHAR) AS abs
               ,s.mother + '' ('' + cust.mother_cell + '')'' AS contact
         FROM KIPP_NJ..STUDENTS s
         JOIN KIPP_NJ..[REPORTING$promo_status#Rise] promo
           ON s.id = promo.studentid
          AND promo.promo_status_att IN (''Warning'', ''Off Track'')
         LEFT OUTER JOIN KIPP_NJ..REPORTING$progress_tracker#Rise prog
           ON s.student_number = prog.student_number
         LEFT OUTER JOIN KIPP_NJ..custom_students cust
           ON s.id = cust.studentid
         WHERE s.grade_level = ' + @this_grade + '
           AND s.enroll_status = 0
           AND s.schoolid = ' + @this_schoolid + '
         ORDER BY cust.advisor
                 ,s.lastfirst'
        --table query 2
       ,' '
       --table query 3
       ,' '
        --table style parameters
       ,'CSS_medium'
       ,' '
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
    ,[csv_toggle]
    ,[csv_query]
    ,[table_query1]
    ,[table_query2]
    ,[table_query3]
    ,[table_style1]
    ,[table_style2]
    ,[table_style3]
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
       ,target.csv_toggle =  source.csv_toggle
       ,target.csv_query =  source.csv_query
       ,target.table_query1 =  source.table_query1
       ,target.table_query2 =  source.table_query2
       ,target.table_query3 =  source.table_query3
       ,target.table_style1 =  source.table_style1
       ,target.table_style2 =  source.table_style2
       ,target.table_style3 =  source.table_style3
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
     ,[csv_toggle]
     ,[csv_query]
     ,[table_query1]
     ,[table_query2]
     ,[table_query3]
     ,[table_style1]
     ,[table_style2]
     ,[table_style3]
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
     ,source.csv_toggle
     ,source.csv_query
     ,source.table_query1
     ,source.table_query2
     ,source.table_query3
     ,source.table_style1
     ,source.table_style2
     ,source.table_style3
   );

END