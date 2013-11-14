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
 ('AR Millionaire Tracking, TEAM Gr. School'
 ,'auto'
 ,'2013-11-15 07:45:00.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 22


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Millionaire Tracking, TEAM Gr. 5'
   ,@send_again = @fake OUTPUT

END


*/

USE KIPP_NJ
GO

DECLARE @helper_schoolid    INT = 133570965
       ,@helper_school      VARCHAR(5) = 'TEAM'
       ,@helper_grade_level VARCHAR(6) = 'School'
       ,@this_job_name      NCHAR(100)
       
BEGIN
  SET @this_job_name = 'AR Millionaire Tracking, ' + @helper_school + ' Gr. ' + @helper_grade_level

MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     (--'amartin@teamschools.org'

        --5th Rise
        --'kdjones@teamschools.org;srutherford@teamschools.org;mjoseph@teamschools.org;dbranson@teamschools.org;eburgos@teamschools.org;ninya-agha@teamschools.org;lepstein@teamschools.org;kgalarza@teamschools.org;kpasheluk@teamschools.org'
        --6th Rise
        --'kdjones@teamschools.org;srutherford@teamschools.org;mjoseph@teamschools.org;dbranson@teamschools.org;eburgos@teamschools.org;ninya-agha@teamschools.org;svanwingerden@teamschools.org;rthomas@teamschools.org;jjones@teamschools.org;scopeland@teamschools.org;ljoseph@teamschools.org'
        --7th Rise
        --'kdjones@teamschools.org;srutherford@teamschools.org;mjoseph@teamschools.org;dbranson@teamschools.org;eburgos@teamschools.org;ninya-agha@teamschools.org;svanwingerden@teamschools.org;msorresso@teamschools.org;cbraman@teamschools.org;melguero@teamschools.org'
        --8th Rise
        --'kdjones@teamschools.org;srutherford@teamschools.org;mjoseph@teamschools.org;dbranson@teamschools.org;eburgos@teamschools.org;ninya-agha@teamschools.org;svanwingerden@teamschools.org;ageiger@teamschools.org;jroman@teamschools.org;rmccreary@teamschools.org;ddobkowski@teamschools.org'
        --SCHOOL Rise
        --'kdjones@teamschools.org;dbranson@teamschools.org'         

        --5th TEAM
        --'anagle@teamschools.org;nvielee@teamschools.org;bdixon@teamschools.org;hfisher@teamschools.org'
        --6th TEAM
        --'dsonnier@teamschools.org;arosenbush@teamschools.org;hturner@teamschools.org;nvielee@teamschools.org;hfisher@teamschools.org'
        --7th TEAM
        --'afurstenau@teamschools.org;hfisher@teamschools.org;mkaiser@teamschools.org;nvielee@teamschools.org;hfisher@teamschools.org'
        --8th TEAM
        --'malgarin@teamschools.org;ssurrey@teamschools.org;hfisher@teamschools.org;nvielee@teamschools.org'
        --SCHOOL TEAM
        'malgarin@teamschools.org;dsonnier@teamschools.org;hfisher@teamschools.org'         

        --SCHOOL TEAM
       ,@this_job_name
       --figure out SEND AGAIN
       ,'SELECT DATEADD(
           DAY, 7, 
             --tldr - 7:45 TODAY
             DATEADD(mi, 45, 
               DATEADD(hh, 7,
                --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
               (DATEADD(yy, DATEPART(YYYY, GETDATE())-1900, 
                --SETS THE MONTH AND DAY PART TO TODAY
                  DATEADD(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1)))
               )
             )
          )'
       ,2
        --stat query 1
       ,'SELECT millionaires
         FROM
               (SELECT school
                      ,CASE GROUPING(grade_level)
                         WHEN 1 THEN ''School''
                         ELSE CAST(grade_level AS VARCHAR)
                       END AS grade_level
                      ,SUM(cur_millionaire_test) AS millionaires
                FROM KIPP_NJ..AR$millionaires#on_track
                GROUP BY school
                        ,CUBE(grade_level)
                ) sub
         WHERE school = ''' + @helper_school + '''
           AND grade_level = ''' + @helper_grade_level + '''
        '
        --stat query 2
       ,'SELECT proj_eoy
         FROM
               (SELECT school
                      ,CASE GROUPING(grade_level)
                         WHEN 1 THEN ''School''
                         ELSE CAST(grade_level AS VARCHAR)
                       END AS grade_level
                      ,SUM(proj_millionaire_dummy) AS proj_eoy
                FROM KIPP_NJ..AR$millionaires#on_track
                GROUP BY school
                        ,CUBE(grade_level)
                ) sub
         WHERE school = ''' + @helper_school + '''
           AND grade_level = ''' + @helper_grade_level + '''
         '
         --stat query 3
        ,'
         '
         --stat query 4
        ,'
         '
         --stat labels 1-4
        ,'# Millionaires'
        ,'Projected EOY Millionaires'
        ,' '
        ,' '
        --image stuff
        ,1
        --dynamic filepath
        ,'\\WINSQL01\r_images\DATEKEY_ar_millionaires_' + @helper_school + '_gr_' + @helper_grade_level + '_wide.png'
        ,' '
        --regular text (use single space for nulls)
        ,'Current millionaires'
        ,'At current pace, will end the year with 1 million+ words:'
        ,'Need a boost: Students projected to end the year between 750K and 1 million'
        ,' '
        --csv stuff
        ,'On'
        --csv query -- all students, no restriction on status
        ,'SELECT sub.student_name
                ,CAST(sub.basic_grade AS VARCHAR) AS grade_level
                ,sub.cur_millionaire
                ,sub.words_read_year
                ,sub.school_rank
                ,sub.network_rank
          FROM
                (SELECT TOP 10000000 ar.student_name
                       ,CASE GROUPING(ar.grade_level)
                          WHEN 1 THEN ''School''
                          ELSE CAST(ar.grade_level AS VARCHAR)
                        END AS grade_level
                       ,s.grade_level AS basic_grade 
                       ,CASE
                          WHEN ar.cur_millionaire_test = 1 THEN ''Yes''
                          WHEN ar.cur_millionaire_test = 0 THEN ''No''
                        END AS cur_millionaire                        
                       ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words_read_year        
                       ,CAST(ar.rank_words_overall_in_school AS VARCHAR) AS school_rank
                       ,CAST(ar.rank_words_overall_in_network AS VARCHAR) AS network_rank
                 FROM KIPP_NJ..AR$millionaires#on_track ar
                 JOIN KIPP_NJ..STUDENTS s
                   ON ar.studentid = s.id
                 WHERE ar.school = ''' + @helper_school + '''
                 GROUP BY ar.student_name
                         ,ar.lastfirst
                         ,CUBE(ar.grade_level)
                         ,s.grade_level
                         ,ar.words
                         ,ar.cur_millionaire_test
                         ,ar.rank_words_overall_in_school
                         ,ar.rank_words_overall_in_network
                 ORDER BY ar.cur_millionaire_test DESC
                         ,s.grade_level                         
                         ,ar.lastfirst
                 ) sub
           WHERE sub.grade_level = ''' + @helper_grade_level + '''
          '
        --table query 1
        ,'SELECT main.student_name, main.grade_level, main.words_read_year, main.school_rank, main.network_rank, CAST(sub.date AS VARCHAR) AS became_millionaire
FROM
      (SELECT sub.student_name
             ,sub.studentid
             ,CAST(sub.basic_grade AS VARCHAR) AS grade_level
             ,sub.words_read_year
             ,sub.school_rank
             ,sub.network_rank
       FROM
             (SELECT TOP 10000000 ar.student_name
                    ,s.id AS studentid
                    ,CASE GROUPING(ar.grade_level)
                       WHEN 1 THEN ''School''
                       ELSE CAST(ar.grade_level AS VARCHAR)
                     END AS grade_level
                    ,s.grade_level AS basic_grade
                    ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words_read_year        
                    ,CAST(ar.rank_words_overall_in_school AS VARCHAR) AS school_rank
                    ,CAST(ar.rank_words_overall_in_network AS VARCHAR) AS network_rank
              FROM KIPP_NJ..AR$millionaires#on_track ar
              JOIN KIPP_NJ..STUDENTS s ON ar.studentid = s.id
              WHERE ar.school = ''' + @helper_school + '''
                AND ar.cur_millionaire_test = 1
              GROUP BY ar.student_name, ar.lastfirst, s.id, CUBE(ar.grade_level), s.grade_level, ar.words, ar.rank_words_overall_in_school, ar.rank_words_overall_in_network
              ORDER BY s.grade_level, ar.lastfirst
              ) sub
        WHERE sub.grade_level = ''' + @helper_grade_level + '''
       ) main
JOIN 
     (SELECT sub.*
      FROM
               (SELECT sub.*
                      ,ROW_NUMBER() OVER
                         (PARTITION BY studentid
                          ORDER BY sub.date ASC) AS rn
                FROM
                      (SELECT scaffold.studentid, scaffold.grade_level, scaffold.school, scaffold.year, scaffold.date
                             ,SUM(CASE WHEN det.tipassed = 1 THEN det.iwordcount ELSE 0 END) AS words
                       FROM 
                         (SELECT c.studentid, s.student_number, c.grade_level
                                ,sch.abbreviation AS school, c.year
                                ,CONVERT(datetime, CAST(''07/01/'' + c.year AS DATE), 101) AS start_date_ar
                                ,c.entrydate, c.exitdate
                                ,CAST(rd.date AS DATE) AS date
                          FROM KIPP_NJ..[COHORT$comprehensive_long#static] c WITH (NOLOCK)
                          JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
                            ON c.schoolid = sch.school_number
                          JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
                            ON c.studentid = s.id
                          JOIN KIPP_NJ..UTIL$reporting_days rd WITH (NOLOCK)
                            ON rd.date <= CAST(GETDATE() AS date)
                           AND rd.date >= ''07-01-2013''
                           AND rd.date >= c.entrydate AND rd.date <  c.exitdate     
                          WHERE c.schoolid = ' + CAST(@helper_schoolid AS VARCHAR) + '
                            AND c.year = 2013 AND c.rn = 1
                         ) scaffold
                       JOIN KIPP_NJ..[AR$test_event_detail#static] det WITH (NOLOCK)
                         ON CAST(scaffold.student_number AS VARCHAR) = det.student_number
                        AND det.dtTaken >= scaffold.start_date_ar
                        AND det.dtTaken <  scaffold.date
                       GROUP BY scaffold.studentid, scaffold.grade_level, scaffold.school, scaffold.year, scaffold.date
                       ) sub
                WHERE words >= 1000000
                ) sub
         WHERE rn = 1
      ) sub
  ON main.studentid = sub.studentid'
          --table query 2
        ,'SELECT sub.student_name
                ,CAST(sub.basic_grade AS VARCHAR) AS grade_level
                ,sub.words_read_year
                ,sub.school_rank
                ,sub.network_rank
          FROM
                (SELECT TOP 10000000 ar.student_name
                       ,CASE GROUPING(ar.grade_level)
                          WHEN 1 THEN ''School''
                          ELSE CAST(ar.grade_level AS VARCHAR)
                        END AS grade_level
                       ,s.grade_level AS basic_grade
                       ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words_read_year        
                       ,CAST(ar.rank_words_overall_in_school AS VARCHAR) AS school_rank
                       ,CAST(ar.rank_words_overall_in_network AS VARCHAR) AS network_rank
                 FROM KIPP_NJ..AR$millionaires#on_track ar
                 JOIN KIPP_NJ..STUDENTS s
                   ON ar.studentid = s.id
                 WHERE ar.school = ''' + @helper_school + '''
                   AND ar.cur_millionaire_test = 0
                   AND ar.proj_millionaire_dummy = 1
                 GROUP BY ar.student_name
                         ,ar.lastfirst
                         ,CUBE(ar.grade_level)
                         ,s.grade_level
                         ,ar.words
                         ,ar.rank_words_overall_in_school
                         ,ar.rank_words_overall_in_network
                 ORDER BY s.grade_level
                         ,ar.lastfirst
                 ) sub
           WHERE sub.grade_level = ''' + @helper_grade_level + '''
          '
          --table query 3
        ,'SELECT sub.student_name
                ,CAST(sub.basic_grade AS VARCHAR) AS grade_level
                ,sub.words_read_year
                ,sub.school_rank
                ,sub.network_rank
          FROM
                (SELECT TOP 10000000 ar.student_name
                       ,CASE GROUPING(ar.grade_level)
                          WHEN 1 THEN ''School''
                          ELSE CAST(ar.grade_level AS VARCHAR)
                        END AS grade_level
                       ,s.grade_level AS basic_grade
                       ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words_read_year        
                       ,CAST(ar.rank_words_overall_in_school AS VARCHAR) AS school_rank
                       ,CAST(ar.rank_words_overall_in_network AS VARCHAR) AS network_rank
                 FROM KIPP_NJ..AR$millionaires#on_track ar
                 JOIN KIPP_NJ..STUDENTS s
                   ON ar.studentid = s.id
                 WHERE ar.school = ''' + @helper_school + '''
                   AND ar.cur_millionaire_test = 0
                   AND ar.proj_yr_words >= 750000
                   AND ar.proj_yr_words < 1000000
                 GROUP BY ar.student_name
                         ,ar.lastfirst
                         ,CUBE(ar.grade_level)
                         ,s.grade_level
                         ,ar.words
                         ,ar.rank_words_overall_in_school
                         ,ar.rank_words_overall_in_network
                 ORDER BY s.grade_level
                         ,ar.lastfirst
                 ) sub
           WHERE sub.grade_level = ''' + @helper_grade_level + '''
          '
          --table style parameters
         ,'CSS_small'
         ,'CSS_small'
         ,'CSS_small'
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