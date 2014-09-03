USE KIPP_NJ
GO

ALTER VIEW AR$time_series_dense_daily AS
WITH stu AS
   (SELECT c.studentid
          ,s.student_number
          ,c.year
          ,c.grade_level
          ,c.schoolid
          ,CONVERT(datetime, CAST('07/05/' + c.year AS DATE), 101) AS custom_entry
          ,c.exitdate
    FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
    JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
      ON c.studentid = s.id
     --AND s.last_name = 'Williams'
    WHERE c.rn = 1
      AND c.year >= 2011
      AND c.schoolid IN (73252, 73253, 133570965, 73254)
      --AND c.studentid = 4054
   )
  ,rd AS
  (SELECT CAST(rd.date AS date) AS date
   FROM KIPP_NJ..UTIL$reporting_days rd WITH(NOLOCK)
   WHERE rd.date >= '07/05/2011'
     AND rd.date <= CAST(GETDATE() AS date)
  )

SELECT stu.studentid
      ,stu.year
      ,stu.grade_level
      ,stu.schoolid
      ,rd.date
/*                     --genre
                     --text difficulty
                       --divide by raw_words_attempted to get lexile weighted by word count
                   ,CASE
                      WHEN CAST(GETDATE() AS DATE) < reporting_weeks.week_start THEN NULL
                      WHEN SUM(ISNULL(ar_activity.words_attempted,0)) = 0 THEN NULL
                      ELSE ROUND(CAST(SUM(ar_activity.book_lexile * ar_activity.words_attempted) AS BIGINT) / SUM(ar_activity.words_attempted), 0) 
                    END AS lexile_avg
 */
      ,SUM
         (CASE
            WHEN te.tipassed = 1 THEN te.iWordCount
            ELSE 0
          END
         ) AS words_to_date
      ,SUM
         (CASE
            WHEN te.tipassed = 1 THEN te.dPointsEarned
            ELSE 0
          END
         ) AS points_to_date
      ,CASE
         WHEN SUM(te.iQuestionsPresented) = 0 THEN NULL
         ELSE CAST(ROUND((SUM(te.iQuestionsCorrect + 0.0) / SUM(te.iQuestionsPresented)) * 100, 0) AS FLOAT)
       END AS mastery_to_date  
      ,SUM
         (CASE
            WHEN te.tipassed = 1 THEN 1
            ELSE 0
          END
         ) AS books_passed_to_date
      ,SUM
         (CASE
            WHEN te.iStudentPracticeID IS NOT NULL THEN 1
            ELSE 0
          END
         ) AS books_attempted_to_date
      ,CASE
         WHEN SUM(ISNULL(te.iWordCount,0)) = 0 THEN NULL
         ELSE CAST(ROUND((SUM(CASE WHEN te.chFictionNonFiction = 'F' THEN te.iWordCount END + 0.0) / SUM(te.iWordCount)) * 100, 0) AS FLOAT)
       END AS fiction_pct_to_date
      ,CASE
         WHEN SUM(ISNULL(te.iWordCount,0)) = 0 THEN NULL
         ELSE ROUND(CAST(SUM(te.iAlternateBookLevel_2 * CAST(te.iWordCount AS bigint)) AS BIGINT) / SUM(te.iWordCount), 0) 
       END AS lexile_avg
FROM stu
JOIN rd
  ON stu.custom_entry <= rd.date
 AND stu.exitdate >= rd.date
LEFT OUTER JOIN AR$test_event_detail#static te WITH(NOLOCK)
  ON CAST(stu.student_number AS VARCHAR) = te.student_number
 AND stu.custom_entry <= CAST(te.dtTaken AS date)
 AND rd.date >= CAST(te.dtTaken AS date)
GROUP BY stu.studentid
        ,stu.year
        ,stu.grade_level
        ,stu.schoolid
        ,rd.date 


  