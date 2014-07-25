USE KIPP_NJ
GO

ALTER VIEW LIT$achieved_by_round AS

-- ES/MS students enrolled this year
WITH roster AS (
  SELECT STUDENTID
        ,SCHOOLID
        ,GRADE_LEVEL
        ,YEAR
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE YEAR = dbo.fn_Global_Academic_Year()
    AND GRADE_LEVEL <= 8
    AND RN = 1
 )

-- 5 rounds a year, over course of 5 years
-- norm on DR/BOY/EOY term names
,terms AS (    
  SELECT *
  FROM 
      (
       SELECT dbo.fn_Global_Academic_Year() AS academic_year
       UNION 
       SELECT dbo.fn_Global_Academic_Year() - 1
       UNION 
       SELECT dbo.fn_Global_Academic_Year() - 2
       UNION 
       SELECT dbo.fn_Global_Academic_Year() - 3
       UNION 
       SELECT dbo.fn_Global_Academic_Year() - 4
      ) years
  JOIN (      
        SELECT 'DR' AS test_round
              ,1 AS round_num
        UNION
        SELECT 'T1'
              ,2
        UNION
        SELECT 'T2'
              ,3
        UNION
        SELECT 'T3'
              ,4
        UNION
        SELECT 'EOY'
              ,5
       ) terms
  ON 1 = 1 
 )
 
-- highest acheived test per round for each student 
,tests AS (
  SELECT r.STUDENTID
        ,r.SCHOOLID
        ,r.GRADE_LEVEL
        ,terms.academic_year
        ,terms.test_round
        ,terms.round_num
        ,achv.unique_id
        ,achv.read_lvl        
        ,achv.GLEQ
        ,achv.goal_lvl
        ,achv.lvl_num
        ,achv.goal_num
        ,achv.met_goal                
        ,ROW_NUMBER() OVER(
            PARTITION BY r.studentid
                ORDER BY terms.academic_year, terms.round_num) AS meta_achv_round
  FROM roster r
  JOIN terms
    ON 1 = 1
  LEFT OUTER JOIN LIT$test_events#identifiers achv WITH(NOLOCK)
    ON r.STUDENTID = achv.studentid   
   AND terms.academic_year = achv.academic_year
   AND terms.test_round = achv.test_round
   AND achv.achv_curr_round = 1
 )
 
-- falls back to most recently achieved reading level for each round, if NULL
SELECT tests.academic_year
      ,tests.SCHOOLID
      ,tests.GRADE_LEVEL
      ,tests.STUDENTID      
      ,tests.test_round      
      ,COALESCE(tests.read_lvl, achv_prev1.read_lvl, achv_prev2.read_lvl, achv_prev3.read_lvl, achv_prev4.read_lvl, achv_prev5.read_lvl) AS read_lvl
      ,COALESCE(tests.gleq, achv_prev1.gleq, achv_prev2.gleq, achv_prev3.gleq, achv_prev4.gleq, achv_prev5.gleq) AS GLEQ
      ,COALESCE(tests.goal_lvl, achv_prev1.goal_lvl, achv_prev2.goal_lvl, achv_prev3.goal_lvl, achv_prev4.goal_lvl, achv_prev5.goal_lvl) AS goal_lvl
      ,COALESCE(tests.lvl_num, achv_prev1.lvl_num, achv_prev2.lvl_num, achv_prev3.lvl_num, achv_prev4.lvl_num, achv_prev5.lvl_num) AS lvl_num
      ,COALESCE(tests.goal_num, achv_prev1.goal_num, achv_prev2.goal_num, achv_prev3.goal_num, achv_prev4.goal_num, achv_prev5.goal_num) AS goal_num
      ,COALESCE(tests.met_goal, achv_prev1.met_goal, achv_prev2.met_goal, achv_prev3.met_goal, achv_prev4.met_goal, achv_prev5.met_goal) AS met_goal
      ,COALESCE(tests.unique_id, achv_prev1.unique_id, achv_prev2.unique_id, achv_prev3.unique_id, achv_prev4.unique_id, achv_prev5.unique_id) AS unique_id
FROM tests
LEFT OUTER JOIN tests achv_prev1
  ON tests.STUDENTID = achv_prev1.STUDENTID
 AND tests.meta_achv_round = (achv_prev1.meta_achv_round + 1)
LEFT OUTER JOIN tests achv_prev2
  ON tests.STUDENTID = achv_prev2.STUDENTID
 AND tests.meta_achv_round = (achv_prev2.meta_achv_round + 2) 
LEFT OUTER JOIN tests achv_prev3
 ON tests.STUDENTID = achv_prev3.STUDENTID
AND tests.meta_achv_round = (achv_prev3.meta_achv_round + 3) 
LEFT OUTER JOIN tests achv_prev4
 ON tests.STUDENTID = achv_prev4.STUDENTID
AND tests.meta_achv_round = (achv_prev4.meta_achv_round + 4) 
LEFT OUTER JOIN tests achv_prev5
 ON tests.STUDENTID = achv_prev5.STUDENTID
AND tests.meta_achv_round = (achv_prev5.meta_achv_round + 5)