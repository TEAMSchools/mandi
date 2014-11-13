USE KIPP_NJ
GO

ALTER VIEW AR$millionaires#on_track AS
WITH scaffold AS (
     SELECT c.studentid
           ,s.student_number
           ,s.lastfirst
           ,s.first_name + ' ' + s.last_name AS student_name
           ,c.grade_level
           ,sch.abbreviation AS school
           ,c.year
           ,CONVERT(datetime, CAST(('07/01/' + CONVERT(VARCHAR,c.year)) AS DATE), 101) AS start_date_ar
           ,CAST(c.entrydate AS date) AS entrydate
           ,CAST(c.exitdate AS date) AS exitdate
     FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
     JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
       ON c.schoolid = sch.school_number
     JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
       ON c.studentid = s.id
      AND s.enroll_status = 0
      --TESTING
     WHERE c.schoolid IN (73252, 133570965, 73253)
       AND c.year = dbo.fn_Global_Academic_Year()
       AND c.rn = 1
    )

SELECT sub.*
      ,(days_to_end / stu_year) frac_remain
      ,ROUND(sub.words / (1-(days_to_end / stu_year)), 0) AS proj_yr_words
      ,CASE
         WHEN ROUND(sub.words / (1-(days_to_end / stu_year)), 0) >= 1000000 THEN 1
         WHEN ROUND(sub.words / (1-(days_to_end / stu_year)), 0) < 1000000  THEN 0
       END AS proj_millionaire_dummy
FROM
     (SELECT sub.*
            ,CASE
               WHEN sub.words >= 1000000 THEN 1
               ELSE 0
             END AS cur_millionaire_test
            ,CAST(DATEDIFF(day,CAST(GETDATE() AS date), sub.exitdate) AS FLOAT) AS days_to_end
            ,CAST(DATEDIFF(day,sub.entrydate, sub.exitdate) AS FLOAT) AS stu_year
      FROM
            (SELECT scaffold.studentid
                   ,scaffold.student_name
                   ,scaffold.lastfirst
                   ,scaffold.grade_level
                   ,scaffold.school
                   ,scaffold.year
                   ,scaffold.entrydate
                   ,scaffold.exitdate
                   ,prog.words
                   ,prog.rank_words_overall_in_school
                   ,prog.rank_words_overall_in_network
             FROM scaffold WITH(NOLOCK)
             JOIN KIPP_NJ..AR$progress_to_goals_long#static prog WITH(NOLOCK)
               ON scaffold.studentid = prog.studentid
              AND prog.yearid = dbo.fn_Global_Term_Id()
              AND prog.time_hierarchy = 1
             ) sub
      ) sub
WHERE stu_year > 0