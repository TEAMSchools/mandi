USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_PS$emerg_release_contact#static|refresh] AS

BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$emerg_release_contact#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$emerg_release_contact#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#PS$emerg_release_contact#static|refresh]
  FROM PS$emerg_release_contact;
         

  -- STEP 3: truncate destination table
  EXEC('DELETE FROM KIPP_NJ..PS$emerg_release_contact#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$emerg_release_contact#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [PS$emerg_release_contact#static]
   (STUDENTID,EMERG_CONTACT_1,EMERG_1_REL,EMERG_PHONE_1,EMERG_CONTACT_2,EMERG_2_REL,EMERG_PHONE_2,EMERG_CONTACT_3,EMERG_3_REL,EMERG_3_PHONE,EMERG_4_NAME,EMERG_4_REL,EMERG_4_PHONE,EMERG_5_NAME,EMERG_5_REL,EMERG_5_PHONE,RELEASE_1_NAME,RELEASE_1_PHONE,RELEASE_1_RELATION,RELEASE_2_NAME,RELEASE_2_PHONE,RELEASE_2_RELATION,RELEASE_3_NAME,RELEASE_3_PHONE,RELEASE_3_RELATION,RELEASE_4_NAME,RELEASE_4_PHONE,RELEASE_4_RELATION,RELEASE_5_NAME,RELEASE_5_PHONE,RELEASE_5_RELATION)
  SELECT STUDENTID,EMERG_CONTACT_1,EMERG_1_REL,EMERG_PHONE_1,EMERG_CONTACT_2,EMERG_2_REL,EMERG_PHONE_2,EMERG_CONTACT_3,EMERG_3_REL,EMERG_3_PHONE,EMERG_4_NAME,EMERG_4_REL,EMERG_4_PHONE,EMERG_5_NAME,EMERG_5_REL,EMERG_5_PHONE,RELEASE_1_NAME,RELEASE_1_PHONE,RELEASE_1_RELATION,RELEASE_2_NAME,RELEASE_2_PHONE,RELEASE_2_RELATION,RELEASE_3_NAME,RELEASE_3_PHONE,RELEASE_3_RELATION,RELEASE_4_NAME,RELEASE_4_PHONE,RELEASE_4_RELATION,RELEASE_5_NAME,RELEASE_5_PHONE,RELEASE_5_RELATION
  FROM [#PS$emerg_release_contact#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$emerg_release_contact#static';
  EXEC (@sql);
  
END                 