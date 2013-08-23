USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$behavior_reporting#SPARKSEEK AS

SELECT student_number
      ,lastfirst
      ,grade_level
      ,team
      ,purple_total
      ,green_total
      ,yellow_total
      ,orange_total
      ,red_total
      ,behavior_days_total
      ,CAST(ROUND(purple_total/behavior_days_total,2,1) AS FLOAT) AS purple_pct
      ,CAST(ROUND(green_total/behavior_days_total,2,1) AS FLOAT) AS green_pct
      ,CAST(ROUND(yellow_total/behavior_days_total,2,1) AS FLOAT) AS yellow_pct
      ,CAST(ROUND(orange_total/behavior_days_total,2,1) AS FLOAT) AS orange_pct
      ,CAST(ROUND(red_total/behavior_days_total,2,1) AS FLOAT) AS red_pct
FROM
	   (SELECT student_number	  
			  ,lastfirst
			  ,grade_level
			  ,team
			  ,SUM(CASE
					WHEN color_day = 'Purple' THEN 1.0
					ELSE 0
				   END) AS purple_total
			  ,SUM(CASE
					WHEN color_day = 'Green' THEN 1.0
					ELSE 0
				   END) AS green_total
			  ,SUM(CASE
					WHEN color_day = 'Yellow' THEN 1.0
					ELSE 0
				   END) AS yellow_total
			  ,SUM(CASE
					WHEN color_day = 'Orange' THEN 1.0
					ELSE 0
				   END) AS orange_total
			  ,SUM(CASE
					WHEN color_day = 'Red' THEN 1.0
					ELSE 0
				   END) AS red_total
			  ,SUM(CASE
					WHEN color_day IS not null THEN 1.0
					ELSE 0
				   END) AS behavior_days_total
		FROM
			  (SELECT *
			   FROM ES_DAILY$daily_tracking_long
			   WHERE att_date >= '2013-08-19'
			   AND schoolid != 73255 --THRIVE has a different behavior system
			  ) sub_1
		GROUP BY student_number, schoolid, lastfirst, grade_level, team
		) sub_2