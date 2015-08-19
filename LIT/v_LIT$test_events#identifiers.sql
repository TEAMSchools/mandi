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
         PARTITION BY studentid, academic_year, test_round, status
           ORDER BY round_num ASC, lvl_num ASC) AS base_round
      /* current letter for the round */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year, test_round, status
           ORDER BY round_num DESC, lvl_num DESC) AS curr_round

      /* base letter for the year */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year, status
           ORDER BY round_num ASC, lvl_num ASC) AS base_yr
      /* current letter for the year */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, academic_year, status
           ORDER BY round_num DESC, lvl_num DESC) AS curr_yr

      /* base letter, all time */
      ,ROW_NUMBER() OVER(
         PARTITION BY studentid, status
           ORDER BY academic_year ASC, round_num ASC, lvl_num ASC) AS base_all      
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
             WHEN co.grade_level < 5 AND COALESCE(rs.test_round, dates.time_per_name) = 'Diagnostic' THEN 'DR' 
             WHEN rs.schoolid IN (133570965, 73252) AND COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR') THEN 'BOY' 
             ELSE COALESCE(rs.test_round, dates.time_per_name)
            END AS test_round
           ,CASE
             WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 1
             WHEN COALESCE(rs.test_round, dates.time_per_name) = 'T1' THEN 2
             WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY','T2') THEN 3
             WHEN COALESCE(rs.test_round, dates.time_per_name) = 'T3' THEN 4
             WHEN COALESCE(rs.test_round, dates.time_per_name) = 'EOY' THEN 5       
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
           ,COALESCE(rs.status,'Did Not Achieve') AS status      
           ,gleq.read_lvl      
           ,gleq.lvl_num
           ,COALESCE(rs.instruct_lvl, gleq.instruct_lvl) AS instruct_lvl
           ,instr.lvl_num AS instruct_lvl_num
           ,COALESCE(rs.indep_lvl, rs.read_lvl, gleq.read_lvl) AS indep_lvl
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
       ON ((rs.test_date >= '2013-07-31' AND rs.schoolid = dates.schoolid) OR (rs.test_date < '2013-07-01' AND dates.schoolid IS NULL))
      AND rs.test_date BETWEEN dates.start_date AND dates.end_date
      AND dates.identifier = 'LIT'
     JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       ON rs.studentid = co.studentid
      AND COALESCE(rs.academic_year, dates.academic_year) = co.year 
      AND co.rn = 1
     JOIN KIPP_NJ..LIT$GLEQ gleq WITH(NOLOCK)
       ON ((rs.testid = 3273 AND rs.read_lvl = gleq.read_lvl) OR (rs.testid != 3273 AND rs.testid = gleq.testid))
      AND gleq.lvl_num > -1
     LEFT OUTER JOIN KIPP_NJ..LIT$GLEQ instr WITH(NOLOCK)
       ON COALESCE(rs.instruct_lvl, gleq.instruct_lvl) = instr.read_lvl
     LEFT OUTER JOIN KIPP_NJ..LIT$GLEQ ind WITH(NOLOCK)
       ON COALESCE(rs.indep_lvl, rs.read_lvl, gleq.read_lvl) = ind.read_lvl
     LEFT OUTER JOIN KIPP_NJ..LIT$goals goals WITH(NOLOCK)
       ON co.grade_level = goals.grade_level
      AND CASE
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 'DR'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T3','EOY') THEN 'T3'
           ELSE COALESCE(rs.test_round, dates.time_per_name)
          END = goals.test_round 
     LEFT OUTER JOIN KIPP_NJ..LIT$individual_goals indiv WITH(NOLOCK)
       ON co.STUDENT_NUMBER = indiv.student_number
      AND co.year = indiv.academic_year
      AND CASE
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 'DR'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T3','EOY') THEN 'T3'
           ELSE COALESCE(rs.test_round, dates.time_per_name)
          END = goals.test_round  

     UNION ALL

     /* Synthetic Pre-DNA Achieved */
     SELECT rs.unique_id
           ,rs.testid   
           ,CASE WHEN rs.testid = 3273 THEN 1 ELSE 0 END AS is_fp
      
           /* date stuff */
           ,COALESCE(rs.academic_year, dates.academic_year) AS academic_year
           ,CASE
             WHEN co.grade_level < 5 AND COALESCE(rs.test_round, dates.time_per_name) = 'Diagnostic' THEN 'DR' 
             WHEN rs.schoolid IN (133570965, 73252) AND COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR') THEN 'BOY' 
             ELSE COALESCE(rs.test_round, dates.time_per_name)
            END AS test_round
           ,CASE
             WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 1
             WHEN COALESCE(rs.test_round, dates.time_per_name) = 'T1' THEN 2
             WHEN COALESCE(rs.test_round, dates.time_per_name) = 'T2' THEN 3
             WHEN COALESCE(rs.test_round, dates.time_per_name) = 'T3' THEN 4
             WHEN COALESCE(rs.test_round, dates.time_per_name) = 'EOY' THEN 5       
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
           ,gleq.lvl_num
           ,COALESCE(rs.instruct_lvl, gleq.instruct_lvl) AS instruct_lvl
           ,instr.lvl_num AS instruct_lvl_num
           ,COALESCE(rs.indep_lvl, rs.read_lvl, gleq.read_lvl) AS indep_lvl
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
       ON ((rs.test_date >= '2013-07-31' AND rs.schoolid = dates.schoolid) OR (rs.test_date < '2013-07-01' AND dates.schoolid IS NULL))
      AND rs.test_date BETWEEN dates.start_date AND dates.end_date
      AND dates.identifier = 'LIT'
     JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       ON rs.studentid = co.studentid
      AND COALESCE(rs.academic_year, dates.academic_year) = co.year 
      AND co.rn = 1
     JOIN KIPP_NJ..LIT$GLEQ gleq WITH(NOLOCK)
       ON gleq.lvl_num = -1
     LEFT OUTER JOIN KIPP_NJ..LIT$GLEQ instr WITH(NOLOCK)
       ON COALESCE(rs.instruct_lvl, gleq.instruct_lvl) = instr.read_lvl
     LEFT OUTER JOIN KIPP_NJ..LIT$GLEQ ind WITH(NOLOCK)
       ON COALESCE(rs.indep_lvl, rs.read_lvl, gleq.read_lvl) = ind.read_lvl
     LEFT OUTER JOIN KIPP_NJ..LIT$goals goals WITH(NOLOCK)
       ON co.grade_level = goals.grade_level
      AND CASE
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 'DR'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T3','EOY') THEN 'T3'
           ELSE COALESCE(rs.test_round, dates.time_per_name)
          END = goals.test_round 
     LEFT OUTER JOIN KIPP_NJ..LIT$individual_goals indiv WITH(NOLOCK)
       ON co.STUDENT_NUMBER = indiv.student_number
      AND co.year = indiv.academic_year
      AND CASE
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('Diagnostic', 'DR', 'BOY') THEN 'DR'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('MOY') THEN 'T2'
           WHEN COALESCE(rs.test_round, dates.time_per_name) IN ('T3','EOY') THEN 'T3'
           ELSE COALESCE(rs.test_round, dates.time_per_name)
          END = goals.test_round  
     WHERE rs.read_lvl = 'Pre'
       AND ((rs.status = 'Did Not Achieve') OR (rs.academic_year >= 2015 AND rs.status IS NULL))
    ) sub