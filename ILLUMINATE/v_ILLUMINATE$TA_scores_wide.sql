USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$TA_scores_wide AS

WITH writing AS (
  SELECT student_number
        ,term
        ,repository_row_id
        ,writing_type
        ,total_prof
        ,date_administered
        ,writing_obj_1
        ,writing_obj_2
        ,writing_obj_3
        ,writing_obj_4
        ,writing_obj_5
        ,writing_obj_6
        ,writing_obj_7
        ,writing_obj_8
        ,writing_obj_9
        ,writing_obj_10
        ,writing_prof_1
        ,writing_prof_2
        ,writing_prof_3
        ,writing_prof_4
        ,writing_prof_5
        ,writing_prof_6
        ,writing_prof_7
        ,writing_prof_8
        ,writing_prof_9
        ,writing_prof_10
        ,n_prof
        ,n_tested
        ,ROUND((CONVERT(FLOAT,n_prof) / CASE WHEN n_tested = 0 THEN NULL ELSE CONVERT(FLOAT,n_tested) END) * 100,0) AS pct_prof
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, term
             ORDER BY date_administered DESC) AS rn_cur
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, term, writing_type
             ORDER BY date_administered DESC) AS rn_type_cur
  FROM
      (
       SELECT student_number
             ,term
             ,repository_row_id
             ,writing_type
             ,total_prof
             ,date_administered
             ,MAX([writing_obj_1]) AS [writing_obj_1]
             ,MAX([writing_obj_2]) AS [writing_obj_2]
             ,MAX([writing_obj_3]) AS [writing_obj_3]
             ,MAX([writing_obj_4]) AS [writing_obj_4]
             ,MAX([writing_obj_5]) AS [writing_obj_5]
             ,MAX([writing_obj_6]) AS [writing_obj_6]
             ,MAX([writing_obj_7]) AS [writing_obj_7]
             ,MAX([writing_obj_8]) AS [writing_obj_8]
             ,MAX([writing_obj_9]) AS [writing_obj_9]
             ,MAX([writing_obj_10]) AS [writing_obj_10]
             ,MAX([writing_prof_1]) AS [writing_prof_1]
             ,MAX([writing_prof_2]) AS [writing_prof_2]
             ,MAX([writing_prof_3]) AS [writing_prof_3]
             ,MAX([writing_prof_4]) AS [writing_prof_4]
             ,MAX([writing_prof_5]) AS [writing_prof_5]
             ,MAX([writing_prof_6]) AS [writing_prof_6]
             ,MAX([writing_prof_7]) AS [writing_prof_7]
             ,MAX([writing_prof_8]) AS [writing_prof_8]
             ,MAX([writing_prof_9]) AS [writing_prof_9]
             ,MAX([writing_prof_10]) AS [writing_prof_10]
             ,SUM(is_prof) AS n_prof
             ,MAX(n_tested) AS n_tested
       FROM
           (
            SELECT student_number
                  ,term
                  ,repository_row_id
                  ,writing_type
                  ,total_prof
                  ,date_administered
                  ,pivot_hash_obj
                  ,pivot_hash_prof
                  ,writing_obj
                  ,proficiency      
                  ,CASE WHEN prof_numeric = 3 THEN 1 ELSE 0 END AS is_prof
                  ,COUNT(prof_numeric) OVER(PARTITION BY student_number, repository_row_id, writing_type) AS n_tested
            FROM ILLUMINATE$writing_scores_long#ES WITH(NOLOCK)
           ) sub
       PIVOT(
         MAX(writing_obj)
         FOR pivot_hash_obj IN ([writing_obj_1]
                               ,[writing_obj_2]
                               ,[writing_obj_3]
                               ,[writing_obj_4]
                               ,[writing_obj_5]
                               ,[writing_obj_6]
                               ,[writing_obj_7]
                               ,[writing_obj_8]
                               ,[writing_obj_9]
                               ,[writing_obj_10])
        ) p1
       PIVOT(
         MAX(proficiency)
         FOR pivot_hash_prof IN ([writing_prof_1]
                                ,[writing_prof_2]
                                ,[writing_prof_3]
                                ,[writing_prof_4]
                                ,[writing_prof_5]
                                ,[writing_prof_6]
                                ,[writing_prof_7]
                                ,[writing_prof_8]
                                ,[writing_prof_9]
                                ,[writing_prof_10])
        ) p2
       GROUP BY student_number
               ,term
               ,repository_row_id
               ,date_administered
               ,writing_type
               ,total_prof
      ) sub
 )

,not_writing AS (
  SELECT student_number
        ,term
        ,[COMP_TA_obj_1]
        ,[COMP_TA_obj_2]
        ,[COMP_TA_obj_3]
        ,[COMP_TA_obj_4]
        ,[COMP_TA_obj_5]
        ,[COMP_TA_obj_6]
        ,[COMP_TA_obj_7]
        ,[COMP_TA_obj_8]
        ,[COMP_TA_obj_9]
        ,[COMP_TA_obj_10]
        ,[COMP_TA_obj_11]
        ,[COMP_TA_obj_12]
        ,[COMP_TA_obj_13]
        ,[COMP_TA_obj_14]
        ,[COMP_TA_obj_15]
        ,[MATH_TA_obj_1]
        ,[MATH_TA_obj_2]
        ,[MATH_TA_obj_3]
        ,[MATH_TA_obj_4]
        ,[MATH_TA_obj_5]
        ,[MATH_TA_obj_6]
        ,[MATH_TA_obj_7]
        ,[MATH_TA_obj_8]
        ,[MATH_TA_obj_9]
        ,[MATH_TA_obj_10]
        ,[MATH_TA_obj_11]
        ,[MATH_TA_obj_12]
        ,[MATH_TA_obj_13]
        ,[MATH_TA_obj_14]
        ,[MATH_TA_obj_15]
        ,[PERF_TA_obj_1]
        ,[PERF_TA_obj_2]
        ,[PERF_TA_obj_3]
        ,[PERF_TA_obj_4]
        ,[PERF_TA_obj_5]
        ,[PERF_TA_obj_6]
        ,[PERF_TA_obj_7]
        ,[PERF_TA_obj_8]
        ,[PERF_TA_obj_9]
        ,[PERF_TA_obj_10]
        ,[PERF_TA_obj_11]
        ,[PERF_TA_obj_12]
        ,[PERF_TA_obj_13]
        ,[PERF_TA_obj_14]
        ,[PERF_TA_obj_15]
        ,[HUM_TA_obj_1]
        ,[HUM_TA_obj_2]
        ,[HUM_TA_obj_3]
        ,[HUM_TA_obj_4]
        ,[HUM_TA_obj_5]
        ,[HUM_TA_obj_6]
        ,[HUM_TA_obj_7]
        ,[HUM_TA_obj_8]
        ,[HUM_TA_obj_9]
        ,[HUM_TA_obj_10]
        ,[HUM_TA_obj_11]
        ,[HUM_TA_obj_12]
        ,[HUM_TA_obj_13]
        ,[HUM_TA_obj_14]
        ,[HUM_TA_obj_15]
        ,[PHON_TA_obj_1]
        ,[PHON_TA_obj_2]
        ,[PHON_TA_obj_3]
        ,[PHON_TA_obj_4]
        ,[PHON_TA_obj_5]
        ,[PHON_TA_obj_6]
        ,[PHON_TA_obj_7]
        ,[PHON_TA_obj_8]
        ,[PHON_TA_obj_9]
        ,[PHON_TA_obj_10]
        ,[PHON_TA_obj_11]
        ,[PHON_TA_obj_12]
        ,[PHON_TA_obj_13]
        ,[PHON_TA_obj_14]
        ,[PHON_TA_obj_15]
        ,[SCI_TA_obj_1]
        ,[SCI_TA_obj_2]
        ,[SCI_TA_obj_3]
        ,[SCI_TA_obj_4]
        ,[SCI_TA_obj_5]
        ,[SCI_TA_obj_6]
        ,[SCI_TA_obj_7]
        ,[SCI_TA_obj_8]
        ,[SCI_TA_obj_9]
        ,[SCI_TA_obj_10]
        ,[SCI_TA_obj_11]
        ,[SCI_TA_obj_12]
        ,[SCI_TA_obj_13]
        ,[SCI_TA_obj_14]
        ,[SCI_TA_obj_15]
        ,[SPAN_TA_obj_1]
        ,[SPAN_TA_obj_2]
        ,[SPAN_TA_obj_3]
        ,[SPAN_TA_obj_4]
        ,[SPAN_TA_obj_5]
        ,[SPAN_TA_obj_6]
        ,[SPAN_TA_obj_7]
        ,[SPAN_TA_obj_8]
        ,[SPAN_TA_obj_9]
        ,[SPAN_TA_obj_10]
        ,[SPAN_TA_obj_11]
        ,[SPAN_TA_obj_12]
        ,[SPAN_TA_obj_13]
        ,[SPAN_TA_obj_14]
        ,[SPAN_TA_obj_15]
        ,[VIZ_TA_obj_1]
        ,[VIZ_TA_obj_2]
        ,[VIZ_TA_obj_3]
        ,[VIZ_TA_obj_4]
        ,[VIZ_TA_obj_5]
        ,[VIZ_TA_obj_6]
        ,[VIZ_TA_obj_7]
        ,[VIZ_TA_obj_8]
        ,[VIZ_TA_obj_9]
        ,[VIZ_TA_obj_10]
        ,[VIZ_TA_obj_11]
        ,[VIZ_TA_obj_12]
        ,[VIZ_TA_obj_13]
        ,[VIZ_TA_obj_14]
        ,[VIZ_TA_obj_15]        
        ,[COMP_TA_prof_1]
        ,[COMP_TA_prof_2]
        ,[COMP_TA_prof_3]
        ,[COMP_TA_prof_4]
        ,[COMP_TA_prof_5]
        ,[COMP_TA_prof_6]
        ,[COMP_TA_prof_7]
        ,[COMP_TA_prof_8]
        ,[COMP_TA_prof_9]
        ,[COMP_TA_prof_10]
        ,[COMP_TA_prof_11]
        ,[COMP_TA_prof_12]
        ,[COMP_TA_prof_13]
        ,[COMP_TA_prof_14]
        ,[COMP_TA_prof_15]
        ,[MATH_TA_prof_1]
        ,[MATH_TA_prof_2]
        ,[MATH_TA_prof_3]
        ,[MATH_TA_prof_4]
        ,[MATH_TA_prof_5]
        ,[MATH_TA_prof_6]
        ,[MATH_TA_prof_7]
        ,[MATH_TA_prof_8]
        ,[MATH_TA_prof_9]
        ,[MATH_TA_prof_10]
        ,[MATH_TA_prof_11]
        ,[MATH_TA_prof_12]
        ,[MATH_TA_prof_13]
        ,[MATH_TA_prof_14]
        ,[MATH_TA_prof_15]
        ,[PERF_TA_prof_1]
        ,[PERF_TA_prof_2]
        ,[PERF_TA_prof_3]
        ,[PERF_TA_prof_4]
        ,[PERF_TA_prof_5]
        ,[PERF_TA_prof_6]
        ,[PERF_TA_prof_7]
        ,[PERF_TA_prof_8]
        ,[PERF_TA_prof_9]
        ,[PERF_TA_prof_10]
        ,[PERF_TA_prof_11]
        ,[PERF_TA_prof_12]
        ,[PERF_TA_prof_13]
        ,[PERF_TA_prof_14]
        ,[PERF_TA_prof_15]
        ,[HUM_TA_prof_1]
        ,[HUM_TA_prof_2]
        ,[HUM_TA_prof_3]
        ,[HUM_TA_prof_4]
        ,[HUM_TA_prof_5]
        ,[HUM_TA_prof_6]
        ,[HUM_TA_prof_7]
        ,[HUM_TA_prof_8]
        ,[HUM_TA_prof_9]
        ,[HUM_TA_prof_10]
        ,[HUM_TA_prof_11]
        ,[HUM_TA_prof_12]
        ,[HUM_TA_prof_13]
        ,[HUM_TA_prof_14]
        ,[HUM_TA_prof_15]
        ,[PHON_TA_prof_1]
        ,[PHON_TA_prof_2]
        ,[PHON_TA_prof_3]
        ,[PHON_TA_prof_4]
        ,[PHON_TA_prof_5]
        ,[PHON_TA_prof_6]
        ,[PHON_TA_prof_7]
        ,[PHON_TA_prof_8]
        ,[PHON_TA_prof_9]
        ,[PHON_TA_prof_10]
        ,[PHON_TA_prof_11]
        ,[PHON_TA_prof_12]
        ,[PHON_TA_prof_13]
        ,[PHON_TA_prof_14]
        ,[PHON_TA_prof_15]
        ,[SCI_TA_prof_1]
        ,[SCI_TA_prof_2]
        ,[SCI_TA_prof_3]
        ,[SCI_TA_prof_4]
        ,[SCI_TA_prof_5]
        ,[SCI_TA_prof_6]
        ,[SCI_TA_prof_7]
        ,[SCI_TA_prof_8]
        ,[SCI_TA_prof_9]
        ,[SCI_TA_prof_10]
        ,[SCI_TA_prof_11]
        ,[SCI_TA_prof_12]
        ,[SCI_TA_prof_13]
        ,[SCI_TA_prof_14]
        ,[SCI_TA_prof_15]
        ,[SPAN_TA_prof_1]
        ,[SPAN_TA_prof_2]
        ,[SPAN_TA_prof_3]
        ,[SPAN_TA_prof_4]
        ,[SPAN_TA_prof_5]
        ,[SPAN_TA_prof_6]
        ,[SPAN_TA_prof_7]
        ,[SPAN_TA_prof_8]
        ,[SPAN_TA_prof_9]
        ,[SPAN_TA_prof_10]
        ,[SPAN_TA_prof_11]
        ,[SPAN_TA_prof_12]
        ,[SPAN_TA_prof_13]
        ,[SPAN_TA_prof_14]
        ,[SPAN_TA_prof_15]
        ,[VIZ_TA_prof_1]
        ,[VIZ_TA_prof_2]
        ,[VIZ_TA_prof_3]
        ,[VIZ_TA_prof_4]
        ,[VIZ_TA_prof_5]
        ,[VIZ_TA_prof_6]
        ,[VIZ_TA_prof_7]
        ,[VIZ_TA_prof_8]
        ,[VIZ_TA_prof_9]
        ,[VIZ_TA_prof_10]
        ,[VIZ_TA_prof_11]
        ,[VIZ_TA_prof_12]
        ,[VIZ_TA_prof_13]
        ,[VIZ_TA_prof_14]
        ,[VIZ_TA_prof_15]        
        ,[COMP_pct_stds_mastered_1] AS [COMP_pct_stds_mastered]
        ,[MATH_pct_stds_mastered_1] AS [MATH_pct_stds_mastered]
        ,[PERF_pct_stds_mastered_1] AS [PERF_pct_stds_mastered]
        ,[PHON_pct_stds_mastered_1] AS [PHON_pct_stds_mastered]
        ,[HUM_pct_stds_mastered_1] AS [HUM_pct_stds_mastered]
        ,[SCI_pct_stds_mastered_1] AS [SCI_pct_stds_mastered]
        ,[SPAN_pct_stds_mastered_1] AS [SPAN_pct_stds_mastered]
        ,[VIZ_pct_stds_mastered_1] AS [VIZ_pct_stds_mastered]        
  FROM
      (
       SELECT student_number
             ,term            
             ,TA_subject + '_' + field + '_' + CONVERT(VARCHAR,standard_rn) AS pivot_hash
             ,value
       FROM
           (
            SELECT student_number      
                  ,term
                  ,TA_subject                
                  ,CONVERT(VARCHAR,TA_obj) AS TA_obj
                  ,CONVERT(VARCHAR,CONVERT(VARCHAR,TA_score) + ' = ' + CONVERT(VARCHAR,TA_prof)) AS TA_prof
                  ,CONVERT(VARCHAR,ROUND((n_mastered / n_total) * 100,0)) AS pct_stds_mastered
                  ,ROW_NUMBER() OVER(
                     PARTITION BY student_number, term
                       ORDER BY ta_standard) AS standard_rn
            FROM ILLUMINATE$TA_standards_mastery WITH(NOLOCK)
           ) sub
       UNPIVOT(
         value
         FOR field IN (TA_obj
                      ,TA_prof
                      ,pct_stds_mastered)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_hash IN ([COMP_TA_obj_1]
                      ,[COMP_TA_obj_2]
                      ,[COMP_TA_obj_3]
                      ,[COMP_TA_obj_4]
                      ,[COMP_TA_obj_5]
                      ,[COMP_TA_obj_6]
                      ,[COMP_TA_obj_7]
                      ,[COMP_TA_obj_8]
                      ,[COMP_TA_obj_9]
                      ,[COMP_TA_obj_10]
                      ,[COMP_TA_obj_11]
                      ,[COMP_TA_obj_12]
                      ,[COMP_TA_obj_13]
                      ,[COMP_TA_obj_14]
                      ,[COMP_TA_obj_15]
                      ,[MATH_TA_obj_1]
                      ,[MATH_TA_obj_2]
                      ,[MATH_TA_obj_3]
                      ,[MATH_TA_obj_4]
                      ,[MATH_TA_obj_5]
                      ,[MATH_TA_obj_6]
                      ,[MATH_TA_obj_7]
                      ,[MATH_TA_obj_8]
                      ,[MATH_TA_obj_9]
                      ,[MATH_TA_obj_10]
                      ,[MATH_TA_obj_11]
                      ,[MATH_TA_obj_12]
                      ,[MATH_TA_obj_13]
                      ,[MATH_TA_obj_14]
                      ,[MATH_TA_obj_15]
                      ,[PERF_TA_obj_1]
                      ,[PERF_TA_obj_2]
                      ,[PERF_TA_obj_3]
                      ,[PERF_TA_obj_4]
                      ,[PERF_TA_obj_5]
                      ,[PERF_TA_obj_6]
                      ,[PERF_TA_obj_7]
                      ,[PERF_TA_obj_8]
                      ,[PERF_TA_obj_9]
                      ,[PERF_TA_obj_10]
                      ,[PERF_TA_obj_11]
                      ,[PERF_TA_obj_12]
                      ,[PERF_TA_obj_13]
                      ,[PERF_TA_obj_14]
                      ,[PERF_TA_obj_15]
                      ,[HUM_TA_obj_1]
                      ,[HUM_TA_obj_2]
                      ,[HUM_TA_obj_3]
                      ,[HUM_TA_obj_4]
                      ,[HUM_TA_obj_5]
                      ,[HUM_TA_obj_6]
                      ,[HUM_TA_obj_7]
                      ,[HUM_TA_obj_8]
                      ,[HUM_TA_obj_9]
                      ,[HUM_TA_obj_10]
                      ,[HUM_TA_obj_11]
                      ,[HUM_TA_obj_12]
                      ,[HUM_TA_obj_13]
                      ,[HUM_TA_obj_14]
                      ,[HUM_TA_obj_15]
                      ,[PHON_TA_obj_1]
                      ,[PHON_TA_obj_2]
                      ,[PHON_TA_obj_3]
                      ,[PHON_TA_obj_4]
                      ,[PHON_TA_obj_5]
                      ,[PHON_TA_obj_6]
                      ,[PHON_TA_obj_7]
                      ,[PHON_TA_obj_8]
                      ,[PHON_TA_obj_9]
                      ,[PHON_TA_obj_10]
                      ,[PHON_TA_obj_11]
                      ,[PHON_TA_obj_12]
                      ,[PHON_TA_obj_13]
                      ,[PHON_TA_obj_14]
                      ,[PHON_TA_obj_15]
                      ,[SCI_TA_obj_1]
                      ,[SCI_TA_obj_2]
                      ,[SCI_TA_obj_3]
                      ,[SCI_TA_obj_4]
                      ,[SCI_TA_obj_5]
                      ,[SCI_TA_obj_6]
                      ,[SCI_TA_obj_7]
                      ,[SCI_TA_obj_8]
                      ,[SCI_TA_obj_9]
                      ,[SCI_TA_obj_10]
                      ,[SCI_TA_obj_11]
                      ,[SCI_TA_obj_12]
                      ,[SCI_TA_obj_13]
                      ,[SCI_TA_obj_14]
                      ,[SCI_TA_obj_15]
                      ,[SPAN_TA_obj_1]
                      ,[SPAN_TA_obj_2]
                      ,[SPAN_TA_obj_3]
                      ,[SPAN_TA_obj_4]
                      ,[SPAN_TA_obj_5]
                      ,[SPAN_TA_obj_6]
                      ,[SPAN_TA_obj_7]
                      ,[SPAN_TA_obj_8]
                      ,[SPAN_TA_obj_9]
                      ,[SPAN_TA_obj_10]
                      ,[SPAN_TA_obj_11]
                      ,[SPAN_TA_obj_12]
                      ,[SPAN_TA_obj_13]
                      ,[SPAN_TA_obj_14]
                      ,[SPAN_TA_obj_15]
                      ,[VIZ_TA_obj_1]
                      ,[VIZ_TA_obj_2]
                      ,[VIZ_TA_obj_3]
                      ,[VIZ_TA_obj_4]
                      ,[VIZ_TA_obj_5]
                      ,[VIZ_TA_obj_6]
                      ,[VIZ_TA_obj_7]
                      ,[VIZ_TA_obj_8]
                      ,[VIZ_TA_obj_9]
                      ,[VIZ_TA_obj_10]
                      ,[VIZ_TA_obj_11]
                      ,[VIZ_TA_obj_12]
                      ,[VIZ_TA_obj_13]
                      ,[VIZ_TA_obj_14]
                      ,[VIZ_TA_obj_15]                    
                      ,[COMP_TA_prof_1]
                      ,[COMP_TA_prof_2]
                      ,[COMP_TA_prof_3]
                      ,[COMP_TA_prof_4]
                      ,[COMP_TA_prof_5]
                      ,[COMP_TA_prof_6]
                      ,[COMP_TA_prof_7]
                      ,[COMP_TA_prof_8]
                      ,[COMP_TA_prof_9]
                      ,[COMP_TA_prof_10]
                      ,[COMP_TA_prof_11]
                      ,[COMP_TA_prof_12]
                      ,[COMP_TA_prof_13]
                      ,[COMP_TA_prof_14]
                      ,[COMP_TA_prof_15]
                      ,[MATH_TA_prof_1]
                      ,[MATH_TA_prof_2]
                      ,[MATH_TA_prof_3]
                      ,[MATH_TA_prof_4]
                      ,[MATH_TA_prof_5]
                      ,[MATH_TA_prof_6]
                      ,[MATH_TA_prof_7]
                      ,[MATH_TA_prof_8]
                      ,[MATH_TA_prof_9]
                      ,[MATH_TA_prof_10]
                      ,[MATH_TA_prof_11]
                      ,[MATH_TA_prof_12]
                      ,[MATH_TA_prof_13]
                      ,[MATH_TA_prof_14]
                      ,[MATH_TA_prof_15]
                      ,[PERF_TA_prof_1]
                      ,[PERF_TA_prof_2]
                      ,[PERF_TA_prof_3]
                      ,[PERF_TA_prof_4]
                      ,[PERF_TA_prof_5]
                      ,[PERF_TA_prof_6]
                      ,[PERF_TA_prof_7]
                      ,[PERF_TA_prof_8]
                      ,[PERF_TA_prof_9]
                      ,[PERF_TA_prof_10]
                      ,[PERF_TA_prof_11]
                      ,[PERF_TA_prof_12]
                      ,[PERF_TA_prof_13]
                      ,[PERF_TA_prof_14]
                      ,[PERF_TA_prof_15]
                      ,[HUM_TA_prof_1]
                      ,[HUM_TA_prof_2]
                      ,[HUM_TA_prof_3]
                      ,[HUM_TA_prof_4]
                      ,[HUM_TA_prof_5]
                      ,[HUM_TA_prof_6]
                      ,[HUM_TA_prof_7]
                      ,[HUM_TA_prof_8]
                      ,[HUM_TA_prof_9]
                      ,[HUM_TA_prof_10]
                      ,[HUM_TA_prof_11]
                      ,[HUM_TA_prof_12]
                      ,[HUM_TA_prof_13]
                      ,[HUM_TA_prof_14]
                      ,[HUM_TA_prof_15]
                      ,[PHON_TA_prof_1]
                      ,[PHON_TA_prof_2]
                      ,[PHON_TA_prof_3]
                      ,[PHON_TA_prof_4]
                      ,[PHON_TA_prof_5]
                      ,[PHON_TA_prof_6]
                      ,[PHON_TA_prof_7]
                      ,[PHON_TA_prof_8]
                      ,[PHON_TA_prof_9]
                      ,[PHON_TA_prof_10]
                      ,[PHON_TA_prof_11]
                      ,[PHON_TA_prof_12]
                      ,[PHON_TA_prof_13]
                      ,[PHON_TA_prof_14]
                      ,[PHON_TA_prof_15]
                      ,[SCI_TA_prof_1]
                      ,[SCI_TA_prof_2]
                      ,[SCI_TA_prof_3]
                      ,[SCI_TA_prof_4]
                      ,[SCI_TA_prof_5]
                      ,[SCI_TA_prof_6]
                      ,[SCI_TA_prof_7]
                      ,[SCI_TA_prof_8]
                      ,[SCI_TA_prof_9]
                      ,[SCI_TA_prof_10]
                      ,[SCI_TA_prof_11]
                      ,[SCI_TA_prof_12]
                      ,[SCI_TA_prof_13]
                      ,[SCI_TA_prof_14]
                      ,[SCI_TA_prof_15]
                      ,[SPAN_TA_prof_1]
                      ,[SPAN_TA_prof_2]
                      ,[SPAN_TA_prof_3]
                      ,[SPAN_TA_prof_4]
                      ,[SPAN_TA_prof_5]
                      ,[SPAN_TA_prof_6]
                      ,[SPAN_TA_prof_7]
                      ,[SPAN_TA_prof_8]
                      ,[SPAN_TA_prof_9]
                      ,[SPAN_TA_prof_10]
                      ,[SPAN_TA_prof_11]
                      ,[SPAN_TA_prof_12]
                      ,[SPAN_TA_prof_13]
                      ,[SPAN_TA_prof_14]
                      ,[SPAN_TA_prof_15]
                      ,[VIZ_TA_prof_1]
                      ,[VIZ_TA_prof_2]
                      ,[VIZ_TA_prof_3]
                      ,[VIZ_TA_prof_4]
                      ,[VIZ_TA_prof_5]
                      ,[VIZ_TA_prof_6]
                      ,[VIZ_TA_prof_7]
                      ,[VIZ_TA_prof_8]
                      ,[VIZ_TA_prof_9]
                      ,[VIZ_TA_prof_10]
                      ,[VIZ_TA_prof_11]
                      ,[VIZ_TA_prof_12]
                      ,[VIZ_TA_prof_13]
                      ,[VIZ_TA_prof_14]
                      ,[VIZ_TA_prof_15]                    
                      ,[COMP_pct_stds_mastered_1]
                      ,[MATH_pct_stds_mastered_1]                      
                      ,[PERF_pct_stds_mastered_1]
                      ,[PHON_pct_stds_mastered_1]
                      ,[HUM_pct_stds_mastered_1]
                      ,[SCI_pct_stds_mastered_1]
                      ,[SPAN_pct_stds_mastered_1]
                      ,[VIZ_pct_stds_mastered_1])
   ) p
 )

SELECT nw.student_number
      ,nw.term
      ,COMP_TA_obj_1
      ,COMP_TA_obj_2
      ,COMP_TA_obj_3
      ,COMP_TA_obj_4
      ,COMP_TA_obj_5
      ,COMP_TA_obj_6
      ,COMP_TA_obj_7
      ,COMP_TA_obj_8
      ,COMP_TA_obj_9
      ,COMP_TA_obj_10
      ,COMP_TA_obj_11
      ,COMP_TA_obj_12
      ,COMP_TA_obj_13
      ,COMP_TA_obj_14
      ,COMP_TA_obj_15
      ,MATH_TA_obj_1
      ,MATH_TA_obj_2
      ,MATH_TA_obj_3
      ,MATH_TA_obj_4
      ,MATH_TA_obj_5
      ,MATH_TA_obj_6
      ,MATH_TA_obj_7
      ,MATH_TA_obj_8
      ,MATH_TA_obj_9
      ,MATH_TA_obj_10
      ,MATH_TA_obj_11
      ,MATH_TA_obj_12
      ,MATH_TA_obj_13
      ,MATH_TA_obj_14
      ,MATH_TA_obj_15
      ,PERF_TA_obj_1
      ,PERF_TA_obj_2
      ,PERF_TA_obj_3
      ,PERF_TA_obj_4
      ,PERF_TA_obj_5
      ,PERF_TA_obj_6
      ,PERF_TA_obj_7
      ,PERF_TA_obj_8
      ,PERF_TA_obj_9
      ,PERF_TA_obj_10
      ,PERF_TA_obj_11
      ,PERF_TA_obj_12
      ,PERF_TA_obj_13
      ,PERF_TA_obj_14
      ,PERF_TA_obj_15
      ,HUM_TA_obj_1
      ,HUM_TA_obj_2
      ,HUM_TA_obj_3
      ,HUM_TA_obj_4
      ,HUM_TA_obj_5
      ,HUM_TA_obj_6
      ,HUM_TA_obj_7
      ,HUM_TA_obj_8
      ,HUM_TA_obj_9
      ,HUM_TA_obj_10
      ,HUM_TA_obj_11
      ,HUM_TA_obj_12
      ,HUM_TA_obj_13
      ,HUM_TA_obj_14
      ,HUM_TA_obj_15
      ,PHON_TA_obj_1
      ,PHON_TA_obj_2
      ,PHON_TA_obj_3
      ,PHON_TA_obj_4
      ,PHON_TA_obj_5
      ,PHON_TA_obj_6
      ,PHON_TA_obj_7
      ,PHON_TA_obj_8
      ,PHON_TA_obj_9
      ,PHON_TA_obj_10
      ,PHON_TA_obj_11
      ,PHON_TA_obj_12
      ,PHON_TA_obj_13
      ,PHON_TA_obj_14
      ,PHON_TA_obj_15
      ,SCI_TA_obj_1
      ,SCI_TA_obj_2
      ,SCI_TA_obj_3
      ,SCI_TA_obj_4
      ,SCI_TA_obj_5
      ,SCI_TA_obj_6
      ,SCI_TA_obj_7
      ,SCI_TA_obj_8
      ,SCI_TA_obj_9
      ,SCI_TA_obj_10
      ,SCI_TA_obj_11
      ,SCI_TA_obj_12
      ,SCI_TA_obj_13
      ,SCI_TA_obj_14
      ,SCI_TA_obj_15
      ,SPAN_TA_obj_1
      ,SPAN_TA_obj_2
      ,SPAN_TA_obj_3
      ,SPAN_TA_obj_4
      ,SPAN_TA_obj_5
      ,SPAN_TA_obj_6
      ,SPAN_TA_obj_7
      ,SPAN_TA_obj_8
      ,SPAN_TA_obj_9
      ,SPAN_TA_obj_10
      ,SPAN_TA_obj_11
      ,SPAN_TA_obj_12
      ,SPAN_TA_obj_13
      ,SPAN_TA_obj_14
      ,SPAN_TA_obj_15
      ,VIZ_TA_obj_1
      ,VIZ_TA_obj_2
      ,VIZ_TA_obj_3
      ,VIZ_TA_obj_4
      ,VIZ_TA_obj_5
      ,VIZ_TA_obj_6
      ,VIZ_TA_obj_7
      ,VIZ_TA_obj_8
      ,VIZ_TA_obj_9
      ,VIZ_TA_obj_10
      ,VIZ_TA_obj_11
      ,VIZ_TA_obj_12
      ,VIZ_TA_obj_13
      ,VIZ_TA_obj_14
      ,VIZ_TA_obj_15
      ,COMP_TA_prof_1
      ,COMP_TA_prof_2
      ,COMP_TA_prof_3
      ,COMP_TA_prof_4
      ,COMP_TA_prof_5
      ,COMP_TA_prof_6
      ,COMP_TA_prof_7
      ,COMP_TA_prof_8
      ,COMP_TA_prof_9
      ,COMP_TA_prof_10
      ,COMP_TA_prof_11
      ,COMP_TA_prof_12
      ,COMP_TA_prof_13
      ,COMP_TA_prof_14
      ,COMP_TA_prof_15
      ,MATH_TA_prof_1
      ,MATH_TA_prof_2
      ,MATH_TA_prof_3
      ,MATH_TA_prof_4
      ,MATH_TA_prof_5
      ,MATH_TA_prof_6
      ,MATH_TA_prof_7
      ,MATH_TA_prof_8
      ,MATH_TA_prof_9
      ,MATH_TA_prof_10
      ,MATH_TA_prof_11
      ,MATH_TA_prof_12
      ,MATH_TA_prof_13
      ,MATH_TA_prof_14
      ,MATH_TA_prof_15
      ,PERF_TA_prof_1
      ,PERF_TA_prof_2
      ,PERF_TA_prof_3
      ,PERF_TA_prof_4
      ,PERF_TA_prof_5
      ,PERF_TA_prof_6
      ,PERF_TA_prof_7
      ,PERF_TA_prof_8
      ,PERF_TA_prof_9
      ,PERF_TA_prof_10
      ,PERF_TA_prof_11
      ,PERF_TA_prof_12
      ,PERF_TA_prof_13
      ,PERF_TA_prof_14
      ,PERF_TA_prof_15
      ,HUM_TA_prof_1
      ,HUM_TA_prof_2
      ,HUM_TA_prof_3
      ,HUM_TA_prof_4
      ,HUM_TA_prof_5
      ,HUM_TA_prof_6
      ,HUM_TA_prof_7
      ,HUM_TA_prof_8
      ,HUM_TA_prof_9
      ,HUM_TA_prof_10
      ,HUM_TA_prof_11
      ,HUM_TA_prof_12
      ,HUM_TA_prof_13
      ,HUM_TA_prof_14
      ,HUM_TA_prof_15
      ,PHON_TA_prof_1
      ,PHON_TA_prof_2
      ,PHON_TA_prof_3
      ,PHON_TA_prof_4
      ,PHON_TA_prof_5
      ,PHON_TA_prof_6
      ,PHON_TA_prof_7
      ,PHON_TA_prof_8
      ,PHON_TA_prof_9
      ,PHON_TA_prof_10
      ,PHON_TA_prof_11
      ,PHON_TA_prof_12
      ,PHON_TA_prof_13
      ,PHON_TA_prof_14
      ,PHON_TA_prof_15
      ,SCI_TA_prof_1
      ,SCI_TA_prof_2
      ,SCI_TA_prof_3
      ,SCI_TA_prof_4
      ,SCI_TA_prof_5
      ,SCI_TA_prof_6
      ,SCI_TA_prof_7
      ,SCI_TA_prof_8
      ,SCI_TA_prof_9
      ,SCI_TA_prof_10
      ,SCI_TA_prof_11
      ,SCI_TA_prof_12
      ,SCI_TA_prof_13
      ,SCI_TA_prof_14
      ,SCI_TA_prof_15
      ,SPAN_TA_prof_1
      ,SPAN_TA_prof_2
      ,SPAN_TA_prof_3
      ,SPAN_TA_prof_4
      ,SPAN_TA_prof_5
      ,SPAN_TA_prof_6
      ,SPAN_TA_prof_7
      ,SPAN_TA_prof_8
      ,SPAN_TA_prof_9
      ,SPAN_TA_prof_10
      ,SPAN_TA_prof_11
      ,SPAN_TA_prof_12
      ,SPAN_TA_prof_13
      ,SPAN_TA_prof_14
      ,SPAN_TA_prof_15
      ,VIZ_TA_prof_1
      ,VIZ_TA_prof_2
      ,VIZ_TA_prof_3
      ,VIZ_TA_prof_4
      ,VIZ_TA_prof_5
      ,VIZ_TA_prof_6
      ,VIZ_TA_prof_7
      ,VIZ_TA_prof_8
      ,VIZ_TA_prof_9
      ,VIZ_TA_prof_10
      ,VIZ_TA_prof_11
      ,VIZ_TA_prof_12
      ,VIZ_TA_prof_13
      ,VIZ_TA_prof_14
      ,VIZ_TA_prof_15
      ,w.writing_obj_1 AS RHET_TA_obj_1
      ,w.writing_obj_2 AS RHET_TA_obj_2
      ,w.writing_obj_3 AS RHET_TA_obj_3
      ,w.writing_obj_4 AS RHET_TA_obj_4
      ,w.writing_obj_5 AS RHET_TA_obj_5
      ,w.writing_obj_6 AS RHET_TA_obj_6
      ,w.writing_obj_7 AS RHET_TA_obj_7
      ,w.writing_obj_8 AS RHET_TA_obj_8
      ,w.writing_obj_9 AS RHET_TA_obj_9
      ,w.writing_obj_10 AS RHET_TA_obj_10
      ,narr.writing_type AS RHET_TA_narr_obj
      ,inf.writing_type AS RHET_TA_info_obj
      ,op.writing_type AS RHET_TA_op_obj
      ,w.writing_prof_1 AS RHET_TA_prof_1
      ,w.writing_prof_2 AS RHET_TA_prof_2
      ,w.writing_prof_3 AS RHET_TA_prof_3
      ,w.writing_prof_4 AS RHET_TA_prof_4
      ,w.writing_prof_5 AS RHET_TA_prof_5
      ,w.writing_prof_6 AS RHET_TA_prof_6
      ,w.writing_prof_7 AS RHET_TA_prof_7
      ,w.writing_prof_8 AS RHET_TA_prof_8
      ,w.writing_prof_9 AS RHET_TA_prof_9
      ,w.writing_prof_10 AS RHET_TA_prof_10
      ,narr.total_prof AS RHET_TA_narr_prof
      ,inf.total_prof AS RHET_TA_info_prof
      ,op.total_prof AS RHET_TA_op_prof
      ,COMP_pct_stds_mastered
      ,MATH_pct_stds_mastered
      ,PERF_pct_stds_mastered
      ,PHON_pct_stds_mastered
      ,HUM_pct_stds_mastered
      ,SCI_pct_stds_mastered
      ,SPAN_pct_stds_mastered
      ,VIZ_pct_stds_mastered
      ,w.pct_prof AS RHET_pct_stds_mastered
FROM not_writing nw WITH(NOLOCK)
LEFT OUTER JOIN writing w WITH(NOLOCK)
  ON nw.student_number = w.student_number
 AND nw.term = w.term
 AND w.rn_cur = 1
LEFT OUTER JOIN writing narr WITH(NOLOCK)
  ON nw.student_number = narr.student_number
 AND nw.term = narr.term
 AND narr.rn_type_cur = 1
 AND narr.writing_type = 'Narrative'
LEFT OUTER JOIN writing inf WITH(NOLOCK)
  ON nw.student_number = inf.student_number
 AND nw.term = inf.term
 AND inf.rn_type_cur = 1
 AND inf.writing_type = 'Informative'
LEFT OUTER JOIN writing op WITH(NOLOCK)
  ON nw.student_number = op.student_number
 AND nw.term = op.term
 AND op.rn_type_cur = 1
 AND op.writing_type = 'Opinion'