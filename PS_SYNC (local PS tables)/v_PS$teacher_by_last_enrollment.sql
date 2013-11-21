USE KIPP_NJ
GO

ALTER VIEW PS$teacher_by_last_enrollment AS
SELECT TOP (100) PERCENT
       schoolid
      ,studentid
      ,teacherid
      ,cast(course_number as varchar(11)) course_number
      ,cast(termid as numeric) termid
      ,last_name
      ,first_name
      ,lastfirst
      ,rn
FROM
     (SELECT cc.schoolid
            ,cc.studentid
            ,cc.teacherid
            ,cc.course_number
            ,cc.termid
            ,tch_sub.last_name
            ,tch_sub.first_name
            ,tch_sub.lastfirst
            ,ROW_NUMBER() OVER(
                PARTITION BY cc.studentid, cc.course_number
                    ORDER BY cc.termid DESC) AS rn
      FROM CC WITH (NOLOCK)
      JOIN (SELECT id AS teacherid
                  ,lastfirst
                  ,last_name
                  ,first_name
            FROM TEACHERS WITH (NOLOCK)
            ) tch_sub
        ON cc.teacherid = tch_sub.teacherid
      WHERE cc.termid >= 2300
     ) sub1
WHERE rn = 1
ORDER BY schoolid, studentid, course_number