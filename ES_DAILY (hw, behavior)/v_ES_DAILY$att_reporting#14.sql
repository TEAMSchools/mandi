USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$att_reporting_long#SY14 AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
		SELECT id
			  ,studentid
			  ,schoolid
			  ,att_date
			  ,att_code
			  ,presence_status_cd
		FROM ps_attendance_daily
		WHERE att_date >= ''2013-08-01''
		  AND att_date <= ''2014-06-30''
		ORDER BY att_date		
')