USE KIPP_NJ
GO

ALTER VIEW LIT$achieved_by_round AS

WITH roster AS (
  SELECT STUDENTID
        ,student_number
        ,SCHOOLID
        ,GRADE_LEVEL
        ,YEAR
  FROM COHORT$identifiers_long#static WITH(NOLOCK)      
  WHERE grade_level < 9
    AND RN = 1
 )

-- active lit rounds by school
,terms AS (      
  SELECT academic_year
        ,schoolid
        ,CASE 
          WHEN school_level = 'MS' AND time_per_name = 'DR' THEN 'BOY' 
          ELSE REPLACE(time_per_name, 'Diagnostic', 'DR')
         END AS test_round
        ,start_date
        ,ROW_NUMBER() OVER (
           PARTITION BY academic_year, schoolid
           ORDER BY start_date ASC) AS round_num
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'LIT'      
    --AND start_date <= GETDATE()
 )
 
,roster_scaffold AS (
  SELECT r.STUDENTID
        ,r.student_number
        ,r.SCHOOLID
        ,r.GRADE_LEVEL
        ,r.year AS academic_year
        ,terms.test_round
        ,terms.round_num
        ,terms.start_date
  FROM roster r WITH(NOLOCK)
  JOIN terms WITH(NOLOCK)
    ON (r.year = terms.academic_year AND r.schoolid = terms.schoolid) 
    OR (r.grade_level <= 4 AND terms.schoolid IS NULL AND r.year <= 2012 AND r.year = terms.academic_year) -- ES rounds for archive years
 )

-- highest acheived test per round for each student 
,tests AS (
  SELECT r.STUDENTID
        ,r.student_number
        ,r.SCHOOLID
        ,r.GRADE_LEVEL
        ,r.academic_year
        ,r.test_round
        ,r.round_num
        ,r.start_date
        ,achv.unique_id
        ,achv.read_lvl    
        ,achv.lvl_num
        ,achv.indep_lvl    
        ,achv.GLEQ
        --,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
        --,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num                     
        ,achv.fp_wpmrate
        ,achv.fp_keylever                
        ,ROW_NUMBER() OVER(
            PARTITION BY r.studentid
                ORDER BY r.academic_year, r.round_num) AS meta_achv_round
  FROM roster_scaffold r WITH(NOLOCK) 
  LEFT OUTER JOIN LIT$test_events#identifiers achv WITH(NOLOCK)
    ON r.STUDENTID = achv.studentid      
   AND r.academic_year = achv.academic_year
   AND r.test_round = achv.test_round
   AND achv.achv_curr_round = 1
  --LEFT OUTER JOIN LIT$goals goals WITH(NOLOCK)
  --  ON r.grade_level = goals.grade_level
  -- AND r.test_round = goals.test_round
  --LEFT OUTER JOIN LIT$individual_goals indiv WITH(NOLOCK)
  --  ON r.STUDENT_NUMBER = indiv.student_number
  -- AND r.test_round = indiv.test_round
 )
 
-- falls back to most recently achieved reading level for each round, if NULL
SELECT academic_year
      ,SCHOOLID
      ,GRADE_LEVEL
      ,STUDENTID
      ,test_round
      ,start_date
      ,read_lvl
      ,indep_lvl
      ,GLEQ
      ,goal_lvl
      ,lvl_num      
      ,fp_wpmrate
      ,fp_keylever
      ,goal_num   
      ,CASE WHEN lvl_num >= goal_num THEN 1 ELSE 0 END AS met_goal
      ,unique_id
FROM
    (
     SELECT sub.academic_year
           ,sub.SCHOOLID
           ,sub.GRADE_LEVEL
           ,sub.STUDENTID
           ,sub.test_round
           ,sub.start_date
           ,sub.read_lvl
           ,sub.indep_lvl
           ,sub.GLEQ
           ,sub.lvl_num      
           ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
           ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num                           
           ,goals.read_lvl AS default_goal_lvl
           ,goals.lvl_num AS default_goal_num
           ,indiv.goal AS indiv_goal_lvl
           ,indiv.lvl_num AS indiv_lvl_num
           ,sub.fp_wpmrate
           ,sub.fp_keylever
           ,sub.unique_id      
     FROM
         (
          SELECT tests.academic_year
                ,tests.SCHOOLID
                ,tests.GRADE_LEVEL
                ,tests.STUDENTID      
                ,tests.student_number
                ,tests.test_round      
                ,tests.start_date
                ,COALESCE(tests.read_lvl, achv_prev1.read_lvl, achv_prev2.read_lvl, achv_prev3.read_lvl, achv_prev4.read_lvl, achv_prev5.read_lvl) AS read_lvl
                ,COALESCE(tests.indep_lvl, achv_prev1.indep_lvl, achv_prev2.indep_lvl, achv_prev3.indep_lvl, achv_prev4.indep_lvl, achv_prev5.indep_lvl) AS indep_lvl
                ,COALESCE(tests.gleq, achv_prev1.gleq, achv_prev2.gleq, achv_prev3.gleq, achv_prev4.gleq, achv_prev5.gleq) AS GLEQ
                ,COALESCE(tests.lvl_num, achv_prev1.lvl_num, achv_prev2.lvl_num, achv_prev3.lvl_num, achv_prev4.lvl_num, achv_prev5.lvl_num) AS lvl_num
                ,COALESCE(tests.fp_wpmrate, achv_prev1.fp_wpmrate, achv_prev2.fp_wpmrate, achv_prev3.fp_wpmrate, achv_prev4.fp_wpmrate, achv_prev5.fp_wpmrate) AS fp_wpmrate
                ,COALESCE(tests.fp_keylever, achv_prev1.fp_keylever, achv_prev2.fp_keylever, achv_prev3.fp_keylever, achv_prev4.fp_keylever, achv_prev5.fp_keylever) AS fp_keylever
                ,COALESCE(tests.unique_id, achv_prev1.unique_id, achv_prev2.unique_id, achv_prev3.unique_id, achv_prev4.unique_id, achv_prev5.unique_id) AS unique_id
          FROM tests WITH(NOLOCK)
          LEFT OUTER JOIN tests achv_prev1 WITH(NOLOCK)
            ON tests.STUDENTID = achv_prev1.STUDENTID
           AND tests.meta_achv_round = (achv_prev1.meta_achv_round + 1)
          LEFT OUTER JOIN tests achv_prev2 WITH(NOLOCK)
            ON tests.STUDENTID = achv_prev2.STUDENTID
           AND tests.meta_achv_round = (achv_prev2.meta_achv_round + 2) 
          LEFT OUTER JOIN tests achv_prev3 WITH(NOLOCK)
            ON tests.STUDENTID = achv_prev3.STUDENTID
           AND tests.meta_achv_round = (achv_prev3.meta_achv_round + 3) 
          LEFT OUTER JOIN tests achv_prev4 WITH(NOLOCK)
            ON tests.STUDENTID = achv_prev4.STUDENTID
           AND tests.meta_achv_round = (achv_prev4.meta_achv_round + 4) 
          LEFT OUTER JOIN tests achv_prev5 WITH(NOLOCK)
            ON tests.STUDENTID = achv_prev5.STUDENTID
           AND tests.meta_achv_round = (achv_prev5.meta_achv_round + 5)
         ) sub
     LEFT OUTER JOIN LIT$goals goals WITH(NOLOCK)
       ON sub.grade_level = goals.grade_level
      AND sub.test_round = goals.test_round
     LEFT OUTER JOIN LIT$individual_goals indiv WITH(NOLOCK)
       ON sub.STUDENT_NUMBER = indiv.student_number
      AND sub.test_round = indiv.test_round
      AND sub.academic_year = dbo.fn_Global_Academic_Year()
    ) sub