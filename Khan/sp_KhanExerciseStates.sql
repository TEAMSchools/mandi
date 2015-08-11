USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanExerciseStates]    Script Date: 8/11/2015 10:12:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_KhanExerciseStates] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_exercise_states') IS NOT NULL
		BEGIN
						DROP TABLE #import_exercise_states
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_exercise_states
		FROM
				(SELECT *
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\exercise_states.csv')
					) sub;

		--2. upsert
		TRUNCATE TABLE exercise_states;

  INSERT 
		INTO exercise_states
  SELECT *
		FROM #import_exercise_states;

END
				

GO


