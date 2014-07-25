USE KIPP_NJ
GO

ALTER VIEW AR$progress_to_goals_long AS

WITH long_goals AS (
  SELECT cohort.studentid
        ,s.student_number
        ,cohort.grade_level
        ,cohort.schoolid
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
  FROM COHORT$comprehensive_long#static cohort WITH (NOLOCK)
  JOIN students s WITH (NOLOCK)
    ON cohort.studentid = s.id
     
   --TESTING
   --AND s.grade_level = 5
   --AND s.schoolid = 73252
   --AND s.ID = 4772
   --AND s.student_number >= 12866

  --year
  JOIN AR$goals_long_decode#static goals WITH (NOLOCK)
     ON CAST(s.student_number AS VARCHAR) = goals.student_number
    AND goals.time_period_hierarchy = 1
    AND cohort.rn = 1
    AND ((cohort.year - 1990) * 100) = goals.yearid

    --TESTING
    --AND goals.yearid = 2400
  --term
  UNION ALL

  SELECT cohort.studentid
        ,s.student_number
        ,cohort.grade_level
        ,cohort.schoolid
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
  JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
    ON cohort.studentid = s.id
   --TESTING
   --AND s.grade_level = 5
   --AND s.schoolid = 73252
   --AND s.id = 4772
   --AND s.student_number >= 12866
  JOIN KIPP_NJ..AR$goals_long_decode#static goals WITH (NOLOCK)
     ON CAST(s.student_number AS VARCHAR) = goals.student_number
    AND goals.time_period_hierarchy = 2
    AND ((year - 1990) * 100) = goals.yearid
    AND cohort.year >= 2011
    AND cohort.rn = 1
    --TESTING
    --AND goals.yearid = dbo.fn_Global_Term_Id()
    --AND goals.time_period_name = 'Hexameter 2'
 )
 
,last_book AS (
  SELECT sub.*
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
       FROM AR$goals_long_decode#static goals WITH (NOLOCK)
       JOIN AR$test_event_detail#static detail WITH (NOLOCK)
         ON goals.student_number = detail.student_number
        AND CAST(detail.dtTaken AS DATE) >= CAST(goals.time_period_start AS DATE)
        AND CAST(detail.dtTaken AS DATE) <= CAST(goals.time_period_end AS DATE)
      ) sub
  WHERE rn_desc = 1  
 )

--query starts here
SELECT totals.*
      ,last_book.last_book_date
      ,last_book.title_string AS last_book
      ,CASE
      --time period over
         WHEN GETDATE() > end_date THEN words_goal
       --during time period
         WHEN GETDATE() < end_date AND
           GETDATE() >= [start_date] THEN
           CASE
             WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
             ELSE (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal)
           END
       END AS ontrack_words
      ,CASE
      --time period over
         WHEN GETDATE() > end_date THEN points_goal
       --during time period
         WHEN GETDATE() < end_date AND
           GETDATE() >= start_date THEN
           CASE
             WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
             ELSE (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal)
           END
       END AS ontrack_points
      ,CASE
      --time period over
         WHEN CAST(GETDATE() AS date) > end_date THEN
           CASE
             WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
             WHEN words >= words_goal THEN 'Met Goal'
             WHEN words < words_goal  THEN 'Missed Goal'
         END
       --during time period
         WHEN CAST(GETDATE() AS date) <= end_date AND
           CAST(GETDATE() AS date) >= start_date THEN
           CASE
             WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
             WHEN words >= (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal)
               THEN 'On Track'
             WHEN words < (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal)
               THEN 'Off Track'
           END
       END AS stu_status_words
      ,CASE
      --time period over
         WHEN CAST(GETDATE() AS date) > end_date THEN
           CASE
             WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
             WHEN points >= points_goal THEN 'Met Goal'
             WHEN points < points_goal  THEN 'Missed Goal'
         END
       --during time period
         WHEN CAST(GETDATE() AS date) <= end_date AND
           CAST(GETDATE() AS date) >= start_date THEN
           CASE
             WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
             WHEN points >= (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal)
               THEN 'On Track'
             WHEN points < (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal)
               THEN 'Off Track'
           END
       END AS stu_status_points
      
      ,CASE
      --time period over
         WHEN CAST(GETDATE() AS date) > end_date THEN
           CASE
             WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
             WHEN words >= words_goal THEN 1
             WHEN words < words_goal  THEN 0
         END
       --during time period
         WHEN CAST(GETDATE() AS date) <= end_date AND
           CAST(GETDATE() AS date) >= start_date THEN
           CASE
             WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
             WHEN words >= (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal) 
               THEN 1
             WHEN words < (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal)
               THEN 0
           END
       END AS stu_status_words_numeric
      
      ,CASE
      --time period over
         WHEN CAST(GETDATE() AS date) > end_date THEN
           CASE
             WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
             WHEN points >= points_goal THEN 1
             WHEN points < points_goal  THEN 0
         END
       --during time period
         WHEN CAST(GETDATE() AS date) <= end_date AND
           CAST(GETDATE() AS date) >= start_date THEN
           CASE
             WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
             WHEN points >= (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal)
               THEN 1
             WHEN points < (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal)
               THEN 0
           END
       END AS stu_status_points_numeric
      
      ,CASE
      --time period over
         WHEN CAST(GETDATE() AS date) > end_date THEN NULL
       --during time period
         WHEN CAST(GETDATE() AS date) <= end_date AND
           CAST(GETDATE() AS date) >= start_date THEN
           CASE
             WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
             WHEN words >= (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal)
               THEN NULL
             WHEN words <(((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal)
               THEN (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * words_goal) - words
           END
       END AS words_needed
      
      ,CASE
      --time period over
         WHEN CAST(GETDATE() AS date) > end_date THEN NULL
       --during time period
         WHEN CAST(GETDATE() AS date) <= end_date AND
           CAST(GETDATE() AS date) >= start_date THEN
           CASE
             WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
             WHEN points >= (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal) 
               THEN NULL
             WHEN points < (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal) 
               THEN (((DATEDIFF(d, [start_date], GETDATE())+0.0) / DATEDIFF(d, [start_date], end_date)) * points_goal) - points
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
       --RANKS
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
            ,long_goals.yearid
            ,long_goals.time_hierarchy
            ,long_goals.time_period_name
            ,long_goals.words_goal
            ,long_goals.points_goal
            ,CAST(long_goals.start_date AS date) AS start_date
            ,CAST(long_goals.end_date AS date) AS end_date

            ,SUM(CASE
                   WHEN ar_all.tipassed = 1 THEN CAST(ar_all.iwordcount AS BIGINT)
                   ELSE 0
                 END) AS words
            ,SUM(CASE
                   WHEN ar_all.tipassed = 1 THEN ar_all.dpointsearned
                   ELSE 0
                 END) AS points
            ,CAST(ROUND((SUM(ar_all.iquestionscorrect + 0.0) / SUM(ar_all.iquestionspresented + 0.0)) * 100,0) AS INT) AS mastery
            --per new RLog
            ,CAST(ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iquestionscorrect ELSE NULL END + 0.0) / 
               SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iquestionspresented ELSE NULL END + 0.0)) * 100,0) AS INT) AS mastery_fiction
            ,CAST(ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction != 'F' THEN ar_all.iquestionscorrect ELSE NULL END + 0.0) / 
               SUM(CASE WHEN ar_all.chfictionnonfiction != 'F' THEN ar_all.iquestionspresented ELSE NULL END + 0.0)) * 100,0) AS INT) AS mastery_nonfiction

            ,CAST(ROUND(
                    ((SUM(
                     CASE
                       WHEN ar_all.chfictionnonfiction IS NULL THEN NULL
                       WHEN ar_all.chfictionnonfiction = 'F' THEN CAST(ar_all.iwordcount AS BIGINT)
                       ELSE 0
                     END) + 0.0) /
                     (SUM(CAST(ar_all.iwordcount AS BIGINT)) + 0.0)
                     ) * 100, 0
                   ) AS INT) AS pct_fiction
            ,SUM(
              CASE
               WHEN ar_all.chfictionnonfiction = 'F' THEN 1
               ELSE NULL
              END) AS n_fiction
            ,SUM(
              CASE
               WHEN ar_all.chfictionnonfiction = 'NF' THEN 1
               ELSE NULL
              END) AS n_nonfic            
            ,ROUND(SUM(CAST(ar_all.ialternatebooklevel_2 * ar_all.iwordcount AS BIGINT))/SUM(CAST(ar_all.iwordcount AS BIGINT)),0) AS avg_lexile
            ,CONVERT(DECIMAL(3,2),ROUND(AVG(ar_all.tibookrating + 0.00),2)) AS avg_rating
            ,MAX(ar_all.dttaken) AS last_quiz
            
            --SQL doesn't support KEEP; refactored LAST BOOK
            ,SUM(ar_all.tipassed) AS N_passed
            ,COUNT(ar_all.iuserid) AS N_total      
      FROM long_goals
      LEFT OUTER JOIN AR$test_event_detail#static ar_all WITH (NOLOCK)
        ON CAST(long_goals.student_number AS VARCHAR) = ar_all.student_number
       AND CAST(ar_all.dttaken AS date) >= CAST(long_goals.start_date_summer_bonus AS date)
       AND CAST(ar_all.dttaken AS date) <= CAST(long_goals.end_date AS date)
       AND ar_all.tiRowStatus = 1
       GROUP BY long_goals.studentid
               ,long_goals.student_number
               ,long_goals.grade_level
               ,long_goals.schoolid
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

/*
ORDER BY time_hierarchy DESC
        ,time_period_name ASC
        ,student_number
*/