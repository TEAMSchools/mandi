USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_MAP$growth_measures_long#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#MAP$growth_measures_long#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#MAP$growth_measures_long#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT *
		INTO [#MAP$growth_measures_long#static|refresh]
  FROM KIPP_NJ..MAP$growth_measures_long
       
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [MAP$growth_measures_long#static] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[MAP$growth_measures_long#static]');

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
   AND sys.objects.name = 'MAP$growth_measures_long#static';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[MAP$growth_measures_long#static]
 SELECT *
 FROM [#MAP$growth_measures_long#static|refresh];

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
  AND sys.objects.name = 'MAP$growth_measures_long#static';

 EXEC (@sql);
  
END
GO
