USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$emerg_release_contact_refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$emerg_release_contact|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$emerg_release_contact|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
  INTO [#PS$emerg_release_contact|refresh]
  FROM OPENQUERY(PS_TEAM,'
        SELECT id AS studentid      
              ,ps_customfields.getcf(''Students'',id,''Emerg_Contact_1'') AS Emerg_Contact_1
              ,ps_customfields.getcf(''Students'',id,''Emerg_1_Rel'') AS Emerg_1_Rel
              ,ps_customfields.getcf(''Students'',id,''Emerg_Phone_1'') AS Emerg_Phone_1
              ,ps_customfields.getcf(''Students'',id,''Emerg_Contact_2'') AS Emerg_Contact_2
              ,ps_customfields.getcf(''Students'',id,''Emerg_2_Rel'') AS Emerg_2_Rel
              ,ps_customfields.getcf(''Students'',id,''Emerg_Phone_2'') AS Emerg_Phone_2
              ,ps_customfields.getcf(''Students'',id,''Emerg_Contact_3'') AS Emerg_Contact_3
              ,ps_customfields.getcf(''Students'',id,''Emerg_3_Rel'') AS Emerg_3_Rel
              ,ps_customfields.getcf(''Students'',id,''Emerg_3_Phone'') AS Emerg_3_Phone
              ,ps_customfields.getcf(''Students'',id,''Emerg_4_Name'') AS Emerg_4_Name
              ,ps_customfields.getcf(''Students'',id,''Emerg_4_Rel'') AS Emerg_4_Rel
              ,ps_customfields.getcf(''Students'',id,''Emerg_4_Phone'') AS Emerg_4_Phone
              ,ps_customfields.getcf(''Students'',id,''Emerg_5_Name'') AS Emerg_5_Name
              ,ps_customfields.getcf(''Students'',id,''Emerg_5_Rel'') AS Emerg_5_Rel
              ,ps_customfields.getcf(''Students'',id,''Emerg_5_Phone'') AS Emerg_5_Phone
              ,ps_customfields.getcf(''Students'',id,''Release_1_Name'') AS Release_1_Name
              ,ps_customfields.getcf(''Students'',id,''Release_1_Phone'') AS Release_1_Phone
              ,ps_customfields.getcf(''Students'',id,''Release_1_Relation'') AS Release_1_Relation      
              ,ps_customfields.getcf(''Students'',id,''Release_2_Name'') AS Release_2_Name
              ,ps_customfields.getcf(''Students'',id,''Release_2_Phone'') AS Release_2_Phone
              ,ps_customfields.getcf(''Students'',id,''Release_2_Relation'') AS Release_2_Relation
              ,ps_customfields.getcf(''Students'',id,''Release_3_Name'') AS Release_3_Name
              ,ps_customfields.getcf(''Students'',id,''Release_3_Phone'') AS Release_3_Phone
              ,ps_customfields.getcf(''Students'',id,''Release_3_Relation'') AS Release_3_Relation
              ,ps_customfields.getcf(''Students'',id,''Release_4_Name'') AS Release_4_Name
              ,ps_customfields.getcf(''Students'',id,''Release_4_Phone'') AS Release_4_Phone
              ,ps_customfields.getcf(''Students'',id,''Release_4_Relation'') AS Release_4_Relation
              ,ps_customfields.getcf(''Students'',id,''Release_5_Name'') AS Release_5_Name
              ,ps_customfields.getcf(''Students'',id,''Release_5_Phone'') AS Release_5_Phone
              ,ps_customfields.getcf(''Students'',id,''Release_5_Relation'') AS Release_5_Relation
        FROM students
        WHERE enroll_status = 0
       ');
         
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate
  EXEC('TRUNCATE TABLE KIPP_NJ..PS$emerg_release_contact');

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
   AND sys.objects.name = 'PS$emerg_release_contact';

 EXEC (@sql);
 
 -- STEP 6: INSERT INTO final destination
 INSERT INTO [dbo].[PS$emerg_release_contact]
 SELECT *
 FROM [#PS$emerg_release_contact|refresh];

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
  AND sys.objects.name = 'PS$emerg_release_contact';

 EXEC (@sql);
  
END