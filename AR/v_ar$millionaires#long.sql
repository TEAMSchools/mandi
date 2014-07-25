USE KIPP_NJ
GO

ALTER VIEW AR$millionaires#long AS
WITH scaffold AS
    (SELECT c.studentid
           ,s.student_number
           ,c.grade_level
           ,sch.abbreviation AS school
           ,c.year
           ,CONVERT(datetime, CAST('07/01/' + c.year AS DATE), 101) AS start_date_ar
           ,c.entrydate
           ,c.exitdate
           ,CAST(rd.date AS DATE) AS date
           ,CAST(DATEPART(month, rd.date) AS VARCHAR) + '/' + CAST(DATEPART(day, rd.date) AS VARCHAR) AS date_no_year
     FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
     JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
       ON c.schoolid = sch.school_number
     JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
       ON c.studentid = s.id
     JOIN KIPP_NJ..UTIL$reporting_days rd WITH (NOLOCK)
       ON rd.date >= c.entrydate
      AND rd.date <  c.exitdate           
     WHERE c.schoolid IN (73252, 133570965, 73253)
       AND c.year IN (2010, 2011, 2012, 2013)
       AND c.rn = 1
       --testing
       --AND s.last_name = 'Williams'
       --AND c.year = 2012
     )

SELECT CASE GROUPING(sub.grade_level)
         WHEN 1 THEN 'School'
         ELSE CAST(sub.grade_level AS NVARCHAR)
       END AS grade_level
      ,sub.school
      ,sub.year
      ,sub.date
      ,sub.date_no_year
      ,SUM(millionaire_test) AS millionaires
      ,CAST(ROUND(AVG(millionaire_test + 0.0) * 100,0) AS FLOAT) AS pct_millionaire
FROM
      (SELECT sub.*
             ,CASE
                WHEN sub.words >= 1000000 THEN 1
                ELSE 0
              END AS millionaire_test
       FROM
             (SELECT TOP 1000000000000 scaffold.studentid
                    ,scaffold.grade_level
                    ,scaffold.school
                    ,scaffold.year
                    ,scaffold.date
                    ,scaffold.date_no_year
                    ,SUM(CASE
                           WHEN det.tipassed = 1 THEN det.iwordcount
                           ELSE 0
                         END) AS words
              FROM scaffold
              JOIN KIPP_NJ..AR$test_event_detail#static det WITH (NOLOCK)
                ON CAST(scaffold.student_number AS VARCHAR) = det.student_number
               AND det.dtTaken >= scaffold.start_date_ar
               AND det.dtTaken <  scaffold.date
              GROUP BY scaffold.studentid
                      ,scaffold.grade_level
                      ,scaffold.school
                      ,scaffold.year
                      ,scaffold.date
                      ,scaffold.date_no_year
              ORDER BY scaffold.studentid
                      ,scaffold.date
              ) sub
       ) sub
GROUP BY CUBE(sub.grade_level)
        ,sub.school
        ,sub.year
        ,sub.date
        ,sub.date_no_year