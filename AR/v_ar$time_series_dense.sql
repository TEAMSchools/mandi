USE KIPP_NJ
GO

ALTER VIEW AR$time_series_dense AS

/* !! CTEs HERE !! */

WITH reporting_weeks AS (
  SELECT reporting_hash
        ,weekday_start AS week_start
        ,weekday_sun AS week_end
        ,ROW_NUMBER() OVER(
           ORDER BY reporting_hash ASC) AS rn
  FROM KIPP_NJ..UTIL$reporting_weeks_days WITH (NOLOCK)
  WHERE reporting_hash >= 201425
    AND reporting_hash <= 201526
 )
    
,goal_stuff AS (
  SELECT s.ID AS studentid
        ,s.student_number
        --takes student enroll date for the year as 
        --goal start *if* after goal start date
        ,CASE WHEN s.entrydate > goals.time_period_start THEN s.entrydate ELSE goals.time_period_start END AS stu_start_date
        ,goals.time_period_start AS goal_start_date
        ,goals.time_period_end AS goal_end_date
        ,goals.time_period_hierarchy
        ,goals.time_period_name
        ,goals.words_goal
        ,goals.points_goal
  FROM KIPP_NJ..AR$goals_long_decode#static goals WITH (NOLOCK)
  JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
    ON goals.student_number = s.STUDENT_NUMBER
   AND s.enroll_status = 0
  WHERE goals.yearid = dbo.fn_Global_Term_Id()
 )

,ar_activity AS (
  SELECT sq_1.*
        ,arsp.dtTaken
        ,CASE WHEN arsp.tiPassed = 1 THEN CAST(arsp.iWordCount AS BIGINT) ELSE 0 END AS words_passed
        ,CASE WHEN arsp.tiPassed = 1 THEN arsp.dPointsEarned ELSE 0 END AS points_earned         
        ,arsp.iQuestionsCorrect
        ,arsp.iQuestionsPresented
        ,CASE WHEN arsp.chFictionNonFiction = 'F' THEN arsp.iWordCount ELSE 0 END AS fiction_words
        ,CAST(arsp.iwordcount AS BIGINT) AS words_attempted
        ,arsp.ialternatebooklevel_2 AS book_lexile
        ,arsp.tipassed
        ,1 AS dummy
  FROM
      (
       SELECT c.studentid
             ,s.student_number
       FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
       JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
         ON c.studentid = s.id
        AND s.enroll_status = 0
       WHERE c.year = dbo.fn_Global_Academic_Year()
         AND c.rn = 1        
      ) sq_1
  LEFT OUTER JOIN KIPP_NJ..AR$test_event_detail#static arsp WITH (NOLOCK)
    ON sq_1.student_number = arsp.student_number
   AND arsp.dtTaken >= '15-JUN-13'
   AND arsp.dtTaken IS NOT NULL
 )

SELECT CAST(studentid AS INT) AS studentid
      ,CAST(reporting_hash AS INT) AS reporting_hash
      ,week_start
      ,week_end
      ,time_period_hierarchy
      ,time_period_name
      ,goal_start_date
      ,goal_end_date
      ,words_goal
      ,points_goal
      ,words AS dense_running_words
      ,points AS dense_running_points
      ,target_words
      ,target_points
      ,CASE
        WHEN target_words IS NULL THEN NULL
        WHEN words = 0 THEN 0
        WHEN words >= target_words THEN 1
        WHEN words <  target_words THEN 0
        ELSE NULL
       END AS on_track_status_words
      ,CASE
        WHEN target_points IS NULL THEN NULL
        WHEN points = 0 THEN 0
        WHEN points >= target_points THEN 1
        WHEN points <  target_points THEN 0
        ELSE NULL
       END AS on_track_status_points
      ,mastery AS dense_running_mastery
      ,fiction_pct AS dense_running_fiction_pct
      ,lexile_avg AS dense_running_weighted_lexile_avg
      ,books_passed AS dense_running_books_passed
      ,books_attempted AS dense_running_books_attempted
      ,goal_index AS year_goal_index
FROM
    (
     SELECT sub.*
           ,CASE 
             WHEN goal_index IS NULL THEN NULL
             WHEN goal_index = 0 THEN NULL
             WHEN words_goal = 0 THEN NULL
             --fraction of term used x words
             ELSE CAST(ROUND(((goal_numerator + 0.0) / goal_index) * words_goal, 0) AS FLOAT)
            END AS target_words
           ,CASE 
             WHEN goal_index IS NULL THEN NULL
             WHEN goal_index = 0 THEN NULL
             WHEN points_goal = 0 THEN NULL
             --fraction of term used x points
             ELSE CAST(ROUND(((goal_numerator + 0.0) / goal_index) * points_goal, 0) AS FLOAT)
            END AS target_points
       FROM
           (
            SELECT goal_stuff.studentid
                  ,goal_stuff.student_number
                  ,goal_stuff.time_period_name
                  ,goal_stuff.time_period_hierarchy
                  ,goal_stuff.words_goal
                  ,goal_stuff.points_goal
                  ,CAST(goal_stuff.stu_start_date AS DATE) AS stu_start_date
                  ,CAST(goal_stuff.goal_start_date AS DATE) AS goal_start_date
                  ,CAST(goal_stuff.goal_end_date AS DATE) AS goal_end_date
                  ,reporting_weeks.reporting_hash
                  ,CAST(reporting_weeks.week_start AS DATE) AS week_start
                  ,CAST(reporting_weeks.week_end AS DATE) AS week_end
                  ,reporting_weeks.rn
                  ,CASE WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL ELSE SUM(ISNULL(ar_activity.words_passed,0)) END AS words
                  ,CASE WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL ELSE SUM(ISNULL(ar_activity.points_earned,0)) END AS points
                   --mastery
                  ,CASE
                    WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL
                    WHEN SUM(ar_activity.iQuestionsPresented) = 0 THEN NULL
                    ELSE CAST(ROUND((SUM(ar_activity.iQuestionsCorrect + 0.0) / SUM(ar_activity.iQuestionsPresented)) * 100, 0) AS FLOAT)
                   END AS mastery
                   --genre
                  ,CASE
                    WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL
                    WHEN SUM(ISNULL(ar_activity.words_attempted,0)) = 0 THEN NULL
                    ELSE CAST(ROUND((SUM(ar_activity.fiction_words + 0.0) / SUM(ar_activity.words_attempted)) * 100, 0) AS FLOAT)
                   END AS fiction_pct
                   --text difficulty
                   --divide by raw_words_attempted to get lexile weighted by word count
                  ,CASE
                    WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL
                    WHEN SUM(ISNULL(ar_activity.words_attempted,0)) = 0 THEN NULL
                    ELSE ROUND(CAST(SUM(ar_activity.book_lexile * ar_activity.words_attempted) AS BIGINT) / SUM(ar_activity.words_attempted), 0) 
                   END AS lexile_avg
                   --count of books
                  ,CASE WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL ELSE SUM(ar_activity.tipassed) END AS books_passed
                  ,CASE WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL ELSE SUM(ar_activity.dummy) END AS books_attempted
                  ,MIN(reporting_weeks.rn) OVER(
                     PARTITION BY goal_stuff.studentid, time_period_name) AS min_valid_week
                  ,MAX(reporting_weeks.rn) OVER(
                     PARTITION BY goal_stuff.studentid, time_period_name) AS valid_for_goal
                  ,MAX(reporting_weeks.rn) OVER(PARTITION BY goal_stuff.studentid, time_period_name) 
                    - MIN(reporting_weeks.rn) OVER(PARTITION BY goal_stuff.studentid,time_period_name) 
                    + 1 AS goal_index
                  ,ROW_NUMBER() OVER(
                     PARTITION BY goal_stuff.studentid, time_period_name
                       ORDER BY reporting_weeks.rn ASC) AS goal_numerator
            FROM goal_stuff WITH(NOLOCK)
            JOIN reporting_weeks WITH(NOLOCK)
              ON goal_stuff.stu_start_date <= reporting_weeks.week_end
             AND goal_stuff.goal_end_date >= reporting_weeks.week_start
            LEFT OUTER JOIN ar_activity WITH(NOLOCK)
              ON goal_stuff.studentid = ar_activity.studentid
             AND ar_activity.dtTaken >= goal_stuff.stu_start_date
             AND ar_activity.dtTaken <= reporting_weeks.week_end
            GROUP BY goal_stuff.studentid
                    ,goal_stuff.student_number
                    ,goal_stuff.time_period_name
                    ,goal_stuff.time_period_hierarchy
                    ,goal_stuff.words_goal
                    ,goal_stuff.points_goal
                    ,goal_stuff.stu_start_date
                    ,goal_stuff.goal_start_date
                    ,goal_stuff.goal_end_date
                    ,reporting_weeks.reporting_hash
                    ,reporting_weeks.week_start
                    ,reporting_weeks.week_end
                    ,reporting_weeks.rn
           ) sub
    ) sub