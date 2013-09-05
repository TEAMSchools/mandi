USE [KIPP_NJ]
GO

/****** Object:  StoredProcedure [dbo].[spTEACHERS_REFRESH]    Script Date: 15.06.2013 17:22:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$TEACHERS_refresh]
AS
BEGIN

	DECLARE @sql AS VARCHAR(MAX)='';

	-- Step 1: truncate table
	EXEC('TRUNCATE TABLE dbo.[TEACHERS]');

	-- Step 2: disable all nonclustered indexes on table
	SELECT @sql = @sql + 
		'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
	FROM 
		sys.indexes
	JOIN 
		sys.objects 
		ON sys.indexes.object_id = sys.objects.object_id
	WHERE sys.indexes.type_desc = 'NONCLUSTERED'
		AND sys.objects.type_desc = 'USER_TABLE'
		AND sys.objects.name = 'TEACHERS';

	EXEC (@sql);

	-- step 3: insert rows from remote source
	INSERT INTO [dbo].[TEACHERS]
	SELECT  *
	FROM OPENQUERY(PS_TEAM, '
	  SELECT *
	  FROM TEACHERS
	');

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
		AND sys.objects.name = 'TEACHERS';

	EXEC (@sql);

END

GO
