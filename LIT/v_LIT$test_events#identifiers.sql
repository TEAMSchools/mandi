USE KIPP_NJ
GO

ALTER VIEW LIT$test_events#identifiers AS

WITH ps_readingscores AS (
  SELECT rs.unique_id
        ,rs.testid   
        ,CASE WHEN rs.testid = 3273 THEN 1 ELSE 0 END AS is_fp
      
        /* date stuff */
        ,COALESCE(rs.academic_year, dates.academic_year) AS academic_year
        ,CASE
          WHEN (co.grade_level >= 5 OR (co.grade_level = 4 AND co.schoolid = 73252)) AND COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR') THEN 'BOY' 
          WHEN co.grade_level <= 4 AND COALESCE(rs.test_round, dates.time_per_name) = 'Diagnostic' THEN 'DR'              
          ELSE COALESCE(rs.test_round, dates.time_per_name)
         END AS test_round
        ,CASE
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 1
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T1','Q1') THEN 2
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY','T2','Q2') THEN 3
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T3','Q3') THEN 4
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('EOY','Q4') THEN 5       
         END AS round_num
        ,rs.test_date
           
        /* student identifiers */
        ,rs.schoolid
        ,co.grade_level
        ,co.COHORT 
        ,rs.studentid
        ,co.student_number
        ,co.LASTFIRST
      
        /* test identifiers */      
        /* In 2015-2016, we changed STEP entry to  only be DNA levels, so Achieved level doesn't correlate with testid anymore */           
        ,COALESCE(rs.status,'Did Not Achieve') AS status           
        ,CASE WHEN co.year >= 2015 THEN rs.read_lvl ELSE gleq.read_lvl END AS read_lvl
        ,CASE WHEN co.year >= 2015 THEN achv.lvl_num ELSE gleq.lvl_num END AS lvl_num
        ,CASE 
          WHEN co.year >= 2015 AND rs.testid != 3273 THEN stepdna.read_lvl 
          WHEN co.year >= 2015 AND rs.testid = 3273 THEN rs.instruct_lvl
          ELSE NULL 
         END AS dna_lvl
        ,CASE 
          WHEN co.year >= 2015 AND rs.testid != 3273 THEN stepdna.lvl_num 
          WHEN co.year >= 2015 AND rs.testid = 3273 THEN instr.lvl_num
          ELSE NULL 
         END AS dna_lvl_num
        ,instr.read_lvl AS instruct_lvl
        ,instr.lvl_num AS instruct_lvl_num
        ,ind.read_lvl AS indep_lvl
        ,ind.lvl_num AS indep_lvl_num

        /* progress to goals */      
        ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
        ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num      
        ,goals.read_lvl AS default_goal_lvl
        ,goals.lvl_num AS default_goal_num
        ,goals.natl_read_lvl AS natl_goal_lvl         
        ,goals.natl_lvl_num AS natl_goal_num
        ,indiv.goal AS indiv_goal_lvl
        ,indiv.lvl_num AS indiv_lvl_num           
        ,CASE WHEN gleq.lvl_num >= COALESCE(indiv.lvl_num, goals.lvl_num) THEN 1 ELSE 0 END AS met_goal
        ,gleq.lvl_num - COALESCE(indiv.lvl_num, goals.lvl_num) AS levels_behind                 

        /* test metadata */
        ,gleq.GLEQ
        ,rs.color
        ,rs.genre
        ,rs.fp_wpmrate
        ,rs.fp_keylever      
        ,rs.coaching_code
  FROM KIPP_NJ..LIT$readingscores#static rs WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dates WITH(NOLOCK)
    ON rs.schoolid = dates.schoolid
   AND rs.test_date BETWEEN dates.start_date AND dates.end_date
   AND dates.identifier = 'LIT'
  JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON rs.studentid = co.studentid
   AND COALESCE(rs.academic_year, dates.academic_year) = co.year /* before 2014-2015, rs.academic_year did not exist, so join to dates table */
   AND co.rn = 1
  JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
    ON ((co.year <= 2014 AND gleq.lvl_num > -1 AND ((rs.testid != 3273 AND rs.testid = gleq.testid) /* before 2015-2016, JOIN Achieved STEP on testid */
                           OR (rs.testid = 3273 AND rs.read_lvl = gleq.read_lvl))) /* before 2015-2016, JOIN Achieved F&P on reading level */
     OR (co.year >= 2015 AND rs.read_lvl = gleq.read_lvl)) /* 2015-2016 onward, JOIN everything on reading level */
   
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq stepdna WITH(NOLOCK)
    ON (co.year >= 2015 AND rs.testid != 3273 AND rs.testid = stepdna.testid AND stepdna.lvl_num > -1)
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq achv WITH(NOLOCK)
    ON rs.read_lvl = achv.read_lvl      
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr WITH(NOLOCK)
    ON rs.instruct_lvl = instr.read_lvl
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq ind WITH(NOLOCK)
    ON COALESCE(rs.indep_lvl, rs.read_lvl) = ind.read_lvl
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_normed_goals goals WITH(NOLOCK)
    ON co.grade_level = goals.grade_level
   AND CASE WHEN co.year >= 2015 THEN co.year ELSE 2014 END = goals.norms_year
   AND CASE
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'BOY') THEN 'DR'           
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'           
        ELSE COALESCE(rs.test_round, dates.time_per_name)
       END = goals.test_round 
  LEFT OUTER JOIN KIPP_NJ..LIT$individual_goals indiv WITH(NOLOCK)
    ON co.STUDENT_NUMBER = indiv.student_number
   AND co.year = indiv.academic_year
   AND CASE
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'BOY') THEN 'DR'           
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'           
        ELSE COALESCE(rs.test_round, dates.time_per_name)
       END = indiv.test_round  

  UNION ALL

  /* Synthetic Pre-DNA Achieved */
  SELECT rs.unique_id
        ,rs.testid   
        ,CASE WHEN rs.testid = 3273 THEN 1 ELSE 0 END AS is_fp
      
        /* date stuff */
        ,COALESCE(rs.academic_year, dates.academic_year) AS academic_year
        ,CASE
          WHEN (co.grade_level >= 5 OR (co.grade_level = 4 AND co.schoolid = 73252)) AND COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR') THEN 'BOY' 
          WHEN co.grade_level <= 4 AND COALESCE(rs.test_round, dates.time_per_name) = 'Diagnostic' THEN 'DR'              
          ELSE COALESCE(rs.test_round, dates.time_per_name)
         END AS test_round
        ,CASE
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 1
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T1','Q1') THEN 2
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY','T2','Q2') THEN 3
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T3','Q3') THEN 4
          WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('EOY','Q4') THEN 5       
         END AS round_num
        ,rs.test_date
           
        /* student identifiers */
        ,rs.schoolid
        ,co.grade_level
        ,co.COHORT 
        ,rs.studentid
        ,co.student_number
        ,co.LASTFIRST
      
        /* test identifiers */      
        ,'Achieved' AS status
        ,'Pre DNA' AS read_lvl           
        ,-1 AS lvl_num
        ,'Pre' AS dna_lvl
        ,0 AS dna_lvl_num
        ,COALESCE(rs.instruct_lvl, 'A') AS instruct_lvl
        ,0 AS instruct_lvl_num
        ,COALESCE(rs.indep_lvl, 'AA') AS indep_lvl
        ,-1 AS indep_lvl_num

        /* progress to goals */      
        ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
        ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num      
        ,goals.read_lvl AS default_goal_lvl
        ,goals.lvl_num AS default_goal_num
        ,goals.natl_read_lvl AS natl_goal_lvl         
        ,goals.natl_lvl_num AS natl_goal_num
        ,indiv.goal AS indiv_goal_lvl
        ,indiv.lvl_num AS indiv_lvl_num
        ,CASE WHEN -1 >= COALESCE(indiv.lvl_num, goals.lvl_num) THEN 1 ELSE 0 END AS met_goal
        ,-1 - COALESCE(indiv.lvl_num, goals.lvl_num) AS levels_behind                 

        /* test metadata */
        ,-1 AS GLEQ
        ,rs.color
        ,rs.genre
        ,rs.fp_wpmrate
        ,rs.fp_keylever      
        ,rs.coaching_code
  FROM KIPP_NJ..LIT$readingscores#static rs WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dates WITH(NOLOCK)
    ON rs.schoolid = dates.schoolid
   AND rs.test_date BETWEEN dates.start_date AND dates.end_date
   AND dates.identifier = 'LIT'
  JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON rs.studentid = co.studentid
   AND COALESCE(rs.academic_year, dates.academic_year) = co.year 
   AND co.rn = 1     
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_normed_goals goals WITH(NOLOCK)
    ON co.grade_level = goals.grade_level
   AND CASE WHEN co.year >= 2015 THEN co.year ELSE 2014 END = goals.norms_year
   AND CASE
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'BOY') THEN 'DR'           
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'           
        ELSE COALESCE(rs.test_round, dates.time_per_name)
       END = goals.test_round 
  LEFT OUTER JOIN KIPP_NJ..LIT$individual_goals indiv WITH(NOLOCK)
    ON co.STUDENT_NUMBER = indiv.student_number
   AND co.year = indiv.academic_year
   AND CASE
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'BOY') THEN 'DR'           
        WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'           
        ELSE COALESCE(rs.test_round, dates.time_per_name)
       END = indiv.test_round  
  WHERE rs.testid = 3280
    AND rs.status = 'Did Not Achieve'
    AND rs.academic_year <= 2014
 )

,illuminate AS (
  SELECT CONCAT('IL',fp.BINI_ID) AS unique_id
        ,3273 AS testid   
        ,1 AS is_fp
      
        /* date stuff */
        ,fp.academic_year
        ,fp.test_round
        ,fp.round_num
        ,fp.date_administered AS test_Date
           
        /* student identifiers */
        ,co.schoolid
        ,co.grade_level
        ,co.COHORT 
        ,co.studentid
        ,co.student_number
        ,co.LASTFIRST
      
        /* test identifiers */      
        /* In 2015-2016, we changed STEP entry to  only be DNA levels, so Achieved level doesn't correlate with testid anymore */           
        ,'Did Not Achieve' AS status
        ,fp.achieved_independent_level AS read_lvl
        ,fp.indep_lvl_num AS lvl_num
        ,fp.instructional_level_tested AS dna_lvl
        ,fp.instr_lvl_num AS dna_lvl_num
        ,fp.instructional_level_tested AS instruct_lvl
        ,fp.instr_lvl_num AS instruct_lvl_num
        ,fp.achieved_independent_level AS indep_lvl
        ,fp.indep_lvl_num AS indep_lvl_num

        /* progress to goals */      
        ,NULL AS goal_lvl
        ,NULL AS goal_num      
        ,NULL AS default_goal_lvl
        ,NULL AS default_goal_num
        ,NULL AS natl_goal_lvl         
        ,NULL AS natl_goal_num
        ,NULL AS indiv_goal_lvl
        ,NULL AS indiv_lvl_num           
        ,NULL AS met_goal
        ,NULL AS levels_behind                 

        /* test metadata */
        ,fp.GLEQ
        ,NULL AS color
        ,NULL AS genre
        ,fp.reading_rate_wpm AS fp_wpmrate
        ,fp.key_lever AS fp_keylever      
        ,NULL AS coaching_code
  FROM KIPP_NJ..LIT$test_events#MS#static fp WITH(NOLOCK)
  JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON fp.student_number = co.student_number
   AND fp.academic_year = co.year
   AND co.rn = 1
 )

,all_systems AS (
  SELECT unique_id
        ,testid
        ,is_fp
        ,academic_year
        ,test_round
        ,round_num
        ,test_date
        ,schoolid
        ,grade_level
        ,COHORT
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
        ,goal_lvl
        ,goal_num
        ,default_goal_lvl
        ,default_goal_num
        ,natl_goal_lvl
        ,natl_goal_num
        ,indiv_goal_lvl
        ,indiv_lvl_num
        ,met_goal
        ,levels_behind
        ,GLEQ
        ,color
        ,genre
        ,fp_wpmrate
        ,fp_keylever
        ,coaching_code
  FROM ps_readingscores 
  UNION ALL
  SELECT unique_id
        ,testid
        ,is_fp
        ,academic_year
        ,test_round
        ,round_num
        ,test_date
        ,schoolid
        ,grade_level
        ,COHORT
        ,studentid
        ,student_number
        ,LASTFIRST
        ,'Did Not Achieve' AS status /* temp fix -- DNA tests coming through as Achieved because of PS > STEP Tool change */
        ,CONVERT(VARCHAR,read_lvl) AS read_lvl
        ,lvl_num
        ,CONVERT(VARCHAR,dna_lvl) AS dna_lvl
        ,dna_lvl_num
        ,CONVERT(VARCHAR,instruct_lvl) AS instruct_lvl
        ,instruct_lvl_num
        ,CONVERT(VARCHAR,indep_lvl) AS indep_lvl
        ,indep_lvl_num
        ,CONVERT(VARCHAR,goal_lvl) AS goal_lvl
        ,goal_num
        ,CONVERT(VARCHAR,default_goal_lvl) AS default_goal_lvl
        ,default_goal_num
        ,CONVERT(VARCHAR,natl_goal_lvl) AS natl_goal_lvl
        ,natl_goal_num
        ,CONVERT(VARCHAR,indiv_goal_lvl) AS indiv_goal_lvl
        ,indiv_lvl_num
        ,met_goal
        ,levels_behind
        ,GLEQ
        ,color
        ,CONVERT(VARCHAR,genre) AS genre
        ,CONVERT(VARCHAR,fp_wpmrate) AS fp_wpmrate
        ,CONVERT(VARCHAR,fp_keylever) AS fp_keylever
        ,CONVERT(VARCHAR,coaching_code) AS coaching_code
  FROM KIPP_NJ..LIT$STEP_Level_Assessment_Data#UChicago#static WITH(NOLOCK)
  WHERE status != 'Did Not Achieve' /* temp fix -- DNA tests coming through as Achieved because of PS > STEP Tool change */
  
  UNION ALL
  
  SELECT unique_id
        ,testid
        ,is_fp
        ,academic_year
        ,test_round
        ,round_num
        ,test_date
        ,schoolid
        ,grade_level
        ,COHORT
        ,studentid
        ,student_number
        ,LASTFIRST
        ,'Did Not Achieve' AS status /* temp fix -- DNA tests coming through as Achieved because of PS > STEP Tool change */
        ,CONVERT(VARCHAR,read_lvl) AS read_lvl
        ,lvl_num
        ,CONVERT(VARCHAR,dna_lvl) AS dna_lvl
        ,dna_lvl_num
        ,CONVERT(VARCHAR,instruct_lvl) AS instruct_lvl
        ,instruct_lvl_num
        ,CONVERT(VARCHAR,indep_lvl) AS indep_lvl
        ,indep_lvl_num
        ,CONVERT(VARCHAR,goal_lvl) AS goal_lvl
        ,goal_num
        ,CONVERT(VARCHAR,default_goal_lvl) AS default_goal_lvl
        ,default_goal_num
        ,CONVERT(VARCHAR,natl_goal_lvl) AS natl_goal_lvl
        ,natl_goal_num
        ,CONVERT(VARCHAR,indiv_goal_lvl) AS indiv_goal_lvl
        ,indiv_lvl_num
        ,met_goal
        ,levels_behind
        ,GLEQ
        ,color
        ,CONVERT(VARCHAR,genre) AS genre
        ,CONVERT(VARCHAR,fp_wpmrate) AS fp_wpmrate
        ,CONVERT(VARCHAR,fp_keylever) AS fp_keylever
        ,CONVERT(VARCHAR,coaching_code) AS coaching_code
  FROM illuminate
 )

SELECT unique_id
      ,testid
      ,is_fp
      ,academic_year
      ,test_round
      ,round_num
      ,test_date
      ,schoolid
      ,grade_level
      ,COHORT
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
      ,goal_lvl
      ,goal_num
      ,default_goal_lvl
      ,default_goal_num
      ,natl_goal_lvl         
      ,natl_goal_num
      ,indiv_goal_lvl
      ,indiv_lvl_num
      ,met_goal
      ,CASE
        WHEN CONVERT(INT,lvl_num) >= CONVERT(INT,goal_num) THEN 'On Track'
        WHEN CONVERT(INT,lvl_num) >= CONVERT(INT,natl_goal_num) THEN 'Off Track'
        WHEN CONVERT(INT,lvl_num) < CONVERT(INT,natl_goal_num) THEN 'ARFR'
       END AS goal_ontrack_status
      ,levels_behind
      ,ROUND(GLEQ,1) AS GLEQ
      ,color
      ,genre
      ,fp_wpmrate
      ,fp_keylever
      ,coaching_code            
       
      /* test sequence identifiers */      
      /* base letter for the round */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, status, academic_year, test_round
           ORDER BY lvl_num DESC) AS base_round
      /* current letter for the round */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, status, academic_year, test_round
           ORDER BY lvl_num DESC) AS curr_round

      /* base letter for the year */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, status, academic_year
           ORDER BY round_num ASC, lvl_num DESC) AS base_yr
      /* current letter for the year */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, status, academic_year
           ORDER BY round_num DESC, lvl_num DESC) AS curr_yr
      /* current letter for the year, regardless of status */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year
           ORDER BY round_num DESC, test_date DESC, lvl_num DESC) AS recent_yr

      /* base letter, all time */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, status
           ORDER BY academic_year ASC, round_num ASC, lvl_num DESC) AS base_all      
      /* current letter, all time */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, status
           ORDER BY academic_year DESC, round_num DESC, lvl_num DESC) AS curr_all       
FROM all_systems