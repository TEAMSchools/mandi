/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue WITH (NOLOCK)
WHERE id >= 878
  AND job_name LIKE ('%Khan Objectives Mastered%')
ORDER BY send_at DESC

--to examine the jobs
SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY id DESC

DELETE
FROM KIPP_NJ..email$template_jobs
WHERE id = 184

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('Khan Objectives Mastered Progress Monitoring Rise Gr 5 to 8 - Sunday goodness [whole school]'
 ,'auto'
 ,'2014-05-04 010:34:00.000')

--to delete from the queue
BEGIN TRANSACTION
DELETE 
--SELECT *
FROM KIPP_NJ..email$template_queue
--WHERE id IN (879, 882, 884, 886, 888, 890, 892, 894, 896,
WHERE job_name LIKE '%90/90%'
  AND send_at IS NULL

BEGIN TRANSACTION
DELETE
FROM KIPP_NJ..EMAIL$template_jobs
WHERE id IN ( 
--ROLLBACK TRANSACTION
COMMIT TRANSACTION

81 AND id <= 88

--future jobs or nulls?
SELECT *
FROM KIPP_NJ..EMAIL$template_queue
WHERE send_at > GETDATE()
  OR send_at IS NULL
ORDER BY job_name

 --to send a job as a test
 DECLARE @fake NVARCHAR(4000)
 BEGIN

   EXEC dbo.sp_EMAIL$send_template_job
     @job_name = 'Khan Objectives Mastered Progress Monitoring Rise Gr 5 to 8 - Sunday goodness [whole school]'
    ,@send_again = @fake OUTPUT

 END



*/

USE KIPP_NJ
GO

DECLARE @helper_low_grade   INT
       ,@helper_high_grade  INT
       ,@helper_schoolid    INT
       ,@helper_school      NVARCHAR(5)
       ,@job_name_text      NVARCHAR(100)
       ,@email_list         VARCHAR(500)
       ,@standard_time      VARCHAR(1000)
       ,@send_again         VARCHAR(1000)
       ,@this_job_name      NCHAR(100)

SET @standard_time = 'CASE
              WHEN DATEPART(WEEKDAY, GETDATE()) = 6
                THEN DATEADD(DAY, 3, 
                DateAdd(mi, 10, DateAdd(hh, 7,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
              ELSE DATEADD(DAY, 1, 
                DateAdd(mi, 10, DateAdd(hh, 7,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
            END'

DECLARE db_cursor CURSOR FOR  
  SELECT low_grade
        ,high_grade
        ,schoolid
        ,school
        ,job_name_text
         --override:
        --,'amartin@teamschools.org' AS email_list
        ,email_list
        ,send_again
  FROM
     (SELECT 5 AS low_grade
            ,5 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'mjoseph@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
     
      SELECT 6 AS low_grade
            ,6 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'tdempsey@teamschools.org;amartin@teamschools.org;lepstein@teamschools.org;mjoseph@teamschools.org;ldesimon@teamschools.org' AS email_list
            ,@standard_time
      UNION
     
      SELECT 7 AS low_grade
            ,7 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'kkell@teamschools.org;lepstein@teamschools.org;jbrooks@teamschools.org' AS email_list
            ,@standard_time
      UNION
     
      SELECT 8 AS low_grade
            ,8 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'nrouhanifard@teamschools.org;tluna@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time
      UNION
     
      SELECT 9 AS low_grade
            ,12 AS high_grade
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'tdockins@teamschools.org;ldesimon@teamschools.org;amartin@teamschools.org' AS email_list
            ,@standard_time
      UNION
      --special asks
      SELECT 5 AS low_grade
            ,5 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,' - Sunday goodness' AS job_name_text
            ,'mjoseph@teamschools.org;lepstein@teamschools.org' AS email_list
            ,'DATEADD(
                DAY, 7, 
                  --tldr - 10:30 TODAY
                  DATEADD(mi, 30, 
                    DATEADD(hh, 10,
                     --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
                    (DATEADD(yy, DATEPART(YYYY, GETDATE())-1900, 
                     --SETS THE MONTH AND DAY PART TO TODAY
                       DATEADD(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1)))
                    )
                  )
               )'
      UNION
      SELECT 6 AS low_grade
            ,6 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,' - Sunday goodness' AS job_name_text
            ,'tdempsey@teamschools.org;lepstein@teamschools.org' AS email_list
            ,'DATEADD(
                DAY, 7, 
                  --tldr - 10:31 TODAY
                  DATEADD(mi, 31, 
                    DATEADD(hh, 10,
                     --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
                    (DATEADD(yy, DATEPART(YYYY, GETDATE())-1900, 
                     --SETS THE MONTH AND DAY PART TO TODAY
                       DATEADD(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1)))
                    )
                  )
               )'
      UNION
      SELECT 7 AS low_grade
            ,7 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,' - Sunday goodness' AS job_name_text
            ,'lepstein@teamschools.org' AS email_list
            ,'DATEADD(
                DAY, 7, 
                  --tldr - 10:32 TODAY
                  DATEADD(mi, 32, 
                    DATEADD(hh, 10,
                     --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
                    (DATEADD(yy, DATEPART(YYYY, GETDATE())-1900, 
                     --SETS THE MONTH AND DAY PART TO TODAY
                       DATEADD(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1)))
                    )
                  )
               )'
      UNION
      SELECT 8 AS low_grade
            ,8 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,' - Sunday goodness' AS job_name_text
            ,'lepstein@teamschools.org' AS email_list
            ,'DATEADD(
                DAY, 7, 
                  --tldr - 10:30 TODAY
                  DATEADD(mi, 33, 
                    DATEADD(hh, 10,
                     --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
                    (DATEADD(yy, DATEPART(YYYY, GETDATE())-1900, 
                     --SETS THE MONTH AND DAY PART TO TODAY
                       DATEADD(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1)))
                    )
                  )
               )'
      UNION
      SELECT 5 AS low_grade
            ,8 AS high_grade
            ,73252 AS schoolid
            ,'Rise' AS school
            ,' - Sunday goodness [whole school]' AS job_name_text
            ,'lepstein@teamschools.org' AS email_list
            ,'DATEADD(
                DAY, 7, 
                  --tldr - 10:30 TODAY
                  DATEADD(mi, 34, 
                    DATEADD(hh, 10,
                     --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
                    (DATEADD(yy, DATEPART(YYYY, GETDATE())-1900, 
                     --SETS THE MONTH AND DAY PART TO TODAY
                       DATEADD(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1)))
                    )
                  )
               )'
     ) sub

OPEN db_cursor
WHILE 1=1
  BEGIN

   FETCH NEXT FROM db_cursor INTO @helper_low_grade, @helper_high_grade, @helper_schoolid, @helper_school, @job_name_text, @email_list, @send_again

   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   IF @helper_low_grade = @helper_high_grade
     BEGIN
       SET @this_job_name = 'Khan Objectives Mastered Progress Monitoring ' + CAST(@helper_school AS NVARCHAR) +
         ' Gr ' + CAST(@helper_low_grade AS NVARCHAR) + @job_name_text
     END

   --multigrade report
   IF @helper_low_grade <> @helper_high_grade
     BEGIN
       SET @this_job_name = 'Khan Objectives Mastered Progress Monitoring ' + CAST(@helper_school AS NVARCHAR) +
         ' Gr ' + CAST(@helper_low_grade AS NVARCHAR) + ' to ' + CAST(@helper_high_grade AS NVARCHAR) + @job_name_text
     END
 
   --poor man's print
   DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
   DECLARE @msg nvarchar(200) = '''%s'''
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT
   SET @msg_value = RTRIM(@email_list)
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

   MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
   USING 
     (VALUES 
        ( @email_list
         ,@this_job_name
          --figure out SEND AGAIN
         ,@send_again
         ,2
          --stat query 1
         ,'SELECT replace(convert(varchar,convert(Money, CAST(SUM(mastered) AS FLOAT)),1),''.00'','''') AS total_mastered
           FROM
                  (SELECT sub.lastfirst
                        ,sub.full_name
                        ,COUNT(*) AS mastered
                  FROM
                        (SELECT e.studentid
                               ,s.lastfirst
                               ,s.first_name + '' '' + s.last_name AS full_name
                               ,s.grade_level
                               ,e.exercise
                               ,e.proficient_date
                               ,e.level
                               ,e.total_done
                               ,e.total_correct
                         FROM Khan..composite_exercises#identifiers e
                         JOIN KIPP_NJ..STUDENTS s
                           ON e.studentid = s.id
                          AND s.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                          AND s.grade_level >= ' + CAST(@helper_low_grade AS NVARCHAR) + '                         
                          AND s.grade_level <= ' + CAST(@helper_high_grade AS NVARCHAR) + '                         
                        WHERE e.mastered = ''True''
                         ) sub
                  GROUP BY sub.lastfirst
                          ,sub.full_name
                  ) sub
          '
          --stat query 2
         ,'SELECT AVG(mastered) AS avg
           FROM
                 (SELECT sub.lastfirst
                        ,sub.full_name
                        ,COUNT(*) AS mastered
                  FROM
                        (SELECT e.studentid
                               ,s.lastfirst
                               ,s.first_name + '' '' + s.last_name AS full_name
                               ,s.grade_level
                               ,e.exercise
                               ,e.proficient_date
                               ,e.level
                               ,e.total_done
                               ,e.total_correct
                         FROM Khan..composite_exercises#identifiers e
                         JOIN KIPP_NJ..STUDENTS s
                           ON e.studentid = s.id
                          AND s.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                          AND s.grade_level >= ' + CAST(@helper_low_grade AS NVARCHAR) + '                         
                          AND s.grade_level <= ' + CAST(@helper_high_grade AS NVARCHAR) + '                         
                         WHERE e.mastered = ''True''
                         ) sub
                  GROUP BY sub.lastfirst
                          ,sub.full_name
                  ) sub
          '
          --stat query 3
         ,' '
          --stat query 4
         ,' '
          --stat labels 1-4
         ,'Total Mastered'
         ,'Avg Mastered'
         ,' '
         ,' '
           --image stuff
         ,0
         --dynamic filepath
         ,' '
         ,' '
         --regular text (use single space for nulls)
         ,' '
         ,' '
         ,' '
         ,' '
         ,' '
         --csv stuff
         ,'On'
         --csv query -- all students, no restriction on status
         ,'SELECT TOP 1000000 sub.full_name AS student
                 ,LEFT(sub.nickname,50) AS nickname
                 ,sub.mastered AS mastered
                 ,replace(convert(varchar,convert(Money, CAST(d.points AS FLOAT)),1),''.00'','''') AS khan_points
           FROM
                 (SELECT sub.studentid
                        ,sub.lastfirst
                        ,sub.full_name
                        ,sub.nickname
                        ,COUNT(*) AS mastered
                  FROM
                        (SELECT e.studentid
                               ,i.nickname
                               ,s.lastfirst
                               ,s.first_name + '' '' + s.last_name AS full_name
                               ,s.grade_level
                               ,e.exercise
                               ,e.proficient_date
                               ,e.level
                               ,e.total_done
                               ,e.total_correct
                         FROM Khan..composite_exercises#identifiers e
                         JOIN Khan..stu_detail#identifiers i
                           ON e.studentid = i.studentid
                         JOIN KIPP_NJ..STUDENTS s
                           ON e.studentid = s.id
                          AND s.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                          AND s.grade_level >= ' + CAST(@helper_low_grade AS NVARCHAR) + '                         
                          AND s.grade_level <= ' + CAST(@helper_high_grade AS NVARCHAR) + '                         
                         WHERE e.mastered = ''True''
                         ) sub
                  GROUP BY sub.studentid
                          ,sub.lastfirst
                          ,sub.nickname
                          ,sub.full_name
                  ) sub
           JOIN Khan..stu_detail#identifiers d
             ON sub.studentid = d.studentid
           ORDER BY mastered DESC
          '
         --table query 1
         ,'SELECT TOP 1000000 sub.full_name AS student
                 ,LEFT(sub.nickname,50) AS nickname
                 ,sub.mastered AS [mastered]
                 ,replace(convert(varchar,convert(Money, CAST(d.points AS FLOAT)),1),''.00'','''') AS [khan points]
           FROM
                 (SELECT sub.studentid
                        ,sub.lastfirst
                        ,sub.full_name
                        ,sub.nickname
                        ,COUNT(*) AS mastered
                  FROM
                        (SELECT e.studentid
                               ,i.nickname
                               ,s.lastfirst
                               ,s.first_name + '' '' + s.last_name AS full_name
                               ,s.grade_level
                               ,e.exercise
                               ,e.proficient_date
                               ,e.level
                               ,e.total_done
                               ,e.total_correct
                         FROM Khan..composite_exercises#identifiers e
                         JOIN Khan..stu_detail#identifiers i
                           ON e.studentid = i.studentid
                         JOIN KIPP_NJ..STUDENTS s
                           ON e.studentid = s.id
                          AND s.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                          AND s.grade_level >= ' + CAST(@helper_low_grade AS NVARCHAR) + '                         
                          AND s.grade_level <= ' + CAST(@helper_high_grade AS NVARCHAR) + '                         
                         WHERE e.mastered = ''True''
                         ) sub
                  GROUP BY sub.studentid
                          ,sub.lastfirst
                          ,sub.nickname
                          ,sub.full_name
                  ) sub
           JOIN Khan..stu_detail#identifiers d
             ON sub.studentid = d.studentid
           ORDER BY mastered DESC
          '
          --table query 2
         ,' '
          --table query 3
         ,' '
          --table query 4
         ,' '
          --table style parameters
         ,'CSS_medium'
         ,' '
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

  END

CLOSE db_cursor
DEALLOCATE db_cursor

