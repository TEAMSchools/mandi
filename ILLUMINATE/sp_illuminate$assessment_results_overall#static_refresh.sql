USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_ILLUMINATE$assessment_results_overall#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$assessment_results_overall#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ILLUMINATE$assessment_results_overall#static|refresh]
		END

  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#ILLUMINATE$assessment_results_overall#static|refresh]
  FROM ILLUMINATE$assessment_results_overall;

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$assessment_results_overall#static');

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
   AND sys.objects.name = 'ILLUMINATE$assessment_results_overall#static';

 EXEC (@sql);

 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$assessment_results_overall#static]
 SELECT *
 FROM [#ILLUMINATE$assessment_results_overall#static|refresh];
 
 -- STEP 7: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'ILLUMINATE$assessment_results_overall#static';

 EXEC (@sql);
  
END

GO