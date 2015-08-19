USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker_wide#MS AS

WITH roster AS (
  SELECT co.year 
        ,co.studentid
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,co.schoolid
        ,co.grade_level
        ,co.SPEDLEP
        ,co.team
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)  
  WHERE co.rn = 1
    AND co.schoolid IN (73252,133570965)
)

,terms AS (      
  SELECT DISTINCT 
         CASE 
          WHEN school_level = 'MS' AND time_per_name = 'DR' THEN 'BOY' 
          ELSE REPLACE(time_per_name, 'Diagnostic', 'DR')
         END AS test_round
        ,ROW_NUMBER() OVER (
           PARTITION BY academic_year, schoolid
           ORDER BY start_date ASC) AS round_num
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'LIT'      
    AND school_level = 'MS'
    AND academic_year = dbo.fn_Global_Academic_Year()
    AND start_date <= CONVERT(DATE,GETDATE())
 )

-- AR data, long by term (including year)
,ar_data AS (
  SELECT yearid
        ,student_number
        ,time_period_name + '_' + field AS header
        ,value
  FROM
      (
       SELECT yearid
             ,student_number
             ,CASE WHEN time_period_name = 'Year' THEN 'Y1' ELSE REPLACE(time_period_name, 'RT', 'HEX') END AS time_period_name
             ,CONVERT(VARCHAR,words) AS words
             ,CONVERT(VARCHAR,CASE WHEN ROUND(words / words_goal * 100, 0) > 110 THEN 110 ELSE ROUND(words / words_goal * 100, 0) END) AS pct_goal
             ,CONVERT(VARCHAR,mastery_fiction) AS mastery_f
             ,CONVERT(VARCHAR,mastery_nonfiction) AS mastery_nf
             ,CONVERT(VARCHAR,mastery) AS mastery_all
             ,CONVERT(VARCHAR,CASE WHEN N_total > 0 THEN ROUND(CONVERT(FLOAT,N_passed) / CONVERT(FLOAT,N_total) * 100,0) ELSE NULL END) AS pct_pass
       FROM AR$progress_to_goals_long#static WITH(NOLOCK)
       WHERE words_goal > 0
      ) sub
  
  UNPIVOT (
     value
     FOR field IN (words, pct_goal, mastery_f, mastery_nf, mastery_all, pct_pass)
   ) u
 )

-- long map data, long by term
,map_scores AS (
  SELECT year
        ,student_number
        ,fallwinterspring + '_' + field AS header
        ,value
  FROM
      (
       SELECT co.STUDENT_NUMBER
             ,co.year             
             ,CASE 
               WHEN map.fallwinterspring IS NULL THEN 'B'
               WHEN map.fallwinterspring = 'Fall' THEN 'B'
               WHEN map.fallwinterspring = 'Winter' THEN 'W'
               WHEN map.fallwinterspring = 'Spring' THEN 'S'
              END AS fallwinterspring
             ,CONVERT(VARCHAR,CASE 
                               WHEN map.fallwinterspring IS NULL THEN base.testritscore
                               WHEN map.fallwinterspring = 'Fall' THEN base.testritscore 
                               ELSE map.testritscore 
                              END) AS rit
             ,CONVERT(VARCHAR,CASE 
                               WHEN map.fallwinterspring IS NULL THEN base.testpercentile 
                               WHEN map.fallwinterspring = 'Fall' THEN base.testpercentile
                               ELSE map.testpercentile 
                              END) AS pct
             ,CONVERT(VARCHAR,CASE
                               WHEN map.fallwinterspring IS NULL THEN REPLACE(base.lexile_score, 'BR', 0) 
                               WHEN map.fallwinterspring = 'Fall' THEN REPLACE(base.lexile_score, 'BR', 0) 
                               ELSE REPLACE(map.rittoreadingscore, 'BR', 0) 
                              END) AS lexile
       FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
       JOIN MAP$best_baseline#static base WITH(NOLOCK)
         ON co.studentid = base.studentid
        AND co.year = base.year
        AND base.measurementscale = 'Reading'
       LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH(NOLOCK)
         ON co.studentid = map.ps_studentid
        AND co.year = map.map_year_academic
        AND base.measurementscale = map.measurementscale   
        AND map.rn = 1
       WHERE co.rn = 1         
      ) sub   
  UNPIVOT (
    value
    FOR field IN (pct, rit, lexile)
   ) u
 )

-- map growth measures, wide
,map_growth AS (
  SELECT year             
        ,studentid
        ,period + '_' + field AS header
        ,value
  FROM
      (
       SELECT base.studentid
             ,base.year                  
             ,CASE        
               WHEN period_string = 'Fall to Winter' THEN 'B2W'
               WHEN period_string = 'Fall to Spring' THEN 'B2S'
               WHEN period_string = 'Spring to Spring' THEN 'B2S'
               WHEN period_string = 'Spring to half-of-Spring' THEN 'B2W'
              END AS period                        
             ,end_npr - start_npr AS pct_change                  
       FROM MAP$best_baseline#static base WITH(NOLOCK)
       JOIN MAP$growth_measures_long#static growth WITH(NOLOCK)
         ON base.studentid = growth.studentid
        AND base.measurementscale = growth.measurementscale
        AND base.year = growth.year
        AND base.termname = growth.start_term_verif           
        AND growth.period_string != 'Winter to Spring'
        AND growth.valid_observation = 1
       WHERE base.measurementscale = 'Reading'

       UNION ALL

       SELECT studentid
             ,year                  
             ,CASE WHEN period_string = 'Winter to Spring' THEN 'W2S' END AS period                        
             ,end_npr - start_npr AS pct_change                  
       FROM MAP$growth_measures_long#static WITH(NOLOCK)
       WHERE valid_observation = 1
         AND measurementscale = 'Reading'              
         AND period_string = 'Winter to Spring'
      ) sub
  UNPIVOT (
    value
    FOR field IN (pct_change)
   ) u        
)

-- F&P testing, long by term
,lit_rounds AS (
  SELECT year
        ,studentid
        ,test_round + '_' + field AS header
        ,CONVERT(VARCHAR,value) AS value
  FROM 
      (
       SELECT fp.studentid
             ,fp.GRADE_LEVEL
             ,fp.academic_year AS year      
             ,CASE 
               WHEN fp.test_round = 'DR' THEN 'BOY'
               WHEN fp.test_round = 'EOY' THEN 'T3'
               ELSE fp.test_round
              END AS test_round
             ,CONVERT(VARCHAR,fp.read_lvl) AS read_lvl
             ,CONVERT(VARCHAR,fp.indep_lvl) AS indep_lvl
             ,CONVERT(VARCHAR,fp.GLEQ) AS GLEQ      
             ,CONVERT(VARCHAR,ROUND(fp.GLEQ - gleq.GLEQ,1)) AS yrs_behind
             ,CONVERT(VARCHAR,CASE WHEN fp.schoolid = 73252 THEN rl.wpm ELSE fp.fp_wpmrate END) AS wpm
             ,CONVERT(VARCHAR,fp.fp_keylever) AS keylever            
       FROM LIT$achieved_by_round#static fp WITH(NOLOCK)       
       LEFT OUTER JOIN LIT$goals goals WITH(NOLOCK)
         ON fp.GRADE_LEVEL = goals.grade_level
        AND REPLACE(fp.test_round, 'EOY', 'T3') = goals.test_round
       LEFT OUTER JOIN LIT$GLEQ gleq WITH(NOLOCK)
         ON goals.read_lvl = gleq.read_lvl        
       LEFT OUTER JOIN SRSLY_DIE_READLIVE rl WITH(NOLOCK)
         ON fp.studentid = rl.studentid
        AND CASE
             WHEN fp.test_round = 'BOY' THEN 'Fall'
             WHEN fp.test_round = 'T1' THEN 'Fall'
             WHEN fp.test_round = 'T2' THEN 'Winter'
             WHEN fp.test_round = 'T3' THEN 'Winter'
             WHEN fp.test_round = 'EOY' THEN 'Spring'
            END = rl.season       
       WHERE ((fp.academic_year < dbo.fn_Global_Academic_Year()) 
               OR (fp.academic_year = dbo.fn_Global_Academic_Year() AND fp.test_round IN (SELECT test_round FROM terms WITH(NOLOCK))))
      ) sub  
  UNPIVOT (
    value
    FOR field IN (read_lvl, indep_lvl, gleq, wpm, keylever, yrs_behind)
   ) u
 )

,lit_growth AS (
  SELECT year
        ,studentid
        ,field AS header
        ,CONVERT(VARCHAR,value) AS value
  FROM
      (
       SELECT year
             ,studentid
             ,yr_growth_GLEQ
             ,t1_growth_GLEQ
             ,t2_growth_GLEQ
             ,t3_growth_GLEQ
             ,t1t2_growth_GLEQ
             ,t2t3_growth_GLEQ
             ,t3EOY_growth_GLEQ
       FROM LIT$growth_measures_wide#static WITH(NOLOCK)
      ) sub  
  UNPIVOT (
    value
    FOR field IN (yr_growth_GLEQ
                 ,t1_growth_GLEQ
                 ,t2_growth_GLEQ
                 ,t3_growth_GLEQ
                 ,t1t2_growth_GLEQ
                 ,t2t3_growth_GLEQ
                 ,t3EOY_growth_GLEQ)
   ) u
 )

,map_goals AS (
  SELECT year
        ,studentid
        ,field AS header
        ,CONVERT(VARCHAR,value) AS value
  FROM
      (
       SELECT map_year_academic AS year
             ,ps_studentid AS studentid
             ,teststartdate
             ,goal1name
             ,goal1ritscore
             ,goal1stderr
             ,goal1range
             ,goal1adjective
             ,goal2name
             ,goal2ritscore
             ,goal2stderr
             ,goal2range
             ,goal2adjective
             ,goal3name
             ,goal3ritscore
             ,goal3stderr
             ,goal3range
             ,goal3adjective
             ,goal4name
             ,goal4ritscore
             ,goal4stderr
             ,goal4range
             ,goal4adjective
             ,goal5name
             ,goal5ritscore
             ,goal5stderr
             ,goal5range
             ,goal5adjective
             ,goal6name
             ,goal6ritscore
             ,goal6stderr
             ,goal6range
             ,goal6adjective
             ,goal7name
             ,goal7ritscore
             ,goal7stderr
             ,goal7range
             ,goal7adjective
             ,goal8name
             ,goal8ritscore
             ,goal8stderr
             ,goal8range
             ,goal8adjective
             ,ROW_NUMBER() OVER(
                PARTITION BY map_year_academic, studentid
                  ORDER BY teststartdate DESC) AS rn_curr
       FROM MAP$comprehensive#identifiers WITH(NOLOCK)
       WHERE rn = 1
         AND measurementscale = 'Reading'
      ) sub
  UNPIVOT(
    value
    FOR field IN (goal1name
                 ,goal1ritscore
                 ,goal1stderr
                 ,goal1range
                 ,goal1adjective
                 ,goal2name
                 ,goal2ritscore
                 ,goal2stderr
                 ,goal2range
                 ,goal2adjective
                 ,goal3name
                 ,goal3ritscore
                 ,goal3stderr
                 ,goal3range
                 ,goal3adjective
                 ,goal4name
                 ,goal4ritscore
                 ,goal4stderr
                 ,goal4range
                 ,goal4adjective
                 ,goal5name
                 ,goal5ritscore
                 ,goal5stderr
                 ,goal5range
                 ,goal5adjective
                 ,goal6name
                 ,goal6ritscore
                 ,goal6stderr
                 ,goal6range
                 ,goal6adjective
                 ,goal7name
                 ,goal7ritscore
                 ,goal7stderr
                 ,goal7range
                 ,goal7adjective
                 ,goal8name
                 ,goal8ritscore
                 ,goal8stderr
                 ,goal8range
                 ,goal8adjective)
   ) u
  WHERE rn_curr = 1
 )

SELECT year
      ,studentid
      ,STUDENT_NUMBER
      ,lastfirst
      ,schoolid
      ,grade_level
      ,SPEDLEP
      ,TEAM
      ,CONVERT(FLOAT,[Y1_words]) AS Y1_words
      ,CONVERT(FLOAT,[Y1_pct_goal]) AS Y1_pct_goal
      ,CONVERT(FLOAT,[Y1_mastery_f]) AS Y1_mastery_f
      ,CONVERT(FLOAT,[Y1_mastery_nf]) AS Y1_mastery_nf
      ,CONVERT(FLOAT,[Y1_mastery_all]) AS Y1_mastery_all
      ,CONVERT(FLOAT,[Y1_pct_pass]) AS Y1_pct_pass
      ,CONVERT(FLOAT,[HEX1_words]) AS HEX1_words
      ,CONVERT(FLOAT,[HEX1_pct_goal]) AS HEX1_pct_goal      
      ,CONVERT(FLOAT,[HEX1_mastery_f]) AS HEX1_mastery_f
      ,CONVERT(FLOAT,[HEX1_mastery_nf]) AS HEX1_mastery_nf
      ,CONVERT(FLOAT,[HEX1_mastery_all]) AS HEX1_mastery_all
      ,CONVERT(FLOAT,[HEX1_pct_pass]) AS HEX1_pct_pass
      ,CONVERT(FLOAT,[HEX2_words]) AS HEX2_words
      ,CONVERT(FLOAT,[HEX2_pct_goal]) AS HEX2_pct_goal
      ,CONVERT(FLOAT,[HEX2_mastery_f]) AS HEX2_mastery_f
      ,CONVERT(FLOAT,[HEX2_mastery_nf]) AS HEX2_mastery_nf
      ,CONVERT(FLOAT,[HEX2_mastery_all]) AS HEX2_mastery_all
      ,CONVERT(FLOAT,[HEX2_pct_pass]) AS HEX2_pct_pass
      ,CONVERT(FLOAT,[HEX3_words]) AS HEX3_words
      ,CONVERT(FLOAT,[HEX3_pct_goal]) AS HEX3_pct_goal
      ,CONVERT(FLOAT,[HEX3_mastery_f]) AS HEX3_mastery_f
      ,CONVERT(FLOAT,[HEX3_mastery_nf]) AS HEX3_mastery_nf
      ,CONVERT(FLOAT,[HEX3_mastery_all]) AS HEX3_mastery_all
      ,CONVERT(FLOAT,[HEX3_pct_pass]) AS HEX3_pct_pass      
      ,CONVERT(FLOAT,[HEX4_words]) AS HEX4_words
      ,CONVERT(FLOAT,[HEX4_pct_goal]) AS HEX4_pct_goal
      ,CONVERT(FLOAT,[HEX4_mastery_f]) AS HEX4_mastery_f
      ,CONVERT(FLOAT,[HEX4_mastery_nf]) AS HEX4_mastery_nf
      ,CONVERT(FLOAT,[HEX4_mastery_all]) AS HEX4_mastery_all
      ,CONVERT(FLOAT,[HEX4_pct_pass]) AS HEX4_pct_pass
      ,CONVERT(FLOAT,[HEX5_words]) AS HEX5_words
      ,CONVERT(FLOAT,[HEX5_pct_goal]) AS HEX5_pct_goal
      ,CONVERT(FLOAT,[HEX5_mastery_f]) AS HEX5_mastery_f
      ,CONVERT(FLOAT,[HEX5_mastery_nf]) AS HEX5_mastery_nf
      ,CONVERT(FLOAT,[HEX5_mastery_all]) AS HEX5_mastery_all
      ,CONVERT(FLOAT,[HEX5_pct_pass]) AS HEX5_pct_pass
      ,CONVERT(FLOAT,[HEX6_words]) AS HEX6_words
      ,CONVERT(FLOAT,[HEX6_pct_goal]) AS HEX6_pct_goal
      ,CONVERT(FLOAT,[HEX6_mastery_f]) AS HEX6_mastery_f
      ,CONVERT(FLOAT,[HEX6_mastery_nf]) AS HEX6_mastery_nf      
      ,CONVERT(FLOAT,[HEX6_mastery_all]) AS HEX6_mastery_all
      ,CONVERT(FLOAT,[HEX6_pct_pass]) AS HEX6_pct_pass      
      ,CONVERT(FLOAT,[B_pct]) AS B_pct
      ,CONVERT(FLOAT,[S_pct]) AS S_pct
      ,CONVERT(FLOAT,[W_pct]) AS W_pct
      ,CONVERT(FLOAT,[B_rit]) AS B_rit
      ,CONVERT(FLOAT,[S_rit]) AS S_rit
      ,CONVERT(FLOAT,[W_rit]) AS W_rit
      ,CONVERT(FLOAT,[B_lexile]) AS B_lexile
      ,CONVERT(FLOAT,[S_lexile]) AS S_lexile
      ,CONVERT(FLOAT,[W_lexile]) AS W_lexile
      ,CONVERT(FLOAT,[W2S_pct_change]) AS W2S_pct_change
      ,CONVERT(FLOAT,[B2W_pct_change]) AS B2W_pct_change
      ,CONVERT(FLOAT,[B2S_pct_change]) AS B2S_pct_change                  
      ,CONVERT(VARCHAR,BOY_read_lvl) AS BOY_read_lvl
      ,CONVERT(VARCHAR,[BOY_indep_lvl]) AS BOY_indep_lvl
      ,CONVERT(FLOAT,[BOY_GLEQ]) AS BOY_GLEQ
      ,CONVERT(FLOAT,[BOY_wpm]) AS BOY_wpm
      ,CONVERT(VARCHAR,[BOY_keylever]) AS BOY_keylever
      ,CONVERT(VARCHAR,T1_read_lvl) AS T1_read_lvl
      ,CONVERT(VARCHAR,T1_indep_lvl) AS T1_indep_lvl
      ,CONVERT(FLOAT,[T1_GLEQ]) AS T1_GLEQ
      ,CONVERT(FLOAT,[T1_wpm]) AS T1_wpm
      ,CONVERT(VARCHAR,[T1_keylever]) AS T1_keylever
      ,CONVERT(VARCHAR,T2_read_lvl) AS T2_read_lvl
      ,CONVERT(VARCHAR,T2_indep_lvl) AS T2_indep_lvl
      ,CONVERT(FLOAT,[T2_GLEQ]) AS T2_GLEQ
      ,CONVERT(FLOAT,[T2_wpm]) AS T2_wpm
      ,CONVERT(VARCHAR,[T2_keylever]) AS T2_keylever
      ,CONVERT(VARCHAR,T3_read_lvl) AS T3_read_lvl
      ,CONVERT(VARCHAR,T3_indep_lvl) AS T3_indep_lvl
      ,CONVERT(FLOAT,[T3_GLEQ]) AS T3_GLEQ
      ,CONVERT(FLOAT,[T3_wpm]) AS T3_wpm
      ,CONVERT(VARCHAR,[T3_keylever]) AS T3_keylever
      ,yr_growth_GLEQ
      ,t1_growth_GLEQ
      ,t2_growth_GLEQ
      ,t3_growth_GLEQ
      ,t1t2_growth_GLEQ
      ,t2t3_growth_GLEQ
      ,t3EOY_growth_GLEQ
      ,CONVERT(FLOAT,[BOY_yrs_behind]) AS [BOY_yrs_behind]
      ,CONVERT(FLOAT,[T1_yrs_behind]) AS [T1_yrs_behind]
      ,CONVERT(FLOAT,[T2_yrs_behind]) AS [T2_yrs_behind]
      ,CONVERT(FLOAT,[T3_yrs_behind]) AS [T3_yrs_behind]
      ,[goal1name]
      ,CONVERT(INT,[goal1ritscore]) AS goal1ritscore
      ,[goal1range]
      ,[goal1adjective]
      ,[goal2name]
      ,CONVERT(INT,[goal2ritscore]) AS goal2ritscore
      ,[goal2range]
      ,[goal2adjective]
      ,[goal3name]
      ,CONVERT(INT,[goal3ritscore]) AS goal3ritscore
      ,[goal3range]
      ,[goal3adjective]
      ,[goal4name]
      ,CONVERT(INT,[goal4ritscore]) AS goal4ritscore
      ,[goal4range]
      ,[goal4adjective]
      ,[goal5name]
      ,CONVERT(INT,[goal5ritscore]) AS goal5ritscore
      ,[goal5range]
      ,[goal5adjective]      
FROM 
    (
     SELECT r.*
           ,ar.header
           ,CONVERT(VARCHAR,ar.value) AS value
     FROM roster r
     JOIN ar_data ar
       ON r.STUDENT_NUMBER = ar.student_number
      AND dbo.YearToTerm(r.year) = ar.yearid

     UNION ALL

     SELECT r.*
           ,map.header
           ,CONVERT(VARCHAR,map.value) AS value
     FROM roster r
     JOIN map_scores map
       ON r.STUDENT_NUMBER = map.STUDENT_NUMBER
      AND r.year = map.year

     UNION ALL

     SELECT r.*
           ,growth.header
           ,CONVERT(VARCHAR,growth.value) AS value
     FROM roster r
     JOIN map_growth growth
       ON r.studentid = growth.studentid
      AND r.year = growth.year

     UNION ALL

     SELECT r.*
           ,fp.header
           ,CONVERT(VARCHAR,fp.value) AS value
     FROM roster r
     JOIN lit_rounds fp
       ON r.studentid = fp.studentid
      AND r.year = fp.year
    
     UNION ALL

     SELECT r.*
           ,lit_growth.header
           ,CONVERT(VARCHAR,lit_growth.value) AS value
     FROM roster r
     JOIN lit_growth
       ON r.studentid = lit_growth.studentid
      AND r.year = lit_growth.year

     UNION ALL

     SELECT r.*
           ,goal.header
           ,CONVERT(VARCHAR,goal.value) AS value
     FROM roster r
     JOIN map_goals goal
       ON r.studentid = goal.studentid
      AND r.year = goal.year
    ) sub

PIVOT (
  MAX(value)
  FOR header IN ([Y1_words]
                ,[Y1_pct_goal]
                ,[Y1_mastery_f]
                ,[Y1_mastery_nf]
                ,[Y1_mastery_all]
                ,[Y1_pct_pass]
                ,[HEX1_words]
                ,[HEX1_pct_goal]
                ,[HEX1_mastery_f]
                ,[HEX1_mastery_nf]
                ,[HEX1_mastery_all]
                ,[HEX1_pct_pass]
                ,[HEX2_words]
                ,[HEX2_pct_goal]
                ,[HEX2_mastery_f]
                ,[HEX2_mastery_nf]
                ,[HEX2_mastery_all]
                ,[HEX2_pct_pass]
                ,[HEX3_words]
                ,[HEX3_pct_goal]
                ,[HEX3_mastery_f]
                ,[HEX3_mastery_nf]
                ,[HEX3_mastery_all]
                ,[HEX3_pct_pass]                
                ,[HEX4_words]
                ,[HEX4_pct_goal]
                ,[HEX4_mastery_f]
                ,[HEX4_mastery_nf]
                ,[HEX4_mastery_all]
                ,[HEX4_pct_pass]
                ,[HEX5_words]
                ,[HEX5_pct_goal]
                ,[HEX5_mastery_f]
                ,[HEX5_mastery_nf]
                ,[HEX5_mastery_all]
                ,[HEX5_pct_pass]
                ,[HEX6_words]
                ,[HEX6_pct_goal]
                ,[HEX6_mastery_f]
                ,[HEX6_mastery_nf]
                ,[HEX6_mastery_all]
                ,[HEX6_pct_pass]                
                ,[B_pct]
                ,[S_pct]
                ,[W_pct]
                ,[B_rit]
                ,[S_rit]
                ,[W_rit]
                ,[B_lexile]
                ,[S_lexile]
                ,[W_lexile]
                ,[W2S_pct_change]
                ,[B2W_pct_change]
                ,[B2S_pct_change]                
                ,[BOY_read_lvl]
                ,[BOY_indep_lvl]
                ,[BOY_GLEQ]
                ,[BOY_wpm]
                ,[BOY_keylever]
                ,[T1_read_lvl]
                ,[T1_indep_lvl]
                ,[T1_GLEQ]
                ,[T1_wpm]
                ,[T1_keylever]
                ,[T2_read_lvl]
                ,[T2_indep_lvl]
                ,[T2_GLEQ]
                ,[T2_wpm]
                ,[T2_keylever]
                ,[T3_read_lvl]
                ,[T3_indep_lvl]
                ,[T3_GLEQ]
                ,[T3_wpm]
                ,[T3_keylever]
                ,[yr_growth_GLEQ]
                ,[t1_growth_GLEQ]
                ,[t2_growth_GLEQ]
                ,[t3_growth_GLEQ]
                ,[t1t2_growth_GLEQ]
                ,[t2t3_growth_GLEQ]
                ,[t3EOY_growth_GLEQ]
                ,[BOY_yrs_behind]
                ,[T1_yrs_behind]
                ,[T2_yrs_behind]
                ,[T3_yrs_behind]
                ,[goal1name]
                ,[goal1ritscore]                
                ,[goal1range]
                ,[goal1adjective]
                ,[goal2name]
                ,[goal2ritscore]                
                ,[goal2range]
                ,[goal2adjective]
                ,[goal3name]
                ,[goal3ritscore]                
                ,[goal3range]
                ,[goal3adjective]
                ,[goal4name]
                ,[goal4ritscore]                
                ,[goal4range]
                ,[goal4adjective]
                ,[goal5name]
                ,[goal5ritscore]                
                ,[goal5range]
                ,[goal5adjective]
                ,[goal6name]
                ,[goal6ritscore]                
                ,[goal6range]
                ,[goal6adjective]
                ,[goal7name]
                ,[goal7ritscore]                
                ,[goal7range]
                ,[goal7adjective]
                ,[goal8name]
                ,[goal8ritscore]                
                ,[goal8range]
                ,[goal8adjective])
 ) p