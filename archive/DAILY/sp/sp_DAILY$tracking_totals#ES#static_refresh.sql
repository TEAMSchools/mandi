USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_DAILY$tracking_totals#ES#static|refresh] AS
BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#DAILY$tracking_totals#ES#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#DAILY$tracking_totals#ES#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#DAILY$tracking_totals#ES#static|refresh]
  FROM DAILY$tracking_totals#ES;
         

  -- STEP 3: truncate destination table
  EXEC('TRUNCATE TABLE KIPP_NJ..DAILY$tracking_totals#ES#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'DAILY$tracking_totals#ES#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [DAILY$tracking_totals#ES#static]
  SELECT *
  FROM [#DAILY$tracking_totals#ES#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'DAILY$tracking_totals#ES#static';
  EXEC (@sql);
  
END                  
