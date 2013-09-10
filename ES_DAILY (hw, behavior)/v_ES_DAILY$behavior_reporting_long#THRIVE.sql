USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$behavior_reporting_long#THRIVE AS
SELECT ROW_NUMBER()
		OVER (ORDER BY rn) AS rn
	  ,ATT_DATE
	  ,STUDENT_NUMBER
	  ,STUDENTID
	  ,LASTFIRST
	  ,GRADE_LEVEL
	  ,TEAM
	  ,hw
	  ,THRIVE_AM  AS color_1
	  ,THRIVE_MID AS color_2
	  ,THRIVE_PM  AS color_3
	  ,CAST(student_number AS VARCHAR(20)) + '_' + CAST(att_date AS VARCHAR(20)) AS hash
FROM ES_DAILY$daily_tracking_long
WHERE SCHOOLID = 73255 --THRIVE only