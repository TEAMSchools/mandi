USE KIPP_NJ
GO

ALTER VIEW LIT$test_events#identifiers AS

SELECT sub.unique_id
      ,sub.testid
      ,sub.is_fp
      ,sub.academic_year
      ,sub.test_round
      ,sub.round_num
      ,sub.test_date
      ,sub.schoolid
      ,sub.grade_level
      ,sub.COHORT
      ,sub.studentid
      ,sub.student_number
      ,sub.LASTFIRST
      ,sub.status
      ,sub.read_lvl
      ,sub.lvl_num
      ,sub.dna_lvl
      ,sub.dna_lvl_num
      ,sub.instruct_lvl
      ,sub.instruct_lvl_num
      ,sub.indep_lvl
      ,sub.indep_lvl_num
      ,sub.goal_lvl
      ,sub.goal_num
      ,sub.default_goal_lvl
      ,sub.default_goal_num
      ,sub.natl_goal_lvl         
      ,sub.natl_goal_num
      ,sub.indiv_goal_lvl
      ,sub.indiv_lvl_num
      ,sub.met_goal
      ,sub.levels_behind
      ,sub.GLEQ
      ,sub.color
      ,sub.genre
      ,sub.fp_wpmrate
      ,sub.fp_keylever
      ,sub.coaching_code      
       
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
FROM
    (
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
       ON ((rs.test_date >= '2013-07-31' AND rs.schoolid = dates.schoolid) OR (rs.test_date < '2013-07-01' AND dates.schoolid IS NULL)) /* CROSS JOIN historical years */
      AND rs.test_date BETWEEN dates.start_date AND dates.end_date
      AND dates.identifier = 'LIT'
     JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       ON rs.studentid = co.studentid
      AND COALESCE(rs.academic_year, dates.academic_year) = co.year /* before 2014-2015, rs.academic_year did not exist, so join to dates table */
      AND co.rn = 1
     JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
       ON ((co.year <= 2014 AND rs.testid != 3273 AND rs.testid = gleq.testid AND gleq.lvl_num > -1) /* before 2015-2016, JOIN Achieved STEP on testid */
              OR (co.year <= 2014 AND rs.testid = 3273 AND rs.read_lvl = gleq.read_lvl) /* before 2015-2016, JOIN Achieved F&P on reading level */
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
       ON ((rs.test_date >= '2013-07-31' AND rs.schoolid = dates.schoolid) OR (rs.test_date < '2013-07-01' AND dates.schoolid IS NULL))
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
    ) sub