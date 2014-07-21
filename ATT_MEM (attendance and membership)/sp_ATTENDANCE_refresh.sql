USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$ATTENDANCE|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$ATTENDANCE|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$ATTENDANCE|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#PS$ATTENDANCE|refresh]
  FROM OPENQUERY(PS_TEAM,'
    SELECT att.*
    FROM PS_ATTENDANCE_DAILY att
    JOIN terms
      ON terms.firstday <= att.att_date
     AND terms.lastday >= att.att_date
     AND terms.yearid >= 23
     AND terms.schoolid = att.schoolid
     AND terms.portion = 1     
    WHERE att.att_date <= TRUNC(SYSDATE)    
  ');
   
  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ATTENDANCE');

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
   AND sys.objects.name = 'ATTENDANCE';
  EXEC (@sql);

  -- step 6: insert into final destination
  INSERT INTO [dbo].[ATTENDANCE]
  SELECT *
  FROM [#PS$ATTENDANCE|refresh];

  -- Step 7: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'ATTENDANCE';
  EXEC (@sql);
  
END