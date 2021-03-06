USE KIPP_NJ
GO

ALTER VIEW AR$progress_to_goals_long AS

WITH long_goals AS (
  /* year */
  SELECT cohort.studentid
        ,cohort.student_number
        ,cohort.grade_level
        ,cohort.schoolid
        ,cohort.year AS academic_year        
        ,cohort.entrydate
        ,COALESCE(goals.yearid, CONVERT(VARCHAR,sy.yearid) + '00') AS yearid
        ,1 AS time_hierarchy
        ,ISNULL(goals.time_period_name,'Year') AS time_period_name
        ,goals.words_goal
        ,goals.points_goal
        ,COALESCE(goals.time_period_start, sy.start_date) AS start_date_summer_bonus
        ,COALESCE(goals.time_period_start, sy.start_date) AS [start_date]
        ,COALESCE(goals.time_period_end, sy.end_date) AS end_date     
  FROM KIPP_NJ..COHORT$comprehensive_long#static cohort WITH (NOLOCK) 
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates sy WITH(NOLOCK)
    ON cohort.year = sy.academic_year
   AND sy.identifier = 'SY'  
  LEFT OUTER JOIN KIPP_NJ..AR$goals goals WITH (NOLOCK)
    ON cohort.student_number = goals.student_number   
   AND cohort.year = goals.academic_year
   AND goals.time_period_hierarchy = 1
  WHERE cohort.rn = 1    
    AND cohort.schoolid != 999999    
    AND cohort.year >= 2009 /* earliest AR data from '09 */
    
  UNION ALL
  
  /* term */
  SELECT cohort.studentid
        ,cohort.student_number
        ,cohort.grade_level
        ,cohort.schoolid
        ,cohort.year AS academic_year
        ,cohort.entrydate
        ,CONVERT(VARCHAR,hex.yearid) + '00' AS yearid
        ,2 AS time_hierarchy
        ,hex.time_per_name AS time_period_name
        ,goals.words_goal
        ,goals.points_goal
        ,COALESCE(goals.time_period_start, hex.start_date) AS start_date_summer_bonus
        ,COALESCE(goals.time_period_start, hex.start_date) AS start_date
        ,COALESCE(goals.time_period_end, hex.end_date) AS end_date
  FROM KIPP_NJ..COHORT$comprehensive_long#static cohort WITH(NOLOCK)       
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates hex WITH(NOLOCK)
    ON cohort.year = hex.academic_year
   AND cohort.schoolid = hex.schoolid
   AND hex.identifier = 'AR'
  LEFT OUTER JOIN KIPP_NJ..AR$goals goals WITH(NOLOCK)
     ON cohort.student_number = goals.student_number
    AND cohort.year = goals.academic_year
    AND hex.time_per_name = goals.time_period_name
  WHERE cohort.rn = 1    
    AND cohort.schoolid != 999999            
    AND cohort.year >= 2009 /* earliest AR data from '09 */
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
      ,NULL AS last_book_date
      ,NULL AS last_book
      ,CASE                
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN words_goal /* time period over */
        WHEN (words IS NULL OR words_goal IS NULL) THEN NULL        
        ELSE ROUND((CONVERT(FLOAT,DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE()))) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) /* during time period */
       END AS ontrack_words
      ,CASE        
        WHEN CONVERT(DATE,GETDATE()) > end_date THEN points_goal /* time period over */
        WHEN (points IS NULL OR points_goal IS NULL) THEN NULL        
        ELSE ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) /* during time period */
       END AS ontrack_points
      ,CASE        
        WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
        WHEN words >= words_goal THEN 'Met Goal'                
        WHEN CONVERT(DATE,GETDATE()) > end_date AND words < words_goal  THEN 'Missed Goal'        
        WHEN words >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 'On Track'
        WHEN words < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 'Off Track'        
       END AS stu_status_words
      ,CASE
        /* any time */
        WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
        WHEN points >= points_goal THEN 'Met Goal'        
        /* during term */
        WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date AND points >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 'On Track'
        WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date AND points < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 'Off Track'
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date AND points < points_goal  THEN 'Missed Goal'
       END AS stu_status_points
      ,CASE
       /* any time */
        WHEN (words IS NULL OR words_goal IS NULL) THEN NULL
        WHEN words >= words_goal THEN 1
        /* during term */
        WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date AND words >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 1
        WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date AND words < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * words_goal,0) THEN 0
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date AND words < words_goal  THEN 0
       END AS stu_status_words_numeric      
      ,CASE
        /* any time */
        WHEN (points IS NULL OR points_goal IS NULL) THEN NULL
        WHEN points >= points_goal THEN 1
        /* during term */
        WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date AND points >= ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 1
        WHEN CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date AND points < ROUND(((DATEDIFF(DAY, [start_date], CONVERT(DATE,GETDATE())) + 0.0) / DATEDIFF(DAY, [start_date], end_date)) * points_goal,0) THEN 0
        /* after term */
        WHEN CONVERT(DATE,GETDATE()) > end_date AND points < points_goal  THEN 0
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
       /* RANKS */
      ,RANK() OVER(PARTITION BY totals.schoolid,totals.grade_level,totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY words DESC) AS rank_words_grade_in_school
      ,RANK() OVER(PARTITION BY totals.grade_level,totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY words DESC) AS rank_words_grade_in_network
      ,RANK() OVER(PARTITION BY totals.schoolid,totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY words DESC) AS rank_words_overall_in_school
      ,RANK() OVER(PARTITION BY totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY words DESC) AS rank_words_overall_in_network       
      ,RANK() OVER(PARTITION BY totals.schoolid,totals.grade_level,totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY points DESC) AS rank_points_grade_in_school
      ,RANK() OVER(PARTITION BY totals.grade_level,totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY points DESC) AS rank_points_grade_in_network
      ,RANK() OVER(PARTITION BY totals.schoolid,totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY points DESC) AS rank_points_overall_in_school
      ,RANK() OVER(PARTITION BY totals.yearid,totals.time_hierarchy,totals.time_period_name ORDER BY points DESC) AS rank_points_overall_in_network      
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
            /* per new RLog */
            ,ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iquestionscorrect ELSE NULL END)
                      / SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iquestionspresented ELSE NULL END)) * 100,0) AS mastery_fiction
            ,ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction != 'F' THEN ar_all.iquestionscorrect ELSE NULL END) 
                      / SUM(CASE WHEN ar_all.chfictionnonfiction != 'F' THEN ar_all.iquestionspresented ELSE NULL END)) * 100,0) AS mastery_nonfiction
            ,ROUND((SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN ar_all.iwordcount ELSE 0 END) 
                      / SUM(ar_all.iwordcount)) * 100, 0) AS pct_fiction
            ,SUM(CASE WHEN ar_all.chfictionnonfiction = 'F' THEN 1 ELSE NULL END) AS n_fiction
            ,SUM(CASE WHEN ar_all.chfictionnonfiction = 'NF' THEN 1 ELSE NULL END) AS n_nonfic
            ,ROUND(SUM(ar_all.ialternatebooklevel_2 * ar_all.iwordcount)
                     / SUM(ar_all.iwordcount),0) AS avg_lexile
            ,ROUND(AVG(ar_all.tibookrating),2) AS avg_rating
            ,MAX(ar_all.dttaken) AS last_quiz            
            ,SUM(ar_all.tipassed) AS N_passed
            ,COUNT(ar_all.iuserid) AS N_total                     
      FROM long_goals WITH(NOLOCK)
      LEFT OUTER JOIN AR$test_event_detail#static ar_all WITH(NOLOCK)
        ON long_goals.student_number = ar_all.student_number
       AND long_goals.academic_year = ar_all.academic_year      
       AND CONVERT(DATE,ar_all.dttaken) BETWEEN long_goals.start_date_summer_bonus AND long_goals.end_date                  
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
WHERE totals.time_period_name IS NOT NULL
  AND (totals.words_goal IS NOT NULL OR totals.points_goal IS NOT NULL)