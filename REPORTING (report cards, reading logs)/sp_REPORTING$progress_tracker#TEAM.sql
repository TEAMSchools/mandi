USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--ALTER PROCEDURE [dbo].[sp_REPORTING$progress_tracker#TEAM_static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#REPORTING$progress_tracker#TEAM_static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#REPORTING$progress_tracker#TEAM_static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.  
  SELECT *
		INTO [#REPORTING$progress_tracker#TEAM_static|refresh]
		FROM REPORTING$progress_tracker#TEAM_refresh
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$FP_test_events_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..REPORTING$progress_tracker#TEAM_static');

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
   AND sys.objects.name = 'REPORTING$progress_tracker#TEAM_static';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[REPORTING$progress_tracker#TEAM_static]
 SELECT *
 FROM [#REPORTING$progress_tracker#TEAM_static|refresh];

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
  AND sys.objects.name = 'REPORTING$progress_tracker#TEAM_static';

 EXEC (@sql);
  
END
GO