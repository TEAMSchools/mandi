USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [sp_ILLUMINATE$summary_assessments#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$summary_assessments#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ILLUMINATE$summary_assessments#static|refresh]
		END
		
		
		--STEP 2: load into a TEMPORARY staging table.  
  SELECT *
		INTO [#ILLUMINATE$summary_assessments#static|refresh]
		FROM ILLUMINATE$summary_assessments;   
  

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$summary_assessments#static');

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
   AND sys.objects.name = 'ILLUMINATE$summary_assessments#static';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$summary_assessments#static]
 SELECT *
 FROM [#ILLUMINATE$summary_assessments#static|refresh];

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
  AND sys.objects.name = 'ILLUMINATE$summary_assessments#static';

 EXEC (@sql);

END

GO