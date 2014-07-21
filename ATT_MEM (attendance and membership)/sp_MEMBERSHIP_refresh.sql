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
           ,s.student_number
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
     FROM ps_adaadm_daily_ctod ctod
     JOIN students s
       ON ctod.studentid = s.id
     JOIN terms
       ON ctod.schoolid = terms.schoolid
      AND ctod.calendardate >= terms.firstday 
      AND ctod.calendardate <= terms.lastday
      AND terms.yearid >= 23
      AND terms.portion = 1     
     WHERE ctod.calendardate <= TRUNC(SYSDATE)
  ');

  --STEP 3: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..MEMBERSHIP');

  --STEP 4: disable all nonclustered indexes on table
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

 -- step 5: insert into final destination
 INSERT INTO [dbo].[MEMBERSHIP]
 SELECT *
 FROM [#PS$MEMBERSHIP|refresh];

 -- Step 6: rebuld all nonclustered indexes on table
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