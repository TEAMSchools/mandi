USE SPI
GO

ALTER VIEW TIME_SERIES_GRADES$weekly_off_track_totals AS

SELECT schools.abbreviation AS school
      ,grade_level
      ,date_value
      ,CONVERT(VARCHAR,DATEPART(YEAR,date_value)) + CONVERT(VARCHAR,DATEPART(WEEK,date_value)) AS reporting_hash
      ,CONVERT(FLOAT,pct_off_track_1) AS pct_off_track_1
      ,CONVERT(FLOAT,pct_off_track_2) AS pct_off_track_2
      ,CONVERT(FLOAT,pct_off_track_3) AS pct_off_track_3
      ,avg_num_off
FROM
    (
     SELECT schoolid       
           ,ISNULL(CONVERT(VARCHAR,grade_level),'campus') AS grade_level
           ,date_value           
           ,ROUND(AVG(off_track_1_flag) * 100, 1) AS pct_off_track_1
           ,ROUND(AVG(off_track_2_flag) * 100, 1) AS pct_off_track_2
           ,ROUND(AVG(off_track_3_flag) * 100, 1) AS pct_off_track_3
           ,ROUND(AVG(num_off), 1) AS avg_num_off
     FROM 
         (
          SELECT s.schoolid
                ,s.grade_level
                ,counts.studentid
                ,counts.date_value                
                ,CONVERT(FLOAT,counts.num_off) AS num_off
                ,CASE
                  WHEN counts.num_off >= 1 THEN 1.0
                  WHEN counts.num_off = 0 THEN 0.0
                 END AS off_track_1_flag
                ,CASE
                  WHEN counts.num_off >= 2 THEN 1.0
                  WHEN counts.num_off < 2 THEN 0.0
                 END AS off_track_2_flag
                ,CASE
                  WHEN counts.num_off >= 3 THEN 1.0
                  WHEN counts.num_off < 3 THEN 0.0
                 END AS off_track_3_flag
          FROM SPI..GRADES$TIME_SERIES#COUNTS counts WITH(NOLOCK)
          JOIN KIPP_NJ..COHORT$comprehensive_long#static s WITH(NOLOCK)
            ON counts.studentid = s.studentid
           AND s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
           AND s.rn = 1
         ) sub1
     WHERE (DATEPART(DW,date_value) = 6 OR date_value = CONVERT(DATE,GETDATE()))
     GROUP BY schoolid
             ,CUBE(grade_level)
             ,date_value
    ) sub2
JOIN KIPP_NJ..schools WITH(NOLOCK)
  ON sub2.schoolid = schools.school_number