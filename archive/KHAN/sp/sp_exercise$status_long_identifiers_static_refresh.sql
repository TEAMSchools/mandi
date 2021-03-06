USE Khan
GO
/****** Object:  StoredProcedure [dbo].[sp_exercise$status_long#identifiers#static|refresh]    Script Date: 05/01/2014 12:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_exercise$status_long#identifiers#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';
 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#exercise$status_long#identifiers#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#exercise$status_long#identifiers#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT k.*
		INTO [#exercise$status_long#identifiers#static|refresh]
  FROM exercise$status_long#identifiers k
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [exercise$status_long#identifiers#static] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[exercise$status_long#identifiers#static]');

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
   AND sys.objects.name = 'exercise$status_long#identifiers#static';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[exercise$status_long#identifiers#static]
 SELECT *
 FROM [#exercise$status_long#identifiers#static|refresh];

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
  AND sys.objects.name = 'exercise$status_long#identifiers#static';

 EXEC (@sql);
  
END
