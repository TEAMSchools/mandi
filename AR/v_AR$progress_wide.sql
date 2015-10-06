USE KIPP_NJ
GO

ALTER VIEW AR$progress_wide AS

SELECT student_number
      ,[CUR_avg_pct_correct]
      ,[CUR_words_goal]
      ,[CUR_words_read]
      ,[CUR_words_status]
      ,[Y1_avg_pct_correct]
      ,[Y1_words_goal]
      ,[Y1_words_read]
      ,[Y1_words_status]
FROM 
    (
     SELECT student_number
           ,CONCAT(term, '_', field) AS pivot_field
           ,value
     FROM
         (
          SELECT ar.student_number      
                ,CONVERT(VARCHAR,ar.mastery) AS avg_pct_correct
                ,CONVERT(VARCHAR,ar.words) AS words_read
                ,CONVERT(VARCHAR,ar.words_goal) AS words_goal
                ,CONVERT(VARCHAR,ar.stu_status_words) AS words_status
                ,'Y1' AS term
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
            ON co.student_number = ar.student_number
           AND co.year = ar.academic_year        
           AND ar.time_period_name = 'Year'
          WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND co.rn = 1          

          UNION ALL

          SELECT ar.student_number      
                ,CONVERT(VARCHAR,ar.mastery) AS avg_pct_correct
                ,CONVERT(VARCHAR,ar.words) AS words_read
                ,CONVERT(VARCHAR,ar.words_goal) AS words_goal
                ,CONVERT(VARCHAR,ar.stu_status_words) AS words_status
                ,'CUR' AS term
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
            ON co.schoolid = dt.schoolid
           AND co.year = dt.academic_year           
           AND CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date 
           AND dt.identifier = 'AR'
          JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
            ON co.student_number = ar.student_number
           AND co.year = ar.academic_year        
           AND dt.time_per_name = ar.time_period_name          
          WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND co.rn = 1          
         ) sub
     UNPIVOT(
       value
       FOR field IN (avg_pct_correct, words_read, words_goal, words_status)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([CUR_avg_pct_correct]
                     ,[CUR_words_goal]
                     ,[CUR_words_read]
                     ,[CUR_words_status]
                     ,[Y1_avg_pct_correct]
                     ,[Y1_words_goal]
                     ,[Y1_words_read]
                     ,[Y1_words_status])
 ) p