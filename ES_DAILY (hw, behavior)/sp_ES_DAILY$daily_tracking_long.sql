USE KIPP_NJ
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_ES_DAILY$daily_tracking_long|refresh] AS

BEGIN

--1) Pull from Oracle.  Put data into a temp table

SELECT sub.*
INTO #es_daily
FROM 
		--bringing data in from oracle xe
	 (SELECT *
		FROM OPENQUERY(PS_TEAM, '
				SELECT schoolid
					  ,att_date
					  ,studentid
					  ,student_number
					  ,lastfirst
					  ,grade_level
					  ,team
					  ,hw
					  ,color_day
					  ,thrive_am
					  ,thrive_mid
					  ,thrive_pm
				FROM
					  (SELECT schoolid
							 ,att_date
							 ,studentid
							 ,student_number
							 ,lastfirst
							 ,grade_level
							 ,team
							 ,hw
							 ,CASE
							   WHEN schoolid = 73255 THEN NULL
							   ELSE color
							 END AS color_day
							 ,CASE
							   WHEN schoolid = 73255 THEN color
							 END AS thrive_am
							 ,CASE
							   WHEN schoolid = 73255 THEN color_mid
							 END AS thrive_mid
							 ,CASE
							   WHEN schoolid = 73255 THEN color_pm
							 END AS thrive_pm     
					  FROM
							(SELECT scores.schoolid
								   ,scores.user_defined_date AS att_date
								   ,scores.foreignkey AS studentid
								   ,s.student_number
								   ,s.lastfirst
								   ,s.grade_level
								   ,s.team
								   --,scores.created_by
								   --,scores.created_on       
								   --,scores.related_to_table
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field1'') hw       
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field2'') color
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field3'') color_mid
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field4'') color_pm
								   /*
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field5'') field5
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field6'') field6
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field6'') field7
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field6'') field8
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field6'') field9
								   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',scores.unique_id,''field6'') field10
								   */
							FROM virtualtablesdata2 scores
							JOIN students s ON s.id = scores.foreignKey
							WHERE scores.related_to_table = ''dailytracking''					  					  
							ORDER BY scores.schoolid, scores.user_defined_date, scores.foreignKey
							)
					  )
				GROUP BY schoolid, att_date, studentid, student_number, lastfirst, grade_level, team, hw, color_day, thrive_am, thrive_mid, thrive_pm
				')) sub
 
--2) If everything has come across, truncate the local table here
--on KIPP_NJ
TRUNCATE TABLE ES_DAILY$daily_tracking

--3) Now insert the new rows
INSERT INTO ES_DAILY$daily_tracking
SELECT *
FROM #es_daily
END 
GO