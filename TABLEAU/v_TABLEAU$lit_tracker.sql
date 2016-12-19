USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker AS

/* student identifiers */
SELECT co.school_name
      ,co.school_level
      ,co.student_number
      ,co.lastfirst AS student_name
      ,co.grade_level      
      ,co.team
      ,co.advisor
      ,co.year AS academic_year            
      ,co.SPEDLEP AS IEP_status      
      ,co.enroll_status      
      ,CASE WHEN sp.programid IS NOT NULL THEN 1 ELSE 0 END AS is_americorps
      
      ,CONVERT(VARCHAR(8),CASE
        WHEN co.year >= 2015 THEN REPLACE(term.hex,'RT','Q') 
        ELSE REPLACE(term.hex,'RT','Hex ') 
       END) AS AR_term      
      ,CONVERT(VARCHAR(8),term.lit) AS lit_term      
      
      /* test identifiers */      
      ,CONVERT(VARCHAR(8),achv.read_lvl) AS read_lvl
      ,achv.lvl_num
      ,CONVERT(VARCHAR(8),achv.dna_lvl) AS dna_lvl
      ,achv.dna_lvl_num
      ,CONVERT(VARCHAR(8),achv.instruct_lvl) AS instruct_lvl
      ,achv.instruct_lvl_num
      ,CONVERT(VARCHAR(8),achv.indep_lvl) AS indep_lvl
      ,achv.indep_lvl_num
      ,CONVERT(VARCHAR(8),achv.prev_read_lvl) AS prev_read_lvl
      ,achv.prev_lvl_num
      ,achv.GLEQ      
      ,CONVERT(VARCHAR(16),achv.fp_keylever) AS fp_keylever
      ,achv.is_new_test
      ,achv.moved_levels      
      ,SUM(CASE 
            WHEN achv.test_round IN ('DR','BOY') THEN NULL 
            ELSE achv.moved_levels 
           END) OVER(PARTITION BY co.student_number, co.year ORDER BY achv.start_date ASC) AS n_levels_moved_y1

      ,testid.test_date
      ,CONVERT(VARCHAR(16),testid.status) AS status
      ,CONVERT(VARCHAR(16),testid.color) AS color
      ,CONVERT(VARCHAR(16),testid.genre) AS genre
      ,testid.is_fp
      ,testid.test_administered_by

      /* progress to goals */
      ,achv.is_curterm
      ,CONVERT(VARCHAR(16),achv.goal_lvl) AS goal_lvl
      ,achv.goal_num
      ,CONVERT(VARCHAR(16),achv.natl_goal_lvl) AS natl_goal_lvl
      ,achv.natl_goal_num
      ,CONVERT(VARCHAR(16),achv.default_goal_lvl) AS default_goal_lvl
      ,achv.default_goal_num      
      ,achv.lvl_num - achv.goal_num AS distance_from_goal            
      ,CONVERT(FLOAT,achv.met_goal) AS met_goal
      ,CONVERT(FLOAT,achv.met_natl_goal) AS met_natl_goal
      ,CONVERT(FLOAT,achv.met_default_goal) AS met_default_goal  
      ,achv.achv_unique_id AS unique_id
      ,achv.dna_unique_id
      
      /* component data */      
      ,CONVERT(VARCHAR(32),long.domain) AS component_domain
      ,CONVERT(VARCHAR(32),long.label) AS component_strand
      ,CONVERT(VARCHAR(32),long.specific_label) AS component_strand_specific
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
 AND long.status != 'Achieved'
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
  ON co.STUDENT_NUMBER = ar.student_number
 AND co.year = ar.academic_year
 AND term.hex = ar.time_period_name 
 AND ar.start_date <= CONVERT(DATE,GETDATE())
 AND ar.N_total > 0
LEFT OUTER JOIN KIPP_NJ..PS$SPENROLLMENTS#static sp WITH(NOLOCK)
  ON co.studentid = sp.studentid
 AND co.year = sp.academic_year
 AND sp.programid = 5224
WHERE co.rn = 1
  AND co.grade_level != 99
  AND co.year >= KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.reporting_schoolid != 5173

UNION ALL

SELECT school_name
      ,school_level
      ,student_number
      ,student_name
      ,grade_level
      ,team
      ,advisor
      ,academic_year
      ,IEP_status
      ,enroll_status
      ,0 AS is_americorps
      ,AR_term
      ,lit_term
      ,read_lvl
      ,lvl_num
      ,dna_lvl
      ,dna_lvl_num
      ,instruct_lvl
      ,instruct_lvl_num
      ,indep_lvl
      ,indep_lvl_num
      ,prev_read_lvl
      ,prev_lvl_num
      ,GLEQ
      ,fp_keylever
      ,is_new_test
      ,moved_levels
      ,n_levels_moved_y1
      ,test_date
      ,status
      ,color
      ,genre
      ,is_fp
      ,NULL AS test_administered_by
      ,is_curterm
      ,goal_lvl
      ,goal_num
      ,natl_goal_lvl
      ,natl_goal_num
      ,default_goal_lvl
      ,default_goal_num
      ,distance_from_goal
      ,met_goal
      ,met_natl_goal
      ,met_default_goal
      ,unique_id
      ,dna_unique_id
      ,component_domain
      ,component_strand
      ,component_strand_specific
      ,component_score
      ,component_benchmark
      ,component_prof
      ,component_margin
      ,dna_filter
      ,words_goal
      ,words
      ,mastery
      ,pct_fiction
      ,avg_lexile
      ,N_passed
      ,N_total
      ,status_words
      ,rn_test
FROM KIPP_NJ..TABLEAU$lit_tracker#archive WITH(NOLOCK)