USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanExerciseMetadata]    Script Date: 8/11/2015 10:12:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*
DROP TABLE exercise_metadata

SELECT *
INTO exercise_metadata
FROM #import_exercise_metadata import
WHERE 1=2
*/


ALTER PROCEDURE [dbo].[sp_KhanExerciseMetadata] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_exercise_metadata') IS NOT NULL
		BEGIN
						DROP TABLE #import_exercise_metadata
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_exercise_metadata
		FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\exer_metadata.csv')
					) sub

		--2. truncate
		TRUNCATE TABLE exercise_metadata
		
		--3. insert
		INSERT INTO exercise_metadata
		SELECT *
		FROM #import_exercise_metadata
		
END
				


GO


