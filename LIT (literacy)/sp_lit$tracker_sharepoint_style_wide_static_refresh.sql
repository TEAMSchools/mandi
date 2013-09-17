USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_LIT$tracker_sharepoint_style_wide#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#tracker_sharepoint_style_wide#static|refresh') IS NOT NULL
		BEGIN
			DROP TABLE [#tracker_sharepoint_style_wide#static|refresh]
		END
		
 --STEP 2: load into a TEMPORARY staging table.
		SELECT *
		INTO [#LIT$tracker_sharepoint_style_wide#static|refresh]
		FROM LIT$tracker_sharepoint_style_wide 
  
 --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
		--SELECT 1 FROM [LIT$step_headline_long#identifiers] WITH (TABLOCKX);

 --STEP 4: truncate 
		EXEC('TRUNCATE TABLE dbo.[LIT$tracker_sharepoint_style_wide#static]');

 --STEP 5: disable all nonclustered indexes on table
		SELECT @sql = @sql + 
			'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
		FROM sys.indexes
		JOIN sys.objects 
		  ON sys.indexes.object_id = sys.objects.object_id
		WHERE sys.indexes.type_desc = 'NONCLUSTERED'
		  AND sys.objects.type_desc = 'USER_TABLE'
		  AND sys.objects.name = 'LIT$tracker_sharepoint_style_wide#static';

		EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[LIT$tracker_sharepoint_style_wide#static]
      ([schoolid]
      ,[Student Number]
      ,[Grade Level]
      ,[TEAM]
      ,[Step Round]
      ,[Test Type]
      ,[Step Level]
      ,[STATUS]
      ,[Independent Level]
      ,[Instructional Level]
      ,[Pre _ Name]
      ,[Pre _ Ph. Aw.-Rhyme]
      ,[Pre - 1 _ Concepts about Print]
      ,[Pre - 2 _ LID Name]
      ,[Pre - 3 _ LID Sound]
      ,[STEP 1 _ PA-1st]
      ,[STEP 1 _ Reading Record]
      ,[STEP 1 - 3 _ Dev. Spell]
      ,[STEP 2_Reading Record: Bk1 Acc]
      ,[STEP 2_Reading Record: Bk2 Acc]
      ,[STEP 2 - 3 _ PA - seg]
      ,[STEP 2 - 3 _ Comprehension]
      ,[STEP 3 - 12 _ Acurracy]
      ,[STEP 4 - 12 _ Fluency]
      ,[STEP 4 - 5 _ Comprehension]
      ,[STEP 4 - 5 _ Dev. Spell]
      ,[STEP 4 - 12 _ Rate]
      ,[STEP 6 - 7 _ Comprehension]
      ,[STEP 6 - 7 _ Dev. Spell]
      ,[STEP 8  _ Comprehension]
      ,[STEP 8 - 12 _ Retell]
      ,[STEP 8 - 10 _ Dev. Spell]
      ,[STEP 9 - 12 _ Comprehension]
      ,[STEP 11 - 12 _ Dev. Spell]
      ,[FP_L-Z_Rate]
      ,[FP_L-Z_Fluency]
      ,[FP_L-Z_Accuracy]
      ,[FP_L-Z_Comprehension])
 SELECT *
 FROM [#LIT$tracker_sharepoint_style_wide#static|refresh];

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
  AND sys.objects.name = 'LIT$tracker_sharepoint_style_wide#static';

 EXEC (@sql);
  
END
GO

