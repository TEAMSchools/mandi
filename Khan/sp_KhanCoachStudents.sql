USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanCoachStudents]    Script Date: 8/11/2015 10:12:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_KhanCoachStudents] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_coach_students') IS NOT NULL
		BEGIN
						DROP TABLE #import_coach_students
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_coach_students
		FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\coach_students.csv')
					) sub;

		--2. upsert
		TRUNCATE TABLE coach_students;

  INSERT 
		INTO coach_students
  SELECT *
		FROM #import_coach_students;

END
				

GO


