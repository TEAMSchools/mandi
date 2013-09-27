USE KIPP_NJ
GO

--ALTER VIEW ES_DAILY$att_reporting_long#SY14 AS
SELECT *
FROM OPENQUERY(PS_TEAM,'
		     SELECT *
		     FROM ps_attendance_daily
		     WHERE att_date >= TO_DATE(''2013-08-01'',''YYYY-MM-DD'')
		       AND att_date <= TO_DATE(''2014-06-30'',''YYYY-MM-DD'')
		     ORDER BY att_date		
       ')