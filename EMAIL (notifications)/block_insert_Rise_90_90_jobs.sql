BEGIN TRANSACTION

USE KIPP_NJ
GO

DECLARE @this_job_name  NCHAR(100)

DECLARE bini_cursor CURSOR FOR
  --some jobs to loop over
  SELECT job_name
  FROM
        (SELECT 'Rise 90/90 Tracking, Rise Advisor Amanda Geiger' AS job_name
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Mark Joseph'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Travis Dempsey'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Daniel Gosselink'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Doug Dobkowski'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Jyron Brooks'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Kristen Jones'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Kristen Pasheluk'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Kristin Kell'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Laura Joseph'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Advisor Marissa Perlman'
         UNION        
         SELECT 'Rise 90/90 Tracking, Rise Advisor Stephany Copeland'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Grade 5'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Grade 6'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Grade 7'
         UNION
         SELECT 'Rise 90/90 Tracking, Rise Grade 8'
         ) sub

OPEN bini_cursor
WHILE 1 = 1
 BEGIN
   FETCH NEXT FROM bini_cursor INTO @this_job_name

   --what to do if we're out of rows
   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   --CURSOR ACTION HERE
     --poor man's print
     DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
     DECLARE @msg nvarchar(200) = '''%s'''
     RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

     INSERT INTO KIPP_NJ..email$template_queue
       (job_name
       ,run_type
       ,send_at)
     VALUES
      (@this_job_name
      ,'auto'
      ,'2013-11-18 07:11:00.000')

 --end of cursor action
 END

CLOSE bini_cursor
DEALLOCATE bini_cursor

COMMIT TRANSACTION

/*

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('AR Millionaire Tracking, TEAM Gr. School'
 ,'auto'
 ,'2013-11-15 07:45:00.000')
*/


