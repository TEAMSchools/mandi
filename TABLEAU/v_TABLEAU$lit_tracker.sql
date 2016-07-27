USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker AS

/* student identifiers */
SELECT co.school_name
      ,co.school_level
      ,CASE WHEN achv.start_date >= CONVERT(DATE,GETDATE()) THEN NULL ELSE co.student_number END AS student_number
      ,co.lastfirst AS student_name
      ,co.grade_level      
      ,co.team
      ,co.advisor
      ,co.year AS academic_year            
      ,co.SPEDLEP AS IEP_status      
      ,co.enroll_status      
      ,CASE
        WHEN co.year >= 2015 THEN REPLACE(term.hex,'RT','Q') 
        ELSE REPLACE(term.hex,'RT','Hex ') 
       END AS AR_term      
      ,term.lit AS lit_term
      
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

      /* progress to goals */
      ,achv.is_curterm
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.natl_goal_lvl
      ,achv.natl_goal_num
      ,achv.default_goal_lvl
      ,achv.default_goal_num      
      ,achv.lvl_num - achv.goal_num AS distance_from_goal            
      ,CONVERT(FLOAT,achv.met_goal) AS met_goal
      ,CONVERT(FLOAT,achv.met_natl_goal) AS met_natl_goal
      ,CONVERT(FLOAT,achv.met_default_goal) AS met_default_goal  
      ,achv.achv_unique_id AS unique_id
      ,achv.dna_unique_id
      
      /* component data */      
      ,long.domain AS component_domain
      ,long.label AS component_strand
      ,long.specific_label AS component_strand_specific
      ,long.score AS component_score
      ,long.benchmark AS component_benchmark
      ,long.is_prof AS component_prof
      ,long.margin AS component_margin            
      ,long.dna_filter

      /* AR */
      ,CASE WHEN ar.words_goal < 0 THEN NULL ELSE ar.words_goal END AS words_goal
      ,ar.words
      ,ar.mastery
      ,ar.pct_fiction
      ,ar.avg_lexile
      ,ar.N_passed
      ,ar.N_total
      ,ar.stu_status_words AS status_words

      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.year, term.lit, term.hex, achv.achv_unique_id
           ORDER BY achv.achv_unique_id) AS rn_test
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
LEFT OUTER JOIN KIPP_NJ..LIT$readingscores_long#static long WITH(NOLOCK)
  ON co.studentid = long.studentid
 AND achv.dna_unique_id = long.unique_id
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
  ON co.STUDENT_NUMBER = ar.student_number
 AND co.year = ar.academic_year
 AND term.hex = ar.time_period_name 
 AND ar.start_date <= CONVERT(DATE,GETDATE())
WHERE co.rn = 1
  AND co.grade_level != 99
  AND co.year >= 2010