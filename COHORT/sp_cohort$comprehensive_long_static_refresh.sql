USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_COHORT$comprehensive_long#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#COHORT$comprehensive_long#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#COHORT$comprehensive_long#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT cohort.*
		INTO [#COHORT$comprehensive_long#static|refresh]
  FROM COHORT$comprehensive_long cohort
   
  --STEP 4: truncate result table
  EXEC('TRUNCATE TABLE dbo.[COHORT$comprehensive_long#static]');

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
   AND sys.objects.name = 'COHORT$comprehensive_long#static';

 EXEC (@sql);

 -- step 6: insert rows into destination table
 INSERT INTO [dbo].[COHORT$comprehensive_long#static]
      ([STUDENTID]
      ,[LASTFIRST]
      ,[HIGHEST_ACHIEVED]
      ,[GRADE_LEVEL]
      ,[SCHOOLID]
      ,[ABBREVIATION]
      ,[YEAR]
      ,[COHORT]
      ,[ENTRYCODE]
      ,[EXITCODE]
      ,[ENTRYDATE]
      ,[EXITDATE]
      ,[RN]
      ,[YEAR_IN_NETWORK])
 SELECT *
 FROM [#COHORT$comprehensive_long#static|refresh];

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
  AND sys.objects.name = 'COHORT$comprehensive_long#static';

 EXEC (@sql);
  
END
GO