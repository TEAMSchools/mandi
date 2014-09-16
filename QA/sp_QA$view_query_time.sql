USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_QA$view_query_time', 'P') IS NOT NULL
    DROP PROCEDURE sp_QA$view_query_time;
GO

CREATE PROCEDURE sp_QA$view_query_time AS

BEGIN  
  DECLARE @viewname SYSNAME
  --dynamic sql below
  DECLARE @sql NVARCHAR(MAX)
  DECLARE @sql_all NVARCHAR(MAX)
  --timing
  DECLARE @refresh_seconds DECIMAL(8,1)
  DECLARE @start_time DATETIME
  --message
  DECLARE @console_output VARCHAR(400)
  --this gets returned
  DECLARE @record_batch INT
  --a cursor to loop over the views
  DECLARE csr CURSOR LOCAL FOR 
    SELECT views.name
    FROM KIPP_NJ.sys.views views WITH(NOLOCK)
    JOIN KIPP_NJ.sys.extended_properties props WITH(NOLOCK)
      ON views.object_id = props.major_id
     AND props.name = 'has_static_cache'
     AND props.value != 'TRUE'
     --AND views.name LIKE 'UTIL%'
    WHERE is_ms_shipped=0 
    ORDER by views.name
  
  --get the sequence number
  INSERT INTO DBA$global_sequence(value) VALUES ('sp_QA$view_query_time');
  --this is the whole point; I want a unique ID back
  SET @record_batch = SCOPE_IDENTITY()
  
  --cursor, loop over views  
  OPEN csr
    FETCH NEXT FROM csr INTO @viewname
    
    WHILE @@FETCH_STATUS = 0
      BEGIN
        SET @sql = 'DECLARE @test NVARCHAR(MAX) 
                    SELECT @test = checksum(*) FROM [' + @viewname + ']'
        SET @sql_all = 'SELECT * 
                        FROM [' + @viewname + '] WITH (NOLOCK)'
        --start timing
        SET @start_time = GETDATE()
        
        --be verbose
        SET @console_output = 'Examining ' + @viewname
        RAISERROR (@console_output, 0, 1) WITH NOWAIT

        --execute the dynamic SQL                
        EXEC sp_executesql @sql
        EXEC sp_executesql @sql_all
        --end timing
        SET @refresh_seconds = RTRIM(CAST(DATEDIFF(MS, @start_time, GETDATE()) AS CHAR(10)))
        --PRINT @refresh_seconds
        --insert into result table
        INSERT INTO QA$response_time_results
          (batch_id, process, [object_name], refresh_time)
        VALUES
          (@record_batch, 'sp_QA$view_query_time', @viewname, @refresh_seconds)
        --next step in cursor
        FETCH NEXT FROM csr INTO @viewname
      END
  CLOSE csr
  DEALLOCATE csr
RETURN @record_batch
END