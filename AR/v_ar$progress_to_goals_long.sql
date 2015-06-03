USE KIPP_NJ
GO

ALTER VIEW AR$progress_to_goals_long AS

WITH long_goals AS (
  SELECT cohort.studentid
        ,cohort.student_number
        ,cohort.grade_level
        ,cohort.schoolid
        ,cohort.year AS academic_year
        ,goals.yearid
        ,1 AS time_hierarchy
        ,goals.time_period_name
        ,goals.words_goal
        ,goals.points_goal

         --UPDATE: 09-30-2013.  Rise is killing this. Just use the goal start date
         --for Rise (and eventually others) summer words are 'bonus'
         --toward year goal.  this requires differentiating between
         --goal start date for calculation and for the join
          
        --,CONVERT(datetime, CAST('07/01/' + CAST(DATEPART(YYYY,time_period_start) AS NVARCHAR) AS DATE), 101) AS start_date_summer_bonus
        --NULL AS start_date_summer_bonus
        --'01-JUN-13' AS start_date_summer_bonus
        ,goals.time_period_start AS start_date_summer_bonus
        ,goals.time_period_start AS [start_date]
        ,goals.time_period_end AS end_date     
  FROM KIPP_NJ..COHORT$comprehensive_long#static cohort WITH (NOLOCK) 
  --year
  JOIN KIPP_NJ..AR$goals_long_decode#static goals WITH (NOLOCK)
    ON cohort.student_number = goals.student_number   
   AND cohort.year = goals.academic_year
   AND goals.time_period_hierarchy = 1
  WHERE cohort.rn = 1    
  
  --term
  UNION ALL

  SELECT cohort.studentid
        ,cohort.student_number
        ,cohort.grade_level
        ,cohort.schoolid
        ,cohort.year AS academic_year
        ,goals.yearid
        --standardize term names
        ,2 AS time_hierarchy
        ,CASE
          --middle
          WHEN time_period_name = 'Trimester 1' THEN 'RT1'
          WHEN time_period_name = 'Trimester 2' THEN 'RT2'
          WHEN time_period_name = 'Trimester 3' THEN 'RT3'
          --TEAM
          WHEN time_period_name = 'Reporting Term 1' THEN 'RT1'
          WHEN time_period_name = 'Reporting Term 2' THEN 'RT2'
          WHEN time_period_name = 'Reporting Term 3' THEN 'RT3'
          WHEN time_period_name = 'Reporting Term 4' THEN 'RT4'
          WHEN time_period_name = 'Reporting Term 5' THEN 'RT5'
          WHEN time_period_name = 'Reporting Term 6' THEN 'RT6'
          --high
          WHEN time_period_name = 'Reporting Term 1' THEN 'RT1'
          WHEN time_period_name = 'Reporting Term 2' THEN 'RT2'
          WHEN time_period_name = 'Reporting Term 3' THEN 'RT3'
          WHEN time_period_name = 'Reporting Term 4' THEN 'RT4'
          --new middle school
          WHEN time_period_name = 'Hexameter 1' THEN 'RT1'
          WHEN time_period_name = 'Hexameter 2' THEN 'RT2'
          WHEN time_period_name = 'Hexameter 3' THEN 'RT3'
          WHEN time_period_name = 'Hexameter 4' THEN 'RT4'
          WHEN time_period_name = 'Hexameter 5' THEN 'RT5'
          WHEN time_period_name = 'Hexameter 6' THEN 'RT6'
          --elementary? (CAPSTONE?)
         END AS time_period_name
        ,goals.words_goal
        ,goals.points_goal
        ,goals.time_period_start AS start_date_summer_bonus
        ,goals.time_period_start AS start_date
        ,goals.time_period_end AS end_date
  FROM KIPP_NJ..COHORT$comprehensive_long#static cohort WITH (NOLOCK)     
  JOIN KIPP_NJ..AR$goals_long_decode#static goals WITH (NOLOCK)
     ON cohort.student_number = goals.student_number
    AND goals.time_period_hierarchy = 2
  WHERE cohort.year = goals.academic_year    
    AND cohort.rn = 1
    --TESTING
    --AND goals.yearid = dbo.fn_Global_Term_Id()
    --AND goals.time_period_name = 'Hexameter 2'
 )
 
,last_book AS (
  SELECT sub.student_number
        ,sub.yearid
        ,sub.time_period_hierarchy
        ,sub.time_period_start
        ,sub.time_period_end
        ,sub.last_book_date
        ,sub.title_string
        ,sub.rn_desc
  FROM
      (
       SELECT goals.student_number
             ,goals.yearid
             ,goals.time_period_hierarchy
             ,goals.time_period_start
             ,goals.time_period_end
             ,detail.dttaken AS last_book_date
             ,CAST(DATEPART(MM, detail.dttaken) AS NVARCHAR) + '/' 
               + CAST(DATEPART(DD, detail.dttaken) AS NVARCHAR) + ' '
               + detail.vchcontenttitle + ' (' 
               + detail.vchauthor + ' | ' 
               + LTRIM(detail.chfictionnonfiction) + ', Lexile: ' 
               + CAST(ialternatebooklevel_2 AS NVARCHAR) + ') [' 
               + CAST(detail.iquestionscorrect AS NVARCHAR) + '/' 
               + CAST(detail.iquestionspresented AS NVARCHAR) + ', ' 
               + CAST(CAST(detail.dpercentcorrect * 100 AS INT) AS NVARCHAR) + '% ' 
               + REPLICATE('+', detail.tibookrating) + ']' AS title_string
             ,ROW_NUMBER() OVER (
                 PARTITION BY goals.student_number
                             ,goals.yearid
                             ,goals.time_period_hierarchy
                             ,goals.time_period_start
                             ,goals.time_period_end
                     ORDER BY detail.dttaken DESC) AS rn_desc
       FROM KIPP_NJ..AR$goals_long_decode#static goals WITH (NOLOCK)
       JOIN KIPP_NJ..AR$test_event_detail#static detail WITH (NOLOCK)
         ON goals.student_number = detail.student_number
        AND detail.dtTaken >= goals.time_period_start
        AND detail.dtTaken <= goals.time_period_end
      ) sub
  WHERE rn_desc = 1  
 )

SELECT totals.studentid
      ,totals.student_number
      ,totals.grade_level
      ,totals.schoolid
      ,totals.academic_year
      ,totals.yearid
      ,totals.time_hierarchy
      ,totals.time_period_name
      ,totals.words_goal
      ,totals.points_goal
      ,totals.start_date
      ,totals.end_date
      ,totals.words
      ,totals.points
      ,totals.mastery
      ,totals.mastery_fiction
      ,totals.mastery_nonfiction
      ,totals.pct_fiction
      ,totals.n_fiction
      ,totals.n_nonfic
      ,totals.avg_lexile
      ,totals.avg_rating
      ,totals.last_quiz
      ,totals.N_passed
      ,totals.N_total
      ,last_book.last_book_date
      ,last_book.title_string AS last_book
      ,CASE
        --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN words_goal
        --during time period
        WHEN CONVERT(DATE,GETDATE()) < end_date AND CONVERT(DATE,GETDATE()) >= [start_date] THEN 
               CASE
                WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
                ELSE ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0)
               END
       END AS ontrack_words
      ,CASE
        --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN points_goal
        --during time period
        WHEN CONVERT(DATE,GETDATE()) < end_date AND CONVERT(DATE,GETDATE()) >= start_date THEN
               CASE
                WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
                ELSE ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0)
               END
       END AS ontrack_points
      ,CASE
        --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN
               CASE
                WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
                WHEN words >= words_goal THEN 'Met Goal'
                WHEN words < words_goal  THEN 'Missed Goal'
               END
        --during time period
        WHEN CONVERT(DATE,GETDATE()) <= end_date AND CONVERT(DATE,GETDATE()) >= start_date THEN
               CASE
                WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
                WHEN words >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 'On Track'
                WHEN words < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 'Off Track'
               END
       END AS stu_status_words
      ,CASE
        --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN
               CASE
                WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
                WHEN points >= points_goal THEN 'Met Goal'
                WHEN points < points_goal  THEN 'Missed Goal'
               END
        --during time period
        WHEN CONVERT(DATE,GETDATE()) <= end_date AND CONVERT(DATE,GETDATE()) >= start_date THEN
               CASE
                WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
                WHEN points >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 'On Track'
                WHEN points < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 'Off Track'
               END
       END AS stu_status_points      
      ,CASE
       --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN
               CASE
                WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
                WHEN words >= words_goal THEN 1
                WHEN words < words_goal  THEN 0
               END
        --during time period
        WHEN CONVERT(DATE,GETDATE()) <= end_date AND CONVERT(DATE,GETDATE()) >= start_date THEN
               CASE
                WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
                WHEN words >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 1
                WHEN words < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 0
               END
       END AS stu_status_words_numeric      
      ,CASE
        --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN
               CASE
                WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
                WHEN points >= points_goal THEN 1
                WHEN points < points_goal  THEN 0
               END
        --during time period
        WHEN CONVERT(DATE,GETDATE()) <= end_date AND CONVERT(DATE,GETDATE()) >= start_date THEN
               CASE
                WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
                WHEN points >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 1
                WHEN points < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 0
               END      
       END AS stu_status_points_numeric      
      ,CASE
        --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN NULL
        --during time period
        WHEN CONVERT(DATE,GETDATE()) <= end_date AND CONVERT(DATE,GETDATE()) >= start_date THEN 
               CASE
                WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
                WHEN words >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN NULL
                WHEN words < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0)
                     THEN ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) - words
               END
       END AS words_needed      
      ,CASE
        --time period over
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN NULL
        --during time period
        WHEN CONVERT(DATE,GETDATE()) <= end_date AND CONVERT(DATE,GETDATE()) >= start_date THEN
               CASE
                WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
                WHEN points >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN NULL
                WHEN points < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0)
                     THEN ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) - points
               END
       END AS points_needed
       --RANKS
      ,RANK () OVER (PARTITION BY totals.schoolid
                                 ,totals.grade_level
                                 ,totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY words DESC) AS rank_words_grade_in_school
      ,RANK () OVER (PARTITION BY totals.grade_level
                                 ,totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY words DESC) AS rank_words_grade_in_network
      ,RANK () OVER (PARTITION BY totals.schoolid
                                 ,totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY words DESC) AS rank_words_overall_in_school
      ,RANK () OVER (PARTITION BY totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY words DESC) AS rank_words_overall_in_network       
      ,RANK () OVER (PARTITION BY totals.schoolid
                                 ,totals.grade_level
                                 ,totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY points DESC) AS rank_points_grade_in_school
      ,RANK () OVER (PARTITION BY totals.grade_level
                                 ,totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY points DESC) AS rank_points_grade_in_network
      ,RANK () OVER (PARTITION BY totals.schoolid
                                 ,totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY points DESC) AS rank_points_overall_in_school
      ,RANK () OVER (PARTITION BY totals.yearid
                                 ,totals.time_hierarchy
                                 ,totals.time_period_name
                         ORDER BY points DESC) AS rank_points_overall_in_network      
FROM    
     (
      SELECT long_goals.studentid
            ,long_goals.student_number
            ,long_goals.grade_level
            ,long_goals.schoolid
            ,long_goals.academic_year
            ,long_goals.yearid
            ,long_goals.time_hierarchy
            ,long_goals.time_period_name
            ,long_goals.words_goal
            ,long_goals.points_goal
            ,long_goals.start_date
            ,long_goals.end_date
            ,SUM(CASE WHEN ar_all.tipassed = 1 THEN ar_all.iwordcount ELSE 0 END) AS words
            ,SUM(CASE WHEN ar_all.tipassed = 1 THEN ar_all.dpointsearned ELSE 0 END) AS points
            ,ROUND((SUM(ar_all.iquestionscorrect) / SUM(ar_all.iquestionspresented)) * 100,0) AS mastery
            --per new RLog
            ,ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iquestionscorrect ELSE NULL END)
                     / 
                    SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iquestionspresented ELSE NULL END))
                     * 100,0) AS mastery_fiction
            ,ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction != 'F' THEN ar_all.iquestionscorrect ELSE NULL END) 
                     / 
                    SUM(CASE WHEN ar_all.chfictionnonfiction != 'F' THEN ar_all.iquestionspresented ELSE NULL END))
                     * 100,0) AS mastery_nonfiction
            ,ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iwordcount ELSE 0 END) 
                     /
                    SUM(ar_all.iwordcount)) 
                     * 100, 0) AS pct_fiction
            ,SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN 1 ELSE NULL END) AS n_fiction
            ,SUM(CASE WHEN ar_all.chfictionnonfiction = 'NF' THEN 1 ELSE NULL END) AS n_nonfic
            ,ROUND(SUM(ar_all.ialternatebooklevel_2 * ar_all.iwordcount)
                    /
                   SUM(ar_all.iwordcount),0) AS avg_lexile
            ,ROUND(AVG(ar_all.tibookrating),2) AS avg_rating
            ,MAX(ar_all.dttaken) AS last_quiz            
            --SQL doesn't support KEEP; refactored LAST BOOK
            ,SUM(ar_all.tipassed) AS N_passed
            ,COUNT(ar_all.iuserid) AS N_total                     
      FROM long_goals
      LEFT OUTER JOIN AR$test_event_detail#static ar_all WITH (NOLOCK)
        ON long_goals.student_number = ar_all.student_number
       AND ar_all.dttaken BETWEEN long_goals.start_date_summer_bonus AND long_goals.end_date
      GROUP BY long_goals.studentid
              ,long_goals.student_number
              ,long_goals.grade_level
              ,long_goals.schoolid
              ,long_goals.academic_year
              ,long_goals.yearid
              ,long_goals.time_hierarchy
              ,long_goals.time_period_name
              ,long_goals.words_goal
              ,long_goals.points_goal
              ,long_goals.start_date
              ,long_goals.end_date
     ) totals
LEFT OUTER JOIN last_book
  ON totals.student_number = last_book.student_number
 --this join is sort of conviluted because we normalized time period names above...
 AND totals.yearid = last_book.yearid
 AND totals.time_hierarchy = last_book.time_period_hierarchy
 AND totals.start_date = last_book.time_period_start
 AND totals.end_date = last_book.time_period_end