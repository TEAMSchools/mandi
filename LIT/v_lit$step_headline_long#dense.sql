USE KIPP_NJ
GO

ALTER VIEW LIT$STEP_headline_long#dense AS
WITH step_detail AS
    (SELECT s.studentid
           ,s.schoolid
           ,s.grade_level
           ,s.lastfirst
           ,s.test_round AS time_per_name
           ,s.test_date
           ,CASE 
              WHEN s.test_round = 'DR' THEN 0
              WHEN s.test_round = 'T1' THEN 1
              WHEN s.test_round = 'T2' THEN 2
              WHEN s.test_round = 'T3' THEN 3
              WHEN s.test_round = 'EOY' THEN 4
            END AS time_per_sort
           ,CASE 
              WHEN s.test_round = 'DR' THEN '0_Diagnostic'
              WHEN s.test_round = 'T1' THEN '1_T1'
              WHEN s.test_round = 'T2' THEN '2_T2'
              WHEN s.test_round = 'T3' THEN '3_T3'
              WHEN s.test_round = 'EOY' THEN '4_EOY'
            END AS time_per_custom
           ,s.lvl_num AS level_number
           ,s.read_lvl AS step_level
           ,s.academic_year AS year
     FROM KIPP_NJ..LIT$test_events#identifiers s
     WHERE s.status = 'Achieved' 
       AND s.achv_base_round = 1
       AND s.is_fp = 0
     )
    ,stu_scaffold AS
    (SELECT c.studentid
           ,c.lastfirst
           ,c.schoolid
           ,c.year
           ,c.grade_level
           ,CASE 
              WHEN c.grade_level = 0 THEN 3 
              WHEN c.grade_level = 1 THEN 6 
              WHEN c.grade_level = 2 THEN 9
              WHEN c.grade_level = 3 THEN 12
              WHEN c.grade_level = 4 THEN 12
            END AS eoy_benchmark
     FROM KIPP_NJ..COHORT$comprehensive_long#static c
     WHERE c.schoolid != 999999 
       AND c.rn = 1
       AND c.schoolid IN (73254, 73255, 73256, 73257, 179901)
       --testing
       --AND c.studentid = 2278
    )
    ,step_scaffold AS
    (SELECT '0_Diagnostic' AS step_term
           ,0 AS step_sort
           ,'08/15' AS canonical_month
           ,0 AS year_offset
     UNION 
     SELECT '1_T1'
           ,1
           ,'10/15' AS canonical_month
           ,0
     UNION
     SELECT '2_T2'
           ,2
           ,'01/15' AS canonical_month
           ,1
     UNION
     SELECT '3_T3'
           ,3
           ,'03/15' AS canonical_month
           ,1
     UNION
     SELECT '4_EOY'
           ,4
           ,'06/15' AS canonical_month
           ,1
    )
   ,step_sparse AS
   (SELECT stu_scaffold.studentid
          ,stu_scaffold.year
          ,stu_scaffold.schoolid
          ,stu_scaffold.grade_level
          ,stu_scaffold.eoy_benchmark
          ,step_scaffold.step_term
          ,step_detail.test_date         
          ,CONVERT(datetime, step_scaffold.canonical_month + '/' +
             CAST((stu_scaffold.year + step_scaffold.year_offset) AS VARCHAR), 101) AS synthetic_date
          ,step_detail.level_number
          ,step_detail.step_level
          ,CASE 
             WHEN stu_scaffold.grade_level = 0 
               AND step_scaffold.step_term = '0_Diagnostic' THEN 0
             WHEN stu_scaffold.grade_level = 0 
               AND step_scaffold.step_term = '1_T1' THEN 1
             WHEN stu_scaffold.grade_level = 0 
               AND step_scaffold.step_term = '2_T2' THEN 2
             WHEN stu_scaffold.grade_level = 0 
               AND step_scaffold.step_term = '3_T3' THEN 3
             WHEN stu_scaffold.grade_level = 0 
               AND step_scaffold.step_term = '4_EOY' THEN 4
             WHEN stu_scaffold.grade_level = 1
               AND step_scaffold.step_term = '0_Diagnostic' THEN 4
             WHEN stu_scaffold.grade_level = 1 
               AND step_scaffold.step_term = '1_T1' THEN 5
             WHEN stu_scaffold.grade_level = 1 
               AND step_scaffold.step_term = '2_T2' THEN 6
             WHEN stu_scaffold.grade_level = 1 
               AND step_scaffold.step_term = '3_T3' THEN 7
             WHEN stu_scaffold.grade_level = 1 
               AND step_scaffold.step_term = '4_EOY' THEN 7
             WHEN stu_scaffold.grade_level = 2 
               AND step_scaffold.step_term = '0_Diagnostic' THEN 7
             WHEN stu_scaffold.grade_level = 2 
               AND step_scaffold.step_term = '1_T1' THEN 8
             WHEN stu_scaffold.grade_level = 2 
               AND step_scaffold.step_term = '2_T2' THEN 9
             WHEN stu_scaffold.grade_level = 2 
               AND step_scaffold.step_term = '3_T3' THEN 10
             WHEN stu_scaffold.grade_level = 2 
               AND step_scaffold.step_term = '4_EOY' THEN 10
           END AS on_track_for_benchmark
          ,ROW_NUMBER() OVER
            (PARTITION BY stu_scaffold.studentid
             ORDER BY stu_scaffold.year
                     ,stu_scaffold.grade_level
                     ,step_scaffold.step_sort
            ) AS rn_sort
    FROM stu_scaffold
    JOIN step_scaffold
      ON 1=1
    LEFT OUTER JOIN step_detail
      ON stu_scaffold.studentid = step_detail.studentid
     AND stu_scaffold.grade_level = step_detail.grade_level
     AND step_scaffold.step_term = step_detail.time_per_custom
     AND stu_scaffold.year = step_detail.year 
   )
SELECT sub.studentid
      ,sub.year
      ,sub.schoolid
      ,sub.grade_level
      ,sub.step_term
      ,sub.test_date
      ,COALESCE(sub.level_number, densify_me.level_number) AS step_dense
      ,CASE 
         WHEN COALESCE(sub.level_number, densify_me.level_number) >= sub.on_track_for_benchmark THEN 'Yes'
         WHEN COALESCE(sub.level_number, densify_me.level_number) < sub.on_track_for_benchmark THEN 'No'
       END AS on_track_for_benchmark
      ,CASE 
         WHEN COALESCE(sub.level_number, densify_me.level_number) >= sub.on_track_for_benchmark THEN 1
         WHEN COALESCE(sub.level_number, densify_me.level_number) < sub.on_track_for_benchmark THEN 0
       END AS on_track_for_numeric
      ,CASE 
         WHEN COALESCE(sub.level_number, densify_me.level_number) >= sub.eoy_benchmark THEN 'Yes'
         WHEN COALESCE(sub.level_number, densify_me.level_number) < sub.eoy_benchmark THEN 'No'
       END AS at_eoy_benchmark
      ,CASE 
         WHEN COALESCE(sub.level_number, densify_me.level_number) >= sub.eoy_benchmark THEN 1
         WHEN COALESCE(sub.level_number, densify_me.level_number) < sub.eoy_benchmark THEN 0
       END AS at_eoy_numeric
      ,sub.s_left_rn AS stu_rn_asc
FROM
      (SELECT s_left.studentid
             ,s_left.year
             ,s_left.schoolid
             ,s_left.grade_level
             ,s_left.on_track_for_benchmark
             ,s_left.eoy_benchmark
             ,s_left.step_term
             ,s_left.synthetic_date AS test_date
             ,s_left.level_number
             ,s_left.step_level
             ,s_left.rn_sort AS s_left_rn
              --row number of the most recent previous test that's NOT null
             ,MAX(s_right.rn_sort) AS prev_rn_to_densify
       FROM step_sparse s_left
       LEFT OUTER JOIN step_sparse s_right
         ON s_left.studentid = s_right.studentid
        AND s_right.rn_sort < s_left.rn_sort
        AND s_right.level_number IS NOT NULL
       GROUP BY s_left.studentid
               ,s_left.year
               ,s_left.schoolid
               ,s_left.grade_level
               ,s_left.on_track_for_benchmark
               ,s_left.eoy_benchmark
               ,s_left.step_term
               ,s_left.synthetic_date
               ,s_left.level_number
               ,s_left.step_level
               ,s_left.rn_sort
       ) sub
LEFT OUTER JOIN step_sparse AS densify_me
  ON sub.studentid = densify_me.studentid
 --this is the dark magic right here
 AND sub.prev_rn_to_densify = densify_me.rn_sort
WHERE sub.test_date <= GETDATE()