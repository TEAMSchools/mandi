USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$behavior_reporting_long#THRIVE AS
SELECT ROW_NUMBER()
		         OVER(ORDER BY rn) AS rn
	     ,att_date
	     ,student_number
	     ,studentid
	     ,lastfirst
	     ,grade_level
	     ,team
	     ,hw
	     ,thrive_am  AS color_1
	     ,thrive_mid AS color_2
	     ,thrive_pm  AS color_3
	     ,CAST(student_number AS VARCHAR(20)) + '_' + CAST(att_date AS VARCHAR(20)) AS hash
FROM ES_DAILY$daily_tracking_long#static WITH (NOLOCK)
WHERE SCHOOLID = 73255 --THRIVE only
  AND att_date >= '04-Sep-13'
  AND att_date <= '22-Nov-13'