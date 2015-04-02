USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_GRADES$STOREDGRADES#static|refresh] AS
BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#GRADES$STOREDGRADES#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#GRADES$STOREDGRADES#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#GRADES$STOREDGRADES#static|refresh]
  FROM GRADES$STOREDGRADES;
         

  -- STEP 3: truncate destination table
  EXEC('TRUNCATE TABLE KIPP_NJ..GRADES$STOREDGRADES#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'GRADES$STOREDGRADES#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [GRADES$STOREDGRADES#static]
  SELECT *
  FROM [#GRADES$STOREDGRADES#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'GRADES$STOREDGRADES#static';
  EXEC (@sql);
  
END                  