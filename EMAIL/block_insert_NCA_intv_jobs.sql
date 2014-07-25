BEGIN TRANSACTION

USE KIPP_NJ
GO

DECLARE @this_job_name  NCHAR(100)
DECLARE bini_cursor CURSOR 

FOR --some jobs to loop over
  SELECT job_name
  FROM
      (
       SELECT 'AR Progress Monitoring NCA Study Hall: Apollon, Roger' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA AR Intervention: Cham, Rebecca' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA ReadLIVE: Walters, Anthony' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA ReadLIVE: DeFinis, Victoria' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA Math RtI: Wright, Bri' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA Study Hall: Blasi, Faith' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA ReadLIVE: Galbraith, Jay' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA Independent Reading: Cham, Rebecca' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA ReadLIVE: Scorzafava, Tina' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA Math RtI: Kendig, Ashley' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA Math RtI: Esteban/McKenzie' AS job_name
       UNION
       SELECT 'AR Progress Monitoring NCA Math RtI: Dockins' AS job_name         
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
     ,'2013-03-21 10:45:00.000')

 END --end of cursor action

CLOSE bini_cursor

DEALLOCATE bini_cursor

COMMIT TRANSACTION
--ROLLBACK TRANSACTION
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