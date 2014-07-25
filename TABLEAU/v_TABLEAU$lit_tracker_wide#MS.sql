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
        ,cs.SPEDLEP
        ,s.team
  FROM COHORT$comprehensive_long#static co
  LEFT OUTER JOIN STUDENTS s
    ON co.studentid = s.id
  LEFT OUTER JOIN CUSTOM_STUDENTS cs
    ON co.studentid = cs.studentid
  WHERE co.rn = 1
    AND co.schoolid IN (73252,133570965)
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
             ,CONVERT(VARCHAR,CASE 
                               WHEN words_goal > 0 AND ROUND(words / words_goal * 100, 0) > 100 THEN 100
                               WHEN words_goal > 0 AND ROUND(words / words_goal * 100, 0) <= 100 THEN ROUND(words / words_goal * 100, 0)
                               ELSE NULL 
                              END) AS pct_goal
             ,CONVERT(VARCHAR,mastery_fiction) AS mastery_f
             ,CONVERT(VARCHAR,mastery_nonfiction) AS mastery_nf
             ,CONVERT(VARCHAR,CASE WHEN N_total > 0 THEN ROUND(CONVERT(FLOAT,N_passed) / CONVERT(FLOAT,N_total) * 100,0) ELSE NULL END) AS pct_pass
       FROM AR$progress_to_goals_long#static WITH(NOLOCK)
       --WHERE yearid = dbo.fn_Global_Term_Id()
      ) sub
  
  UNPIVOT (
     value
     FOR field IN (words, pct_goal, mastery_f, mastery_nf, pct_pass)
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
               WHEN map.fallwinterspring = 'Fall' THEN 'B'
               WHEN map.fallwinterspring = 'Winter' THEN 'W'
               WHEN map.fallwinterspring = 'Spring' THEN 'S'
              END AS fallwinterspring
             ,CONVERT(VARCHAR,CASE WHEN map.fallwinterspring = 'Fall' THEN base.testritscore ELSE map.testritscore END) AS rit
             ,CONVERT(VARCHAR,CASE WHEN map.fallwinterspring = 'Fall' THEN base.testpercentile ELSE map.testpercentile END) AS pct
             ,CONVERT(VARCHAR,CASE WHEN map.fallwinterspring = 'Fall' THEN base.lexile_score ELSE map.rittoreadingscore END) AS lexile
       FROM COHORT$comprehensive_long#static co  
       JOIN MAP$best_baseline#static base
         ON co.studentid = base.studentid
        AND co.year = base.year
        AND base.measurementscale = 'Reading'
       JOIN MAP$comprehensive#identifiers map
         ON co.studentid = map.ps_studentid
        AND co.year = map.map_year_academic
        AND base.measurementscale = map.measurementscale   
        AND map.rn = 1
       WHERE co.rn = 1
      ) sub
   
  UNPIVOT (
    value
    FOR field IN (pct)
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
             --,fp.academic_year -- no data, replace when year gets started        
             --,test_round -- no data, replace when year gets started
             ,CASE WHEN DATEPART(MONTH,fp.test_date) < 7 THEN DATEPART(YEAR,fp.test_date) - 1 ELSE DATEPART(YEAR,fp.test_date) END AS year
             ,d.time_per_name AS test_round
             ,CONVERT(VARCHAR,fp.read_lvl) AS read_lvl
             ,CONVERT(VARCHAR,fp.GLEQ) AS GLEQ
             ,CONVERT(VARCHAR,CASE WHEN fp.schoolid = 73252 THEN rl.wpm ELSE fp.fp_wpmrate END) AS wpm
       FROM LIT$test_events#identifiers fp
       LEFT OUTER JOIN REPORTING$dates d
         ON fp.test_date >= d.start_date
        AND fp.test_date <= d.end_date
        AND fp.schoolid = d.schoolid
        AND d.identifier = 'LIT'
       LEFT OUTER JOIN SRSLY_DIE_READLIVE rl WITH(NOLOCK)
         ON fp.studentid = rl.studentid
        AND CASE
             WHEN d.time_per_name = 'BOY' THEN 'Fall'
             WHEN d.time_per_name = 'T1' THEN 'Fall'
             WHEN d.time_per_name = 'T2' THEN 'Winter'
             WHEN d.time_per_name = 'T3' THEN 'Winter'
             WHEN d.time_per_name = 'EOY' THEN 'Spring'
            END = rl.season
       WHERE testid = 3273
         AND achv_curr_round = 1    
      ) sub
  
  UNPIVOT (
    value
    FOR field IN (read_lvl, gleq, wpm)
   ) u
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
      ,CONVERT(FLOAT,[Y1_pct_pass]) AS Y1_pct_pass
      ,CONVERT(FLOAT,[HEX1_words]) AS HEX1_words
      ,CONVERT(FLOAT,[HEX1_pct_goal]) AS HEX1_pct_goal
      ,CONVERT(FLOAT,[HEX1_mastery_f]) AS HEX1_mastery_f
      ,CONVERT(FLOAT,[HEX1_pct_pass]) AS HEX1_pct_pass
      ,CONVERT(FLOAT,[HEX2_words]) AS HEX2_words
      ,CONVERT(FLOAT,[HEX2_pct_goal]) AS HEX2_pct_goal
      ,CONVERT(FLOAT,[HEX2_mastery_f]) AS HEX2_mastery_f
      ,CONVERT(FLOAT,[HEX2_mastery_nf]) AS HEX2_mastery_nf
      ,CONVERT(FLOAT,[HEX2_pct_pass]) AS HEX2_pct_pass
      ,CONVERT(FLOAT,[HEX3_words]) AS HEX3_words
      ,CONVERT(FLOAT,[HEX3_pct_goal]) AS HEX3_pct_goal
      ,CONVERT(FLOAT,[HEX3_mastery_f]) AS HEX3_mastery_f
      ,CONVERT(FLOAT,[HEX3_mastery_nf]) AS HEX3_mastery_nf
      ,CONVERT(FLOAT,[HEX3_pct_pass]) AS HEX3_pct_pass
      ,CONVERT(FLOAT,[HEX1_mastery_nf]) AS HEX1_mastery_nf
      ,CONVERT(FLOAT,[HEX4_words]) AS HEX4_words
      ,CONVERT(FLOAT,[HEX4_pct_goal]) AS HEX4_pct_goal
      ,CONVERT(FLOAT,[HEX4_mastery_f]) AS HEX4_mastery_f
      ,CONVERT(FLOAT,[HEX4_pct_pass]) AS HEX4_pct_pass
      ,CONVERT(FLOAT,[HEX5_words]) AS HEX5_words
      ,CONVERT(FLOAT,[HEX5_pct_goal]) AS HEX5_pct_goal
      ,CONVERT(FLOAT,[HEX5_mastery_f]) AS HEX5_mastery_f
      ,CONVERT(FLOAT,[HEX5_mastery_nf]) AS HEX5_mastery_nf
      ,CONVERT(FLOAT,[HEX5_pct_pass]) AS HEX5_pct_pass
      ,CONVERT(FLOAT,[HEX6_words]) AS HEX6_words
      ,CONVERT(FLOAT,[HEX6_pct_goal]) AS HEX6_pct_goal
      ,CONVERT(FLOAT,[HEX6_mastery_f]) AS HEX6_mastery_f
      ,CONVERT(FLOAT,[HEX6_pct_pass]) AS HEX6_pct_pass
      ,CONVERT(FLOAT,[HEX6_mastery_nf]) AS HEX6_mastery_nf
      ,CONVERT(FLOAT,[HEX4_mastery_nf]) AS HEX4_mastery_nf
      ,CONVERT(FLOAT,[B_pct]) AS B_pct
      ,CONVERT(FLOAT,[S_pct]) AS S_pct
      ,CONVERT(FLOAT,[W_pct]) AS W_pct
      ,CONVERT(FLOAT,[W2S_pct_change]) AS W2S_pct_change
      ,CONVERT(FLOAT,[B2W_pct_change]) AS B2W_pct_change
      ,CONVERT(FLOAT,[B2S_pct_change]) AS B2S_pct_change                  
      ,BOY_read_lvl
      ,CONVERT(FLOAT,[BOY_GLEQ]) AS BOY_GLEQ
      ,CONVERT(FLOAT,[BOY_wpm]) AS BOY_wpm
      ,T1_read_lvl
      ,CONVERT(FLOAT,[T1_GLEQ]) AS T1_GLEQ
      ,CONVERT(FLOAT,[T1_wpm]) AS T1_wpm
      ,T2_read_lvl      
      ,CONVERT(FLOAT,[T2_GLEQ]) AS T2_GLEQ
      ,CONVERT(FLOAT,[T2_wpm]) AS T2_wpm
      ,T3_read_lvl
      ,CONVERT(FLOAT,[T3_GLEQ]) AS T3_GLEQ
      ,CONVERT(FLOAT,[T3_wpm]) AS T3_wpm
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
    ) sub

PIVOT (
  MAX(value)
  FOR header IN ([Y1_words]
                ,[Y1_pct_goal]
                ,[Y1_mastery_f]
                ,[Y1_mastery_nf]
                ,[Y1_pct_pass]
                ,[HEX1_words]
                ,[HEX1_pct_goal]
                ,[HEX1_mastery_f]
                ,[HEX1_pct_pass]
                ,[HEX2_words]
                ,[HEX2_pct_goal]
                ,[HEX2_mastery_f]
                ,[HEX2_mastery_nf]
                ,[HEX2_pct_pass]
                ,[HEX3_words]
                ,[HEX3_pct_goal]
                ,[HEX3_mastery_f]
                ,[HEX3_mastery_nf]
                ,[HEX3_pct_pass]
                ,[HEX1_mastery_nf]
                ,[HEX4_words]
                ,[HEX4_pct_goal]
                ,[HEX4_mastery_f]
                ,[HEX4_pct_pass]
                ,[HEX5_words]
                ,[HEX5_pct_goal]
                ,[HEX5_mastery_f]
                ,[HEX5_mastery_nf]
                ,[HEX5_pct_pass]
                ,[HEX6_words]
                ,[HEX6_pct_goal]
                ,[HEX6_mastery_f]
                ,[HEX6_pct_pass]
                ,[HEX6_mastery_nf]
                ,[HEX4_mastery_nf]
                ,[B_pct]
                ,[S_pct]
                ,[W_pct]
                ,[W2S_pct_change]
                ,[B2W_pct_change]
                ,[B2S_pct_change]                
                ,[T2_read_lvl]
                ,[T2_GLEQ]
                ,[T3_read_lvl]
                ,[T3_GLEQ]
                ,[T3_wpm]
                ,[T2_wpm]
                ,[T1_read_lvl]
                ,[T1_GLEQ]
                ,[T1_wpm]
                ,[BOY_read_lvl]
                ,[BOY_GLEQ]
                ,[BOY_wpm])
 ) p