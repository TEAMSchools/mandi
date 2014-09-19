USE SPI
GO

--time series calculations are probably the only thing that will stay over on
--the old oracle box.
ALTER VIEW TIME_SERIES_GRADES$student_counts AS
SELECT *
FROM OPENQUERY(KIPP_NWK,
  'SELECT *
   FROM GRADES$TIME_SERIES#COUNTS'
)