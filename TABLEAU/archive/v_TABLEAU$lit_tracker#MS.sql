USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker#MS AS

WITH most_recent AS (
  SELECT academic_year
        ,student_number        
        ,read_lvl
        ,GLEQ
        ,instruct_lvl
        ,instruct_lvl_num
        ,indep_lvl
        ,indep_lvl_num
        ,fp_keylever
  FROM KIPP_NJ..LIT$all_test_events#identifiers#static WITH(NOLOCK)
  WHERE curr_yr = 1
    AND ((academic_year >= 2015 AND status = 'Did Not Achieve') OR (academic_year <= 2014 AND status = 'Achieved'))
 )

,base_round AS (
  SELECT academic_year
        ,student_number        
        ,read_lvl
        ,GLEQ
        ,instruct_lvl
        ,instruct_lvl_num
        ,indep_lvl
        ,indep_lvl_num
        ,fp_keylever
  FROM KIPP_NJ..LIT$all_test_events#identifiers#static WITH(NOLOCK)
  WHERE base_yr = 1
    AND ((academic_year >= 2015 AND status = 'Did Not Achieve') OR (academic_year <= 2014 AND status = 'Achieved'))
)

SELECT -- student identifiers
       r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.schoolid
      ,r.grade_level
      ,r.team
      ,r.spedlep
      ,CASE 
        WHEN r.year >= 2015 THEN REPLACE(term.hex,'RT','Q') 
        ELSE REPLACE(term.hex,'RT','Hex ') 
       END AS AR_term      
      ,term.lit AS lit_term              
      
      /* AR */
      ,CASE WHEN words_goal < 0 THEN NULL ELSE words_goal END AS words_goal
      ,CASE WHEN points_goal < 0 THEN NULL ELSE points_goal END AS points_goal
      ,ar.words
      ,ar.points
      ,ar.mastery
      ,ar.mastery_fiction
      ,ar.mastery_nonfiction
      ,ar.pct_fiction
      ,100 - pct_fiction AS pct_nonfic
      ,ar.n_fiction
      ,ar.n_nonfic
      ,ar.avg_lexile
      ,ar.N_passed
      ,ar.N_total
      ,ROUND(CONVERT(FLOAT,N_passed) / CONVERT(FLOAT,N_total) * 100,0) AS pct_passed
      ,ar.last_book
      ,stu_status_points AS status_points
      ,stu_status_words AS status_words        
      ,ar.rank_words_grade_in_school
      ,ar.rank_words_overall_in_school
      ,ar.rank_words_grade_in_network
      ,ar.rank_words_overall_in_network
      
      /* F&P */
      ,lit_rounds.read_lvl
      ,lit_rounds.lvl_num      
      ,lit_rounds.instruct_lvl
      ,lit_rounds.instruct_lvl_num
      ,lit_rounds.GLEQ
      ,lit_rounds.fp_wpmrate
      ,lit_rounds.fp_keylever
      ,lit_rounds.is_new_test
      ,LAG(lit_rounds.lvl_num, 1) OVER(PARTITION BY r.student_number, r.year ORDER BY term.hex) AS prev_lvl_num

      /* most recent test for year */      
      ,mr.read_lvl AS curr_read_lvl
      ,mr.GLEQ AS curr_GLEQ
      ,mr.instruct_lvl AS curr_instruct_lvl
      ,mr.instruct_lvl_num AS curr_instruct_lvl_num
      ,mr.indep_lvl AS curr_indep_lvl
      ,mr.indep_lvl_num AS curr_indep_lvl_num
      ,mr.fp_keylever AS curr_keylever

      /* base test for year */      
      ,br.read_lvl AS base_read_lvl
      ,br.GLEQ AS base_GLEQ
      ,br.instruct_lvl AS base_instruct_lvl
      ,br.instruct_lvl_num AS base_instruct_lvl_num
      ,br.indep_lvl AS base_indep_lvl
      ,br.indep_lvl_num AS base_indep_lvl_num
      ,br.fp_keylever AS base_keylever
FROM KIPP_NJ..COHORT$identifiers_long#static r WITH(NOLOCK)  
JOIN KIPP_NJ..REPORTING$term_map term WITH(NOLOCK)
  ON r.year BETWEEN term.min_year AND term.max_year
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
  ON r.STUDENT_NUMBER = ar.student_number
 AND r.year = ar.academic_year
 AND term.hex = ar.time_period_name 
 AND ar.start_date <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN KIPP_NJ..LIT$achieved_by_round#static lit_rounds WITH(NOLOCK)
  ON r.studentid = lit_rounds.studentid
 AND r.year = lit_rounds.academic_year
 AND term.lit = lit_rounds.test_round
 AND lit_rounds.start_date <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN most_recent mr
  ON r.student_number = mr.student_number
 AND r.year = mr.academic_year
LEFT OUTER JOIN base_round br
  ON r.student_number = br.student_number
 AND r.year = br.academic_year
WHERE ((r.grade_level BETWEEN 5 AND 8) OR (r.schoolid = 73252 AND r.grade_level = 4))
  AND r.rn = 1    
  AND r.year >= 2010 /* oldest AR data we have */
  
  