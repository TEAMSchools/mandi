USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [sp_ILLUMINATE$repository_fields#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$repository_fields#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ILLUMINATE$repository_fields#static|refresh]
		END
		
		
		--STEP 2: load into a TEMPORARY staging table.  
  SELECT *
		INTO [#ILLUMINATE$repository_fields#static|refresh]
		FROM (
		      SELECT *
              ,ROW_NUMBER() OVER(
                  PARTITION BY repository_id, dupe_check
                      ORDER BY updated_at DESC) AS rn
        FROM
            (
             SELECT *
                   ,CASE WHEN CHARINDEX('_', RIGHT(name, 2)) > 0 THEN LEFT(name, (LEN(name) - 2)) ELSE name END AS dupe_check
             FROM OPENQUERY(ILLUMINATE,'
               SELECT repository_id        
                     ,field_id
                     ,name        
                     ,label
                     ,type
                     ,seq
                     ,calculation        
                     ,expression_id                
                     ,created_at
                     ,updated_at           
                     ,deleted_at     
               FROM dna_repositories.fields
             ')
            ) sub
		     ) rustandmartysurvive;
  

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$repository_fields');


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
   AND sys.objects.name = 'ILLUMINATE$repository_fields';
 EXEC (@sql);


 -- step 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$repository_fields]
 SELECT *
 FROM [#ILLUMINATE$repository_fields#static|refresh];
 

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
  AND sys.objects.name = 'ILLUMINATE$repository_fields';
 EXEC (@sql);

END

GO