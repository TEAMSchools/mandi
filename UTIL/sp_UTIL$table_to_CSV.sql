/*
	Name: uspTableToCSV
	Author: Ritesh Kumar
	Created on: 08/23/2013
	Description: Generate a csv file of given sql query at specificed location.
		
	--To Debug:
	
	DECLARE @vcCsvFileLocation AS VARCHAR(500)
	
	EXECUTE dbo.sp_UTIL$table_to_CSV 
		'SELECT lastfirst FROM KIPP_NJ..STUDENTS',
		'C:\data_robot\raw_exports\',
		@vcCsvFileLocation OUTPUT
	
	SELECT @vcCsvFileLocation AS vcCsvFileLocation
	
*/
USE KIPP_NJ
GO

CREATE PROCEDURE sp_UTIL$table_to_CSV(
	@vcSqlQuery AS VARCHAR(8000),
	@vcFilePath AS VARCHAR(500),
	@vcCsvFileLocation AS VARCHAR(500) OUTPUT
) 
AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @vcGetColumn AS NVARCHAR(4000)
	DECLARE @vcBulkExportQuery AS VARCHAR(8000)
	DECLARE @vcColumnListQuery AS VARCHAR(8000)
	DECLARE @vcExportFile AS VARCHAR(8000)
	DECLARE @vcFileName AS VARCHAR(500)
	DECLARE @vcTablePrefix AS VARCHAR(36)
	DECLARE @vcKillTempTableQuery AS VARCHAR(4000)
	
	BEGIN TRY
    
		--Getting a unique file name
		SET @vcTablePrefix = REPLACE(NEWID(),'-','')
		SET @vcFileName =  @vcTablePrefix + '.csv'
		
		--Keeping the query data into temporary table
		SET @vcGetColumn = N'SELECT * 
			INTO ##tblTempDataTable_' + @vcTablePrefix + 
			' FROM(' + @vcSqlQuery + ') AS tblTempDataTable; '
			
		--Getting the field list
		SET @vcGetColumn += N'SELECT 
				@vcColumnListQuery = ISNULL(@vcColumnListQuery + '','',''SELECT '') + '''''''' + [Name] + ''''''''
			FROM tempdb.sys.columns 
			WHERE [object_id] = OBJECT_ID(''tempdb..##tblTempDataTable_' + @vcTablePrefix + ''')'	
		
		--Executing query to keep data into the temporaray table and getting the list fields	
		EXECUTE SP_EXECUTESQL 
			@vcGetColumn,
			N'@vcColumnListQuery VARCHAR(MAX) OUTPUT',
			@vcColumnListQuery OUTPUT
		
		--Preparing query to keep to save the fields list in the temp file
		SET @vcColumnListQuery = 'BCP "' + @vcColumnListQuery  + '" ' + 
			+ 'QUERYOUT ' + @vcFilePath + 'Header_' + @vcFileName + ' -c -t, -T -S ' 
			+ @@SERVERNAME
		
		--Preparing query to save the query data in the another temp file	
		SET @vcBulkExportQuery = 'BCP "SELECT * FROM ##tblTempDataTable_' + @vcTablePrefix+ '" ' + 
			+ 'QUERYOUT ' + @vcFilePath + 'Data_' + @vcFileName + ' -c -t, -T -S ' 
			+ @@SERVERNAME
		
		--Preparing query to remove temp table
		SET @vcKillTempTableQuery = 'IF OBJECT_ID(''tempdb..##tblTempDataTable_' 
			+ @vcTablePrefix + ''') IS NOT NULL DROP TABLE ##tblTempDataTable_' 
			+ @vcTablePrefix 
		
		--Preparing query to merge both the temp files and save in the another files and deleting all temp files.
		SET @vcExportFile = 'COPY /b ' 
			+ @vcFilePath + 'Header_' + @vcFileName + ' + ' 
			+ @vcFilePath + 'Data_' + @vcFileName + ' ' 
			+ @vcFilePath + 'TableData_' + @vcFileName
			+ ' && '
			+ ' DEL ' + @vcFilePath + 'Header_' + @vcFileName
			+ ' && '
			+ ' DEL ' + @vcFilePath + 'Data_' + @vcFileName
			
		--Executing all above queries
		EXECUTE master..XP_CMDSHELL @vcColumnListQuery ,NO_OUTPUT 
		EXECUTE master..XP_CMDSHELL @vcBulkExportQuery, NO_OUTPUT 
		EXECUTE master..XP_CMDSHELL @vcExportFile,NO_OUTPUT 
		EXECUTE(@vcKillTempTableQuery)
		
		SET @vcCsvFileLocation = @vcFilePath + 'TableData_' + @vcFileName
		
	END TRY
	BEGIN CATCH
	
		SELECT ERROR_MESSAGE()
		
	END CATCH
END