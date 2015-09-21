USE KIPP_NJ
GO

ALTER VIEW AR$progress_wide AS

SELECT student_number
      ,[Y1_avg_pct_correct]
      ,[Y1_words_read]
      ,[CUR_avg_pct_correct]
      ,[CUR_words_read]
FROM 
    (
     SELECT student_number
           ,CONCAT(term, '_', field) AS pivot_field
           ,value
     FROM
         (
          SELECT ar.student_number      
                ,ROUND(AVG(ar.dpercentcorrect) * 100,0) AS avg_pct_correct
                ,SUM(CASE WHEN ar.tipassed = 1 THEN ar.iwordcount ELSE 0 END) AS words_read
                ,'Y1' AS term
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          JOIN KIPP_NJ..AR$test_event_detail#static ar WITH(NOLOCK)
            ON co.student_number = ar.student_number
           AND co.year = ar.academic_year        
          WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND co.rn = 1
          GROUP BY ar.student_number

          UNION ALL

          SELECT ar.student_number      
                ,ROUND(AVG(ar.dpercentcorrect) * 100,0) AS avg_pct_correct
                ,SUM(CASE WHEN ar.tipassed = 1 THEN ar.iwordcount ELSE 0 END) AS words_read
                ,'CUR'
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          JOIN KIPP_NJ..AR$test_event_detail#static ar WITH(NOLOCK)
            ON co.student_number = ar.student_number
           AND co.year = ar.academic_year        
          JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
            ON co.schoolid = dt.schoolid
           AND co.year = dt.academic_year
           AND CONVERT(DATE,ar.dtTakenOriginal) BETWEEN dt.start_date AND dt.end_date 
           AND CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date 
           AND dt.identifier = 'RT'
          WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND co.rn = 1
          GROUP BY ar.student_number
         ) sub
     UNPIVOT(
       value
       FOR field IN (avg_pct_correct, words_read)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([Y1_avg_pct_correct]
                     ,[Y1_words_read]
                     ,[CUR_avg_pct_correct]
                     ,[CUR_words_read])
 ) p