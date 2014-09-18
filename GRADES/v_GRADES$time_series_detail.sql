USE SPI
GO

ALTER VIEW GRADES$times_series_detail AS

SELECT *
FROM OPENQUERY(KIPP_NWK,'
  SELECT *
  FROM grades$time_series_detail
  WHERE date_value >= TO_DATE(''2014-08-01'',''YYYY-MM-DD'')
')