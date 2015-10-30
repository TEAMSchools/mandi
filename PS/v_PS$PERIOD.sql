USE KIPP_NJ
GO

ALTER VIEW PS$PERIOD AS

SELECT *
      ,KIPP_NJ.dbo.fn_TermToYear(CONCAT(year_id,'00')) AS academic_year
FROM OPENQUERY(PS_TEAM,'
  SELECT *
  FROM PERIOD
')