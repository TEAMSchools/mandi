USE KIPP_NJ
GO

ALTER VIEW QA$lit_test_entry_audit AS

/* student identifiers */
SELECT co.school_name
      ,co.school_level
      ,CASE WHEN achv.start_date >= CONVERT(DATE,GETDATE()) THEN NULL ELSE co.student_number END AS student_number
      ,co.lastfirst AS student_name
      ,co.grade_level      
      ,co.team      
      ,co.year AS academic_year            
      ,co.SPEDLEP AS IEP_status      
      ,co.enroll_status            
      ,term.lit AS lit_term
      ,CASE
        WHEN co.year >= 2015 THEN REPLACE(term.hex,'RT','Q') 
        ELSE REPLACE(term.hex,'RT','Hex ') 
       END AS AR_term 
      
      /* test identifiers */      
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.dna_lvl
      ,achv.dna_lvl_num
      ,achv.instruct_lvl
      ,achv.instruct_lvl_num
      ,achv.indep_lvl
      ,achv.indep_lvl_num
      ,achv.prev_read_lvl
      ,achv.prev_lvl_num
      ,achv.GLEQ      
      ,achv.fp_keylever
      ,achv.is_new_test
      ,achv.moved_levels      
      ,SUM(CASE 
            WHEN achv.test_round IN ('DR','BOY') THEN NULL 
            ELSE achv.moved_levels 
           END) OVER(PARTITION BY co.student_number, co.year ORDER BY achv.start_date ASC) AS n_levels_moved_y1

      ,testid.test_date
      ,testid.status
      ,testid.color
      ,testid.genre
      ,testid.is_fp
      ,dna.test_date AS dna_date
      ,CASE                      
        WHEN achv.test_round IN ('BOY','DR') AND testid.test_round IN ('EOY','Q4','T3') AND achv.academic_year = testid.academic_year + 1 THEN 1
        WHEN testid.test_date >= achv.start_date THEN 1        
        WHEN achv.test_round IN ('BOY','DR') AND dna.test_round IN ('EOY','Q4','T3') AND achv.academic_year = dna.academic_year + 1 THEN 2
        WHEN dna.test_date >= achv.start_date THEN 2        
        ELSE 3
       END AS test_audit

      /* progress to goals */
      ,achv.is_curterm
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.natl_goal_lvl
      ,achv.natl_goal_num
      ,achv.default_goal_lvl
      ,achv.default_goal_num      
      ,achv.lvl_num - achv.goal_num AS distance_from_goal            
      ,achv.met_goal AS met_goal
      ,achv.met_natl_goal AS met_natl_goal
      ,achv.met_default_goal AS met_default_goal  
      ,achv.achv_unique_id
      ,achv.dna_unique_id

FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_REP_term_map term WITH(NOLOCK)
  ON co.school_level = term.school_level
 AND co.year BETWEEN term.min_year AND term.max_year 
LEFT OUTER JOIN KIPP_NJ..LIT$achieved_by_round#static achv WITH(NOLOCK)
  ON co.studentid = achv.STUDENTID
 AND co.year = achv.academic_year
 AND term.lit = achv.test_round
 AND achv.start_date <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static testid WITH(NOLOCK)
  ON co.studentid = testid.studentid
 AND achv.achv_unique_id = testid.unique_id 
LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static dna WITH(NOLOCK)
  ON co.studentid = dna.studentid
 AND achv.dna_unique_id = dna.unique_id 
WHERE co.rn = 1
  AND co.grade_level != 99
  AND co.year >= 2010