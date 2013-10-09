/*
  Used for grade wide pivots by credittype
  
  This view gives each MS student a row for 5 core credittypes
  
  For students who do not take Writing, or History (@ TEAM), course number is null
 
*/


USE KIPP_NJ
GO

--ALTER VIEW GRADES$detail_placeholder#MS AS


SELECT TOP 100 PERCENT sub2.*
FROM
(
SELECT sub1.*
      ,grades.course_number
      ,sub1.rn as rn_format
FROM
   (SELECT
       id AS studentid
      ,student_number
      ,schoolid
      ,lastfirst
      ,grade_level
      ,rn
      ,CASE WHEN rn = 1 THEN 'ENG' 
            WHEN rn = 2 THEN 'RHET'
            WHEN rn = 3 THEN 'MATH'
            WHEN rn = 4 THEN 'SCI' 
            WHEN rn = 5 THEN 'SOC' 
         
            ELSE NULL
            END credittype
    FROM
       (SELECT s.student_number
              ,s.id
              ,s.schoolid
              ,s.lastfirst
              ,s.grade_level
              ,row_number() 
                OVER 
               (PARTITION BY s.id
                ORDER BY s.lastfirst) AS rn
        FROM students s
        JOIN t500 t on s.student_number != t.id

        WHERE s.schoolid IN (73252,133570965)
          AND s.enroll_status = 0
          AND t.id <= 5
       )
       sub
   )
   sub1
LEFT OUTER JOIN GRADES$DETAIL#MS grades 
  ON sub1.studentid = grades.studentid 
  AND sub1.credittype = grades.credittype
)
sub2
ORDER BY lastfirst,rn