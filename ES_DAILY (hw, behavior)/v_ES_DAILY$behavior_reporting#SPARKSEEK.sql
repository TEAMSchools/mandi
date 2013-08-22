USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$behavior_reporting#SPARKSEEK AS

SELECT student_number AS [STUDENT_ID]
	  ,student_number AS [BASE_STUDENT_NUMBER]
      ,lastfirst
      ,grade_level AS [GRADE]
      ,team
      ,SUM(CASE
            WHEN color_day = 'Purple' THEN 1
            ELSE 0
           END) AS [Purple]
      ,SUM(CASE
            WHEN color_day = 'Green' THEN 1
            ELSE 0
           END) AS [Green]
      ,SUM(CASE
            WHEN color_day = 'Yellow' THEN 1
            ELSE 0
           END) AS [Yellow]
      ,SUM(CASE
            WHEN color_day = 'Orange' THEN 1
            ELSE 0
           END) AS [Orange]
      ,SUM(CASE
            WHEN color_day = 'Red' THEN 1
            ELSE 0
           END) AS [Red]        
FROM
      (SELECT *
       FROM ES_DAILY$daily_tracking_long       
       WHERE att_date >= '2013-08-19'
       AND schoolid != 73255 --THRIVE has a different behavior system
      ) sub
GROUP BY student_number, schoolid, lastfirst, grade_level, team   