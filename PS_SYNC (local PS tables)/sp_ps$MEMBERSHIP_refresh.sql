USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$MEMBERSHIP|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$MEMBERSHIP|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$MEMBERSHIP|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#PS$MEMBERSHIP|refresh]
  FROM OPENQUERY(PS_TEAM,'
     SELECT ctod.studentid
           ,ctod.student_number
           ,ctod.schoolid
           ,ctod.calendardate
           ,ctod.fteid
           ,ctod.attendance_conversion_id
           ,ctod.attendancevalue
           ,ctod.membershipvalue             
           ,ctod.ontrack
           ,ctod.offtrack
           ,ctod.student_track
           ,ctod.potential_attendancevalue
     FROM pssis_adaadm_daily_ctod ctod
     JOIN terms
       ON terms.firstday <= ctod.calendardate
      AND terms.lastday >= ctod.calendardate
      AND terms.yearid = 23
      AND terms.schoolid = ctod.schoolid
      AND terms.portion = 1     
     ORDER BY ctod.studentid
             ,ctod.calendardate
  ');
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$FP_test_events_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..MEMBERSHIP');

  --STEP 5: disable all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'MEMBERSHIP';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[MEMBERSHIP]
 SELECT *
 FROM [#PS$MEMBERSHIP|refresh];

 -- Step 4: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'MEMBERSHIP';

 EXEC (@sql);
  
END