USE KIPP_NJ
GO

ALTER VIEW LIT$all_test_events#identifiers AS

WITH all_systems AS (
  SELECT unique_id
        ,testid
        ,is_fp
        ,academic_year
        ,test_round
        ,round_num
        ,test_date
        ,schoolid
        ,grade_level      
        ,studentid
        ,student_number
        ,LASTFIRST
        ,status
        ,read_lvl
        ,lvl_num
        ,dna_lvl
        ,dna_lvl_num
        ,instruct_lvl
        ,instruct_lvl_num
        ,indep_lvl
        ,indep_lvl_num      
        ,GLEQ
        ,color
        ,genre
        ,fp_wpmrate
        ,fp_keylever
        ,coaching_code
        ,NULL AS test_administered_by
  FROM KIPP_NJ..LIT$PS_test_events#identifiers#static ps WITH(NOLOCK)

  UNION ALL

  SELECT unique_id
        ,ps_testid AS testid
        ,0 AS is_fp
        ,academic_year
        ,test_round
        ,round_num
        ,test_date
        ,schoolid
        ,grade_level      
        ,studentid
        ,student_number
        ,LASTFIRST
        ,status
        ,read_lvl
        ,lvl_num
        ,NULL AS dna_lvl
        ,NULL AS dna_lvl_num
        ,NULL AS instruct_lvl
        ,NULL AS instruct_lvl_num
        ,NULL AS indep_lvl
        ,NULL AS indep_lvl_num      
        ,GLEQ
        ,color
        ,NULL AS genre
        ,NULL AS fp_wpmrate
        ,NULL AS fp_keylever
        ,NULL AS coaching_code
        ,recorder AS test_administered_by
  FROM KIPP_NJ..LIT$UCHICAGO_test_events#identifiers#static uc WITH(NOLOCK)

  UNION ALL

  SELECT unique_id
        ,3273 AS testid
        ,1 AS is_fp
        ,academic_year
        ,test_round
        ,round_num
        ,date_administered AS test_date
        ,schoolid
        ,grade_level      
        ,studentid
        ,student_number
        ,LASTFIRST
        ,status
        ,achieved_independent_level AS read_lvl
        ,indep_lvl_num AS lvl_num
        ,instructional_level_tested AS dna_lvl
        ,instr_lvl_num AS dna_lvl_num
        ,instructional_level_tested AS instruct_lvl
        ,instr_lvl_num AS instruct_lvl_num
        ,achieved_independent_level AS indep_lvl
        ,indep_lvl_num      
        ,GLEQ
        ,NULL AS color
        ,fiction_nonfiction AS genre
        ,reading_rate_wpm AS fp_wpmrate
        ,key_lever AS fp_keylever
        ,NULL AS coaching_code
        ,test_administered_by
  FROM KIPP_NJ..LIT$ILLUMINATE_test_events#identifiers#static ill WITH(NOLOCK)
 )

SELECT rs.unique_id
      ,rs.testid
      ,rs.is_fp
      ,rs.academic_year
      ,rs.test_round
      ,rs.round_num
      ,rs.test_date
      ,rs.schoolid
      ,rs.grade_level
      ,rs.studentid
      ,rs.student_number
      ,rs.LASTFIRST
      ,rs.status
      ,rs.read_lvl
      ,rs.lvl_num
      ,rs.dna_lvl
      ,rs.dna_lvl_num
      ,rs.instruct_lvl
      ,rs.instruct_lvl_num
      ,rs.indep_lvl
      ,rs.indep_lvl_num
      ,rs.GLEQ
      ,rs.color
      ,rs.genre
      ,rs.fp_wpmrate
      ,rs.fp_keylever
      ,rs.coaching_code
      ,rs.test_administered_by

      ,goals.read_lvl AS default_goal_lvl
      ,goals.lvl_num AS default_goal_num
      ,goals.natl_read_lvl AS natl_goal_lvl
      ,goals.natl_lvl_num AS natl_goal_num
      
      ,indiv.goal AS indiv_goal_lvl
      ,indiv.lvl_num indiv_lvl_num
      
      ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
      ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num
      
      ,CASE 
        WHEN rs.lvl_num >= COALESCE(indiv.lvl_num, goals.lvl_num) THEN 1 
        WHEN rs.lvl_num < COALESCE(indiv.lvl_num, goals.lvl_num) THEN 0
       END AS met_goal
      ,rs.lvl_num - COALESCE(indiv.lvl_num, goals.lvl_num) AS levels_behind                       

      /* test sequence identifiers */      
      /* base letter for the round */
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.studentid, rs.status, rs.academic_year, rs.test_round
           ORDER BY rs.lvl_num DESC) AS base_round
      /* current letter for the round */
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.studentid, rs.status, rs.academic_year, rs.test_round
           ORDER BY rs.lvl_num DESC) AS curr_round

      /* base letter for the year */
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.studentid, rs.status, rs.academic_year
           ORDER BY rs.round_num ASC, rs.lvl_num DESC) AS base_yr
      /* current letter for the year */
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.studentid, rs.status, rs.academic_year
           ORDER BY rs.round_num DESC, rs.lvl_num DESC) AS curr_yr
      /* current letter for the year, regardless of status */
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.studentid, rs.academic_year
           ORDER BY rs.round_num DESC, rs.test_date DESC, rs.lvl_num DESC) AS recent_yr

      /* base letter, all time */
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.studentid, rs.status
           ORDER BY rs.academic_year ASC, rs.round_num ASC, rs.lvl_num DESC) AS base_all      
      /* current letter, all time */
      ,ROW_NUMBER() OVER(
         PARTITION BY rs.studentid, rs.status
           ORDER BY rs.academic_year DESC, rs.round_num DESC, rs.lvl_num DESC) AS curr_all     
FROM all_systems rs
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_normed_goals goals WITH(NOLOCK)
  ON rs.grade_level = goals.grade_level
 AND CASE WHEN rs.academic_year >= 2015 THEN rs.academic_year ELSE 2014 END = goals.norms_year
 AND rs.test_round = goals.test_round 
LEFT OUTER JOIN KIPP_NJ..LIT$individual_goals indiv WITH(NOLOCK)
  ON rs.STUDENT_NUMBER = indiv.student_number
 AND rs.academic_year = indiv.academic_year
 AND rs.test_round = indiv.test_round