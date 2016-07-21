USE KIPP_NJ
GO

ALTER VIEW AR$millionaires#on_track AS

SELECT studentid
      ,student_name
      ,lastfirst
      ,grade_level
      ,school
      ,year
      ,entrydate
      ,exitdate
      ,words
      ,rank_words_overall_in_school
      ,rank_words_overall_in_network
      ,cur_millionaire_test
      ,days_to_end
      ,stu_year
      ,(days_to_end / stu_year) frac_remain
      ,ROUND(sub.words / (1-(days_to_end / stu_year)), 0) AS proj_yr_words
      ,CASE
        WHEN ROUND(sub.words / (1 - (days_to_end / stu_year)), 0) >= 1000000 THEN 1
        WHEN ROUND(sub.words / (1 - (days_to_end / stu_year)), 0) < 1000000  THEN 0
       END AS proj_millionaire_dummy
FROM
    (
     SELECT studentid
           ,student_name
           ,lastfirst
           ,grade_level
           ,school
           ,year
           ,entrydate
           ,exitdate
           ,words
           ,rank_words_overall_in_school
           ,rank_words_overall_in_network
           ,CASE WHEN sub.words >= 1000000 THEN 1 ELSE 0 END AS cur_millionaire_test
           ,CAST(DATEDIFF(day,CAST(GETDATE() AS date), sub.exitdate) AS FLOAT) AS days_to_end
           ,CAST(DATEDIFF(day,sub.entrydate, sub.exitdate) AS FLOAT) AS stu_year
     FROM
         (
          SELECT c.studentid
                ,c.full_name AS student_name
                ,c.lastfirst
                ,c.grade_level
                ,c.school_name AS school
                ,c.year
                ,c.entrydate
                ,c.exitdate
                ,prog.words
                ,prog.rank_words_overall_in_school
                ,prog.rank_words_overall_in_network
          FROM KIPP_NJ..COHORT$identifiers_long#static c WITH (NOLOCK)
          JOIN KIPP_NJ..AR$progress_to_goals_long#static prog WITH(NOLOCK)
            ON c.studentid = prog.studentid
           AND c.year = prog.academic_year
           AND prog.time_hierarchy = 1
          WHERE c.schoolid IN (73252, 133570965, 73253)
            AND c.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND c.rn = 1
            AND c.enroll_status = 0
         ) sub
    ) sub
WHERE stu_year > 0