USE KIPP_NJ
GO

ALTER VIEW LIT$STEP_Level_Assessment_Data#UChicago AS

SELECT DISTINCT 
       CONCAT('UC', step.[index]) AS unique_id
      ,CASE               
        WHEN CONVERT(INT,step.step) = 0 THEN 3280
        WHEN CONVERT(INT,step.step) = 1 THEN 3281
        WHEN CONVERT(INT,step.step) = 2 THEN 3282
        WHEN CONVERT(INT,step.step) = 3 THEN 3380
        WHEN CONVERT(INT,step.step) = 4 THEN 3397
        WHEN CONVERT(INT,step.step) = 5 THEN 3411
        WHEN CONVERT(INT,step.step) = 6 THEN 3425
        WHEN CONVERT(INT,step.step) = 7 THEN 3441
        WHEN CONVERT(INT,step.step) = 8 THEN 3458
        WHEN CONVERT(INT,step.step) = 9 THEN 3474
        WHEN CONVERT(INT,step.step) = 10 THEN 3493
        WHEN CONVERT(INT,step.step) = 11 THEN 3511
        WHEN CONVERT(INT,step.step) = 12 THEN 3527
       END AS testid
      ,0 AS is_fp
      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)) AS academic_year
      ,dt.time_per_name AS test_round
      ,CASE
        WHEN dt.time_per_name = 'DR' THEN 1
        WHEN dt.time_per_name = 'Q1' THEN 2
        WHEN dt.time_per_name = 'Q2' THEN 3
        WHEN dt.time_per_name = 'Q3' THEN 4
        WHEN dt.time_per_name = 'Q4' THEN 5
       END AS round_num
      ,CONVERT(DATE,step.date) AS test_date
      ,co.schoolid
      ,co.grade_level
      ,co.cohort
      ,co.studentid
      ,step.studentid AS student_number      
      ,co.lastfirst
      ,CASE 
        WHEN step.passed = 1 THEN 'Achieved'
        WHEN step.passed = 0 THEN 'Did Not Achieve'
       END AS status           
      ,REPLACE(step.step, 0, 'Pre') AS read_lvl
      ,CONVERT(INT,step.step) AS lvl_num
      ,NULL AS dna_lvl
      ,NULL AS dna_lvl_num
      ,NULL AS instruct_lvl
      ,NULL AS instruct_lvl_num
      ,NULL AS indep_lvl
      ,NULL AS indep_lvl_num
      ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
      ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num      
      ,goals.read_lvl AS default_goal_lvl
      ,goals.lvl_num AS default_goal_num
      ,goals.read_lvl AS natl_goal_lvl
      ,goals.lvl_num AS natl_goal_num
      ,indiv.goal AS indiv_goal_lvl
      ,indiv.lvl_num AS indiv_lvl_num
      ,CASE WHEN CONVERT(INT,step.step) >= COALESCE(indiv.lvl_num, goals.lvl_num) THEN 1 ELSE 0 END AS met_goal
      ,CONVERT(INT,step.step) - COALESCE(indiv.lvl_num, goals.lvl_num) AS levels_behind                 

      ,NULL AS gleq
      ,step.book AS color
      ,NULL AS genre
      ,NULL AS fp_wpmrate
      ,NULL AS fp_keylever
      ,NULL AS coaching_code
FROM KIPP_NJ..[AUTOLOAD$STEP_Level_Assessment_Data_long] step WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON step.schoolid = dt.schoolid
 AND CONVERT(DATE,step.date) BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'LIT'     
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON step.studentid = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,step.date)) = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_normed_goals goals WITH(NOLOCK)
  ON co.grade_level = goals.grade_level
 AND dt.time_per_name = goals.test_round
 AND goals.norms_year = 2015
LEFT OUTER JOIN KIPP_NJ..LIT$individual_goals indiv WITH(NOLOCK)
  ON co.student_number = indiv.student_number
 AND co.year = indiv.academic_year
 AND dt.time_per_name = indiv.test_round