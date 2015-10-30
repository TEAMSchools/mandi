USE KIPP_NJ
GO

ALTER VIEW LIT$achieved_by_round AS

WITH roster_scaffold AS (
  SELECT r.STUDENTID
        ,r.student_number
        ,r.SCHOOLID
        ,r.GRADE_LEVEL
        ,r.year AS academic_year
        ,CASE 
          WHEN terms.school_level = 'MS' AND terms.time_per_name = 'DR' THEN 'BOY' 
          ELSE REPLACE(terms.time_per_name, 'Diagnostic', 'DR')
         END AS test_round
        ,ROW_NUMBER() OVER (
           PARTITION BY r.studentid, r.year
             ORDER BY terms.start_date ASC) AS round_num
        ,terms.start_date
  FROM KIPP_NJ..COHORT$identifiers_long#static r WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates terms WITH(NOLOCK)
    ON r.year = terms.academic_year 
   AND r.schoolid = terms.schoolid
   AND r.exitdate > terms.start_date       
   AND terms.identifier = 'LIT'          
  WHERE r.grade_level <= 8
    AND r.rn = 1  
 )

,fp_end_2014 AS (
  SELECT fp.academic_year
        ,'T3' AS test_round
        ,fp.student_number        
        ,CASE WHEN fp.status = 'Achieved' AND fp.indep_lvl IS NULL THEN fp.read_lvl ELSE fp.indep_lvl END AS read_lvl
        ,CASE WHEN fp.status = 'Achieved' AND fp.indep_lvl IS NULL THEN fp.lvl_num ELSE fp.indep_lvl_num END AS lvl_num
        ,CASE WHEN fp.status = 'Achieved' AND fp.indep_lvl IS NULL THEN fp.read_lvl ELSE fp.indep_lvl END AS indep_lvl
        ,CASE WHEN fp.status = 'Achieved' AND fp.indep_lvl IS NULL THEN fp.lvl_num ELSE fp.indep_lvl_num END AS indep_lvl_num
        ,gleq.GLEQ
        ,fp.instruct_lvl
        ,fp.instruct_lvl_num
        ,fp.fp_keylever
        ,fp.fp_wpmrate
  FROM KIPP_NJ..LIT$test_events#identifiers fp WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
    ON CASE WHEN fp.status = 'Achieved' AND fp.indep_lvl IS NULL THEN fp.read_lvl ELSE fp.indep_lvl END = gleq.read_lvl
   AND gleq.testid = 3273
  WHERE academic_year = 2014
    AND schoolid = 133570965
    AND recent_yr = 1
 )

/* highest acheived test per round for each student */
,tests AS (
  SELECT r.STUDENTID
        ,r.student_number
        ,r.SCHOOLID
        ,r.GRADE_LEVEL
        ,r.academic_year
        ,r.test_round
        ,r.round_num
        ,r.start_date
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.achieved_independent_level, dna.read_lvl) ELSE COALESCE(zomg.read_lvl, achv.read_lvl) END AS read_lvl
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.indep_lvl_num, dna.lvl_num) ELSE COALESCE(zomg.lvl_num, achv.lvl_num) END AS lvl_num
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.achieved_independent_level, dna.indep_lvl) ELSE COALESCE(zomg.indep_lvl, achv.indep_lvl) END AS indep_lvl
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.indep_lvl_num, dna.indep_lvl_num) ELSE COALESCE(zomg.indep_lvl_num, achv.indep_lvl_num) END AS indep_lvl_num
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.instructional_level_tested, dna.instruct_lvl) ELSE COALESCE(zomg.instruct_lvl, achv.instruct_lvl) END AS instruct_lvl
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.instr_lvl_num, dna.instruct_lvl_num) ELSE COALESCE(zomg.instruct_lvl_num, achv.instruct_lvl_num) END AS instruct_lvl_num
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.GLEQ, dna.GLEQ) ELSE COALESCE(zomg.GLEQ, achv.GLEQ) END AS GLEQ
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.reading_rate_wpm, dna.fp_wpmrate) ELSE COALESCE(zomg.fp_wpmrate, achv.fp_wpmrate) END AS fp_wpmrate
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.key_lever, dna.fp_keylever) ELSE COALESCE(zomg.fp_keylever, achv.fp_keylever) END AS fp_keylever
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.instructional_level_tested, dna.dna_lvl) ELSE dna.read_lvl END AS dna_lvl
        ,CASE WHEN r.academic_year >= 2015 THEN COALESCE(fp.instr_lvl_num, dna.dna_lvl_num) ELSE dna.lvl_num END AS dna_lvl_num
        ,dna.unique_id --,CASE WHEN r.academic_year >= 2015 THEN dna.unique_id ELSE achv.unique_id END AS unique_id /* zomg */
        ,ROW_NUMBER() OVER(
           PARTITION BY r.studentid
             ORDER BY r.academic_year DESC, r.round_num DESC) AS meta_achv_round
  FROM roster_scaffold r WITH(NOLOCK) 
  LEFT OUTER JOIN KIPP_NJ..LIT$test_events#identifiers achv WITH(NOLOCK)
    ON r.STUDENTID = achv.studentid      
   AND r.academic_year = achv.academic_year
   AND r.test_round = achv.test_round
   AND (achv.status = 'Achieved')
   AND achv.curr_round = 1
  LEFT OUTER JOIN KIPP_NJ..LIT$test_events#identifiers dna WITH(NOLOCK)
    ON r.STUDENTID = dna.studentid      
   AND r.academic_year = dna.academic_year
   AND r.test_round = dna.test_round
   AND dna.status = 'Did Not Achieve'
   AND dna.curr_round = 1
  LEFT OUTER JOIN KIPP_NJ..LIT$test_events#MS#static fp WITH(NOLOCK)
    ON r.student_number = fp.student_number
   AND r.academic_year = fp.academic_year
   AND r.test_round = fp.test_round
   AND fp.curr_round = 1
  LEFT OUTER JOIN fp_end_2014 zomg WITH(NOLOCK)
    ON r.student_number = zomg.student_number
   AND r.academic_year = zomg.academic_year
   AND r.test_round = zomg.test_round
 )
 
/* falls back to most recently achieved reading level for each round, if NULL */
SELECT academic_year
      ,SCHOOLID
      ,GRADE_LEVEL
      ,STUDENTID
      ,test_round
      ,start_date
      ,read_lvl
      ,instruct_lvl
      ,instruct_lvl_num
      ,indep_lvl
      ,indep_lvl_num
      ,dna_lvl
      ,dna_lvl_num
      ,GLEQ      
      ,lvl_num      
      ,fp_wpmrate
      ,fp_keylever
      ,goal_lvl      
      ,goal_num   
      ,CASE WHEN lvl_num >= goal_num THEN 1 ELSE 0 END AS met_goal
      ,default_goal_lvl      
      ,default_goal_num   
      ,CASE WHEN lvl_num >= default_goal_num THEN 1 ELSE 0 END AS met_default_goal
      ,natl_goal_lvl
      ,natl_goal_num      
      ,CASE WHEN lvl_num >= natl_goal_num THEN 1 ELSE 0 END AS met_natl_goal
      ,levels_behind
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
           ,sub.lvl_num 
           ,sub.instruct_lvl
           ,sub.instruct_lvl_num     
           ,sub.indep_lvl
           ,sub.indep_lvl_num
           ,sub.dna_lvl
           ,sub.dna_lvl_num
           ,sub.GLEQ           
           ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
           ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num                           
           ,goals.read_lvl AS default_goal_lvl
           ,goals.lvl_num AS default_goal_num
           ,indiv.goal AS indiv_goal_lvl
           ,indiv.lvl_num AS indiv_lvl_num
           ,goals.natl_read_lvl AS natl_goal_lvl         
           ,goals.natl_lvl_num AS natl_goal_num
           ,sub.fp_wpmrate
           ,sub.fp_keylever
           ,sub.lvl_num - COALESCE(indiv.lvl_num, goals.lvl_num) AS levels_behind
           ,sub.unique_id      
     FROM
         (
          SELECT tests.academic_year
                ,tests.SCHOOLID
                ,tests.GRADE_LEVEL
                ,tests.STUDENTID      
                ,tests.student_number
                ,tests.test_round 
                ,tests.round_num     
                ,tests.start_date
                ,COALESCE(tests.read_lvl,achv_prev.read_lvl) AS read_lvl
                ,COALESCE(tests.lvl_num,achv_prev.lvl_num) AS lvl_num
                ,COALESCE(tests.indep_lvl,achv_prev.indep_lvl) AS indep_lvl
                ,COALESCE(tests.indep_lvl_num,achv_prev.indep_lvl_num) AS indep_lvl_num
                ,COALESCE(tests.instruct_lvl,achv_prev.instruct_lvl) AS instruct_lvl
                ,COALESCE(tests.instruct_lvl_num,achv_prev.instruct_lvl_num) AS instruct_lvl_num
                ,COALESCE(tests.GLEQ,achv_prev.GLEQ) AS GLEQ
                ,COALESCE(tests.fp_wpmrate,achv_prev.fp_wpmrate) AS fp_wpmrate
                ,COALESCE(tests.fp_keylever,achv_prev.fp_keylever) AS fp_keylever
                ,COALESCE(tests.dna_lvl,achv_prev.dna_lvl) AS dna_lvl
                ,COALESCE(tests.dna_lvl_num,achv_prev.dna_lvl_num) AS dna_lvl_num
                ,COALESCE(tests.unique_id,achv_prev.unique_id) AS unique_id
                --,tests.meta_achv_round
                --,achv_prev.meta_achv_round AS prev_rn
                ,ROW_NUMBER() OVER(
                  PARTITION BY tests.studentid, tests.meta_achv_round
                    ORDER BY achv_prev.meta_achv_round) AS rn
          FROM tests WITH(NOLOCK)
          LEFT OUTER JOIN tests achv_prev WITH(NOLOCK)
            ON tests.STUDENTID = achv_prev.STUDENTID
           AND tests.meta_achv_round < achv_prev.meta_achv_round
           AND achv_prev.read_lvl IS NOT NULL                    
           AND tests.start_date <= CONVERT(DATE,GETDATE()) /* preserves the scaffold but will not carry scores to a future term */
         ) sub
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_normed_goals goals WITH(NOLOCK)
       ON sub.grade_level = goals.grade_level
      AND CASE WHEN sub.academic_year >= 2015 THEN sub.academic_year ELSE 2014 END = goals.norms_year
      AND sub.test_round = goals.test_round
     LEFT OUTER JOIN KIPP_NJ..LIT$individual_goals indiv WITH(NOLOCK)
       ON sub.STUDENT_NUMBER = indiv.student_number
      AND sub.test_round = indiv.test_round
      AND sub.academic_year = indiv.academic_year
     WHERE sub.rn = 1     
    ) sub