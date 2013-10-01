USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$behavior_reporting_totals#THRIVE AS
SELECT student_number
	     ,studentid
      ,lastfirst
      ,grade_level
      ,team
      ,pink_total
      ,green_total
      ,yellow_total
      ,orange_total
      ,red_total
      ,behavior_count_total
      ,CAST(ROUND(pink_total   / behavior_count_total,2,1)*100 AS FLOAT) AS pink_pct
      ,CAST(ROUND(green_total  / behavior_count_total,2,1)*100 AS FLOAT) AS green_pct
      ,CAST(ROUND(yellow_total / behavior_count_total,2,1)*100 AS FLOAT) AS yellow_pct
      ,CAST(ROUND(orange_total / behavior_count_total,2,1)*100 AS FLOAT) AS orange_pct
      ,CAST(ROUND(red_total    / behavior_count_total,2,1)*100 AS FLOAT) AS red_pct
FROM
		   (SELECT student_number
			         ,studentid
			         ,lastfirst
			         ,grade_level
			         ,team
			         ,pink_total_1 + pink_total_2 + pink_total_3 AS pink_total
			         ,green_total_1 + green_total_2 + green_total_3 AS green_total
			         ,yellow_total_1 + yellow_total_2 + yellow_total_3 AS yellow_total
			         ,orange_total_1 + orange_total_2 + orange_total_3 AS orange_total
			         ,red_total_1 + red_total_2 + red_total_3 AS red_total
			         ,CASE
			           WHEN counts_total_1 + counts_total_2 + counts_total_3 = 0 THEN NULL
			           ELSE counts_total_1 + counts_total_2 + counts_total_3
			          END AS behavior_count_total
		    FROM
			        (SELECT student_number
					             ,studentid	  
					             ,lastfirst
					             ,grade_level
					             ,team			  
					             --pink
					             ,SUM(CASE WHEN color_1 = 'Pink' THEN 1.0 ELSE 0 END) AS pink_total_1
					             ,SUM(CASE WHEN color_2 = 'Pink' THEN 1.0	ELSE 0 END) AS pink_total_2
					             ,SUM(CASE	WHEN color_3 = 'Pink' THEN 1.0	ELSE 0 END) AS pink_total_3
					             --green
					             ,SUM(CASE WHEN color_1 = 'Green' THEN 1.0 ELSE 0 END) AS green_total_1
					             ,SUM(CASE	WHEN color_2 = 'Green' THEN 1.0	ELSE 0 END) AS green_total_2
					             ,SUM(CASE	WHEN color_3 = 'Green' THEN 1.0	ELSE 0 END) AS green_total_3
					             --yellow
					             ,SUM(CASE WHEN color_1 = 'Yellow' THEN 1.0 ELSE 0 END) AS yellow_total_1
					             ,SUM(CASE	WHEN color_2 = 'Yellow' THEN 1.0	ELSE 0 END) AS yellow_total_2
					             ,SUM(CASE	WHEN color_3 = 'Yellow' THEN 1.0	ELSE 0 END) AS yellow_total_3
					             --orange
					             ,SUM(CASE	WHEN color_1 = 'Orange' THEN 1.0 ELSE 0 END) AS orange_total_1
					             ,SUM(CASE	WHEN color_2 = 'Orange' THEN 1.0	ELSE 0 END) AS orange_total_2
					             ,SUM(CASE WHEN color_3 = 'Orange' THEN 1.0	ELSE 0 END) AS orange_total_3
					             --red
					             ,SUM(CASE WHEN color_1 = 'Red' THEN 1.0 ELSE 0 END) AS red_total_1
					             ,SUM(CASE	WHEN color_2 = 'Red' THEN 1.0	ELSE 0 END) AS red_total_2
					             ,SUM(CASE	WHEN color_3 = 'Red' THEN 1.0	ELSE 0 END) AS red_total_3			  
					             --total counts
					             ,SUM(CASE WHEN color_1 IS NOT NULL THEN 1.0 ELSE 0 END) AS counts_total_1
					             ,SUM(CASE WHEN color_2 IS NOT NULL THEN 1.0 ELSE 0 END) AS counts_total_2
					             ,SUM(CASE WHEN color_3 IS NOT NULL THEN 1.0 ELSE 0 END) AS counts_total_3
				        FROM
					            (SELECT *
					             FROM ES_DAILY$behavior_reporting_long#THRIVE
					             --WHERE schoolid = 73255					             
					            ) sub_1
				        GROUP BY student_number, studentid, lastfirst, grade_level, team
				       ) sub_2
				 ) sub_3