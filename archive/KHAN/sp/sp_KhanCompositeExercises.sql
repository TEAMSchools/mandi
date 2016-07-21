USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanCompositeExercises]    Script Date: 8/11/2015 10:12:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_KhanCompositeExercises] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_composite_exercises') IS NOT NULL
		BEGIN
						DROP TABLE #import_composite_exercises
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_composite_exercises
		FROM
					(SELECT [streak]
      ,[total_done]
      ,[practiced]
      ,[level]
      ,[last_done]
      ,[proficient]
      ,[maximum_exercise_progress_dt]
      ,[mastered]
      ,[student]
      ,[longest_streak]
      ,[progress]
      ,[practiced_date]
      ,[total_correct]
      ,[struggling]
      ,[exercise]
      ,CASE WHEN [proficient_date] = '0' THEN NULL ELSE [proficient_date] END AS proficient_date
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\composite_exercises.csv')
					) sub;

		--2. upsert
		TRUNCATE TABLE composite_exercises;

  INSERT 
		INTO composite_exercises
  SELECT *
		FROM #import_composite_exercises;

END
				

GO


