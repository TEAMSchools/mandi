USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanBadgeDetail]    Script Date: 8/11/2015 10:12:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_KhanBadgeDetail] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_badge_detail') IS NOT NULL
		BEGIN
						DROP TABLE #import_badge_detail
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_badge_detail
		FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\badge_detail.csv')
					) sub;

		--2. upsert
		TRUNCATE TABLE badge_detail;

  INSERT 
		INTO badge_detail
  SELECT *
		FROM #import_badge_detail;

END
				

GO


