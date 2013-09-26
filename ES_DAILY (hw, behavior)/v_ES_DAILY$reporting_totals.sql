USE KIPP_NJ
GO

WITH roster AS
     (SELECT c.schoolid
            ,s.student_number
            ,s.id AS studentid
            ,s.lastfirst
            ,c.grade_level            
            ,s.team
      FROM KIPP_NJ..COHORT$comprehensive_long#static c
      JOIN KIPP_NJ..STUDENTS s
        ON c.studentid = s.id
       AND s.enroll_status = 0       
      WHERE c.year = 2013
        AND c.rn = 1        
        AND c.schoolid IN (73254,73255,73256)
     )

SELECT roster.*
      ,hw.hw_year_total
      ,hw.hw_year_complete
      ,hw.hw_year_missing
      
      ,'|' AS SPARKSEEK
      ,spsk_behav.purple_total
      ,spsk_behav.green_total
      ,spsk_behav.yellow_total
      ,spsk_behav.orange_total
      ,spsk_behav.red_total
      ,spsk_behav.behavior_days_total
      ,spsk_behav.purple_pct
      ,spsk_behav.green_pct
      ,spsk_behav.yellow_pct
      ,spsk_behav.orange_pct
      ,spsk_behav.red_pct
      
      ,'|' AS THRIVE
      ,th_behav.pink_total
      ,th_behav.green_total
      ,th_behav.yellow_total
      ,th_behav.orange_total
      ,th_behav.red_total
      ,th_behav.behavior_days_total
      ,th_behav.pink_pct
      ,th_behav.green_pct
      ,th_behav.yellow_pct
      ,th_behav.orange_pct
      ,th_behav.red_pct
      
FROM roster
LEFT OUTER JOIN
     (SELECT sub.*
	           ,CAST(ROUND(hw_year_complete / hw_year_total,2,1) AS FLOAT) AS hw_year_pct
      FROM
		         (SELECT studentid 
		                ,SUM(CASE WHEN hw IS NOT NULL THEN 1.0 ELSE NULL END) AS hw_year_total
			               ,SUM(CASE	WHEN hw = 'Yes' THEN 1.0 END) AS hw_year_complete
			               ,SUM(CASE	WHEN hw = 'No'  THEN 1.0 END) AS hw_year_missing
		          FROM ES_DAILY$daily_tracking_long#static			       
		          GROUP BY studentid
	          ) sub
	    ) hw
  ON roster.studentid = hw.studentid
	    
LEFT OUTER JOIN
     (SELECT sub.*
            ,CAST(ROUND(purple_total / behavior_days_total,2,1) * 100 AS FLOAT) AS purple_pct
            ,CAST(ROUND(green_total  / behavior_days_total,2,1) * 100	AS FLOAT) AS green_pct
            ,CAST(ROUND(yellow_total / behavior_days_total,2,1) * 100 AS FLOAT) AS yellow_pct
            ,CAST(ROUND(orange_total / behavior_days_total,2,1) * 100 AS FLOAT) AS orange_pct
            ,CAST(ROUND(red_total    / behavior_days_total,2,1) * 100	AS FLOAT) AS red_pct
      FROM
	          (SELECT studentid			         
			               ,SUM(CASE WHEN color_day = 'Purple'  THEN 1.0 ELSE 0 END) AS purple_total
			               ,SUM(CASE WHEN color_day = 'Green'   THEN 1.0 ELSE 0 END) AS green_total
			               ,SUM(CASE WHEN color_day = 'Yellow'  THEN 1.0 ELSE 0 END) AS yellow_total
			               ,SUM(CASE WHEN color_day = 'Orange'  THEN 1.0 ELSE 0 END) AS orange_total
			               ,SUM(CASE WHEN color_day = 'Red'     THEN 1.0 ELSE 0 END) AS red_total
			               ,SUM(CASE WHEN color_day IS NOT NULL THEN 1.0 ELSE NULL END) AS behavior_days_total
		          FROM ES_DAILY$daily_tracking_long#static
		          WHERE schoolid != 73255
		          GROUP BY studentid
		         ) sub
     ) spsk_behav
ON roster.studentid = spsk_behav.studentid
		   
LEFT OUTER JOIN
     (SELECT sub_2.*
            ,CAST(ROUND(pink_total   / behavior_days_total,2,1)*100 AS FLOAT) AS pink_pct
            ,CAST(ROUND(green_total  / behavior_days_total,2,1)*100 AS FLOAT) AS green_pct
            ,CAST(ROUND(yellow_total / behavior_days_total,2,1)*100 AS FLOAT) AS yellow_pct
            ,CAST(ROUND(orange_total / behavior_days_total,2,1)*100 AS FLOAT) AS orange_pct
            ,CAST(ROUND(red_total    / behavior_days_total,2,1)*100 AS FLOAT) AS red_pct
      FROM
	          (SELECT studentid			         
		                ,pink_total_1   + pink_total_2   + pink_total_3   AS pink_total
		                ,green_total_1  + green_total_2  + green_total_3  AS green_total
		                ,yellow_total_1 + yellow_total_2 + yellow_total_3 AS yellow_total
		                ,orange_total_1 + orange_total_2 + orange_total_3 AS orange_total
		                ,red_total_1    + red_total_2    + red_total_3    AS red_total
		                ,counts_total_1 + counts_total_2 + counts_total_3 AS behavior_days_total
	           FROM
		               (SELECT studentid	  					             
				                    --pink
				                    ,SUM(CASE WHEN thrive_am = 'Pink' THEN 1.0 ELSE 0 END) AS pink_total_1
				                    ,SUM(CASE WHEN thrive_mid = 'Pink' THEN 1.0	ELSE 0 END) AS pink_total_2
				                    ,SUM(CASE	WHEN thrive_pm = 'Pink' THEN 1.0	ELSE 0 END) AS pink_total_3
				                    --green
				                    ,SUM(CASE WHEN thrive_am = 'Green' THEN 1.0 ELSE 0 END) AS green_total_1
				                    ,SUM(CASE	WHEN thrive_mid = 'Green' THEN 1.0	ELSE 0 END) AS green_total_2
				                    ,SUM(CASE	WHEN thrive_pm = 'Green' THEN 1.0	ELSE 0 END) AS green_total_3
				                    --yellow
				                    ,SUM(CASE WHEN thrive_am = 'Yellow' THEN 1.0 ELSE 0 END) AS yellow_total_1
				                    ,SUM(CASE	WHEN thrive_mid = 'Yellow' THEN 1.0	ELSE 0 END) AS yellow_total_2
				                    ,SUM(CASE	WHEN thrive_pm = 'Yellow' THEN 1.0	ELSE 0 END) AS yellow_total_3
				                    --orange
				                    ,SUM(CASE	WHEN thrive_am = 'Orange' THEN 1.0 ELSE 0 END) AS orange_total_1
				                    ,SUM(CASE	WHEN thrive_mid = 'Orange' THEN 1.0	ELSE 0 END) AS orange_total_2
				                    ,SUM(CASE WHEN thrive_pm = 'Orange' THEN 1.0	ELSE 0 END) AS orange_total_3
				                    --red
				                    ,SUM(CASE WHEN thrive_am = 'Red' THEN 1.0 ELSE 0 END) AS red_total_1
				                    ,SUM(CASE	WHEN thrive_mid = 'Red' THEN 1.0	ELSE 0 END) AS red_total_2
				                    ,SUM(CASE	WHEN thrive_pm = 'Red' THEN 1.0	ELSE 0 END) AS red_total_3			  
				                    --total counts
				                    ,SUM(CASE WHEN thrive_am IS NOT NULL THEN 1.0 ELSE NULL END) AS counts_total_1
				                    ,SUM(CASE WHEN thrive_mid IS NOT NULL THEN 1.0 ELSE NULL END) AS counts_total_2
				                    ,SUM(CASE WHEN thrive_pm IS NOT NULL THEN 1.0 ELSE NULL END) AS counts_total_3
			               FROM ES_DAILY$daily_tracking_long#static
				              WHERE schoolid = 73255					      
			               GROUP BY studentid
			              ) sub_1
			        ) sub_2
     ) th_behav
  ON roster.studentid = th_behav.studentid