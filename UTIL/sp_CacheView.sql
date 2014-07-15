-- takes a view and creates a static refresh procedure
-- pass a database name and view name to the procedure

-- DON'T FORGET TO COPY THE OUTPUT AND VERSION CONTROL IT!
-- and don't forget to add it to a scheduled job

USE KIPP_NJ
GO

ALTER PROCEDURE sp_CacheView
  @db NVARCHAR(256), -- name of the destination DB
  @view NVARCHAR(256) -- name of the view you want to cache
AS

BEGIN  
  
  -- check that the object exists and is a view
  IF OBJECTPROPERTY(OBJECT_ID(@db + '..' + @view), 'ISVIEW') IS NULL OR OBJECTPROPERTY(OBJECT_ID(@db + '..' + @view), 'ISVIEW') = 0
      BEGIN
        PRINT 'You need a view, bro.  Try again.'
      END

    ELSE
      BEGIN
        -- check that there already isn't an existing object with the same name
        IF OBJECT_ID(@db + '..' + @view + '#static') IS NULL
            BEGIN
        
              DECLARE @sql NVARCHAR(MAX);

              -- create the table structure
              BEGIN                
                SET @sql = '
                  SELECT *
                  INTO [' + @view + '#static]
                  FROM ' + @db + '..' + @view + '
                  WHERE 1 = 2
                ';
                EXEC(@sql);
                PRINT 'Table ' + @db + '..' + @view + ' created'; 
              END

              BEGIN                
                -- make sure it's operating on the destination DB
                -- this needed to be separated out from the rest of the procedure code
                -- otherwise it throws a syntax error
                SET @sql = '
                  USE ' + @db + '
                ';
                EXEC(@sql);

                -- actual procedure code starts here
                SET @sql = '                  
                  CREATE PROCEDURE [sp_' + @view + '#static|refresh] AS
                  BEGIN

                    DECLARE @sql AS VARCHAR(MAX)='''';

                    -- STEP 1: make sure no temp table
		                  IF OBJECT_ID(N''tempdb..#' + @view + '#static|refresh'') IS NOT NULL
		                  BEGIN
						                  DROP TABLE [#' + @view + '#static|refresh]
		                  END


                    -- STEP 2: load into a temporary staging table.
                    SELECT *
		                  INTO [#' + @view + '#static|refresh]
                    FROM ' + @view + ';
         

                    -- STEP 3: truncate destination table
                    EXEC(''TRUNCATE TABLE ' + @db + '..' + @view + '#static'');


                    -- STEP 4: disable all nonclustered indexes on table
                    SELECT @sql = @sql + ''ALTER INDEX '' 
                                   + indexes.name + '' ON dbo.'' 
                                   + objects.name + '' DISABLE;'' + CHAR(13) + CHAR(10)
                    FROM sys.indexes
                    JOIN sys.objects 
                      ON sys.indexes.object_id = sys.objects.object_id
                    WHERE sys.indexes.type_desc = ''NONCLUSTERED''
                      AND sys.objects.type_desc = ''USER_TABLE''
                      AND sys.objects.name = ''' + @view + '#static'';
                    EXEC (@sql);


                    -- STEP 5: insert into final destination
                    INSERT INTO [' + @view + '#static]
                    SELECT *
                    FROM [#' + @view + '#static|refresh];
 

                    -- STEP 6: rebuld all nonclustered indexes on table
                    SELECT @sql = @sql + ''ALTER INDEX '' 
                                    + indexes.name + '' ON dbo.'' 
                                    + objects.name + '' REBUILD;'' + CHAR(13) + CHAR(10)
                    FROM sys.indexes
                    JOIN sys.objects 
                      ON sys.indexes.object_id = sys.objects.object_id
                    WHERE sys.indexes.type_desc = ''NONCLUSTERED''
                      AND sys.objects.type_desc = ''USER_TABLE''
                      AND sys.objects.name = ''' + @view + '#static'';
                    EXEC (@sql);
  
                  END                  
                ';                
                -- print the generated code to console and then execute the creation
                -- SAVE THIS TO mandi!
                PRINT 'Copy and save this code as sp_' + @view + '#static_refresh:' + CHAR(13) + CHAR(10)
                PRINT 'USE [' + @db + ']' + CHAR(13) + CHAR(10)
                        + 'GO'  + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10)
                        + 'SET ANSI_NULLS ON' + CHAR(13) + CHAR(10)
                        + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
                        + 'SET QUOTED_IDENTIFIER ON' + CHAR(13) + CHAR(10)
                        + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
                        + REPLACE(@sql,'CREATE','ALTER'); -- changes it to ALTER for you
                EXEC(@sql);

                -- finally, execute the newly created procedure
                SET @sql = '
                  EXEC [sp_' + @view + '#static|refresh]
                ';
                EXEC(@sql)
                
              END

            END

          ELSE      

            -- if the table exists, this will print and the procedure will terminate
            -- I'm thinking about adding a 3rd parameter for rebuilding static tables that need to be adjusted
            BEGIN
              PRINT 'Static table already exists.  You''re gonna break something, ya dingus.  Aborting process...'
            END
      END
END