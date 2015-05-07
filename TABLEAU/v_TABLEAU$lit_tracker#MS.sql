USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker#MS AS

WITH term_map AS (
  SELECT hex
        ,lit
        ,map
        ,is_curterm
  FROM KIPP_NJ..REPORTING$term_map WITH(NOLOCK)

  UNION ALL

  SELECT REPLACE(hex,'Hexameter ','RT') AS hex
        ,lit
        ,NULL AS map
        ,1 AS is_curterm
  FROM
      (
       SELECT DISTINCT identifier
             ,time_per_name
       FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
       WHERE start_date <= CONVERT(DATE,GETDATE())
         AND end_date >= CONVERT(DATE,GETDATE())
         AND identifier IN ('HEX','LIT','MAP')
         AND schoolid IN (73252,133570965)
      ) sub
  
  PIVOT (
    MAX(time_per_name)
    FOR identifier IN ([LIT],[HEX])
  ) p
 )

,roster AS (
  SELECT co.year
        ,co.studentid
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,co.schoolid
        ,co.grade_level
        ,co.SPEDLEP
        ,co.team
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
  WHERE co.rn = 1
    AND co.schoolid IN (73252,133570965)
    AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
)

-- AR data, long by term (including year)
,ar_data AS (
  SELECT student_number
        ,(yearid + CONVERT(FLOAT, '1.990000e+05')) / 100 AS year
        ,time_period_name
        ,CASE WHEN words_goal < 0 THEN NULL ELSE words_goal END AS words_goal
        ,CASE WHEN points_goal < 0 THEN NULL ELSE points_goal END AS points_goal
        ,words
        ,points
        ,mastery
        ,mastery_fiction
        ,mastery_nonfiction
        ,pct_fiction
        ,100 - pct_fiction AS pct_nonfic
        ,n_fiction
        ,n_nonfic
        ,avg_lexile
        ,N_passed
        ,N_total
        ,ROUND(CONVERT(FLOAT,N_passed) / CONVERT(FLOAT,N_total) * 100,0) AS pct_passed
        ,last_book
        ,stu_status_points AS status_points
        ,stu_status_words AS status_words        
        ,rank_words_grade_in_school
        ,rank_words_overall_in_school
        ,rank_words_grade_in_network
        ,rank_words_overall_in_network        
  FROM KIPP_NJ..AR$progress_to_goals_long#static WITH(NOLOCK)  
 )

-- long map data, long by term
,map_scores AS (
  -- MAP
  SELECT co.studentid
        ,co.year
        ,map_terms.map AS fallwinterspring
        ,map.testritscore AS rit
        ,map.testpercentile AS percentile
        ,map.rittoreadingscore AS lexile
        ,map.goal1name
        ,map.goal1ritscore
        ,map.goal1adjective
        ,map.goal2name
        ,map.goal2ritscore
        ,map.goal2adjective
        ,map.goal3name
        ,map.goal3ritscore
        ,map.goal3adjective
        ,map.goal4name
        ,map.goal4ritscore
        ,map.goal4adjective
        ,map.goal5name
        ,map.goal5ritscore
        ,map.goal5adjective
        ,domain.goal1name AS base_goal1name
        ,domain.goal1ritscore AS base_goal1ritscore
        ,domain.goal1adjective AS base_goal1adjective
        ,domain.goal2name AS base_goal2name
        ,domain.goal2ritscore AS base_goal2ritscore
        ,domain.goal2adjective AS base_goal2adjective
        ,domain.goal3name AS base_goal3name
        ,domain.goal3ritscore AS base_goal3ritscore
        ,domain.goal3adjective AS base_goal3adjective
        ,domain.goal4name AS base_goal4name
        ,domain.goal4ritscore AS base_goal4ritscore
        ,domain.goal4adjective AS base_goal4adjective
        ,domain.goal5name AS base_goal5name
        ,domain.goal5ritscore AS base_goal5ritscore
        ,domain.goal5adjective AS base_goal5adjective
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_percentile        
        ,base.lexile_score AS base_lexile
        ,rr.keep_up_goal
        ,rr.keep_up_rit
        ,rr.rutgers_ready_goal
        ,rr.rutgers_ready_rit
        ,map.rn_curr        
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  CROSS JOIN (
              SELECT DISTINCT map
              FROM term_map 
              WHERE map != 'Year'
             ) map_terms    
  LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
    ON co.studentid = base.studentid
   AND co.year = base.year
   AND base.measurementscale = 'Reading' 
  LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
    ON base.studentid = rr.studentid
   AND base.year = rr.year
   AND base.measurementscale = rr.measurementscale
  LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers#static map WITH(NOLOCK)
    ON base.studentid = map.ps_studentid
   AND base.year = map.map_year_academic
   AND base.measurementscale = map.measurementscale
   AND map_terms.map = map.fallwinterspring
   AND map.rn = 1
  LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers#static domain WITH(NOLOCK)
    ON base.studentid = domain.ps_studentid   
   AND base.measurementscale = domain.measurementscale
   AND base.termname = domain.termname
   AND domain.rn = 1
  WHERE co.rn = 1
 )

-- map growth measures, wide
,map_growth AS (
  SELECT studentid
        ,year        
        ,[F2W_rit_change]
        ,[F2W_pct_change]
        ,[F2W_lexile_change]
        ,[F2W_met]
        ,[W2S_rit_change]
        ,[W2S_pct_change]
        ,[W2S_lexile_change]
        ,[W2S_met]
        ,[F2S_rit_change]
        ,[F2S_pct_change]
        ,[F2S_lexile_change]
        ,[F2S_met]
        ,[S2S_rit_change]
        ,[S2S_pct_change]
        ,[S2S_lexile_change]
        ,[S2S_met]
        ,[S2W_rit_change]
        ,[S2W_pct_change]
        ,[S2W_lexile_change]
        ,[S2W_met]
  FROM
      (
       SELECT studentid
             ,year
             --,term
             ,period + '_' + field AS field
             ,value
       FROM
           (
            SELECT growth.studentid
                  ,growth.year      
                  ,CASE        
                    WHEN growth.period_string = 'Fall to Winter' THEN 'F2W'        
                    WHEN growth.period_string = 'Fall to Spring' THEN 'F2S'
                    WHEN growth.period_string = 'Spring to Spring' THEN 'S2S'
                    WHEN growth.period_string = 'Spring to half-of-Spring' THEN 'S2W'
                   END AS period      
                  ,growth.end_rit - CASE
                                     WHEN growth.start_term_string = 'Fall' AND base.testritscore IS NULL THEN growth.start_rit 
                                     WHEN growth.start_term_string = 'Fall' THEN base.testritscore
                                     ELSE growth.start_rit 
                                    END AS rit_change      
                  ,growth.end_npr - CASE
                                     WHEN growth.start_term_string = 'Fall' AND base.testpercentile IS NULL THEN growth.start_npr
                                     WHEN growth.start_term_string = 'Fall' THEN base.testpercentile
                                     ELSE growth.start_npr
                                    END AS pct_change     
                  ,CONVERT(INT,REPLACE(growth.end_lex,'BR', 0)) - CASE
                                                                   WHEN growth.start_term_string = 'Fall' AND base.lexile_score IS NULL THEN CONVERT(INT,REPLACE(growth.start_lex,'BR', 0))
                                                                   WHEN growth.start_term_string = 'Fall' THEN CONVERT(INT,REPLACE(base.lexile_score,'BR', 0))
                                                                   ELSE CONVERT(INT,REPLACE(growth.start_lex,'BR', 0))
                                                                  END AS lexile_change
                  ,growth.met_typical_growth_target AS met
            FROM KIPP_NJ..MAP$growth_measures_long#static growth WITH(NOLOCK)
            LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
              ON growth.studentid = base.studentid
             AND growth.year = base.year
             AND growth.measurementscale = base.measurementscale
            WHERE growth.measurementscale = 'Reading'
              AND growth.period_string != 'Winter to Spring'  

            UNION ALL

            SELECT growth.studentid
                  ,growth.year      
                  ,CASE WHEN period_string = 'Winter to Spring' THEN 'W2S' END AS period      
                  ,growth.end_rit - CASE
                                     WHEN growth.start_term_string = 'Fall' AND base.testritscore IS NULL THEN growth.start_rit 
                                     WHEN growth.start_term_string = 'Fall' THEN base.testritscore
                                     ELSE growth.start_rit 
                                    END AS rit_change      
                  ,growth.end_npr - CASE
                                     WHEN growth.start_term_string = 'Fall' AND base.testpercentile IS NULL THEN growth.start_npr
                                     WHEN growth.start_term_string = 'Fall' THEN base.testpercentile
                                     ELSE growth.start_npr
                                    END AS pct_change     
                  ,CONVERT(INT,REPLACE(growth.end_lex,'BR', 0)) - CASE
                                                                   WHEN growth.start_term_string = 'Fall' AND base.lexile_score IS NULL THEN CONVERT(INT,REPLACE(growth.start_lex,'BR', 0))
                                                                   WHEN growth.start_term_string = 'Fall' THEN CONVERT(INT,REPLACE(base.lexile_score,'BR', 0))
                                                                   ELSE CONVERT(INT,REPLACE(growth.start_lex,'BR', 0))
                                                                  END AS lexile_change
                  ,growth.met_typical_growth_target AS met
            FROM KIPP_NJ..MAP$growth_measures_long#static growth WITH(NOLOCK)
            LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
              ON growth.studentid = base.studentid
             AND growth.year = base.year
             AND growth.measurementscale = base.measurementscale
            WHERE growth.measurementscale = 'Reading'
              AND growth.period_string = 'Winter to Spring'
           ) sub

       UNPIVOT (
         value
         FOR field IN (rit_change, pct_change, lexile_change, met)
        ) u
      ) sub2

  PIVOT (
    MAX(value)
    FOR field IN ([F2W_rit_change]
                 ,[F2W_pct_change]
                 ,[F2W_lexile_change]
                 ,[F2W_met]
                 ,[W2S_rit_change]
                 ,[W2S_pct_change]
                 ,[W2S_lexile_change]
                 ,[W2S_met]
                 ,[F2S_rit_change]
                 ,[F2S_pct_change]
                 ,[F2S_lexile_change]
                 ,[F2S_met]
                 ,[S2S_rit_change]
                 ,[S2S_pct_change]
                 ,[S2S_lexile_change]
                 ,[S2S_met]
                 ,[S2W_rit_change]
                 ,[S2W_pct_change]
                 ,[S2W_lexile_change]
                 ,[S2W_met])
   ) p
)

-- F&P testing, long by term
,lit_rounds AS (
  SELECT studentid
        ,fp.academic_year        
        ,test_round AS test_round
        ,read_lvl
        ,GLEQ
        ,fp_wpmrate
        ,fp_keylever
  FROM KIPP_NJ..LIT$achieved_by_round#static fp WITH(NOLOCK)      
 )

,lit_growth AS (
  SELECT year
        ,studentid
        ,yr_growth_GLEQ
        ,t1_growth_GLEQ
        ,t2_growth_GLEQ
        ,t3_growth_GLEQ
        ,t1t2_growth_GLEQ
        ,t2t3_growth_GLEQ
        ,t3EOY_growth_GLEQ
  FROM KIPP_NJ..LIT$growth_measures_wide#static WITH(NOLOCK)  
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
      
      -- terms
      ,CASE WHEN term.is_curterm = 1 THEN 'Current' ELSE term.hex END AS AR_term
      ,CASE WHEN term.is_curterm = 1 THEN 'Current' ELSE term.lit END AS lit_term
      ,CASE WHEN term.is_curterm = 1 THEN 'Current' ELSE term.map END AS MAP_term
      ,term.is_curterm            
      
      -- AR
      ,words_goal
      ,points_goal
      ,words
      ,points
      ,mastery
      ,mastery_fiction
      ,mastery_nonfiction
      ,pct_fiction
      ,pct_nonfic
      ,n_fiction
      ,n_nonfic
      ,avg_lexile
      ,N_passed
      ,N_total
      ,pct_passed
      ,last_book
      ,status_points
      ,status_words
      ,rank_words_grade_in_school
      ,rank_words_overall_in_school
      ,rank_words_grade_in_network
      ,rank_words_overall_in_network
      
      -- MAP
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_rit IS NULL THEN map_scores.rit 
        WHEN term.map = 'Fall' THEN map_scores.base_rit        
        ELSE map_scores.rit 
       END AS rit
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_percentile IS NULL THEN map_scores.percentile 
        WHEN term.map = 'Fall' THEN map_scores.base_percentile        
        ELSE map_scores.percentile 
       END AS percentile
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_lexile IS NULL THEN map_scores.lexile 
        WHEN term.map = 'Fall' THEN map_scores.base_lexile        
        ELSE map_scores.lexile 
       END AS lexile      
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal1name IS NULL THEN map_scores.goal1name 
        WHEN term.map = 'Fall' THEN map_scores.base_goal1name 
        ELSE map_scores.goal1name 
       END AS goal1name
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal1ritscore IS NULL THEN map_scores.goal1ritscore 
        WHEN term.map = 'Fall' THEN map_scores.base_goal1ritscore 
        ELSE map_scores.goal1ritscore 
       END AS goal1ritscore
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal1adjective IS NULL THEN map_scores.goal1adjective 
        WHEN term.map = 'Fall' THEN map_scores.base_goal1adjective 
        ELSE map_scores.goal1adjective 
       END AS goal1adjective
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal2name IS NULL THEN map_scores.goal2name 
        WHEN term.map = 'Fall' THEN map_scores.base_goal2name 
        ELSE map_scores.goal2name 
       END AS goal2name
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal2ritscore IS NULL THEN map_scores.goal2ritscore 
        WHEN term.map = 'Fall' THEN map_scores.base_goal2ritscore 
        ELSE map_scores.goal2ritscore 
       END AS goal2ritscore
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal2adjective IS NULL THEN map_scores.goal2adjective 
        WHEN term.map = 'Fall' THEN map_scores.base_goal2adjective 
        ELSE map_scores.goal2adjective 
       END AS goal2adjective
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal3name IS NULL THEN map_scores.goal3name 
        WHEN term.map = 'Fall' THEN map_scores.base_goal3name 
        ELSE map_scores.goal3name 
       END AS goal3name
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal3ritscore IS NULL THEN map_scores.goal3ritscore 
        WHEN term.map = 'Fall' THEN map_scores.base_goal3ritscore 
        ELSE map_scores.goal3ritscore 
       END AS goal3ritscore
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal3adjective IS NULL THEN map_scores.goal3adjective 
        WHEN term.map = 'Fall' THEN map_scores.base_goal3adjective 
        ELSE map_scores.goal3adjective 
       END AS goal3adjective
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal4name IS NULL THEN map_scores.goal4name 
        WHEN term.map = 'Fall' THEN map_scores.base_goal4name 
        ELSE map_scores.goal4name 
       END AS goal4name
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal4ritscore IS NULL THEN map_scores.goal4ritscore 
        WHEN term.map = 'Fall' THEN map_scores.base_goal4ritscore 
        ELSE map_scores.goal4ritscore 
       END AS goal4ritscore
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal4adjective IS NULL THEN map_scores.goal4adjective 
        WHEN term.map = 'Fall' THEN map_scores.base_goal4adjective 
        ELSE map_scores.goal4adjective 
       END AS goal4adjective
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal5name IS NULL THEN map_scores.goal5name 
        WHEN term.map = 'Fall' THEN map_scores.base_goal5name 
        ELSE map_scores.goal5name 
       END AS goal5name
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal5ritscore IS NULL THEN map_scores.goal5ritscore 
        WHEN term.map = 'Fall' THEN map_scores.base_goal5ritscore 
        ELSE map_scores.goal5ritscore 
       END AS goal5ritscore
      ,CASE 
        WHEN term.map = 'Fall' AND map_scores.base_goal5adjective IS NULL THEN map_scores.goal5adjective 
        WHEN term.map = 'Fall' THEN map_scores.base_goal5adjective 
        ELSE map_scores.goal5adjective 
       END AS goal5adjective
      ,base_rit
      ,base_percentile
      ,keep_up_goal
      ,keep_up_rit
      ,rutgers_ready_goal
      ,rutgers_ready_rit
      ,rn_curr AS MAP_curr      
      ,F2W_rit_change
      ,F2W_pct_change
      ,F2W_lexile_change
      ,F2W_met
      ,W2S_rit_change
      ,W2S_pct_change
      ,W2S_lexile_change
      ,W2S_met
      ,F2S_rit_change
      ,F2S_pct_change
      ,F2S_lexile_change
      ,F2S_met
      ,S2S_rit_change
      ,S2S_pct_change
      ,S2S_lexile_change
      ,S2S_met
      ,map_scores.rit - map_scores.base_rit AS B2C_rit_change
      ,map_scores.percentile - map_scores.base_percentile AS B2C_pct_change
      ,CASE WHEN map_scores.lexile = 'BR' THEN 0 ELSE CONVERT(INT,map_scores.lexile) END - CASE WHEN map_scores.base_lexile = 'BR' THEN 0 ELSE CONVERT(INT,map_scores.base_lexile) END AS B2C_lexile_change
      ,CASE WHEN map_growth.F2W_rit_change IS NULL THEN map_growth.S2W_rit_change ELSE map_growth.F2W_rit_change END AS B2W_rit_change
      ,CASE WHEN map_growth.F2W_pct_change IS NULL THEN map_growth.S2W_pct_change ELSE map_growth.F2W_pct_change END AS B2W_pct_change
      ,CASE WHEN map_growth.F2W_met IS NULL THEN map_growth.S2W_met ELSE map_growth.F2W_met END AS B2W_met
      ,CASE WHEN map_growth.F2S_rit_change IS NULL THEN map_growth.S2S_rit_change ELSE map_growth.F2S_rit_change END AS B2S_rit_change
      ,CASE WHEN map_growth.F2S_pct_change IS NULL THEN map_growth.S2S_pct_change ELSE map_growth.F2S_pct_change END AS B2S_pct_change
      ,CASE WHEN map_growth.F2S_met IS NULL THEN map_growth.S2S_met ELSE map_growth.F2S_met END AS B2S_met
      
      -- F&P      
      ,read_lvl
      ,GLEQ
      ,fp_wpmrate
      ,fp_keylever

      -- F&P growth
      ,yr_growth_GLEQ
      ,t1_growth_GLEQ
      ,t2_growth_GLEQ
      ,t3_growth_GLEQ
      ,t1t2_growth_GLEQ
      ,t2t3_growth_GLEQ
      ,t3EOY_growth_GLEQ
FROM roster r
CROSS JOIN term_map term
LEFT OUTER JOIN ar_data ar
  ON r.STUDENT_NUMBER = ar.student_number
 AND r.year = ar.year
 AND term.hex = ar.time_period_name 
LEFT OUTER JOIN map_scores
  ON r.studentid = map_scores.studentid
 AND r.year = map_scores.year
 AND term.map = map_scores.fallwinterspring
LEFT OUTER JOIN lit_rounds
  ON r.studentid = lit_rounds.studentid
 AND r.year = lit_rounds.academic_year
 AND REPLACE(term.lit, 'BOY', 'DR') = REPLACE(lit_rounds.test_round, 'BOY', 'DR')
LEFT OUTER JOIN map_growth
  ON r.studentid = map_growth.studentid
 AND r.year = map_growth.year
LEFT OUTER JOIN lit_growth
  ON r.studentid = lit_growth.studentid
 AND r.year = lit_growth.year