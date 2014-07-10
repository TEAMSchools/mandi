USE KIPP_NJ
GO

ALTER PROCEDURE sp_LoadFolder
  @dir VARCHAR(8000)
AS

DECLARE @sql NVARCHAR(MAX),
        @filename NVARCHAR(1024),
        @ID INT;

-- if the filepath ends with a \ then leave it alone
-- if not append it to the filepath
IF RIGHT(@dir,1) = '\'
    SET @dir = @dir
  ELSE
    SET @dir = @dir + '\'

-- we need a temp table holding the names of the files we want to import
-- if the table exists drop it
IF OBJECT_ID('tempdb..#TEMP_import_files') IS NOT NULL
    DROP TABLE #TEMP_import_files;

-- recreate the table with a primary key
-- it will be used in the WHILE loop
CREATE TABLE #TEMP_import_files 
  (       
   id INT IDENTITY(1,1)
  ,subdirectory NVARCHAR(512)
  ,depth INT
  ,isfile BIT
  );

-- insert the filenames into the temp table
-- the folder path is specified as a parameter of the stored procedure
PRINT 'Loading filenames into temp table...'
INSERT INTO #TEMP_import_files
  (
   subdirectory
  ,depth
  ,isfile
  )
EXEC xp_dirtree @dir, 1, 1;

-- start the while loop
WHILE EXISTS (SELECT id FROM #TEMP_import_files)
  BEGIN

    -- take the top record and eliminate the file extension  
    SELECT TOP(1) 
           @ID = id
          ,@filename = REVERSE(SUBSTRING(REVERSE(subdirectory),CHARINDEX('.', REVERSE(subdirectory)) + 1, 999))        
    FROM #TEMP_import_files;   

    -- if a corresponding table exists, TRUNCATE it
    -- if not, create it using SELECT * INTO via OPENROWSET and then TRUNCATE it so you don't get dupes
    -- for new tables, add a primary key for indexing purposes
    -- I called ours BINI_ID because my life is dope and I do dope shit
    SET @sql = '    
      IF OBJECT_ID(''KIPP_NJ..' + @filename + ''') IS NOT NULL
          BEGIN
            EXEC(''TRUNCATE TABLE KIPP_NJ..' + @filename + ''');
            PRINT CHAR(13) + CHAR(13) + ''TRUNCATE ' + @filename + '''
          END
        ELSE        
          BEGIN
            PRINT ''CREATE TABLE ' + @filename + '''
            SELECT *
            INTO KIPP_NJ..' + @filename + '
            FROM OPENROWSET(
              ''MSDASQL''
             ,''Driver={Microsoft Access Text Driver (*.txt, *.csv)};''
             ,''SELECT * FROM ' + @dir + @filename  + '.csv'');
        
            ALTER TABLE ' + @filename + '
            ADD BINI_ID INT IDENTITY(1,1);
        
            ALTER TABLE ' + @filename + '
            ADD CONSTRAINT PK_' + @filename + ' PRIMARY KEY(BINI_ID);
            
            PRINT ''TRUNCATE ' + @filename + '''
            EXEC(''TRUNCATE TABLE KIPP_NJ..' + @filename + ''');
          END
    '  
    EXEC sp_executesql @sql;
          

        
    -- load the new data into the tables via OPENROWSET
    -- the CTE isn't totally necessary in this case, but it's 
    -- kind of a nice way to organize the code
    SET @sql = '      
      DECLARE @inner_sql NVARCHAR(MAX)

      PRINT ''Loading ' + @filename + '...'';

      SELECT @inner_sql = ''ALTER INDEX '' 
              + indexes.name + '' ON dbo.'' 
              + objects.name + '' DISABLE;'' + CHAR(13) + CHAR(10)
      FROM sys.indexes
      JOIN sys.objects 
        ON sys.indexes.object_id = sys.objects.object_id
      WHERE sys.indexes.type_desc = ''NONCLUSTERED''
        AND sys.objects.type_desc = ''USER_TABLE''
        AND sys.objects.name = ''' + @filename + ''';
      EXEC (@inner_sql);

      WITH flatfile AS (
        SELECT *
        FROM OPENROWSET(
          ''MSDASQL''
         ,''Driver={Microsoft Access Text Driver (*.txt, *.csv)};''
         ,''SELECT * FROM ' + @dir + @filename  + '.csv'')
       )

      INSERT INTO ' + @filename + '
      SELECT *  
      FROM flatfile;


      SELECT @inner_sql = ''ALTER INDEX '' 
              + indexes.name + '' ON dbo.'' 
              + objects.name + '' REBUILD;'' + CHAR(13) + CHAR(10)
      FROM sys.indexes
      JOIN sys.objects 
        ON sys.indexes.object_id = sys.objects.object_id
      WHERE sys.indexes.type_desc = ''NONCLUSTERED''
        AND sys.objects.type_desc = ''USER_TABLE''
        AND sys.objects.name = ''' + @filename + ''';
      EXEC (@inner_sql);
    '
    EXEC sp_executesql @sql;
  
    -- remove it from the list
    PRINT CHAR(13) + 'Removing ' + @filename + ' from import list...'
    DELETE FROM #TEMP_import_files WHERE id = @ID;
    
    PRINT CHAR(13) + 'Next!'

  END