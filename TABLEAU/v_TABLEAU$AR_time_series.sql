USE KIPP_NJ
GO

ALTER VIEW TABLEAU$AR_time_series AS

WITH ar_long AS (
  SELECT student_number
        ,academic_year              
        ,CONVERT(DATE,dtTaken) AS date_taken        
        ,MIN(CONVERT(DATE,dtTaken)) OVER(PARTITION BY student_number, academic_year) AS min_date_taken        
        ,SUM(tipassed) AS n_books_passed
        ,COUNT(iStudentPracticeID) AS n_books_read
        ,SUM(CASE WHEN tiPassed = 1 THEN dPointsEarned END) AS n_points_earned
        ,SUM(CASE WHEN tiPassed = 1 THEN iWordCount END) AS n_words_read        
        ,SUM(CASE WHEN chfictionnonfiction = 'F' THEN 1 ELSE 0 END) AS n_fiction        
        ,AVG(dPercentCorrect) AS avg_pct_correct
        ,ROUND(AVG(iAlternateBookLevel_2),0) AS avg_lexile
  FROM KIPP_NJ..AR$test_event_detail#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  GROUP BY student_number
          ,academic_year      
          ,CONVERT(DATE,dtTaken)
 )

,last_book AS (
  SELECT student_number
        ,academic_year
        ,CASE 
          WHEN academic_year < KIPP_NJ.dbo.fn_Global_Academic_Year() THEN DATEDIFF(DAY, dttaken, CONVERT(DATE,CONCAT(academic_year,'-06-30')))
          ELSE DATEDIFF(DAY, dttaken, GETDATE())
         END AS n_days_ago
        ,vchContentTitle AS book_title
        ,iAlternateBookLevel_2 AS book_lexile
        ,dPercentCorrect AS book_pct_correct
        ,iWordCount AS word_count
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY dttaken DESC) AS rn
  FROM KIPP_NJ..AR$test_event_detail#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

SELECT student_number
      ,lastfirst
      ,year
      ,schoolid
      ,grade_level
      ,team
      ,advisor
      ,SPEDLEP
      ,term
      ,date
      ,is_current_week
      ,is_curterm
      ,COURSE_NAME
      ,COURSE_NUMBER
      ,SECTION_NUMBER
      ,teacher_name
      ,homeroom_section
      ,homeroom_teacher
      ,words_goal_yr
      ,points_goal_yr
      ,goal_term
      ,words_goal_term
      ,points_goal_term
      ,n_words_read
      ,n_points_earned
      ,n_books_read
      ,n_fiction
      ,avg_lexile
      ,avg_pct_correct
      ,last_book_title
      ,last_book_days_ago
      ,last_book_lexile
      ,last_book_pct_correct
      ,ontrack_words_yr
      ,NULL AS ontrack_points_yr
      ,ontrack_words_term
      ,NULL AS ontrack_points_term
      ,n_words_read_running_term
      ,n_words_read_running_yr
      ,NULL AS n_points_earned_running_term
      ,NULL AS n_points_earned_running_yr
      ,CASE 
        WHEN ontrack_words_term IS NULL THEN NULL
        --WHEN schoolid = 73253 AND n_points_earned_running_term >= ontrack_points_term THEN 1
        WHEN schoolid != 73253 AND n_words_read_running_term >= ontrack_words_term THEN 1
        ELSE 0
       END AS is_ontrack_term
      ,CASE 
        WHEN ontrack_words_yr IS NULL THEN NULL
        --WHEN schoolid = 73253 AND n_points_earned_running_yr >= ontrack_points_yr THEN 1
        WHEN schoolid != 73253 AND n_words_read_running_yr >= ontrack_words_yr THEN 1
        ELSE 0
       END AS is_ontrack_yr
FROM
    (
     SELECT co.student_number
           ,co.lastfirst
           ,co.year
           ,co.reporting_schoolid AS schoolid
           ,co.grade_level
           ,co.team
           ,co.advisor
           ,co.SPEDLEP
           ,dts.alt_name AS term
           ,co.date           
           ,CASE 
             WHEN DATEPART(WEEK,co.date) = DATEPART(WEEK,CONVERT(DATE,GETDATE())) THEN 1 
             WHEN DATEPART(WEEK,co.date) = DATEPART(WEEK,MAX(co.date) OVER(PARTITION BY co.schoolid, co.year, co.student_number)) THEN 1 
             ELSE 0 
            END AS is_current_week
           ,CASE 
             WHEN CONVERT(DATE,GETDATE()) BETWEEN term_goal.time_period_start AND term_goal.time_period_end THEN 1 
             WHEN MAX(co.date) OVER(PARTITION BY co.schoolid, co.year, co.student_number) BETWEEN term_goal.time_period_start AND term_goal.time_period_end THEN 1 
             ELSE 0 
            END AS is_curterm
      
           ,enr.COURSE_NAME
           ,enr.COURSE_NUMBER
           ,enr.SECTION_NUMBER
           ,enr.teacher_name           
           
           ,hr.SECTION_NUMBER AS homeroom_section
           ,hr.teacher_name AS homeroom_teacher
      
           ,y1_goal.words_goal AS words_goal_yr
           ,y1_goal.points_goal AS points_goal_yr               
           
           ,term_goal.time_period_name AS goal_term
           ,term_goal.words_goal AS words_goal_term
           ,term_goal.points_goal AS points_goal_term           
      
           ,ar.n_words_read
           ,ar.n_points_earned
           ,ar.n_books_read
           ,ar.n_fiction
           ,ar.avg_lexile
           ,ar.avg_pct_correct
           
           ,bk.book_title AS last_book_title
           ,bk.n_days_ago AS last_book_days_ago 
           ,bk.book_lexile AS last_book_lexile
           ,bk.book_pct_correct AS last_book_pct_correct
           ,bk.word_count AS last_book_word_count

           ,y1_goal.words_goal * (CONVERT(FLOAT,DATEDIFF(DAY, y1_goal.time_period_start, co.date)) / DATEDIFF(DAY, y1_goal.time_period_start, y1_goal.time_period_end)) AS ontrack_words_yr           
           ,term_goal.words_goal * (CONVERT(FLOAT,DATEDIFF(DAY, term_goal.time_period_start, co.date)) / DATEDIFF(DAY, term_goal.time_period_start, term_goal.time_period_end)) AS ontrack_words_term           
           ,SUM(ar.n_words_read) OVER(
              PARTITION BY co.student_number, co.year, term_goal.time_period_name
                ORDER BY co.date) AS n_words_read_running_term
           ,SUM(ar.n_words_read) OVER(
              PARTITION BY co.student_number, co.year
                ORDER BY co.date) AS n_words_read_running_yr
           /*
           ,SUM(y1_goal.points_goal / DATEDIFF(DAY, y1_goal.time_period_start, y1_goal.time_period_end)) OVER(
              PARTITION BY co.student_number, co.year
                ORDER BY co.date) AS ontrack_points_yr  
           ,SUM(term_goal.points_goal / DATEDIFF(DAY, y1_goal.time_period_start, term_goal.time_period_end)) OVER(
              PARTITION BY co.student_number, co.year, term_goal.time_period_name
                ORDER BY co.date) AS ontrack_points_term
           ,SUM(ar.n_points_earned) OVER(
              PARTITION BY co.student_number, co.year, term_goal.time_period_name
                ORDER BY co.date) AS n_points_earned_running_term
           ,SUM(ar.n_points_earned) OVER(
              PARTITION BY co.student_number, co.year
                ORDER BY co.date) AS n_points_earned_running_yr
           */
     FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
       ON co.year = dts.academic_year
      AND co.schoolid = dts.schoolid
      AND co.date BETWEEN dts.start_date AND dts.end_date
      AND dts.identifier = 'AR'
     LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       ON co.student_number = enr.student_number
      AND co.year = enr.academic_year
      AND enr.CREDITTYPE = 'ENG'
      AND enr.drop_flags = 0
      AND enr.rn_subject = 1
     LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static hr WITH(NOLOCK)
       ON co.student_number = hr.student_number
      AND co.year = hr.academic_year
      AND hr.COURSE_NUMBER = 'HR'
      AND hr.drop_flags = 0      
      AND hr.rn_subject = 1
     LEFT OUTER JOIN KIPP_NJ..AR$goals y1_goal WITH(NOLOCK)
       ON co.student_number = y1_goal.student_number   
      AND co.date BETWEEN y1_goal.time_period_start AND y1_goal.time_period_end
      AND y1_goal.time_period_hierarchy = 1
     LEFT OUTER JOIN KIPP_NJ..AR$goals term_goal WITH(NOLOCK)
       ON co.student_number = term_goal.student_number   
      AND co.date BETWEEN term_goal.time_period_start AND term_goal.time_period_end
      AND term_goal.time_period_hierarchy = 2
     LEFT OUTER JOIN ar_long ar
       ON co.student_number = ar.student_number
      AND co.date = ar.date_taken
     LEFT OUTER JOIN last_book bk
       ON co.student_number = bk.student_number
      AND co.year = bk.academic_year
      AND bk.rn = 1
     WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND co.reporting_schoolid NOT IN (999999, 5173)
       AND ((co.grade_level >= 5)
            OR (co.schoolid IN (73252, 179901) AND co.grade_level >= 3)
            OR (co.schoolid IN (73255) AND co.grade_level >= 2))
       AND co.date <= CONVERT(DATE,GETDATE())
       AND co.enroll_status = 0       
       --AND co.date >= CASE WHEN ar.min_date_taken <= co.entrydate THEN ar.min_date_taken ELSE co.entrydate END
    ) sub

UNION ALL

SELECT student_number
      ,lastfirst
      ,year
      ,schoolid
      ,grade_level
      ,team
      ,advisor
      ,SPEDLEP
      ,term
      ,date
      ,is_current_week
      ,is_curterm
      ,COURSE_NAME
      ,COURSE_NUMBER
      ,SECTION_NUMBER
      ,teacher_name
      ,homeroom_section
      ,homeroom_teacher
      ,words_goal_yr
      ,points_goal_yr
      ,goal_term
      ,words_goal_term
      ,points_goal_term
      ,n_words_read
      ,n_points_earned
      ,n_books_read
      ,n_fiction
      ,avg_lexile
      ,avg_pct_correct
      ,last_book_title
      ,last_book_days_ago
      ,last_book_lexile
      ,last_book_pct_correct
      ,ontrack_words_yr
      ,ontrack_points_yr
      ,ontrack_words_term
      ,ontrack_points_term
      ,n_words_read_running_term
      ,n_words_read_running_yr
      ,n_points_earned_running_term
      ,n_points_earned_running_yr
      ,is_ontrack_term
      ,is_ontrack_yr
FROM KIPP_NJ..TABLEAU$AR_time_series#ARCHIVE WITH(NOLOCK)