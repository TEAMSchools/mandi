USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_LIT$FP_test_events_long#identifiers|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#LIT$FP_test_events_long#identifiers|refresh1') IS NOT NULL
		BEGIN
						DROP TABLE [#LIT$FP_test_events_long#identifiers|refresh1]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT *
		INTO [#LIT$FP_test_events_long#identifiers|refresh1]
  FROM [LIT$FP_test_events_long#identifiers] WITH(NOLOCK)
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$FP_test_events_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[LIT$FP_test_events_long#identifiers#static]');

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
   AND sys.objects.name = 'LIT$FP_test_events_long#identifiers';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[LIT$FP_test_events_long#identifiers#static]      
 SELECT *
 FROM [#LIT$FP_test_events_long#identifiers|refresh1];

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
  AND sys.objects.name = 'LIT$FP_test_events_long#identifiers';

 EXEC (@sql);
  
END
GO