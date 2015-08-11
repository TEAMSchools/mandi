USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanCompositeBadges]    Script Date: 8/11/2015 10:12:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_KhanCompositeBadges] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_composite_badges') IS NOT NULL
		BEGIN
						DROP TABLE #import_composite_badges
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_composite_badges
		FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\composite_badges.csv')
					) sub;

		--2. upsert
		TRUNCATE TABLE composite_badges;

  INSERT 
		INTO composite_badges
  SELECT *
		FROM #import_composite_badges;

END
				

GO


