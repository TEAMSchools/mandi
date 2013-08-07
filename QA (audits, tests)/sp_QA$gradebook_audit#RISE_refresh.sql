USE [KIPP_NJ]
GO

ALTER PROCEDURE [dbo].[sp_QA$gradebook_audit#RISE|refresh] AS 

BEGIN

/*
--for quickly changing structure

DROP TABLE qa$gradebook_audit#rise

SELECT * INTO 
qa$gradebook_audit#rise
FROM #rise_gradebook
WHERE 1=2

GRANT SELECT ON [dbo].[qa$gradebook_audit#rise] TO [TEAMSCHOOLS\All Users]

*/

--1) Pull from Oracle.  Put data into a temp table
IF OBJECT_ID(N'tempdb..#rise_gradebook') IS NOT NULL
BEGIN
    DROP TABLE #rise_gradebook
END


SELECT sub.*
INTO #rise_gradebook
FROM 
  --bringing data in from oracle xe
  (SELECT *
  FROM
  OPENQUERY(KIPP_NWK,
    'SELECT gb.* 
     FROM qa$gradebook_audit#rise gb'
  )) sub

  

--2) If everything has come across, truncate the local table here
--on KIPP_NJ
TRUNCATE TABLE qa$gradebook_audit#rise

--3) Now insert the new rows
INSERT INTO qa$gradebook_audit#rise 
SELECT *
FROM #rise_gradebook

END 
GO

