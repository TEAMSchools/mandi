USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$hw_reporting AS
SELECT student_number AS [STUDENT_ID]
	  ,student_number AS [BASE_STUDENT_NUMBER]
	  ,lastfirst
	  ,grade_level AS [GRADE]
	  ,team
	  ,[HW_Yearly_Total]
	  ,[HW_Yearly_Complete]
	  ,[HW_Yearly_Missing]
	  ,CAST(ROUND([HW_Yearly_Complete]/[HW_Yearly_Total],2,1) AS FLOAT) AS [HW_Yearly_%]
FROM
		(SELECT student_number
			  ,schoolid
			  ,lastfirst
			  ,grade_level
			  ,team            
			  ,SUM(CASE
					WHEN hw IS NOT NULL THEN 1.0
				   END) AS [HW_Yearly_Total]      
			  ,SUM(CASE
					WHEN hw = 'Yes' THEN 1.0
				   END) AS [HW_Yearly_Complete]
			  ,SUM(CASE
					WHEN hw = 'No' THEN 1.0
				   END) AS [HW_Yearly_Missing]
		FROM
			  (SELECT *
			   FROM ES_DAILY$daily_tracking_long       
			   WHERE att_date >= '2013-08-19'       
			  ) sub_1
		GROUP BY student_number, schoolid, lastfirst, grade_level, team
		) sub_2