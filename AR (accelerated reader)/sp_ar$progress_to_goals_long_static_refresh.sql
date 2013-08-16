USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_AR$progress_to_goals_long#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';
 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#AR$progress_to_goals_long#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#AR$progress_to_goals_long#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT ar.*
		INTO [#AR$progress_to_goals_long#static|refresh]
  FROM AR$progress_to_goals_long ar
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [AR$progress_to_goals_long#static] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[AR$progress_to_goals_long#static]');

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
   AND sys.objects.name = 'AR$progress_to_goals_long#static';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[AR$progress_to_goals_long#static]
      ([studentid]
      ,[student_number]
      ,[yearid]
      ,[time_hierarchy]
      ,[time_period_name]
      ,[words_goal]
      ,[points_goal]
      ,[start_date]
      ,[end_date]
      ,[words]
      ,[points]
      ,[mastery]
      ,[pct_fiction]
      ,[avg_lexile]
      ,[avg_rating]
      ,[last_quiz]
      ,[N_passed]
      ,[N_total]
      ,[last_book]
      ,[ontrack_words]
      ,[ontrack_points]
      ,[stu_status_words]
      ,[stu_status_points]
      ,[stu_status_words_numeric]
      ,[stu_status_points_numeric]
      ,[words_needed]
      ,[points_needed])
 SELECT *
 FROM [#AR$progress_to_goals_long#static|refresh];

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
  AND sys.objects.name = 'AR$progress_to_goals_long#static';

 EXEC (@sql);
  
END
GO