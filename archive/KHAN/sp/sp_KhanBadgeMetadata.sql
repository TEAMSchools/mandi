USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanBadgeMetadata]    Script Date: 8/11/2015 10:12:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
DROP TABLE badge_metadata

SELECT *
INTO badge_metadata
FROM #import_badge_metadata import
WHERE 1=2
*/


ALTER PROCEDURE [dbo].[sp_KhanBadgeMetadata] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_badge_metadata') IS NOT NULL
		BEGIN
						DROP TABLE #import_badge_metadata
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_badge_metadata
		FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\badge_metadata.csv')
					) sub

		--2. truncate
		TRUNCATE TABLE badge_metadata
		
		--3. insert
		INSERT INTO badge_metadata
		SELECT *
		FROM #import_badge_metadata
		
END
				

GO


