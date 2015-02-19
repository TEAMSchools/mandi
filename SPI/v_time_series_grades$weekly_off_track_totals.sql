USE SPI
GO

ALTER VIEW TIME_SERIES_GRADES$weekly_off_track_totals AS

SELECT school
      ,ISNULL(CONVERT(VARCHAR,grade_level),'campus') AS grade_level
      ,date_value           
      ,CONVERT(VARCHAR,DATEPART(YEAR,date_value)) + RIGHT('0' + CONVERT(VARCHAR,DATEPART(WEEK,date_value)),2) AS reporting_hash
      ,CONVERT(FLOAT,ROUND(AVG(off_track_1_flag) * 100, 1)) AS pct_off_track_1
      ,CONVERT(FLOAT,ROUND(AVG(off_track_2_flag) * 100, 1)) AS pct_off_track_2
      ,CONVERT(FLOAT,ROUND(AVG(off_track_3_flag) * 100, 1)) AS pct_off_track_3
      ,CONVERT(FLOAT,ROUND(AVG(num_off), 1)) AS avg_num_off
FROM 
    (
     SELECT school
           ,grade_level
           ,studentid
           ,date_value
           ,SUM(is_offtrack) AS num_off
           ,CASE WHEN SUM(is_offtrack) >= 1 THEN 1.0 ELSE 0.0 END AS off_track_1_flag
           ,CASE WHEN SUM(is_offtrack) >= 2 THEN 1.0 ELSE 0.0 END AS off_track_2_flag
           ,CASE WHEN SUM(is_offtrack) >= 3 THEN 1.0 ELSE 0.0 END AS off_track_3_flag
     FROM
         (
          SELECT s.school_name AS school
                ,s.grade_level
                ,s.studentid
                ,counts.date AS date_value       
                ,CASE
                  WHEN counts.schoolid = 73253 AND moving_average < 70 THEN 1.0
                  WHEN counts.schoolid != 73253 AND moving_average < 65 THEN 1.0
                  ELSE 0.0
                 END AS is_offtrack
          FROM KIPP_NJ..GRADES$time_series#STAGING counts WITH(NOLOCK)
          JOIN KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
            ON counts.student_number = s.student_number
           AND s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
           AND s.rn = 1
          WHERE counts.finalgradename = 'Y1'
            AND (DATEPART(DW,counts.date) = 7 OR counts.date = CONVERT(DATE,GETDATE()))
         ) sub
     GROUP BY school
             ,grade_level
             ,studentid
             ,date_value        
    ) sub
GROUP BY school
        ,CUBE(grade_level)
        ,date_value