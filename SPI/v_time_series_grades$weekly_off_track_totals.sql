USE SPI
GO

CREATE VIEW TIME_SERIES_GRADES$weekly_off_track_totals AS
SELECT *
FROM OPENQUERY(KIPP_NWK, '
  SELECT schools.abbreviation AS school
        ,grade_level
        ,date_value
        ,(to_char(date_value, ''YYYY'') * 
            100 + to_char(date_value, ''IW'')) 
            AS reporting_hash
        ,pct_off_track_1
        ,pct_off_track_2
        ,pct_off_track_3
        ,avg_num_off
  FROM
       (SELECT schoolid
              ,DECODE(GROUPING(grade_level),0,TO_CHAR(grade_level),''campus'') AS grade_level
              ,date_value
              ,ROUND(AVG(off_track_1_flag)*100,1) AS pct_off_track_1
              ,ROUND(AVG(off_track_2_flag)*100,1) AS pct_off_track_2
              ,ROUND(AVG(off_track_3_flag)*100,1) AS pct_off_track_3
              ,ROUND(AVG(num_off),1) AS avg_num_off
        FROM 
             (SELECT s.schoolid
                    ,s.grade_level
                    ,counts.studentid
                    ,counts.date_value
                    ,counts.num_off
                    ,CASE
                       WHEN counts.num_off >= 1 THEN 1
                       WHEN counts.num_off = 0 THEN 0
                     END AS off_track_1_flag
                    ,CASE
                       WHEN counts.num_off >= 2 THEN 1
                       WHEN counts.num_off < 2 THEN 0
                     END AS off_track_2_flag
                    ,CASE
                       WHEN counts.num_off >= 3 THEN 1
                       WHEN counts.num_off < 3 THEN 0
                     END AS off_track_3_flag
              FROM GRADES$TIME_SERIES#COUNTS counts
              JOIN cohort$comprehensive_long s
                ON s.studentid = counts.studentid
               AND s.year = 2012
               AND s.rn = 1
              )
        WHERE to_char(date_value, ''D'') = 6 
           OR date_value = TRUNC(SYSDATE)
        GROUP BY schoolid
              ,CUBE(grade_level)
              ,date_value
        )
  JOIN schools@PS_TEAM
    ON schoolid = schools.school_number
  ORDER BY date_value DESC
          ,schoolid
          ,grade_level
')