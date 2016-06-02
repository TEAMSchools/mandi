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
        ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN terms.start_date AND terms.end_date THEN 1 ELSE 0 END AS is_curterm
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

,tests AS (
  SELECT *
        ,ROW_NUMBER() OVER(
           PARTITION BY sub.studentid
             ORDER BY sub.academic_year DESC, sub.round_num DESC) AS meta_achv_round
  FROM
      (
       SELECT r.STUDENTID
             ,r.student_number
             ,r.SCHOOLID
             ,r.GRADE_LEVEL
             ,r.academic_year
             ,r.test_round
             ,r.round_num
             ,r.start_date                
             ,r.is_curterm
        
             ,COALESCE(achv.read_lvl, ps.read_lvl) AS read_lvl
             ,COALESCE(achv.lvl_num, ps.lvl_num) AS lvl_num
             ,COALESCE(achv.indep_lvl, ps.indep_lvl) AS indep_lvl
             ,COALESCE(achv.indep_lvl_num, ps.indep_lvl_num) AS indep_lvl_num
             ,COALESCE(achv.instruct_lvl, ps.instruct_lvl) AS instruct_lvl
             ,COALESCE(achv.instruct_lvl_num, ps.instruct_lvl_num) AS instruct_lvl_num
             ,COALESCE(achv.GLEQ, ps.GLEQ) AS GLEQ
             ,COALESCE(achv.fp_wpmrate, ps.fp_wpmrate) AS fp_wpmrate
             ,COALESCE(achv.fp_keylever, ps.fp_keylever) AS fp_keylever
             ,COALESCE(dna.read_lvl, ps.dna_lvl) AS dna_lvl
             ,COALESCE(dna.lvl_num, ps.dna_lvl_num) AS dna_lvl_num
             ,COALESCE(achv.unique_id, ps.unique_id) AS achv_unique_id
             ,COALESCE(dna.unique_id, ps.unique_id) AS dna_unique_id
       FROM roster_scaffold r WITH(NOLOCK) 
       LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static ps WITH(NOLOCK)
         ON r.STUDENTID = ps.studentid      
        AND r.academic_year = ps.academic_year
        AND r.test_round = ps.test_round
        AND ps.status = 'Mixed'
        AND ps.curr_round = 1
       LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static achv WITH(NOLOCK)
         ON r.STUDENTID = achv.studentid      
        AND r.academic_year = achv.academic_year
        AND r.test_round = achv.test_round
        AND achv.status = 'Achieved'
        AND achv.curr_round = 1
       LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static dna WITH(NOLOCK)
         ON r.STUDENTID = dna.studentid      
        AND r.academic_year = dna.academic_year
        AND r.test_round = dna.test_round
        AND dna.status = 'Did Not Achieve'
        AND dna.curr_round = 1
       WHERE r.academic_year >= 2015

       UNION ALL

       /* historical data */
       SELECT r.STUDENTID
             ,r.student_number
             ,r.SCHOOLID
             ,r.GRADE_LEVEL
             ,r.academic_year
             ,r.test_round
             ,r.round_num
             ,r.start_date
             ,0 AS is_curterm

             ,achv.read_lvl
             ,achv.lvl_num
             ,achv.indep_lvl
             ,achv.indep_lvl_num
             ,achv.instruct_lvl
             ,achv.instruct_lvl_num
             ,achv.GLEQ
             ,achv.fp_wpmrate
             ,achv.fp_keylever
             ,dna.read_lvl AS dna_lvl
             ,dna.lvl_num AS dna_lvl_num
             ,achv.unique_id AS achv_unique_id
             ,dna.unique_id AS dna_unique_id
       FROM roster_scaffold r WITH(NOLOCK) 
       LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static achv WITH(NOLOCK)
         ON r.STUDENTID = achv.studentid      
        AND r.academic_year = achv.academic_year
        AND r.test_round = achv.test_round
        AND achv.status = 'Achieved'
        AND achv.curr_round = 1
       LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static dna WITH(NOLOCK)
         ON r.STUDENTID = dna.studentid      
        AND r.academic_year = dna.academic_year
        AND r.test_round = dna.test_round
        AND dna.status = 'Did Not Achieve'
        AND dna.curr_round = 1    
       WHERE r.academic_year <= 2014
         AND NOT (r.academic_year = 2014 AND r.schoolid = 133570965 AND r.test_round = 'T3')

       UNION ALL

       SELECT fp.STUDENTID
             ,fp.student_number
             ,fp.SCHOOLID
             ,fp.GRADE_LEVEL
             ,fp.academic_year
             ,'T3' AS test_round
             ,4 AS round_num
             ,'2015-06-05' AS start_date
             ,0 AS is_curterm

             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.read_lvl, fp.indep_lvl) ELSE fp.indep_lvl END AS read_lvl
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.lvl_num, fp.indep_lvl_num) ELSE fp.indep_lvl_num END AS lvl_num
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.read_lvl, fp.indep_lvl) ELSE fp.indep_lvl END AS indep_lvl
             ,CASE WHEN fp.status = 'Achieved' THEN COALESCE(fp.lvl_num, fp.indep_lvl_num) ELSE fp.indep_lvl_num END AS indep_lvl_num        
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.read_lvl
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN gleq.instruct_lvl
               ELSE COALESCE(fp.instruct_lvl, gleq.instruct_lvl)
              END AS instruct_lvl
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.lvl_num
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN (gleq.fp_lvl_num + 1)
               ELSE COALESCE(fp.instruct_lvl_num, (gleq.fp_lvl_num + 1))
              END AS instruct_lvl_num
             ,gleq.GLEQ        
             ,fp.fp_wpmrate
             ,fp.fp_keylever
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.read_lvl
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN gleq.instruct_lvl
               ELSE COALESCE(fp.instruct_lvl, gleq.instruct_lvl)
              END AS dna_lvl
             ,CASE
               WHEN fp.status = 'Did Not Achieve' AND fp.instruct_lvl = fp.indep_lvl THEN fp.lvl_num
               WHEN fp.status = 'Achieved' AND fp.instruct_lvl = fp.indep_lvl THEN (gleq.fp_lvl_num + 1)
               ELSE COALESCE(fp.instruct_lvl_num, (gleq.fp_lvl_num + 1))
              END AS dna_lvl_num
             ,fp.unique_id AS achv_unique_id
             ,fp.unique_id AS dna_unique_id            
       FROM KIPP_NJ..LIT$all_test_events#identifiers#static fp WITH(NOLOCK)       
       LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
         ON CASE WHEN fp.status = 'Achieved' AND fp.indep_lvl IS NULL THEN fp.read_lvl ELSE fp.indep_lvl END = gleq.read_lvl
        AND gleq.testid = 3273
       WHERE fp.academic_year = 2014
         AND fp.schoolid = 133570965
         AND fp.recent_yr = 1    
      ) sub
 )

/* falls back to most recently achieved reading level for each round, if NULL */
SELECT academic_year
      ,SCHOOLID
      ,GRADE_LEVEL
      ,STUDENTID
      ,student_number
      ,test_round
      ,start_date
      ,is_curterm

      ,read_lvl
      ,instruct_lvl
      ,instruct_lvl_num
      ,indep_lvl
      ,indep_lvl_num
      ,dna_lvl
      ,dna_lvl_num
      ,prev_read_lvl
      ,prev_lvl_num
      ,CASE 
        WHEN lvl_num > prev_lvl_num THEN 1 
        WHEN lvl_num <= prev_lvl_num THEN 0        
       END AS moved_levels
      ,GLEQ      
      ,lvl_num      
      ,fp_wpmrate
      ,fp_keylever
      ,goal_lvl      
      ,goal_num   
      ,CASE         
        WHEN lvl_num >= goal_num THEN 1 
        WHEN lvl_num < goal_num THEN 0        
       END AS met_goal
      ,default_goal_lvl      
      ,default_goal_num   
      ,CASE
        WHEN lvl_num >= default_goal_num THEN 1 
        WHEN lvl_num < default_goal_num THEN 0
       END AS met_default_goal
      ,natl_goal_lvl
      ,natl_goal_num      
      ,CASE 
        WHEN lvl_num >= natl_goal_num THEN 1 
        WHEN lvl_num < natl_goal_num THEN 0
       END AS met_natl_goal
      ,CASE
        WHEN lvl_num >= goal_num THEN 'On Track'
        WHEN lvl_num >= natl_goal_num THEN 'Off Track'
        WHEN lvl_num < natl_goal_num THEN 'ARFR'
       END AS goal_status
      ,levels_behind
      ,achv_unique_id
      ,dna_unique_id
      ,is_new_test
FROM
    (
     SELECT sub.academic_year
           ,sub.SCHOOLID
           ,sub.GRADE_LEVEL
           ,sub.STUDENTID
           ,sub.student_number
           ,sub.test_round
           ,sub.start_date
           ,sub.is_curterm

           ,sub.read_lvl           
           ,sub.lvl_num            
           ,sub.instruct_lvl
           ,sub.instruct_lvl_num     
           ,sub.indep_lvl
           ,sub.indep_lvl_num
           ,sub.dna_lvl
           ,sub.dna_lvl_num
           ,LAG(sub.read_lvl, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.academic_year ASC, sub.start_date ASC) AS prev_read_lvl
           ,LAG(sub.lvl_num, 1) OVER(PARTITION BY sub.student_number ORDER BY sub.academic_year ASC, sub.start_date ASC) AS prev_lvl_num
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
           ,sub.achv_unique_id      
           ,sub.dna_unique_id      
           ,CASE WHEN sub.academic_year = lit.academic_year AND sub.round_num = lit.round_num THEN 1 ELSE 0 END AS is_new_test
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
                ,tests.is_curterm

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
                ,COALESCE(tests.achv_unique_id,achv_prev.achv_unique_id) AS achv_unique_id
                ,COALESCE(tests.dna_unique_id,achv_prev.dna_unique_id) AS dna_unique_id
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
     LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static lit WITH(NOLOCK)
       ON sub.achv_unique_id = lit.unique_id
      AND lit.status != 'Did Not Achieve'
     WHERE sub.rn = 1     
    ) sub