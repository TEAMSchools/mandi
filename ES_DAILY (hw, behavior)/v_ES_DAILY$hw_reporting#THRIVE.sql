USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$hw_reporting#THRIVE AS
SELECT student_number	  
	     ,lastfirst
	     ,grade_level
	     ,team
	     ,hw_year_total
	     ,hw_year_complete
	     ,hw_year_missing
	     ,CAST(ROUND(hw_year_complete / hw_year_total,2,1)*100 AS FLOAT) AS hw_year_pct
FROM
		(SELECT student_number
			      ,schoolid
			      ,lastfirst
			      ,grade_level
			      ,team            
			      ,SUM(CASE WHEN hw IS NOT NULL THEN 1.0 ELSE NULL END) AS hw_year_total
			      ,SUM(CASE	WHEN hw = 'Yes' THEN 1.0 END) AS hw_year_complete
			      ,SUM(CASE	WHEN hw = 'No'  THEN 1.0 END) AS hw_year_missing
		 FROM
			     (SELECT *
			      FROM ES_DAILY$daily_tracking_long#static
			      WHERE att_date >= '04-Sep-13'
           AND att_date <= '22-Nov-13'
			     ) sub_1
		 GROUP BY student_number, schoolid, lastfirst, grade_level, team
		) sub_2
WHERE schoolid = 73255 --THRIVE only