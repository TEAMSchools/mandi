USE KIPP_NJ
GO

ALTER VIEW PS$FTE AS

SELECT *
      ,KIPP_NJ.dbo.fn_TermToYear(CONVERT(VARCHAR,YEARID) + '00') AS academic_year
FROM OPENQUERY(PS_TEAM,'
  SELECT *
  FROM FTE
')