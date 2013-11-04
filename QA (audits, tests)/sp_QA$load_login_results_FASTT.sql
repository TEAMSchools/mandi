USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_QA$load_login_results#FASTT] AS 
BEGIN
  DECLARE @oq_file_string AS VARCHAR(250)

		--0. ensure temp table doesn't exist in use
		IF OBJECT_ID(N'tempdb..#login_test') IS NOT NULL
		BEGIN
						DROP TABLE #login_test
		END
	
--to do: rewrite to accept this.  see: http://stackoverflow.com/a/13831792/561698
 SET @oq_file_string = 'select * from c:\data_robot\diy\logins\' + 'filename_variable'

	--1. bulk load csv and SELECT INTO temp table
		SELECT sub.*
		INTO #login_test
		FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};DefaultDir=c:\data_robot\logins\data;'
						,'select * from c:\data_robot\logins\data\fastt_login_tests.csv')
					) sub;

		--2. upsert
		WITH new_data AS (
    SELECT *
		  FROM #login_test
  )

		MERGE QA$student_login_tests target
		USING new_data staging
					ON target.studentid = staging.studentid
    AND target.product = staging.product
				AND target.tested_on = staging.tested_on
		WHEN MATCHED THEN
				UPDATE SET  
						target.outcome = staging.outcome
		WHEN NOT MATCHED BY target THEN
		INSERT (product
									,studentid
         ,tested_on
									,outcome) 
		VALUES (staging.product
									,staging.studentid
         ,staging.tested_on
									,staging.outcome);
END
				