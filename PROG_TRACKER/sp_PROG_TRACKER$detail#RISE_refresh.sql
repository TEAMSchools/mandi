USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PROG_TRACKER$detail#RISE|refresh] AS 

BEGIN

--1) Pull from Oracle.  Put data into a temp table

SELECT sub.*
INTO #rise_tracker
FROM 
		--bringing data in from oracle xe
	 (SELECT *
		FROM
		OPENQUERY(KIPP_NWK,
				'SELECT * FROM PROGRESS_TRACKER#RISE'
		)) sub
 
--2) If everything has come across, truncate the local table here
--on KIPP_NJ
TRUNCATE TABLE PROGRESS_TRACKER#RISE

--3) Now insert the new rows
INSERT INTO PROGRESS_TRACKER#RISE
SELECT *
FROM #rise_tracker

END 
GO


