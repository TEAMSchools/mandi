-- pass a database and folder directory on WINSQL01 as a parameter
-- use this sp_ to trigger a db load after a web-scraping jobs complete
-- for example, using DB-API: conn.execute("EXEC sp_LoadFolder 'KIPP_NJ', 'C:\\data_robot\\naviance'")

USE KIPP_NJ
GO

ALTER PROCEDURE sp_LoadFolder
  @dbname NVARCHAR(256),
  @dir VARCHAR(8000)
AS

BEGIN

  DECLARE @sql NVARCHAR(MAX),
          @filename NVARCHAR(1024),          
          @tablename NVARCHAR(1024),          
          @ID INT,
          @CMD VARCHAR(256);


  -- set the command line for xp_cmdshell
  SET @CMD = 'DIR "' + @dir + '" /A /S'


  -- if the filepath ends with a '\' then leave it alone
  -- if not append it to the filepath
  IF RIGHT(@dir,1) = '\'
      SET @dir = @dir
    ELSE
      SET @dir = @dir + '\'


  -- we need temp tables to hold the command line response
  -- as well as the names of the files we want to import
  IF OBJECT_ID('tempdb..#cmd_response') IS NOT NULL
      DROP TABLE #cmd_response

  IF OBJECT_ID('tempdb..#import_files') IS NOT NULL
      DROP TABLE #import_files;

  CREATE TABLE #cmd_response
    (
     returnval NVARCHAR(500)
    )

  CREATE TABLE #import_files 
    (       
     id INT IDENTITY(1,1) -- the ID key is used for the WHILE loop
    ,subdirectory NVARCHAR(512)
    ,size INT
    ,extension NVARCHAR(16)
    );


  -- populate temp table with the command line response
  -- and delete rows with no file information
  PRINT 'Getting list of files in folder...'
  INSERT #cmd_response EXEC master..xp_cmdshell @cmd;
  PRINT CHAR(13) + 'Cleaning up the file list...'
  DELETE FROM #cmd_response 
  WHERE returnval IS NULL
    OR (ISNUMERIC(LEFT(returnval,1))=0 
        AND returnval NOT LIKE '%Directory of%')
    OR returnval LIKE '%<DIR>          .%';


  -- parse the command line response and then
  -- insert the file metadata into the temp table
  PRINT CHAR(13) + 'Loading filenames into temp table...'
  INSERT INTO #import_files
    (
     subdirectory
    ,size
    ,extension
    )
  SELECT subdirectory
        ,size
        ,extension
  FROM 
      (
       SELECT CASE 
               WHEN SUBSTRING(returnval,22,17) LIKE '%<DIR>%' THEN NULL 
               ELSE CONVERT(INT,REPLACE(SUBSTRING(returnval, 22, 17), ',', '')) 
              END AS size
             ,RIGHT(RTRIM([returnval]), LEN(RTRIM([returnval])) - 39) AS subdirectory
             ,CASE 
               WHEN SUBSTRING(returnval, 22, 17) LIKE '%<DIR>%' THEN NULL 
               ELSE RIGHT(rtrim([returnval]), CHARINDEX('.', REVERSE(RTRIM([returnval])))) 
              END AS extension
       FROM #cmd_response t
       WHERE returnval NOT LIKE '%Directory of%'
      ) sub
  ;


  -- start the loop!
  PRINT CHAR(13) + 'Leg''go!'
  WHILE EXISTS (
                SELECT id 
                FROM #import_files
                WHERE extension IN ('.csv','.txt')
                  AND size > 0
               )
    BEGIN
    
      -- for debugging if this gets stuck in an infinite loop
      --SELECT *
      --FROM #import_files
      --WHERE extension IN ('.csv','.txt')
      --  AND size > 0;

      -- take the top record and eliminate the file extension  
      SELECT TOP(1) 
             @ID = id
            ,@filename = subdirectory            
            ,@tablename = 'AUTOLOAD$' + REVERSE(SUBSTRING(REVERSE(subdirectory),CHARINDEX('.', REVERSE(subdirectory)) + 1, 999)) 
            -- the 'AUTOLOAD$' prefix will help keep track of tables created by this procedure
      FROM #import_files
      WHERE extension IN ('.csv','.txt')
        AND size > 0;

      -- if a corresponding table exists, TRUNCATE it
      -- if not, create it using SELECT * INTO via OPENROWSET and then TRUNCATE it so you don't get dupes
      -- for new tables, add a primary key for indexing purposes
      -- I called ours BINI_ID because my life is dope and I do dope shit
      SET @sql = '    
        IF OBJECT_ID(''' + @dbname + '..' + @tablename + ''') IS NOT NULL
            BEGIN
              EXEC(''TRUNCATE TABLE ' + @dbname + '..' + @tablename + ''');
              PRINT CHAR(13) + ''TRUNCATE ' + @tablename + '''
            END
          ELSE        
            BEGIN
              PRINT CHAR(13) + CHAR(13) + ''CREATE TABLE ' + @tablename + '''
              SELECT *
              INTO ' + @dbname + '..' + @tablename + '
              FROM OPENROWSET(
                ''MSDASQL''
               ,''Driver={Microsoft Access Text Driver (*.txt, *.csv)};''
               ,''SELECT * FROM ' + @dir + @filename  + ''');
        
              ALTER TABLE ' + @tablename + '
              ADD BINI_ID INT IDENTITY(1,1);
        
              ALTER TABLE ' + @tablename + '
              ADD CONSTRAINT PK_' + @tablename + ' PRIMARY KEY(BINI_ID);
            
              PRINT ''TRUNCATE ' + @tablename + '''
              EXEC(''TRUNCATE TABLE ' + @dbname + '..' + @tablename + ''');
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
          AND sys.objects.name = ''' + @tablename + ''';
        EXEC (@inner_sql);

        WITH flatfile AS (
          SELECT *
          FROM OPENROWSET(
            ''MSDASQL''
           ,''Driver={Microsoft Access Text Driver (*.txt, *.csv)};''
           ,''SELECT * FROM ' + @dir + @filename + ''')
         )

        INSERT INTO ' + @tablename + '
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
          AND sys.objects.name = ''' + @tablename + ''';
        EXEC (@inner_sql);
      '
      EXEC sp_executesql @sql;
  
      -- remove it from the list
      PRINT CHAR(13) + 'Removing ' + @filename + ' from import list...'
      DELETE FROM #import_files WHERE id = @ID;
    
      PRINT CHAR(13) + 'Next!'

    END

  SELECT 'Flat files in ' + @dir + ' have been loaded into ' + @dbname + ', baby!' AS result
  RETURN 0

END