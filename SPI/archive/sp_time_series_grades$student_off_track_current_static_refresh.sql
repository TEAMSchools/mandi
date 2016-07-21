USE [SPI]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_TIME_SERIES_GRADES$student_off_track_current#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#TIME_SERIES_GRADES$student_off_track_current|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#TIME_SERIES_GRADES$student_off_track_current|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT *
		INTO [#TIME_SERIES_GRADES$student_off_track_current|refresh]
  FROM [TIME_SERIES_GRADES$student_off_track_current]
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [TIME_SERIES_GRADES$student_off_track_current] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[TIME_SERIES_GRADES$student_off_track_current#static]');

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
   AND sys.objects.name = 'TIME_SERIES_GRADES$student_off_track_current';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[TIME_SERIES_GRADES$student_off_track_current#static]
 SELECT *
 FROM [#TIME_SERIES_GRADES$student_off_track_current|refresh];

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
  AND sys.objects.name = 'TIME_SERIES_GRADES$student_off_track_current';

 EXEC (@sql);
  
END
GO
