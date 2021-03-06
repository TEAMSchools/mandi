/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id

--to examine the jobs
SELECT *
FROM KIPP_NJ..email$template_jobs

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('Rise 90/90 Tracking, Rise Advisor Stephany Copeland'
 ,'auto'
 ,'2014-11-14 07:11:00.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id >= 488


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Rise 90/90 Tracking, Rise Grade 5'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Rise 90/90 Tracking, Rise Grade 6'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Rise 90/90 Tracking, Rise Grade 7'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Rise 90/90 Tracking, Rise Advisor Stephany Copeland'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Rise 90/90 Tracking, Rise Advisor Travis Dempsey'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Rise 90/90 Tracking, Rise Advisor Amanda Geiger'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Rise 90/90 Tracking, Rise Advisor Laura Joseph'
   ,@send_again = @fake OUTPUT

END


*/

BEGIN TRANSACTION

USE KIPP_NJ
GO

DECLARE @helper_school      VARCHAR(5) 
       ,@helper_org_type    VARCHAR(10)
       ,@helper_org_unit    VARCHAR(50)
       ,@email_list         VARCHAR(200)
       ,@this_job_name      NCHAR(100)

DECLARE db_cursor CURSOR FOR  
  SELECT school
        ,org_type
        ,org_unit
        ,email_list
        --,'cbini@kippnj.org' AS email_list
  FROM
     (SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'5' AS org_unit
            ,'ageiger@teamschools.org;mjoseph@teamschools.org;swilliams@teamschools.org;kpasheluk@teamschools.org' AS email_list
      UNION
      
      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'6' AS org_unit
            ,'tdempsey@teamschools.org;jjones@teamschools.org;scopeland@teamschools.org;mjoseph@teamschools.org;svanwingerden@teamschools.org' AS email_list
      UNION
      
      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'7' AS org_unit
            ,'msorresso@teamschools.org;mjoseph@teamschools.org;ljoseph@teamschools.org;cmetzger@teamschools.org;aburke@kippnj.org' AS email_list
      UNION
      
      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'8' AS org_unit
            ,'nrouhanifard@teamschools.org;mjoseph@teamschools.org' AS email_list
      UNION
     
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Amanda Geiger' AS org_unit
            ,'ageiger@teamschools.org' AS email_list
      UNION
            
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Kristen Pasheluk' AS org_unit
            ,'kpasheluk@teamschools.org' AS email_list
      UNION
      
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Laura Joseph' AS org_unit
            ,'ljoseph@teamschools.org; kkell@teamschools.org' AS email_list
      UNION
            
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Stephany Copeland' AS org_unit
            ,'scopeland@teamschools.org;svanwingerden@teamschools.org' AS email_list
      UNION
      
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Travis Dempsey' AS org_unit
            ,'tdempsey@teamschools.org' AS email_list
      UNION
      
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Jaleesa Jones' AS org_unit
            ,'jjones@teamschools.org;rthomas@teamschools.org' AS email_list
      UNION
      
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Mariel Elguero' AS org_unit
            ,'melguero@teamschools.org;dgosselink@teamschools.org' AS email_list

      UNION
      
      SELECT 'Rise' AS school
            ,'Advisor' AS org_type
            ,'Marc Sorresso' AS org_unit
            ,'MSorresso@kippnj.org;aburke@kippnj.org' AS email_list
     ) sub

OPEN db_cursor
WHILE 1 = 1
 BEGIN
   FETCH NEXT FROM db_cursor INTO @helper_school, @helper_org_type, @helper_org_unit, @email_list  

   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   SET @this_job_name = 'Rise 90/90 Tracking, ' + @helper_school + ' ' + @helper_org_type + ' ' + @helper_org_unit

   --poor man's print
   DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
   DECLARE @msg nvarchar(200) = '''%s'''
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

   MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
   USING 
     (VALUES 
        (  @email_list
          ,@this_job_name
          --figure out SEND AGAIN
         ,'DATEADD(DAY, 7, 
               DateAdd(mi, 11, DateAdd(hh, 7,
                 (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                    DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                 ))
               )'
          ,3
           --stat query 1
          ,'SELECT ''&nbsp;&nbsp;'' + CAST(COUNT(*) AS VARCHAR) + ''&nbsp;&nbsp;''
            FROM
                  (SELECT s.id AS studentid
                         ,CAST(s.grade_level AS VARCHAR) AS org_unit
                   FROM KIPP_NJ..STUDENTS s
                   WHERE s.enroll_status = 0
                     AND s.SCHOOLID = 73252

                   UNION ALL
                   --hr teacher/advisor
                   SELECT s.id
                         ,t.first_name + '' '' + t.last_name AS advisor
                   FROM KIPP_NJ..STUDENTS s
                   JOIN KIPP_NJ..CC
                     ON s.id = cc.STUDENTID
                    AND cc.course_number = ''HR''
                    AND cc.termid >= 2400
                    AND cc.dateenrolled <= CAST(GETDATE() AS date)
                    AND cc.dateleft >= CAST(GETDATE() AS date)
                   JOIN KIPP_NJ..SECTIONS sect
                     ON cc.sectionid = sect.id
                   JOIN KIPP_NJ..TEACHERS t
                     ON sect.teacher = t.id
                   WHERE s.enroll_status = 0
                     AND s.schoolid = 73252
                   ) sub
            JOIN KIPP_NJ..GRADES$HW_90_90#Rise n
              ON sub.studentid = n.studentid
             AND n.cur_ninety_ninety_status = ''Above''
            WHERE org_unit = ''' + @helper_org_unit + ''' 
           '
           --stat query 2
          ,'SELECT COUNT(*)
            FROM
                  (SELECT s.id AS studentid
                         ,CAST(s.grade_level AS VARCHAR) AS org_unit
                   FROM KIPP_NJ..STUDENTS s
                   WHERE s.enroll_status = 0
                     AND s.SCHOOLID = 73252

                   UNION ALL
                   --hr teacher/advisor
                   SELECT s.id
                         ,t.first_name + '' '' + t.last_name AS advisor
                   FROM KIPP_NJ..STUDENTS s
                   JOIN KIPP_NJ..CC
                     ON s.id = cc.STUDENTID
                    AND cc.course_number = ''HR''
                    AND cc.termid >= 2400
                    AND cc.dateenrolled <= CAST(GETDATE() AS date)
                    AND cc.dateleft >= CAST(GETDATE() AS date)
                   JOIN KIPP_NJ..SECTIONS sect
                     ON cc.sectionid = sect.id
                   JOIN KIPP_NJ..TEACHERS t
                     ON sect.teacher = t.id
                   WHERE s.enroll_status = 0
                     AND s.schoolid = 73252
                   ) sub
            JOIN KIPP_NJ..GRADES$HW_90_90#Rise n
              ON sub.studentid = n.studentid
             AND n.cur_ninety_ninety_status = ''Middle''
            WHERE org_unit = ''' + @helper_org_unit + '''
           '
            --stat query 3
          ,'SELECT ''&nbsp;&nbsp;'' + CAST(COUNT(*) AS VARCHAR) + ''&nbsp;&nbsp;''
            FROM
                  (SELECT s.id AS studentid
                         ,CAST(s.grade_level AS VARCHAR) AS org_unit
                   FROM KIPP_NJ..STUDENTS s
                   WHERE s.enroll_status = 0
                     AND s.SCHOOLID = 73252

                   UNION ALL
                   --hr teacher/advisor
                   SELECT s.id
                         ,t.first_name + '' '' + t.last_name AS advisor
                   FROM KIPP_NJ..STUDENTS s
                   JOIN KIPP_NJ..CC
                     ON s.id = cc.STUDENTID
                    AND cc.course_number = ''HR''
                    AND cc.termid >= 2400
                    AND cc.dateenrolled <= CAST(GETDATE() AS date)
                    AND cc.dateleft >= CAST(GETDATE() AS date)
                   JOIN KIPP_NJ..SECTIONS sect
                     ON cc.sectionid = sect.id
                   JOIN KIPP_NJ..TEACHERS t
                     ON sect.teacher = t.id
                   WHERE s.enroll_status = 0
                     AND s.schoolid = 73252
                   ) sub
            JOIN KIPP_NJ..GRADES$HW_90_90#Rise n
              ON sub.studentid = n.studentid
             AND n.cur_ninety_ninety_status = ''Below''
            WHERE org_unit = ''' + @helper_org_unit + '''
           '
            --stat query 4
           ,'
            '
            --stat labels 1-4
           ,'# 90/90'
           ,'# Middle'
           ,'# Below'
           ,' '
           --image stuff
           ,0
           --dynamic filepath
           ,' '
           ,' '
           --regular text (use single space for nulls)
           ,' '
           ,'90/90 Club'
           ,'Middle Group'
           ,'Below Target'
           ,' '
           --csv stuff
           ,'On'
           --csv query -- all students, no restriction on status
           ,'SELECT n.stu_name
                   ,CAST(n.cur_h AS VARCHAR) AS homework_completion
                   ,CAST(n.cur_q AS VARCHAR) AS homework_quality
             FROM
                   (SELECT s.id AS studentid
                          ,CAST(s.grade_level AS VARCHAR) AS org_unit
                    FROM KIPP_NJ..STUDENTS s
                    WHERE s.enroll_status = 0
                      AND s.SCHOOLID = 73252

                    UNION ALL
                    --hr teacher/advisor
                    SELECT s.id
                          ,t.first_name + '' '' + t.last_name AS advisor
                    FROM KIPP_NJ..STUDENTS s
                    JOIN KIPP_NJ..CC
                      ON s.id = cc.STUDENTID
                     AND cc.course_number = ''HR''
                     AND cc.termid >= 2400
                     AND cc.dateenrolled <= CAST(GETDATE() AS date)
                     AND cc.dateleft >= CAST(GETDATE() AS date)
                    JOIN KIPP_NJ..SECTIONS sect
                      ON cc.sectionid = sect.id
                    JOIN KIPP_NJ..TEACHERS t
                      ON sect.teacher = t.id
                    WHERE s.enroll_status = 0
                      AND s.schoolid = 73252
                    ) sub
             JOIN KIPP_NJ..GRADES$HW_90_90#Rise n
               ON sub.studentid = n.studentid
             WHERE org_unit = ''' + @helper_org_unit + '''
            '
           --table query 1
           ,'SELECT org_unit AS ' + @helper_org_type + '
                   ,Above
                   ,Middle
                   ,Below
             FROM KIPP_NJ..GRADES$HW_90_90#Rise#pivot
             WHERE term = ''Cur term''
               AND org_unit = ''' + @helper_org_unit + '''
           '
           --table query 2
           ,'SELECT n.stu_name AS ''Student Name''
                   ,CAST(n.cur_h AS VARCHAR) AS ''HW Completion''
                   ,CAST(n.cur_q AS VARCHAR) AS ''HW Quality''
             FROM
                   (SELECT s.id AS studentid
                          ,CAST(s.grade_level AS VARCHAR) AS org_unit
                    FROM KIPP_NJ..STUDENTS s
                    WHERE s.enroll_status = 0
                      AND s.SCHOOLID = 73252

                    UNION ALL
                    --hr teacher/advisor
                    SELECT s.id
                          ,t.first_name + '' '' + t.last_name AS advisor
                    FROM KIPP_NJ..STUDENTS s
                    JOIN KIPP_NJ..CC
                      ON s.id = cc.STUDENTID
                     AND cc.course_number = ''HR''
                     AND cc.termid >= 2400
                     AND cc.dateenrolled <= CAST(GETDATE() AS date)
                     AND cc.dateleft >= CAST(GETDATE() AS date)
                    JOIN KIPP_NJ..SECTIONS sect
                      ON cc.sectionid = sect.id
                    JOIN KIPP_NJ..TEACHERS t
                      ON sect.teacher = t.id
                    WHERE s.enroll_status = 0
                      AND s.schoolid = 73252
                    ) sub
             JOIN KIPP_NJ..GRADES$HW_90_90#Rise n
               ON sub.studentid = n.studentid
              AND n.cur_ninety_ninety_status = ''Above''
             WHERE org_unit = ''' + @helper_org_unit + '''
            '
             --table query 3
           ,'SELECT n.stu_name AS ''Student Name''
                   ,CAST(n.cur_h AS VARCHAR) AS ''HW Completion''
                   ,CAST(n.cur_q AS VARCHAR) AS ''HW Quality''
             FROM
                   (SELECT s.id AS studentid
                          ,CAST(s.grade_level AS VARCHAR) AS org_unit
                    FROM KIPP_NJ..STUDENTS s
                    WHERE s.enroll_status = 0
                      AND s.SCHOOLID = 73252

                    UNION ALL
                    --hr teacher/advisor
                    SELECT s.id
                          ,t.first_name + '' '' + t.last_name AS advisor
                    FROM KIPP_NJ..STUDENTS s
                    JOIN KIPP_NJ..CC
                      ON s.id = cc.STUDENTID
                     AND cc.course_number = ''HR''
                     AND cc.termid >= 2400
                     AND cc.dateenrolled <= CAST(GETDATE() AS date)
                     AND cc.dateleft >= CAST(GETDATE() AS date)
                    JOIN KIPP_NJ..SECTIONS sect
                      ON cc.sectionid = sect.id
                    JOIN KIPP_NJ..TEACHERS t
                      ON sect.teacher = t.id
                    WHERE s.enroll_status = 0
                      AND s.schoolid = 73252
                    ) sub
             JOIN KIPP_NJ..GRADES$HW_90_90#Rise n
               ON sub.studentid = n.studentid
              AND n.cur_ninety_ninety_status = ''Middle''
             WHERE org_unit = ''' + @helper_org_unit + '''
            '
             --table query 4
           ,'SELECT n.stu_name AS ''Student Name''
                   ,CAST(n.cur_h AS VARCHAR) AS ''HW Completion''
                   ,CAST(n.cur_q AS VARCHAR) AS ''HW Quality''
             FROM
                   (SELECT s.id AS studentid
                          ,CAST(s.grade_level AS VARCHAR) AS org_unit
                    FROM KIPP_NJ..STUDENTS s
                    WHERE s.enroll_status = 0
                      AND s.SCHOOLID = 73252

                    UNION ALL
                    --hr teacher/advisor
                    SELECT s.id
                          ,t.first_name + '' '' + t.last_name AS advisor
                    FROM KIPP_NJ..STUDENTS s
                    JOIN KIPP_NJ..CC
                      ON s.id = cc.STUDENTID
                     AND cc.course_number = ''HR''
                     AND cc.termid >= 2400
                     AND cc.dateenrolled <= CAST(GETDATE() AS date)
                     AND cc.dateleft >= CAST(GETDATE() AS date)
                    JOIN KIPP_NJ..SECTIONS sect
                      ON cc.sectionid = sect.id
                    JOIN KIPP_NJ..TEACHERS t
                      ON sect.teacher = t.id
                    WHERE s.enroll_status = 0
                      AND s.schoolid = 73252
                    ) sub
             JOIN KIPP_NJ..GRADES$HW_90_90#Rise n
               ON sub.studentid = n.studentid
              AND n.cur_ninety_ninety_status = ''Below''
             WHERE org_unit = ''' + @helper_org_unit + '''
            '
             --table style parameters
            ,'CSS_small'
            ,'CSS_medium'
            ,'CSS_medium'
            ,'CSS_medium'
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
          ,target.table_query1 =  source.table_query1
          ,target.table_query2 =  source.table_query2
          ,target.table_query3 =  source.table_query3
          ,target.table_query4 =  source.table_query4
          ,target.table_style1 =  source.table_style1
          ,target.table_style2 =  source.table_style2
          ,target.table_style3 =  source.table_style3
          ,target.table_style4 =  source.table_style4
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
        ,source.table_query1
        ,source.table_query2
        ,source.table_query3
        ,source.table_query4
        ,source.table_style1
        ,source.table_style2
        ,source.table_style3
        ,source.table_style4
      );
  --end cursor action
  END

CLOSE db_cursor
DEALLOCATE db_cursor

--ROLLBACK TRANSACTION
COMMIT TRANSACTION