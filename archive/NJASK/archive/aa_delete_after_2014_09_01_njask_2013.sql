USE [KIPP_NJ]
GO

/****** Object:  View [dbo].[aa_delete_after_2014_09_01_njask_2013]    Script Date: 4/15/2015 9:55:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[aa_delete_after_2014_09_01_njask_2013] AS
SELECT *
FROM
					(SELECT * 
					FROM OPENROWSET(
							'MSDASQL'
						,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
						,'select * from C:\data_robot\raw_csv\raw_njask_2013.csv')
					) sub

GO


