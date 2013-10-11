USE KIPP_NJ
GO

ALTER VIEW AR$time_series_dense AS

/* !! CTEs HERE !! */
WITH ar_activity AS
   --aggregate to level of week HERE
  (SELECT studentid
         ,reporting_hash
          --points/words
         ,SUM(words) AS words
         ,SUM(points) AS points
          --mastery
         ,SUM(iQuestionsCorrect) AS q_correct
         ,SUM(iQuestionsPresented) AS q_presented
          --genre
         ,SUM(fiction_words) AS fiction_words
          --NOT limited to mastered words; needed for denominators
         ,SUM(words_attempted) AS raw_words_attempted
          --text difficulty
            --divide by raw_words_attempted to get lexile weighted by word count
         ,CAST(SUM(book_lexile * words_attempted) AS BIGINT) AS lexile_numerator    
          --count of books
         ,SUM(tipassed) AS books_passed
         ,COUNT(*) AS books_attempted
   FROM
         (SELECT sq_2.studentid
                --takes student enroll date for the year as 
                --goal start *if* after goal start date
                ,sq_2.dtTaken
                ,sq_2.reporting_hash 
                 --words/points
                 --!only passed books!
                ,CASE
                   WHEN sq_2.tipassed = 1 AND sq_2.dtTaken >= ar.start_date
                      THEN CAST(sq_2.words AS BIGINT)
                   ELSE 0
                 END AS words
                ,CASE
                   WHEN sq_2.tipassed = 1 AND sq_2.dtTaken >= ar.start_date
                     THEN sq_2.points
                   ELSE 0
                 END AS points
                 --mastery
                ,sq_2.iQuestionsCorrect
                ,sq_2.iQuestionsPresented
                 --genre
                ,CASE
                   WHEN sq_2.chFictionNonFiction = 'F' THEN sq_2.words
                   ELSE 0
                 END AS fiction_words
                ,sq_2.words AS words_attempted
                 --text difficulty
                ,sq_2.book_lexile
                 --credit for book?
                ,sq_2.tiPassed          
          FROM
                --START SQ 2: LEFT OUTER JOIN TO BOOKS READ. LONG.
               (SELECT sq_1.*
                      ,arsp.tipassed
                      ,arsp.iwordcount AS words
                      ,arsp.dpointsearned AS points
                      ,arsp.iquestionscorrect
                      ,arsp.iquestionspresented
                      ,arsp.dttaken
                      ,arsp.chFictionNonFiction
                      ,arsp.ialternatebooklevel_2 AS book_lexile
                      ,(DATEPART(yyyy, arsp.dtTaken) * 100) + DATEPART(wk, arsp.dtTaken) AS reporting_hash
                FROM
                      --START SQ 1: STUDENTS
                      (SELECT c.studentid
                             ,s.student_number
                       FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
                       JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
                         ON c.studentid = s.id
                        AND c.year = 2013
                        AND c.rn = 1
                        AND s.enroll_status = 0
                        --for testing - limit to one school/grade
                        --AND s.schoolid = 73252
                        --AND s.grade_level = 6  
                        --AND s.id IN (2995, 4077, 4681)
                      ) sq_1
                      --END SQ 1
                LEFT OUTER JOIN KIPP_NJ..AR$test_event_detail arsp WITH (NOLOCK)
                  ON CAST(sq_1.student_number AS VARCHAR) = arsp.student_number
                 AND arsp.dtTaken >= '15-JUN-13'
                ) sq_2
                --END SQ 2
          LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH (NOLOCK)
            ON sq_2.studentid = ar.studentid
           AND ar.time_hierarchy = 1
           AND ar.yearid >= 2300
          ) sq_3
   GROUP BY studentid
           ,reporting_hash
  )
 
 ,reporting_weeks AS 
  (SELECT reporting_hash AS synthetic_hash
         ,weekday_start AS week_start
         ,weekday_sun AS week_end
         ,ROW_NUMBER() OVER
            (ORDER BY reporting_hash ASC) AS rn
     FROM KIPP_NJ..UTIL$reporting_weeks_days WITH (NOLOCK)
   WHERE reporting_hash >= 201325
     AND reporting_hash <= 201426
  )
  
 ,goal_stuff AS
  (SELECT s.ID AS studentid
         --takes student enroll date for the year as 
         --goal start *if* after goal start date
         ,CASE
            WHEN s.entrydate > goals.time_period_start THEN s.entrydate
            ELSE goals.time_period_start
          END AS stu_start_date
         ,goals.time_period_start AS goal_start_date
         ,goals.time_period_end AS goal_end_date
         ,goals.time_period_hierarchy
         ,goals.time_period_name
         ,goals.words_goal
         ,goals.points_goal
   FROM KIPP_NJ..AR$goals_long_decode goals
   JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
     ON goals.student_number = CAST(s.STUDENT_NUMBER AS VARCHAR)
    AND s.enroll_status = 0
   WHERE goals.yearid = 2300
  )


/* !! END CTEs, QUERY STARTS HERE!! */

SELECT TOP (100) PERCENT 
       CAST(studentid AS INT) AS studentid
      ,CAST(reporting_hash AS INT) AS reporting_hash
      ,week_start
      ,week_end
      ,time_period_hierarchy
      ,time_period_name
      ,goal_start_date
      ,goal_end_date
      ,words_goal
      ,points_goal
      ,dense_running_words
      ,dense_running_points
      ,target_words
      ,target_points
      ,CASE
         WHEN target_words IS NULL THEN NULL
         WHEN dense_running_words = 0 THEN 0
         WHEN dense_running_words >= target_words THEN 1
         WHEN dense_running_words <  target_words THEN 0
         ELSE NULL
       END AS on_track_status_words
      ,CASE
         WHEN target_points IS NULL THEN NULL
         WHEN dense_running_points = 0 THEN 0
         WHEN dense_running_points >= target_points THEN 1
         WHEN dense_running_points <  target_points THEN 0
         ELSE NULL
       END AS on_track_status_points
      ,dense_running_mastery
      ,dense_running_fiction_pct
      ,dense_running_weighted_lexile_avg
      ,dense_running_books_passed
      ,dense_running_books_attempted
      ,year_goal_index
      --,min_valid_week
      --,valid_for_goal
FROM
      (SELECT sub.*
             ,CASE 
                WHEN year_goal_index IS NULL THEN NULL
                --gah random divide by zeros
                WHEN CAST(MAX(year_goal_index) OVER 
                         (PARTITION BY studentid
                                      ,time_period_name) AS FLOAT) = 0 THEN NULL
                WHEN words_goal = 0 THEN NULL
                ELSE 
                  ROUND(
                    (CAST(year_goal_index AS FLOAT) / 
                      CAST(MAX(year_goal_index) OVER 
                         (PARTITION BY studentid
                                      ,time_period_name) AS FLOAT)
                       ) * CAST(words_goal AS FLOAT)
                  ,0)
               END AS target_words
             ,CASE 
                WHEN year_goal_index IS NULL THEN NULL
                --gah random divide by zeros
                WHEN CAST(MAX(year_goal_index) OVER 
                         (PARTITION BY studentid
                                      ,time_period_name) AS FLOAT) = 0 THEN NULL
                WHEN points_goal = 0 THEN NULL
                ELSE 
                  ROUND(
                    (CAST(year_goal_index AS FLOAT) / 
                      CAST(MAX(year_goal_index) OVER 
                         (PARTITION BY studentid
                                      ,time_period_name) AS FLOAT)
                       ) * CAST(points_goal AS FLOAT)
                  ,0)
               END AS target_points
       FROM
             
             (SELECT sub.*
                    ,(valid_for_goal - min_valid_week) AS year_goal_index
              FROM   
                     --ALL DATA AND DENSIFICATION HAPPENS HERE.  EVERYTHING ABOVE THIS
                     --IS ON TRACK/OFF TRACK DETERMINATION
                    (
                     
                     SELECT a.studentid
                           ,a.reporting_hash
                           ,a.week_start
                           ,a.week_end
                           ,a.stu_start_date
                           ,a.goal_start_date
                           ,a.goal_end_date
                           ,a.time_period_hierarchy
                           ,a.time_period_name
                           ,a.words_goal
                           ,a.points_goal
                           ,a.rn
                            --words/points
                           ,CASE
                              --leave future NULL
                              WHEN (DATEPART(yyyy, GETDATE()) * 100) + DATEPART(wk, GETDATE()) < a.reporting_hash THEN NULL
                              ELSE SUM(b.words) 
                            END AS dense_running_words
                           ,CASE
                              WHEN (DATEPART(yyyy, GETDATE()) * 100) + DATEPART(wk, GETDATE()) < a.reporting_hash THEN NULL
                              ELSE SUM(b.points) 
                            END AS dense_running_points
                            --mastery
                           ,CASE
                              WHEN (DATEPART(yyyy, GETDATE()) * 100) + DATEPART(wk, GETDATE()) < a.reporting_hash THEN NULL
                              WHEN SUM(b.q_presented) = 0 THEN NULL
                              ELSE ROUND((SUM(b.q_correct) / SUM(b.q_presented)) * 100, 0) 
                            END AS dense_running_mastery
                            --genre
                           ,CASE
                              WHEN (DATEPART(yyyy, GETDATE()) * 100) + DATEPART(wk, GETDATE()) < a.reporting_hash THEN NULL
                              WHEN SUM(b.raw_words_attempted) = 0 THEN NULL
                              ELSE ROUND((SUM(b.fiction_words) / SUM(b.raw_words_attempted)) * 100, 0) 
                            END AS dense_running_fiction_pct       
                            --text difficulty
                           ,CASE
                              WHEN (DATEPART(yyyy, GETDATE()) * 100) + DATEPART(wk, GETDATE()) < a.reporting_hash THEN NULL
                              WHEN SUM(b.raw_words_attempted) = 0 THEN NULL
                              ELSE ROUND(SUM(b.lexile_numerator) / SUM(b.raw_words_attempted), 0) 
                            END AS dense_running_weighted_lexile_avg
                            --book count
                           ,CASE
                              WHEN (DATEPART(yyyy, GETDATE()) * 100) + DATEPART(wk, GETDATE()) < a.reporting_hash THEN NULL
                              ELSE SUM(b.books_passed) 
                            END AS dense_running_books_passed
                           ,CASE 
                              WHEN (DATEPART(yyyy, GETDATE()) * 100) + DATEPART(wk, GETDATE()) < a.reporting_hash THEN NULL
                              ELSE SUM(b.books_attempted) 
                            END AS dense_running_books_attempted
                           ,MIN(b.valid_for_goal) AS min_valid_week
                           ,MAX(b.valid_for_goal) AS valid_for_goal
                     FROM
                            --*A* has densified weeks, enrollments, etc
                           (SELECT dense_weeks.studentid
                                  ,dense_weeks.synthetic_hash AS reporting_hash
                                  ,dense_weeks.week_start
                                  ,dense_weeks.week_end
                                  ,goal_stuff.stu_start_date
                                  ,goal_stuff.goal_start_date
                                  ,goal_stuff.goal_end_date
                                  ,goal_stuff.time_period_hierarchy
                                  ,goal_stuff.time_period_name
                                  ,goal_stuff.words_goal
                                  ,goal_stuff.points_goal
                                  ,dense_weeks.rn
                            FROM
                                  (SELECT a.studentid
                                         ,a.reporting_hash
                                   FROM ar_activity a
                                   ) sub
                            --ROJ to reporting weeks to densify - ensure EVERY kid has entry for EVERY week         
                            RIGHT OUTER JOIN 
                                (SELECT id AS studentid
                                       ,reporting_weeks.synthetic_hash
                                       ,reporting_weeks.week_start
                                       ,reporting_weeks.week_end
                                       ,reporting_weeks.rn
                                 FROM reporting_weeks
                                 JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
                                   ON 1=1
                                  AND s.enroll_status = 0
                                  --for testing - limit to one school/grade
                                  --AND s.schoolid = 73252
                                  --AND s.grade_level = 6  
                                  --AND s.id IN (2995, 4077, 4681)
                                ) dense_weeks
                              ON sub.studentid = dense_weeks.studentid
                             AND sub.reporting_hash = dense_weeks.synthetic_hash
                            
                            --get goal per kid for year
                            LEFT OUTER JOIN goal_stuff
                              ON dense_weeks.studentid = goal_stuff.studentid
                            ) a
                     --this sucks but per http://stackoverflow.com/a/861073/561698 it's the only solution until we upgrade to 2012 
                     JOIN 
                         --*B* has all the analytic, densified goodness
                         (SELECT dense_weeks.studentid
                                ,dense_weeks.synthetic_hash AS reporting_hash
                                ,dense_weeks.week_start
                                ,dense_weeks.week_end
                                ,goal_stuff.stu_start_date
                                ,goal_stuff.goal_start_date
                                ,goal_stuff.goal_end_date
                                ,goal_stuff.time_period_hierarchy
                                ,goal_stuff.time_period_name
                                 --this is where the magic happens - 
                                   --LOOK at the week number generated by the process below
                                   --EVALUATE if it INSIDE or OUTSIDE of the student's goal window
                                   --IF SO, bring back the RN.  using min/max (see above) 
                                   --we can dynamically vary the length of the goal period 
                                   --in weeks for each kid.  this allows for custom goal windows
                                   --and handles mid-year entrants (ultimate corner cases) nicely.
                                 ,CASE
                                    WHEN (dense_weeks.synthetic_hash >= (DATEPART(yyyy, goal_stuff.goal_start_date) * 100) + DATEPART(wk, goal_stuff.goal_start_date)
                                          AND dense_weeks.synthetic_hash <= (DATEPART(yyyy, goal_stuff.goal_end_date) * 100) + DATEPART(wk, goal_stuff.goal_end_date)
                                          --don't count if student isn't enrolled in school yet
                                          AND dense_weeks.synthetic_hash >= (DATEPART(yyyy, goal_stuff.stu_start_date) * 100) + DATEPART(wk, goal_stuff.stu_start_date)
                                         ) THEN dense_weeks.rn
                                    ELSE NULL
                                  END AS valid_for_goal

                                --!! HANDLE NULLS HERE !!
                                --words/points
                                ,ISNULL(sub.words, 0) AS words
                                ,ISNULL(sub.points, 0) AS points
                                --mastery
                                ,CAST(ISNULL(sub.q_correct, 0) AS FLOAT) AS q_correct
                                ,CAST(ISNULL(sub.q_presented, 0) AS FLOAT) AS q_presented
                                --genre
                                ,CAST(ISNULL(sub.fiction_words, 0) AS FLOAT) AS fiction_words
                                ,CAST(ISNULL(sub.raw_words_attempted, 0) AS FLOAT) AS raw_words_attempted
                                --text difficulty
                                ,ISNULL(sub.lexile_numerator, 0) AS lexile_numerator
                                --book count
                                ,ISNULL(sub.books_passed, 0) AS books_passed
                                ,ISNULL(sub.books_attempted, 0) AS books_attempted
                          FROM
                                (SELECT ar.studentid
                                       ,ar.reporting_hash
                                       --!! DATA TO BE ROLLED UP NEEDS TO APPEAR HERE!!
                                       ,ar.words
                                       ,ar.points
                                       --mastery
                                       ,ar.q_correct
                                       ,ar.q_presented
                                       --genre
                                       ,ar.fiction_words
                                       ,ar.raw_words_attempted
                                       --text difficulty
                                       ,ar.lexile_numerator
                                       --book count
                                       ,ar.books_passed
                                       ,ar.books_attempted
                                 FROM ar_activity ar
                                 ) sub
                                   
                          RIGHT OUTER JOIN 
                              (SELECT id AS studentid
                                     ,reporting_weeks.synthetic_hash
                                     ,reporting_weeks.week_start
                                     ,reporting_weeks.week_end
                                     ,reporting_weeks.rn
                               FROM reporting_weeks
                               JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
                                 ON 1=1
                                AND s.enroll_status = 0
                                --for testing - limit to one school/grade
                                --AND s.schoolid = 73252
                                --AND s.grade_level = 6  
                                --AND s.id IN (2995, 4077, 4681)
                              ) dense_weeks
                            ON sub.studentid = dense_weeks.studentid
                           AND sub.reporting_hash = dense_weeks.synthetic_hash

                          LEFT OUTER JOIN goal_stuff
                            ON dense_weeks.studentid = goal_stuff.studentid
                          ) b
                       ON a.studentid = b.studentid
                      AND a.time_period_name = b.time_period_name
                      --UNBOUND BACKWARDS
                      AND b.reporting_hash <= a.reporting_hash
                      --BUT NOT IN THE PAST!
                      AND b.week_end >= a.stu_start_date
                      --AND NOT BEYOND THE GOAL DATE!
                      AND b.week_start <= a.goal_end_date
                      GROUP BY a.studentid
                             ,a.reporting_hash
                             ,a.week_start
                             ,a.week_end
                             ,a.stu_start_date      
                             ,a.goal_start_date
                             ,a.goal_end_date
                             ,a.time_period_hierarchy
                             ,a.time_period_name
                             ,a.words_goal
                             ,a.points_goal
                             ,a.rn


                     ) sub
              ) sub
       ) sub
ORDER BY studentid
        ,reporting_hash
