USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_LIT$step_headline_long#identifiers|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#LIT$step_headline_long#identifiers|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#LIT$step_headline_long#identifiers|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT sub.*
		INTO [#LIT$step_headline_long#identifiers|refresh]
  FROM 
        (SELECT step.*
               ,cohort.schoolid
               ,cohort.grade_level
               ,cohort.abbreviation
               ,cohort.year
               ,ROW_NUMBER() OVER
                  (PARTITION BY step.studentid
                               ,cohort.year
                   ORDER BY step.date_taken ASC) AS rn_asc
               ,ROW_NUMBER() OVER
                  (PARTITION BY step.studentid
                               ,cohort.year
                   ORDER BY step.date_taken DESC) AS rn_desc
         FROM LIT$step_headline_long step
         JOIN COHORT$comprehensive_long cohort
           ON step.studentid = cohort.studentid
          AND step.date_taken >= cohort.entrydate
          AND step.date_taken <= cohort.exitdate
          AND cohort.rn = 1
         ) sub
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$step_headline_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[LIT$step_headline_long#identifiers]');

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
   AND sys.objects.name = 'LIT$step_headline_long#identifiers';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[LIT$step_headline_long#identifiers]
      ([STUDENTID]
      ,[LASTFIRST]
      ,[STUDENT_NUMBER]
      ,[DATE_TAKEN]
      ,[STEP_LEVEL]
      ,[TESTID]
      ,[STATUS]
      ,[STEP_LEVEL_NUMERIC]
      ,[schoolid]
      ,[grade_level]
      ,[abbreviation]
      ,[year]
      ,[rn_asc]
      ,[rn_desc])
 SELECT *
 FROM [#LIT$step_headline_long#identifiers|refresh];

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
  AND sys.objects.name = 'LIT$step_headline_long#identifiers';

 EXEC (@sql);
  
END
GO

