USE KIPP_NJ
GO
ALTER VIEW EMAIL$off_track_today#NCA AS
SELECT * FROM 
OPENQUERY(KIPP_NWK,
  'SELECT sub_2.*
FROM
     (SELECT date_value
            ,GROUPING(course_number) AS course_g
            ,GROUPING(credittype) AS credit_g
            ,GROUPING(just_number) AS number_g
            ,GROUPING(course_number) || GROUPING(credittype) || GROUPING(just_number) AS grouping_hash
            ,DECODE(GROUPING(course_number),0,course_number,''All'') course_number
            ,DECODE(GROUPING(credittype),0,TO_CHAR(credittype),''All'') credittype
            ,DECODE(GROUPING(just_number),0,TO_CHAR(just_number),''All'') just_number
            ,ROUND(AVG(off_track_flag) * 100,0) AS pct_off_track
            ,COUNT(*) AS N
            ,stragg_vert_pipe(DISTINCT course_name) AS elements
      FROM
           (SELECT grades.date_value
                  ,grades.course_number
                  ,courses.course_name
                  ,courses.credittype
                  ,FLOOR(REGEXP_SUBSTR(courses.course_number, ''[[:digit:]]+'')/10)*10 || 0 AS just_number
                  ,CASE
                     WHEN synthetic_percent < 70 THEN 1
                     WHEN synthetic_percent >= 70 THEN 0
                   END AS off_track_flag
            FROM grades$time_series_detail grades
            JOIN students
              ON grades.studentid = students.ID
             AND students.schoolid = 73253
            JOIN courses
              ON grades.course_number = courses.course_number
             AND courses.credittype != ''STUDY''
             AND courses.credittype != ''ART''
            WHERE grades.rt_name = ''Y1''
              AND grades.synthetic_percent IS NOT NULL
              AND grades.date_value = TRUNC(SYSDATE)
              --AND TO_CHAR(grades.date_value,''MMM'') = ''07-MAY-13''
              --AND TO_CHAR(grades.date_value,''MM'') = ''05''
            ) sub_1
      GROUP BY date_value
              ,CUBE(course_number
                   ,credittype
                   ,just_number)
      ) sub_2
WHERE grouping_hash IN 
  (''100'' --maximum detail (credits, rolled up by 100s)
  ,''111'' --all courses
  ,''101'' --rollup by credit only
  ,''110'' --rollup by number only
  )'
)




