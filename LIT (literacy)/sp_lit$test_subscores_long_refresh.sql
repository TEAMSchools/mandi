USE [KIPP_NJ]
GO

/****** Object:  StoredProcedure [dbo].[sp_LIT$test_subscores_long|refresh]    Script Date: 08/13/2013 15:25:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_LIT$test_subscores_long|refresh] AS
BEGIN

--variables
DECLARE @sql AS VARCHAR(MAX)='';

	--step 1: truncate result table
	EXEC('TRUNCATE TABLE KIPP_NJ.DBO.LIT$TEST_SUBSCORES_LONG')

	--step 2: disable nonclustered indexes on table
	SELECT @sql = @sql + 
		'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
	FROM 
		sys.indexes
	JOIN 
		sys.objects 
		ON sys.indexes.object_id = sys.objects.object_id
	WHERE sys.indexes.type_desc = 'NONCLUSTERED'
		AND sys.objects.type_desc = 'USER_TABLE'
		AND sys.objects.name = 'LIT$TEST_SUBSCORES_LONG';
		
	EXEC (@sql);

	--step 3: insert rows from remote
	INSERT INTO dbo.lit$test_subscores_long
			([CUST_STUDENTID]
			,[STUDENTID]
			,[STUDENT_NUMBER]
			,[RD_TESTID_BASE]
			,[SCOREID]
			,[DATE_TAKEN]
			,[RDG_LEVEL]
			,[STATUS]
			,[DCID]
			,[RD_TESTID_SUB]
			,[TEST_NAME]
			,[SUBTEST_NAME]
			,[FIELDNAME]
			,[SORTORDER]
			,[VALUE])
	SELECT sub.*
			--uncomment to create a destination table
			--INTO LIT$TEST_SUBSCORES_LONG
	FROM OPENQUERY(PS_TEAM, '
			WITH base_tests AS
				(SELECT foreignKey                       AS cust_studentid
											,s.id                             AS studentid
											,s.student_number
											,scores.foreignKey_alpha          AS rd_testid_base
											,scores.unique_id                 AS scoreid
											,scores.user_defined_date         AS date_taken
											,user_defined_text                AS rdg_level
											,user_defined_text2               AS status
					FROM virtualtablesdata3 scores
					JOIN students s on s.id = scores.foreignKey 
					WHERE scores.related_to_table = ''readingScores'' 
					ORDER BY scores.schoolid, s.grade_level, s.team, s.lastfirst, scores.user_defined_date DESC),

				subscores AS
				(SELECT main_test.dcid
											,main_test.id rd_testid_sub
											,main_test.name AS test_name
											,subtest.NAME AS subtest_name
											,subtest.value2 AS fieldname
											,subtest.sortorder
					FROM gen main_test
					JOIN gen subtest 
							ON main_test.id = subtest.valueli 
						AND subtest.cat = ''rdgTestField''
					WHERE main_test.cat = ''rdgTest''
					ORDER BY main_test.name)
	   
	SELECT base_tests.*
							,subscores.*
							,PS_CUSTOMFIELDS.GETCF(''readingScores'', subscore_values.unique_id, subscores.fieldname) AS value
	FROM base_tests
	JOIN subscores
			ON base_tests.rd_testid_base = subscores.rd_testid_sub
	JOIN virtualtablesdata3 subscore_values
			ON base_tests.scoreid = subscore_values.unique_id'
	) sub


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
		AND sys.objects.name = 'LIT$TEST_SUBSCORES_LONG';

	EXEC (@sql);

END

GO

