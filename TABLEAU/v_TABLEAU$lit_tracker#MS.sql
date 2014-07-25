USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker#MS AS

-- this one is pretty crazy
-- in order to align terms, we need to place them in relation to one another
-- and make the term name JOIN friendly for the actual data tables
WITH term_scaffold AS (
  SELECT n
  FROM UTIL$row_generator WITH(NOLOCK)
  WHERE n >= 1
    AND n <= 8
)

-- AR
,hexes AS (
  SELECT 'HEX' AS time_per
        ,n
        ,'RT' + CONVERT(VARCHAR,n) AS hash
  FROM UTIL$row_generator WITH(NOLOCK)
  WHERE n >= 1
    AND n <= 6
)

-- LIT
,lit AS (
  SELECT 'LIT' AS time_per
        ,n
        ,'LIT' + CONVERT(VARCHAR,n) AS hash
  FROM UTIL$row_generator WITH(NOLOCK)
  WHERE n >= 1
    AND n <= 4
)

-- MAP
,map AS (
  SELECT time_per
        ,n
        ,CASE
          WHEN hash LIKE '%1%' THEN 'Fall'
          WHEN hash LIKE '%2%' THEN 'Winter'
          WHEN hash LIKE '%3%' THEN 'Spring'
         END AS hash
  FROM
      (
       SELECT 'MAP' AS time_per
             ,n
             ,'MAP' + CONVERT(VARCHAR,n) AS hash
       FROM UTIL$row_generator WITH(NOLOCK)
       WHERE n >= 1
         AND n <= 3
      ) sub  
)

-- all together now
,term_map AS (
  SELECT hexes.hash AS hex
        ,CASE 
          WHEN lit.hash LIKE '%1%' THEN 'BOY'
          WHEN lit.hash LIKE '%2%' THEN 'T1'
          WHEN lit.hash LIKE '%3%' THEN 'T2'
          WHEN lit.hash LIKE '%4%' THEN 'T3'
         END AS lit
        ,map.hash AS map
        ,0 AS is_curterm
  FROM term_scaffold
  LEFT OUTER JOIN lit
    ON ((term_scaffold.n + 1) / 2) = lit.n
  LEFT OUTER JOIN hexes
    ON term_scaffold.n = (hexes.n + 2)
  LEFT OUTER JOIN map
    ON ((term_scaffold.n - 1) / 2) = map.n

  UNION ALL

  SELECT 'Year' AS hex
        ,'Year' AS lit
        ,'Year' AS map
        ,0 AS is_curterm

  UNION ALL

  SELECT REPLACE(hex,'Hexameter ','RT') AS hex
        ,lit
        ,NULL AS map
        ,1 AS is_curterm
  FROM
      (
       SELECT DISTINCT identifier
             ,time_per_name
       FROM REPORTING$dates WITH(NOLOCK)
       WHERE start_date <= '2014-05-15' -- replace with GETDATE
         AND end_date >= '2014-05-15'   -- replace with GETDATE      
         AND identifier IN ('HEX','LIT','MAP')
         AND schoolid IN (73252,133570965)
      ) sub
  
  PIVOT (
    MAX(time_per_name)
    FOR identifier IN ([LIT],[HEX])
  ) p
 )

,roster AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,co.schoolid
        ,co.grade_level
        ,cs.SPEDLEP
        ,s.team
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.id
  LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.studentid
  WHERE co.year = dbo.fn_Global_Academic_Year()
    AND co.rn = 1
    AND co.schoolid IN (73252,133570965)
)

-- AR data, long by term (including year)
,ar_data AS (
  SELECT student_number
        ,time_period_name
        ,words_goal
        ,points_goal
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
  FROM AR$progress_to_goals_long#static WITH(NOLOCK)
  WHERE yearid = dbo.fn_Global_Term_Id()
 )

-- long map data, long by term
,map_scores AS (
  SELECT co.studentid
        ,map_terms.hash AS fallwinterspring
        ,map.testritscore AS rit
        ,map.testpercentile AS percentile
        ,rittoreadingscore AS lexile
        ,goal1name
        ,goal1ritscore
        ,goal1adjective
        ,goal2name
        ,goal2ritscore
        ,goal2adjective
        ,goal3name
        ,goal3ritscore
        ,goal3adjective
        ,goal4name
        ,goal4ritscore
        ,goal4adjective
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_percentile        
        ,base.lexile_score AS base_lexile
        ,rr.keep_up_goal
        ,rr.keep_up_rit
        ,rr.rutgers_ready_goal
        ,rr.rutgers_ready_rit
        ,map.rn_curr
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN map map_terms
    ON 1 = 1
  LEFT OUTER JOIN MAP$best_baseline#static base WITH(NOLOCK)
    ON co.studentid = base.studentid
   AND co.year = base.year
   AND base.measurementscale = 'Reading' 
  LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
    ON base.studentid = rr.studentid
   AND base.year = rr.year
   AND base.measurementscale = rr.measurementscale
  LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH(NOLOCK)
    ON base.studentid = map.ps_studentid
   AND base.year = map.map_year_academic
   AND base.measurementscale = map.measurementscale
   AND map_terms.hash = map.fallwinterspring
   AND map.rn = 1
  WHERE co.year = dbo.fn_Global_Academic_Year()
    AND co.rn = 1    
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
            SELECT base.studentid
                  ,base.year
                  --,start_term_string AS term
                  ,CASE        
                    WHEN period_string = 'Fall to Winter' THEN 'F2W'        
                    WHEN period_string = 'Fall to Spring' THEN 'F2S'
                    WHEN period_string = 'Spring to Spring' THEN 'S2S'
                    WHEN period_string = 'Spring to half-of-Spring' THEN 'S2W'
                   END AS period      
                  ,rit_change
                  ,lexile_change
                  ,end_npr - start_npr AS pct_change
                  ,met_typical_growth_target AS met
            FROM MAP$best_baseline#static base WITH(NOLOCK)
            JOIN MAP$growth_measures_long#static growth WITH(NOLOCK)
              ON base.studentid = growth.studentid
             AND base.measurementscale = growth.measurementscale
             AND base.year = growth.year
             AND base.termname = growth.start_term_verif           
             AND growth.period_string != 'Winter to Spring'
             AND growth.valid_observation = 1
            WHERE base.measurementscale = 'Reading'
              AND base.year = dbo.fn_Global_Academic_Year()

            UNION ALL

            SELECT studentid
                  ,year
                  --,start_term_string AS term
                  ,CASE WHEN period_string = 'Winter to Spring' THEN 'W2S' END AS period      
                  ,rit_change
                  ,lexile_change
                  ,end_npr - start_npr AS pct_change
                  ,met_typical_growth_target AS met
            FROM MAP$growth_measures_long#static WITH(NOLOCK)
            WHERE valid_observation = 1
              AND measurementscale = 'Reading'
              AND year = dbo.fn_Global_Academic_Year()
              AND period_string = 'Winter to Spring'
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
        --,fp.academic_year -- no data, replace when year gets started        
        --,test_round -- no data, replace when year gets started
        ,d.time_per_name AS test_round
        ,read_lvl
        ,GLEQ
        ,fp_wpmrate
  FROM LIT$test_events#identifiers fp WITH(NOLOCK)
  LEFT OUTER JOIN REPORTING$dates d WITH(NOLOCK)
    ON fp.test_date >= d.start_date
   AND fp.test_date <= d.end_date
   AND fp.schoolid = d.schoolid
   AND d.identifier = 'LIT'
  WHERE testid = 3273
    AND achv_curr_round = 1
    AND test_date >= '2013-05-15' -- no data, remove when year gets started
 )

SELECT -- student identifiers
       r.studentid
      ,r.student_number
      ,r.lastfirst
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
      ,CASE WHEN term.map = 'Fall' AND map_scores.rit IS NULL THEN map_scores.base_rit ELSE map_scores.rit END AS rit
      ,CASE WHEN term.map = 'Fall' AND map_scores.percentile IS NULL THEN map_scores.base_percentile ELSE map_scores.percentile END AS percentile
      ,CASE WHEN term.map = 'Fall' AND map_scores.lexile IS NULL THEN map_scores.base_lexile ELSE map_scores.lexile END AS lexile      
      ,goal1name
      ,goal1ritscore
      ,goal1adjective
      ,goal2name
      ,goal2ritscore
      ,goal2adjective
      ,goal3name
      ,goal3ritscore
      ,goal3adjective
      ,goal4name
      ,goal4ritscore
      ,goal4adjective
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
FROM roster r
JOIN term_map term
  ON 1 = 1
LEFT OUTER JOIN ar_data ar
  ON r.STUDENT_NUMBER = ar.student_number
 AND term.hex = ar.time_period_name
LEFT OUTER JOIN map_scores
  ON r.studentid = map_scores.studentid
 AND term.map = map_scores.fallwinterspring
LEFT OUTER JOIN map_growth
  ON r.studentid = map_growth.studentid
LEFT OUTER JOIN lit_rounds
  ON r.studentid = lit_rounds.studentid
 AND term.lit = lit_rounds.test_round