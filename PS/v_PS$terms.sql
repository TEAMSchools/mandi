USE KIPP_NJ
GO

ALTER VIEW PS$TERMS AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT *
  FROM TERMS
')