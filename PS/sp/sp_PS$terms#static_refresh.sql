USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_PS$terms#static|refresh] AS

BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$terms#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$terms#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#PS$terms#static|refresh]
  FROM PS$terms;
         

  -- STEP 3: truncate destination table
  EXEC('DELETE FROM KIPP_NJ..PS$terms#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$terms#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [PS$terms#static]
   (DCID,ID,NAME,FIRSTDAY,LASTDAY,YEARID,ABBREVIATION,NOOFDAYS,SCHOOLID,YEARLYCREDITHRS,TERMSINYEAR,PORTION,IMPORTMAP,AUTOBUILDBIN,ISYEARREC,PERIODS_PER_DAY,DAYS_PER_CYCLE,ATTENDANCE_CALCULATION_CODE,STERMS,TERMINFO_GUID,PSGUID)
  SELECT DCID,ID,NAME,FIRSTDAY,LASTDAY,YEARID,ABBREVIATION,NOOFDAYS,SCHOOLID,YEARLYCREDITHRS,TERMSINYEAR,PORTION,IMPORTMAP,AUTOBUILDBIN,ISYEARREC,PERIODS_PER_DAY,DAYS_PER_CYCLE,ATTENDANCE_CALCULATION_CODE,STERMS,TERMINFO_GUID,PSGUID
  FROM [#PS$terms#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$terms#static';
  EXEC (@sql);
  
END                  