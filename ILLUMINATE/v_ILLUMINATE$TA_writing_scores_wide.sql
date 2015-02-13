USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$TA_writing_scores_wide AS

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
        --,ROUND((CONVERT(FLOAT,n_prof) / CASE WHEN n_tested = 0 THEN NULL ELSE CONVERT(FLOAT,n_tested) END) * 100,0) AS pct_prof
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
                  ,CASE WHEN prof_numeric >= 3 THEN 1 ELSE 0 END AS is_prof
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
 
SELECT w.student_number      
      ,w.term            
      --,w.rn_cur
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
      ,ROUND(
        (CONVERT(FLOAT,ISNULL(w.n_prof,0) 
          + CASE WHEN narr.total_prof LIKE '3%' THEN 1.0 ELSE 0.0 END 
          + CASE WHEN inf.total_prof LIKE '3%' THEN 1.0 ELSE 0.0 END 
          + CASE WHEN op.total_prof LIKE '3%' THEN 1.0 ELSE 0.0 END)
          / 
         CASE
          WHEN CONVERT(FLOAT,w.n_tested 
                + CASE WHEN narr.n_tested IS NOT NULL THEN 1.0 ELSE 0.0 END 
                + CASE WHEN inf.n_tested IS NOT NULL THEN 1.0 ELSE 0.0 END 
                + CASE WHEN op.n_tested IS NOT NULL THEN 1.0 ELSE 0.0 END) = 0 THEN NULL
          ELSE CONVERT(FLOAT,w.n_tested 
                + CASE WHEN narr.n_tested IS NOT NULL THEN 1.0 ELSE 0.0 END 
                + CASE WHEN inf.n_tested IS NOT NULL THEN 1.0 ELSE 0.0 END 
                + CASE WHEN op.n_tested IS NOT NULL THEN 1.0 ELSE 0.0 END)
         END)
          * 100
        ,0) AS RHET_pct_stds_mastered      
FROM writing w WITH(NOLOCK)  
LEFT OUTER JOIN writing narr WITH(NOLOCK)
  ON w.student_number = narr.student_number
 AND w.term = narr.term
 AND narr.rn_type_cur = 1
 AND narr.writing_type = 'Narrative'
LEFT OUTER JOIN writing inf WITH(NOLOCK)
  ON w.student_number = inf.student_number
 AND w.term = inf.term
 AND inf.rn_type_cur = 1
 AND inf.writing_type = 'Informative'
LEFT OUTER JOIN writing op WITH(NOLOCK)
  ON w.student_number = op.student_number
 AND w.term = op.term
 AND op.rn_type_cur = 1
 AND op.writing_type = 'Opinion'
WHERE w.rn_cur = 1