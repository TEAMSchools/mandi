BEGIN TRANSACTION

USE KIPP_NJ
GO

DECLARE @this_job_name  NCHAR(100)

DECLARE bini_cursor CURSOR FOR
  --some jobs to loop over
  SELECT job_name
  FROM
        (SELECT 'AR Progress Monitoring NCA AR Intervention: McCormack, Jessica' AS job_name
         UNION
         SELECT 'AR Progress Monitoring NCA AR Intervention: Proto, Marisa'
         UNION
         SELECT 'AR Progress Monitoring NCA AR Intervention: Sgalambro, Jonathan'
         UNION
         SELECT 'AR Progress Monitoring NCA AR Intervention: White, Charisse'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Bernard, Pascale'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Blasi, Faith'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Bolden, Sharmaine'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Cangialosi, Vincent'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Lisa Cucciniello'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Fleming, Jeff'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Galbraith, Jay'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Ibeh, Katie'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: James, Jennifer'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Melgarejo, Jose'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Morrison, Jessica'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: OLeary, Kaitlyn'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Richardson, Deanna'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Richardson, Mimi'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Sarah Gray'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Weissglass, Elysha'
         UNION
         SELECT 'AR Progress Monitoring NCA Independent Reading: Williams, Renae'
         UNION
         SELECT 'AR Progress Monitoring NCA Reading Enrichment: Halpern, Katelyn'
         UNION
         SELECT 'AR Progress Monitoring NCA Reading Enrichment: Love/Taylor'
         UNION
         SELECT 'AR Progress Monitoring NCA Reading Enrichment: Proft, Kristin'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Bonnet, Andrea'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Cardosa, Karen'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Frohman, Terri'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Gillam, Norah'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Goodlow, Gigg'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Hawthorn, Eric'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Lopez, Lynette'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Mustapha, Sherry'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Rogers, Lavinia'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Teichman, Elliot'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Thaler, Melissa'
         UNION
         SELECT 'AR Progress Monitoring NCA Study Hall: Woolgar, Chris'
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
      ,'2013-12-17 10:45:00.000')

 --end of cursor action
 END

CLOSE bini_cursor
DEALLOCATE bini_cursor

COMMIT TRANSACTION
ROLLBACK TRANSACTION
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


