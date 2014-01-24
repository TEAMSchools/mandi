USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$bus_info_refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$bus_info|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$bus_info|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
  INTO [#PS$bus_info|refresh]
  FROM OPENQUERY(PS_TEAM,'
         SELECT id AS studentid      
               ,ps_customfields.getcf(''Students'',id,''Bus_Info_AM'') AS Bus_Info_AM
               ,ps_customfields.getcf(''Students'',id,''Bus_Info_PM_Summer'') AS Bus_Info_PM_Summer
               ,ps_customfields.getcf(''Students'',id,''Bus_Info_PM'') AS Bus_Info_PM
               ,ps_customfields.getcf(''Students'',id,''Bus_Info_Fridays'') AS Bus_Info_Fridays
               ,ps_customfields.getcf(''Students'',id,''Bus_Notes'') AS Bus_Notes
               ,ps_customfields.getcf(''Students'',id,''Bus_Name_AM'') AS Bus_Name_AM
               ,ps_customfields.getcf(''Students'',id,''Bus_Stop_AM'') AS Bus_Stop_AM
               ,ps_customfields.getcf(''Students'',id,''bus_time_am'') AS bus_time_am
               ,ps_customfields.getcf(''Students'',id,''Bus_Name_PM'') AS Bus_Name_PM
               ,ps_customfields.getcf(''Students'',id,''Bus_Stop_PM'') AS Bus_Stop_PM
               ,ps_customfields.getcf(''Students'',id,''bus_time_pm'') AS bus_time_pm
               ,ps_customfields.getcf(''Students'',id,''geocode'') AS geocode
               ,ps_customfields.getcf(''Students'',id,''Bus_Info_BGC'') AS Bus_Info_BGC
         FROM students
         WHERE schoolid IN (73254,73255,73256)
           AND enroll_status = 0
       ');
         
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate
  EXEC('TRUNCATE TABLE KIPP_NJ..PS$bus_info');

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
   AND sys.objects.name = 'PS$bus_info';

 EXEC (@sql);
 
 -- STEP 6: INSERT INTO final destination
 INSERT INTO [dbo].[PS$bus_info]
 SELECT *
 FROM [#PS$bus_info|refresh];

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
  AND sys.objects.name = 'PS$bus_info';

 EXEC (@sql);
  
END