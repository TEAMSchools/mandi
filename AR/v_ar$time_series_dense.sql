USE KIPP_NJ
GO

ALTER VIEW AR$time_series_dense AS

WITH reporting_weeks AS (
  SELECT weekday_sun AS week_start
        ,weekday_sat AS week_end
        ,reporting_hash
        ,ROW_NUMBER() OVER(
           ORDER BY reporting_hash) AS rn         
  FROM UTIL$reporting_weeks_days#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND weekday_sun <= CONVERT(DATE,GETDATE())
 )

SELECT CONVERT(INT,studentid) AS studentid
      ,CONVERT(INT,reporting_hash) AS reporting_hash
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
     SELECT studentid
           ,time_period_name
           ,time_period_hierarchy
           ,words_goal
           ,points_goal
           ,goal_start_date
           ,goal_end_date
           ,week_start
           ,week_end
           ,reporting_hash
           ,words
           ,points
           ,mastery
           ,fiction_pct
           ,lexile_avg
           ,books_passed
           ,books_attempted           
           ,goal_index           
           ,CASE 
             WHEN goal_index IS NULL THEN NULL
             WHEN goal_index = 0 THEN NULL
             WHEN words_goal = 0 THEN NULL
             --fraction of term used x words
             ELSE ROUND((CONVERT(FLOAT,goal_numerator) / CONVERT(FLOAT,goal_index)) * words_goal,0)
            END AS target_words
           ,CASE 
             WHEN goal_index IS NULL THEN NULL
             WHEN goal_index = 0 THEN NULL
             WHEN points_goal = 0 THEN NULL
             --fraction of term used x points
             ELSE ROUND((CONVERT(FLOAT,goal_numerator) / CONVERT(FLOAT,goal_index)) * points_goal,0)
            END AS target_points
       FROM
           (
            SELECT studentid                  
                  ,time_period_name
                  ,time_period_hierarchy
                  ,words_goal
                  ,points_goal                  
                  ,CONVERT(DATE,time_period_start) AS goal_start_date
                  ,CONVERT(DATE,time_period_end) AS goal_end_date                  
                  ,CONVERT(DATE,week_start) AS week_start
                  ,CONVERT(DATE,week_end) AS week_end
                  ,reporting_hash
                  --,rn
                  ,SUM(ISNULL(words_passed,0)) AS words
                  ,SUM(ISNULL(points_earned,0)) AS points
                   --mastery
                  ,CASE                    
                    WHEN SUM(iQuestionsPresented) = 0 THEN NULL
                    ELSE ROUND((SUM(CONVERT(FLOAT,iQuestionsCorrect)) / SUM(CONVERT(FLOAT,iQuestionsPresented))) * 100,0)
                   END AS mastery
                   --genre
                  ,CASE                    
                    WHEN SUM(ISNULL(words_attempted,0)) = 0 THEN NULL
                    ELSE ROUND((SUM(CONVERT(FLOAT,fiction_words)) / SUM(CONVERT(FLOAT,words_attempted))) * 100,0)
                   END AS fiction_pct
                   --text difficulty
                   --divide by raw_words_attempted to get lexile weighted by word count
                  ,CASE                    
                    WHEN SUM(ISNULL(words_attempted,0)) = 0 THEN NULL
                    ELSE ROUND(CONVERT(BIGINT,SUM(book_lexile * words_attempted)) / SUM(CONVERT(FLOAT,words_attempted)),0)
                   END AS lexile_avg
                   --count of books
                  ,SUM(tipassed) AS books_passed
                  ,SUM(dummy) AS books_attempted
                  --,MIN(rn) OVER(PARTITION BY studentid, time_period_name) AS min_valid_week
                  --,MAX(rn) OVER(PARTITION BY studentid, time_period_name) AS valid_for_goal
                  ,MAX(rn) OVER(PARTITION BY studentid, time_period_name) - MIN(rn) OVER(PARTITION BY studentid,time_period_name) + 1 AS goal_index
                  ,ROW_NUMBER() OVER(
                     PARTITION BY studentid, time_period_name
                       ORDER BY rn ASC) AS goal_numerator
            FROM 
                (
                 SELECT sub.studentid
                       ,sub.student_number
                       ,sub.entrydate        
                       ,sub.reporting_hash
                       ,sub.week_start
                       ,sub.week_end
                       ,sub.time_period_start
                       ,sub.time_period_end
                       ,sub.time_period_hierarchy
                       ,sub.time_period_name
                       ,sub.words_goal
                       ,sub.points_goal
                       ,sub.dummy
                       ,sub.rn
                       ,ar.dtTaken
                       ,CASE WHEN ar.tiPassed = 1 THEN CAST(ar.iWordCount AS BIGINT) ELSE 0 END AS words_passed
                       ,CASE WHEN ar.tiPassed = 1 THEN ar.dPointsEarned ELSE 0 END AS points_earned         
                       ,ar.iQuestionsCorrect
                       ,ar.iQuestionsPresented
                       ,CASE WHEN ar.chFictionNonFiction = 'F' THEN ar.iWordCount ELSE 0 END AS fiction_words
                       ,CAST(ar.iwordcount AS BIGINT) AS words_attempted
                       ,ar.ialternatebooklevel_2 AS book_lexile
                       ,ar.tipassed
                 FROM
                     (
                      SELECT co.studentid
                            ,co.student_number
                            ,co.entrydate
                            ,co.year
                            ,wk.reporting_hash      
                            ,wk.week_start
                            ,wk.week_end
                            ,goals.time_period_start
                            ,goals.time_period_end
                            ,goals.time_period_hierarchy
                            ,goals.time_period_name
                            ,goals.words_goal
                            ,goals.points_goal              
                            ,1 AS dummy
                            ,wk.rn
                      FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
                      JOIN reporting_weeks wk WITH(NOLOCK)
                        ON co.entrydate <= wk.week_start
                      LEFT OUTER JOIN KIPP_NJ..AR$goals_long_decode#static goals WITH (NOLOCK)
                        ON co.student_number = goals.student_number  
                       AND wk.week_start BETWEEN goals.time_period_start AND goals.time_period_end  
                      WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
                        AND co.enroll_status = 0
                        AND co.rn = 1         
                        --AND co.studentid = 2307 -- testing                
                     ) sub
                 LEFT OUTER JOIN AR$test_event_detail#static ar WITH(NOLOCK)
                   ON sub.student_number = ar.student_number 
                  AND sub.year = ar.academic_year
                  AND sub.week_start >= ar.dttaken
                  AND ar.dttaken BETWEEN sub.time_period_start AND sub.time_period_end 
                 WHERE ar.student_number NOT IN ('joyke','Mr.Pa','STU1','STU6','STUa','STUb','STUc','STUd','STUe','STUg','STUh','STUj','STUk','STUl','STUm','STUn','STUp','STUr','STUs','STUt','STUw') -- dirty AR data
                ) sub
            GROUP BY studentid
                    ,student_number
                    ,time_period_name
                    ,time_period_hierarchy
                    ,words_goal
                    ,points_goal
                    ,entrydate
                    ,time_period_start
                    ,time_period_end
                    ,reporting_hash
                    ,week_start
                    ,week_end
                    ,rn
           ) sub
    ) sub