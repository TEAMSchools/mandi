USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanTopicMetadata]    Script Date: 8/11/2015 10:11:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*
DROP TABLE topic_metadata

SELECT *
INTO topic_metadata
FROM #import_topic_metadata import
WHERE 1=2
*/


ALTER PROCEDURE [dbo].[sp_KhanTopicMetadata] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_topic_metadata') IS NOT NULL
		BEGIN
						DROP TABLE #import_topic_metadata
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_topic_metadata
		FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\topic_metadata.csv')
					) sub

		--2. truncate
		TRUNCATE TABLE topic_metadata
		
		--3. insert
		INSERT INTO topic_metadata
		SELECT *
		FROM #import_topic_metadata
		
END
				



GO


