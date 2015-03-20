USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_COHORT$comprehensive_long#static|refresh] AS

BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#COHORT$comprehensive_long#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#COHORT$comprehensive_long#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#COHORT$comprehensive_long#static|refresh]
  FROM COHORT$comprehensive_long;
         

  -- STEP 3: truncate destination table
  EXEC('DELETE FROM KIPP_NJ..COHORT$comprehensive_long#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'COHORT$comprehensive_long#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [COHORT$comprehensive_long#static]
   (studentid,STUDENT_NUMBER,lastfirst,highest_achieved,grade_level,schoolid,abbreviation,year,cohort,entrycode,exitcode,entrydate,exitdate,rn,year_in_network)
  SELECT studentid,STUDENT_NUMBER,lastfirst,highest_achieved,grade_level,schoolid,abbreviation,year,cohort,entrycode,exitcode,entrydate,exitdate,rn,year_in_network
  FROM [#COHORT$comprehensive_long#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'COHORT$comprehensive_long#static';
  EXEC (@sql);
  
END                  
