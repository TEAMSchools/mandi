-- takes a view and creates a static refresh procedure
-- pass a database name and view name to the procedure

-- DON'T FORGET TO COPY THE OUTPUT AND VERSION CONTROL IT!
-- and don't forget to add it to a scheduled job

USE KIPP_NJ
GO

ALTER PROCEDURE sp_CacheView
  @db NVARCHAR(256),
  @view NVARCHAR(256)
AS

BEGIN  
  
  IF OBJECTPROPERTY(OBJECT_ID(@db + '..' + @view), 'ISVIEW') IS NULL OR OBJECTPROPERTY(OBJECT_ID(@db + '..' + @view), 'ISVIEW') = 0
      BEGIN
        PRINT 'You need a view, bro.  Try again.'
      END

    ELSE
      BEGIN
        IF OBJECT_ID(@db + '..' + @view + '#static') IS NULL
            BEGIN
        
              DECLARE @sql NVARCHAR(MAX);

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
                SET @sql = '
                  USE ' + @db + '
                ';
                EXEC(@sql);

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
                PRINT 'Copy and save this code as sp_' + @view + '#static_refresh:' + CHAR(13) + CHAR(10)
                PRINT 'USE [' + @db + ']' + CHAR(13) + CHAR(10)
                        + 'GO'  + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10)
                        + 'SET ANSI_NULLS ON' + CHAR(13) + CHAR(10)
                        + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
                        + 'SET QUOTED_IDENTIFIER ON' + CHAR(13) + CHAR(10)
                        + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
                        + REPLACE(@sql,'CREATE','ALTER');
                EXEC(@sql);

                SET @sql = '
                  EXEC [sp_' + @view + '#static|refresh]
                ';
                EXEC(@sql)
                
              END

            END

          ELSE      

            BEGIN
              PRINT 'Static table already exists.  You''re gonna break something, ya dingus.  Aborting process...'
            END
      END
END