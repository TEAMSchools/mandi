USE KIPP_NJ
GO

ALTER PROCEDURE [sp_ILLUMINATE$summary_assessment_results_long#static|refresh] AS

BEGIN
  
  SET NOCOUNT ON

-- 1.) Drop and recreate the temp table --
  IF OBJECT_ID(N'tempdb..#ILLUMINATE$summary_assessment_results_long#static|refresh') IS NOT NULL
    DROP TABLE [#ILLUMINATE$summary_assessment_results_long#static|refresh]
    CREATE TABLE [#ILLUMINATE$summary_assessment_results_long#static|refresh] (
      repository_id INT
     ,repository_row_id INT
     ,student_id INT
     ,field NVARCHAR(MAX)
     ,value NVARCHAR(MAX)
     ,ID INT
     ,is_deleted BIT)


-- 2.) Declare variables --
  DECLARE @query NVARCHAR(MAX)
  DECLARE @repository_id NVARCHAR(MAX)
  DECLARE @cols NVARCHAR(MAX)
  DECLARE @converted_cols NVARCHAR(MAX)
  DECLARE @sql NVARCHAR(MAX)


-- 3.) Declare the cursor FOR the set of records it will loop over --
  -- cursor name MUST be unique within schema
  -- TODO: MERGE only repos created or updated in the past day  
  DECLARE illuminate_cursor CURSOR FOR
    SELECT repository_id        
    FROM OPENQUERY(ILLUMINATE,'
      SELECT repository_id          
      FROM dna_repositories.repositories    
      WHERE deleted_at IS NULL      
        AND (created_at >= (current_date - interval ''1 day'') OR updated_at >= (current_date - interval ''1 day''))
        AND repository_id <= 110
      ORDER BY repository_id DESC
    ')

  		    
-- 4.) Do work, son --
  -- boilerplate cursor stuff
  OPEN illuminate_cursor
  WHILE 1 = 1
    BEGIN
    
      FETCH NEXT FROM illuminate_cursor INTO @repository_id
      
      IF @@FETCH_STATUS <> 0
        BEGIN
          BREAK
        END  
    
      -- grab column headers using GROUP_CONCAT
      -- this allows you to SELECT/INSERT/UNPIVOT arbitrary column names
      SELECT @cols = '[' + dbo.GROUP_CONCAT_D(name, '],[') + ']'
      FROM OPENQUERY(ILLUMINATE,'
        SELECT name
              ,repository_id
        FROM dna_repositories.fields  
        WHERE deleted_at IS NULL        
      ')
      WHERE repository_id = @repository_id

      -- grab another set of column headers for the SELECT statement, CONVERTing everything to TEXT (NVARCHAR)
      -- this avoids the data-type collisions that would otherwise occur during the UNPIVOT
      SELECT @converted_cols = dbo.GROUP_CONCAT_D('CONVERT(NVARCHAR(MAX),' + name + ') AS ' + name, ',')
      FROM OPENQUERY(ILLUMINATE,'
        SELECT name
              ,repository_id
        FROM dna_repositories.fields
        WHERE deleted_at IS NULL
      ')
      WHERE repository_id = @repository_id

      -- here's the beef, the query that the cursor is going to iterate over
      -- for each repo, SELECT the columns, CONVERT them to TEXT, and then UNPIVOT into a normalized form
      -- then INSERT INTO the temp table      
      SET @query = N'INSERT INTO [#ILLUMINATE$summary_assessment_results_long#static|refresh]
        SELECT ' + @repository_id + ' AS repository_id
               ,repository_row_id
               ,student_id
               ,field
               ,value
               ,NULL AS ID
               ,0 AS is_deleted
        FROM 
            (
             SELECT local_student_id AS student_id
                   ,repository_row_id
                   ,' + @converted_cols + '
             FROM OPENQUERY(ILLUMINATE,''
               SELECT s.local_student_id          
                     ,repo.*
               FROM dna_repositories.repository_' + @repository_id + ' repo 
               JOIN public.students s 
                 ON repo.student_id = s.student_id
             '')
            ) sub
        UNPIVOT (
          value
          FOR field IN (' + @cols + ')
         ) unpiv
      '        
      
      -- print the query that has just been prepared (for debugging)
      RAISERROR(@query, 0, 1)
      
      -- execute the query string above
      -- wash, rinse, repeat
      EXEC(@query)
          
    END

  -- this is important
  CLOSE illuminate_cursor
  DEALLOCATE illuminate_cursor;


-- 5.) UPSERT: matching on repo, row number, studentid, and field name.  DELETE if on TARGET but not MATCHED by SOURCE
  MERGE ILLUMINATE$summary_assessment_results_long#static AS TARGET
  USING 
       (
        SELECT repository_id
              ,repository_row_id
              ,student_id
              ,field
              ,value
        FROM [#ILLUMINATE$summary_assessment_results_long#static|refresh]
       ) AS SOURCE  
       (
        repository_id
       ,repository_row_id
       ,student_id
       ,field
       ,value
       )
     ON TARGET.repository_id = SOURCE.repository_id
    AND TARGET.repository_row_id = SOURCE.repository_row_id
    AND TARGET.student_id = SOURCE.student_id
    AND TARGET.field = SOURCE.field           
  WHEN MATCHED THEN 
   UPDATE
    SET TARGET.value = SOURCE.value          
  WHEN NOT MATCHED BY TARGET THEN 
   INSERT
    (repository_id
    ,repository_row_id
    ,student_id
    ,field
    ,value)
   VALUES 
    (SOURCE.repository_id
    ,SOURCE.repository_row_id
    ,SOURCE.student_id
    ,SOURCE.field
    ,SOURCE.value)
  WHEN NOT MATCHED BY SOURCE AND TARGET.repository_id IN (SELECT repository_id FROM [#ILLUMINATE$summary_assessment_results_long#static|refresh]) THEN 
   DELETE
  OUTPUT $ACTION, deleted.*;

END

GO


/* -- IN CASE OF EMERGENCY, OLD TRUNCATE/INSERT CODE
  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$summary_assessment_results_long#static');


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
   AND sys.objects.name = 'ILLUMINATE$summary_assessment_results_long#static';
 EXEC (@sql);


 -- step 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$summary_assessment_results_long#static]
   (repository_id
   ,repository_row_id
   ,student_id
   ,field
   ,value         
   ,is_deleted)
 SELECT repository_id
       ,repository_row_id
       ,student_id
       ,field
       ,value         
       ,is_deleted
 FROM [#ILLUMINATE$summary_assessment_results_long#static|refresh];
 

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
  AND sys.objects.name = 'ILLUMINATE$summary_assessment_results_long#static';
 EXEC (@sql);
*/