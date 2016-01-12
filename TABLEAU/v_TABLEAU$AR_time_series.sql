USE KIPP_NJ
GO

ALTER VIEW TABLEAU$AR_time_series AS

WITH ar_long AS (
  SELECT student_number
        ,academic_year      
        ,CONVERT(DATE,dtTaken) AS date_taken        
        ,SUM(dPointsEarned) AS n_points_earned
        ,SUM(iWordCount) AS n_words_read        
        ,SUM(CASE WHEN chfictionnonfiction = 'F' THEN 1 ELSE 0 END) AS n_fiction
        ,COUNT(iStudentPracticeID) AS n_books_read
        ,AVG(dPercentCorrect) AS avg_pct_correct
        ,AVG(iAlternateBookLevel_2) AS avg_lexile
  FROM KIPP_NJ..AR$test_event_detail#static WITH(NOLOCK)
  WHERE tiPassed = 1
  GROUP BY student_number
          ,academic_year      
          ,CONVERT(DATE,dtTaken)
 )

SELECT *
      ,CASE 
        WHEN COALESCE(ontrack_points_term, ontrack_words_term) IS NULL THEN NULL
        WHEN schoolid = 73253 AND n_points_earned_running_term >= ontrack_points_term THEN 1
        WHEN schoolid != 73253 AND n_words_read_running_term >= ontrack_words_term THEN 1
        ELSE 0
       END AS is_ontrack_term
      ,CASE 
        WHEN COALESCE(ontrack_points_yr, ontrack_words_yr) IS NULL THEN NULL
        WHEN schoolid = 73253 AND n_points_earned_running_yr >= ontrack_points_yr THEN 1
        WHEN schoolid != 73253 AND n_words_read_running_yr >= ontrack_words_yr THEN 1
        ELSE 0
       END AS is_ontrack_yr
FROM
    (
     SELECT co.student_number
           ,co.lastfirst
           ,co.year
           ,co.schoolid
           ,co.grade_level
           ,co.team
           ,co.advisor
           ,co.SPEDLEP
           ,co.term
           ,co.date           
           ,CASE WHEN DATEPART(WEEK,co.date) = DATEPART(WEEK,CONVERT(DATE,GETDATE())) THEN 1 ELSE 0 END AS is_current_week
      
           ,enr.COURSE_NAME
           ,enr.COURSE_NUMBER
           ,enr.SECTION_NUMBER
           ,enr.teacher_name
      
           ,y1_goal.words_goal AS words_goal_yr
           ,y1_goal.points_goal AS points_goal_yr           
           ,SUM(y1_goal.words_goal / DATEDIFF(DAY, y1_goal.time_period_start, y1_goal.time_period_end))  OVER(
              PARTITION BY co.student_number, co.year
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS ontrack_words_yr
           ,SUM(y1_goal.points_goal / DATEDIFF(DAY, y1_goal.time_period_start, y1_goal.time_period_end))  OVER(
              PARTITION BY co.student_number, co.year
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS ontrack_points_yr      
           
           ,term_goal.time_period_name AS goal_term
           ,term_goal.words_goal AS words_goal_term
           ,term_goal.points_goal AS points_goal_term
           ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN term_goal.time_period_start AND term_goal.time_period_end THEN 1 ELSE 0 END AS is_curterm
           ,SUM(term_goal.words_goal / DATEDIFF(DAY, term_goal.time_period_start, term_goal.time_period_end))  OVER(
              PARTITION BY co.student_number, co.year, co.term
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS ontrack_words_term
           ,SUM(term_goal.points_goal / DATEDIFF(DAY, term_goal.time_period_start, term_goal.time_period_end))  OVER(
              PARTITION BY co.student_number, co.year, co.term
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS ontrack_points_term
      
           ,ar.n_words_read
           ,ar.n_points_earned
           ,ar.n_books_read
           ,ar.n_fiction
           ,ar.avg_lexile
           ,ar.avg_pct_correct
           ,NULL AS book_titles

           ,SUM(ar.n_words_read) OVER(
              PARTITION BY co.student_number, co.year, co.term
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS n_words_read_running_term
           ,SUM(ar.n_words_read) OVER(
              PARTITION BY co.student_number, co.year
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS n_words_read_running_yr
           ,SUM(ar.n_points_earned) OVER(
              PARTITION BY co.student_number, co.year, co.term
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS n_points_earned_running_term
           ,SUM(ar.n_points_earned) OVER(
              PARTITION BY co.student_number, co.year
                ORDER BY co.date ROWS UNBOUNDED PRECEDING) AS n_points_earned_running_yr
     FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
     JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       ON co.student_number = enr.student_number
      AND co.year = enr.academic_year
      AND enr.CREDITTYPE = 'ENG'
      AND enr.drop_flags = 0
      AND enr.rn_subject = 1
     LEFT OUTER JOIN KIPP_NJ..AR$goals y1_goal WITH (NOLOCK)
       ON co.student_number = y1_goal.student_number   
      AND co.date BETWEEN y1_goal.time_period_start AND y1_goal.time_period_end
      AND y1_goal.time_period_hierarchy = 1
     LEFT OUTER JOIN KIPP_NJ..AR$goals term_goal WITH (NOLOCK)
       ON co.student_number = term_goal.student_number   
      AND co.date BETWEEN term_goal.time_period_start AND term_goal.time_period_end
      AND term_goal.time_period_hierarchy = 2
     LEFT OUTER JOIN ar_long ar
       ON co.student_number = ar.student_number
      AND co.date = ar.date_taken
     WHERE co.year >= 2013
       AND co.schoolid != 999999
       AND ((co.grade_level >= 5) OR (co.schoolid = 73252 AND co.grade_level = 4))
       AND co.date <= CONVERT(DATE,GETDATE())
       AND co.enroll_status = 0
    ) sub