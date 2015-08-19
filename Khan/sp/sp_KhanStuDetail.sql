USE [Khan]
GO

/****** Object:  StoredProcedure [dbo].[sp_KhanStuDetail]    Script Date: 8/11/2015 10:09:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_KhanStuDetail] AS 
BEGIN

		--0. ensure temp table doesn't exist
		IF OBJECT_ID(N'tempdb..#import_stu_detail') IS NOT NULL
		BEGIN
						DROP TABLE #import_stu_detail
		END
	
	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #import_stu_detail
		FROM
					(SELECT [badge_lev1]
      ,[badge_lev0]
      ,[badge_lev3]
      ,[badge_lev2]
      ,[badge_lev5]
      ,[badge_lev4]
      ,CASE WHEN [first_visit] = 'None' THEN NULL ELSE [first_visit] END AS [first_visit]
      ,[all_proficient_exercises]
      ,[identity_email]
      ,CASE WHEN [registration_date] = 'None' THEN NULL ELSE [registration_date] END AS [registration_date]
      ,CASE WHEN [joined] = 'None' THEN NULL ELSE [joined] END AS [joined]
      ,[username]
      ,[coaches]
      ,[profile_root]
      ,[points]
      ,[student]
      ,[proficient_exercises]
      ,[total_seconds_watched]
      ,[nickname]
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\khan\khan_school\khan_data\stu_detail.csv')
					) sub;

		--2. upsert
		TRUNCATE TABLE stu_detail;

  INSERT 
		INTO stu_detail
  SELECT *
		FROM #import_stu_detail;

END
				

GO


