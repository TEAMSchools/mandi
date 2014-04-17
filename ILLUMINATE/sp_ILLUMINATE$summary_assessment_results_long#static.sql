USE KIPP_NJ
GO

ALTER PROCEDURE [sp_ILLUMINATE$summary_assessment_results_long#static|refresh] AS

-- Step 1: drop and recreate the temp table --
IF OBJECT_ID(N'tempdb..#ILLUMINATE$summary_assessment_results_long#static|refresh') IS NOT NULL
  DROP TABLE [#ILLUMINATE$summary_assessment_results_long#static|refresh]
  CREATE TABLE [#ILLUMINATE$summary_assessment_results_long#static|refresh] (repository_id INT, student_id INT, field NVARCHAR(MAX), value NVARCHAR(MAX))

-- Step 2: declare variables --
DECLARE @query NVARCHAR(MAX)
DECLARE @repository_id NVARCHAR(MAX)
DECLARE @cols NVARCHAR(MAX)
DECLARE @converted_cols NVARCHAR(MAX)

-- Step 3: declare the cursor FOR the set of records it will loop over --
DECLARE illuminate_cursor CURSOR FOR
  SELECT repository_id        
  FROM OPENQUERY(ILLUMINATE,'
    SELECT repository_id          
    FROM dna_repositories.repositories    
    WHERE deleted_at IS NULL      
  ')
		    
-- Step 4: do work, son --
--
OPEN illuminate_cursor
WHILE 1 = 1
  BEGIN
  
    FETCH NEXT FROM illuminate_cursor INTO @repository_id
    
    IF @@FETCH_STATUS <> 0
      BEGIN
        BREAK
      END
--

  -- code block goes here
    -- grab column headers using GROUP_CONCAT to format them for the UNPIVOT statement
    SELECT @cols = '[' + dbo.GROUP_CONCAT_D(name, '], [') + ']'
    FROM OPENQUERY(ILLUMINATE,'
      SELECT name
            ,repository_id
      FROM dna_repositories.fields  
      WHERE deleted_at IS NULL        
    ')
    WHERE repository_id = @repository_id

    -- grab another set of column headers for the SELECT statement, CONVERTing everything to TEXT (NVARCHAR)
    -- this avoids the data-type collisions that would occur during the UNPIVOT
    SELECT @converted_cols = dbo.GROUP_CONCAT_BIGD(' , CAST(' + name, ' AS TEXT) ')
    FROM OPENQUERY(ILLUMINATE,'
      SELECT name
            ,repository_id
      FROM dna_repositories.fields
      WHERE deleted_at IS NULL
    ')
    WHERE repository_id = @repository_id

    -- here's the beef, the query that the cursor is going to iterate over    
    -- for each repo, SELECT the columns, CONVERT them to TEXT, and UNPIVOT into a long format
    -- then INSERT INTO the temp table 
    SET @query = N'                  
      INSERT INTO [#ILLUMINATE$summary_assessment_results_long#static|refresh]
      SELECT ' + @repository_id + ' AS repository_id
            ,student_id
            ,field
            ,value
      FROM OPENQUERY(ILLUMINATE,''
        SELECT student_id ' + @converted_cols + ' AS TEXT)
        FROM dna_repositories.repository_' + @repository_id + '
      '')
      
      UNPIVOT (
        value
        FOR field IN (' + @cols + ')
       ) unpiv           
    '        
    
    -- executes the query string above
    EXEC(@query)
        
  END

CLOSE illuminate_cursor
DEALLOCATE illuminate_cursor;

-- clear out the results table
EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$summary_assessment_results_long#static');

-- UPSERT, matching on repo, student, and field
MERGE ILLUMINATE$summary_assessment_results_long#static AS TARGET
  USING (
         SELECT *
         FROM [#ILLUMINATE$summary_assessment_results_long#static|refresh]
         ) AS SOURCE
        (repository_id
        ,student_id
        ,field
        ,value) 
   ON target.repository_id = source.repository_id
  AND target.student_id = source.student_id
  AND target.field = source.field
         
    WHEN MATCHED THEN
      UPDATE
        SET target.value = source.value
        
    WHEN NOT MATCHED THEN
      INSERT (repository_id
             ,student_id
             ,field
             ,value)
      VALUES (source.repository_id
             ,source.student_id
             ,source.field
             ,source.value);