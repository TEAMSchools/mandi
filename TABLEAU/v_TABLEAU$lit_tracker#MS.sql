USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker#MS AS

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

      /* F&P growth */
      ,lit_growth.yr_growth_GLEQ
      ,lit_growth.t1_growth_GLEQ
      ,lit_growth.t2_growth_GLEQ
      ,lit_growth.t3_growth_GLEQ
      ,lit_growth.t1t2_growth_GLEQ
      ,lit_growth.t2t3_growth_GLEQ
      ,lit_growth.t3EOY_growth_GLEQ  
FROM KIPP_NJ..COHORT$identifiers_long#static r WITH(NOLOCK)  
JOIN KIPP_NJ..REPORTING$term_map term WITH(NOLOCK)
  ON r.year BETWEEN term.min_year AND term.max_year
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
  ON r.STUDENT_NUMBER = ar.student_number
 AND r.year = ar.academic_year
 AND term.hex = ar.time_period_name 
LEFT OUTER JOIN KIPP_NJ..LIT$achieved_by_round#static lit_rounds WITH(NOLOCK)
  ON r.studentid = lit_rounds.studentid
 AND r.year = lit_rounds.academic_year
 AND term.lit = lit_rounds.test_round
LEFT OUTER JOIN KIPP_NJ..LIT$growth_measures_wide#static lit_growth WITH(NOLOCK)
  ON r.studentid = lit_growth.studentid
 AND r.year = lit_growth.year
WHERE ((r.grade_level BETWEEN 5 AND 8) OR (r.schoolid = 73252 AND r.grade_level = 4))
  AND r.rn = 1    
  AND r.year >= 2013 /* oldest AR data we have */