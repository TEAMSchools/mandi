USE KIPP_NJ
GO

ALTER VIEW reporting$reading_log AS

WITH roster AS (
  SELECT c.studentid
        ,c.student_number
        ,c.grade_level
        ,c.schoolid
        ,c.lastfirst
        ,c.full_name AS name
        ,c.school_name AS school
  FROM KIPP_NJ..COHORT$identifiers_long#static c WITH(NOLOCK)   
  WHERE year = dbo.fn_Global_Academic_Year()
    AND rn = 1    
    AND c.schoolid IN (73252, 133570965)
    AND c.enroll_status = 0    
 )
 
,curterm AS (
  SELECT schoolid
        ,REPLACE(time_per_name,'Hexameter ','RT') AS time_per_name
        ,alt_name
        ,start_date
        ,end_date
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE GETDATE() >= start_date
    AND GETDATE() <= end_date
    AND identifier = 'HEX'
 )
 
--,enrollments AS (
--  SELECT cc.termid AS termid
--        ,cc.studentid
--        ,sections.id AS sectionid
--        ,sections.section_number
--        ,courses.course_number
--        ,courses.course_name
--  FROM cc WITH(NOLOCK)
--  JOIN sections WITH(NOLOCK)
--    ON cc.sectionid = sections.id
--   AND cc.termid >= dbo.fn_Global_Term_Id()
--  JOIN courses WITH(NOLOCK)
--    ON sections.course_number = courses.course_number
--   AND courses.credittype LIKE 'ENG'
--  WHERE cc.dateenrolled <= GETDATE()
--	   AND cc.dateleft >= GETDATE()
-- )
  
,map_goals AS (
  SELECT studentid
        ,keep_up_goal
        ,keep_up_rit
        ,rutgers_ready_goal
        ,rutgers_ready_rit
  FROM KIPP_NJ..MAP$rutgers_ready_student_goals g WITH(NOLOCK)
  WHERE g.measurementscale = 'Reading'
    AND g.year = dbo.fn_Global_Academic_Year()
 )

,cur_rit AS (
  SELECT ps_studentid
        ,[map_year_academic]
        ,[fallwinterspring]
        ,[map_year]
        ,[TermName]
        ,[MeasurementScale]
        ,[TestRITScore]
        ,TestPercentile
        ,[RITtoReadingScore]        
    FROM KIPP_NJ..MAP$comprehensive#identifiers map WITH(NOLOCK)
    WHERE map.MeasurementScale = 'Reading'
      AND map.map_year_academic = dbo.fn_Global_Academic_Year()
      AND map.rn_curr = 1
 )

,readlive AS (
  SELECT studentid
        ,wpm        
        ,yearid
        ,ROW_NUMBER() OVER(
           PARTITION BY studentid, yearid
             ORDER BY CASE WHEN season = 'Fall' THEN 1 WHEN season = 'Winter' THEN 2 WHEN season = 'Spring' THEN 3 ELSE NULL END ASC) AS rn_base
        ,ROW_NUMBER() OVER(
           PARTITION BY studentid
             ORDER BY yearid DESC, CASE WHEN season = 'Fall' THEN 1 WHEN season = 'Winter' THEN 2 WHEN season = 'Spring' THEN 3 ELSE NULL END DESC) AS rn_cur
  FROM SRSLY_DIE_READLIVE WITH(NOLOCK)
 )
     
SELECT roster.studentid
      ,roster.student_number
      ,roster.grade_level
      ,roster.schoolid
      ,roster.lastfirst
      ,roster.name
      ,roster.school
      ,enr.course_name + '|' + enr.section_number AS enr_hash
      ,gr.course_number
      ,gr.course_name
      ,gr_cur.pct AS cur_term_rdg_gr
      ,gr.Y1 AS y1_rdg_gr
      ,ele.grade_1 AS cur_term_rdg_hw_avg /*--UPDATE FIELD FOR CURRENT TERM--*/
      ,ele.simple_avg AS y1_rdg_hw_avg
      ,COALESCE(fp_base.read_lvl, fp_cur.read_lvl) AS fp_base_letter
      ,COALESCE(fp_cur.read_lvl, fp_dna_curr.read_lvl) AS fp_cur_letter
      ,base.testritscore AS map_baseline
      ,COALESCE(cur_rit.TestRITScore, base.testritscore) AS cur_RIT
      ,COALESCE(cur_rit.TestPercentile, base.testpercentile) AS cur_RIT_percentile
       --use MAP for lexile      
      ,base.lexile_score AS lexile_baseline_MAP
      ,map_fall.rittoreadingscore AS lexile_fall
      ,map_winter.rittoreadingscore AS lexile_winter
       --readlive
      ,rl_base.wpm AS starting_fluency
      ,COALESCE(rl_cur.wpm, rl_base.wpm) AS cur_fluency      
 
       --AR cur
      ,replace(convert(varchar,convert(Money, ar_cur.words),1),'.00','') AS hex_words
      ,replace(convert(varchar,convert(Money, ar_cur.words_goal),1),'.00','') AS hex_goal
      ,replace(convert(varchar,convert(Money, CAST(ROUND(ar_cur.ontrack_words,0) AS INT)),1),'.00','') AS hex_needed
      ,ar_cur.stu_status_words AS hex_on_track
      ,ar_cur.rank_words_grade_in_school AS hex_rank_words
      ,ar_cur.N_passed
      ,ar_cur.N_total
      --accuracy cur term
      ,ar_cur.mastery AS cur_accuracy
      ,ar_cur.mastery_fiction AS cur_accuracy_fiction
      ,ar_cur.mastery_nonfiction AS cur_accuracy_nonfiction

       --AR year
      ,replace(convert(varchar,convert(Money, ar_year.words),1),'.00','') AS year_words
      ,replace(convert(varchar,convert(Money, ar_year.words_goal),1),'.00','') AS year_goal  
      ,100 - ar_year.pct_fiction AS year_pct_nf 
      ,ar_year.rank_words_grade_in_school AS year_rank_words
      --accuracy year
      ,ar_year.mastery AS accuracy
      ,ar_year.mastery_fiction AS accuracy_fiction
      ,ar_year.mastery_nonfiction AS accuracy_nonfiction
      ,ar_year.n_fiction
      ,ar_year.n_nonfic
      ,ROUND((CONVERT(FLOAT,ar_year.N_passed) / CONVERT(FLOAT,ar_year.N_total) * 100),1) AS pct_passing_yr
      
      --AR by Hex
        --Hex 1
      ,replace(convert(varchar,convert(Money, ar_h1.words),1),'.00','') AS hex1_words
      ,replace(convert(varchar,convert(Money, ar_h1.words_goal),1),'.00','') AS hex1_goal
      ,CASE
        WHEN CONVERT(FLOAT,ROUND((ar_h1.words / ar_h1.words_goal * 100),1)) > 100 THEN 100 
        ELSE CONVERT(FLOAT,ROUND((ar_h1.words / ar_h1.words_goal * 100),1))
       END AS hex1_pct_goal
      ,ROUND((CONVERT(FLOAT,ar_h1.N_passed) / CONVERT(FLOAT,ar_h1.N_total) * 100),1) AS hex1_pct_passing
      ,ar_h1.mastery_fiction AS hex1_accuracy_fiction
      ,ar_h1.mastery_nonfiction AS hex1_accuracy_nonfiction
      ,ar_h1.mastery AS hex1_accuracy_all
        --Hex 2
      ,replace(convert(varchar,convert(Money, ar_h2.words),1),'.00','') AS hex2_words
      ,replace(convert(varchar,convert(Money, ar_h2.words_goal),1),'.00','') AS hex2_goal
      ,CASE
        WHEN CONVERT(FLOAT,ROUND((ar_h2.words / ar_h2.words_goal * 100),1)) > 100 THEN 100
        ELSE CONVERT(FLOAT,ROUND((ar_h2.words / ar_h2.words_goal * 100),1))
       END AS hex2_pct_goal
      ,ROUND((CONVERT(FLOAT,ar_h2.N_passed) / CONVERT(FLOAT,ar_h2.N_total) * 100),1) AS hex2_pct_passing
      ,ar_h2.mastery_fiction AS hex2_accuracy_fiction
      ,ar_h2.mastery_nonfiction AS hex2_accuracy_nonfiction
      ,ar_h2.mastery AS hex2_accuracy_all
        --Hex 3
      ,replace(convert(varchar,convert(Money, ar_h3.words),1),'.00','') AS hex3_words
      ,replace(convert(varchar,convert(Money, ar_h3.words_goal),1),'.00','') AS hex3_goal
      ,CASE
        WHEN CONVERT(FLOAT,ROUND((ar_h3.words / ar_h3.words_goal * 100),1)) > 100 THEN 100
        ELSE CONVERT(FLOAT,ROUND((ar_h3.words / ar_h3.words_goal * 100),1))
       END AS hex3_pct_goal
      ,ROUND((CONVERT(FLOAT,ar_h3.N_passed) / CONVERT(FLOAT,ar_h3.N_total) * 100),1) AS hex3_pct_passing
      ,ar_h3.mastery_fiction AS hex3_accuracy_fiction
      ,ar_h3.mastery_nonfiction AS hex3_accuracy_nonfiction
      ,ar_h3.mastery AS hex3_accuracy_all
        --Hex 4
      ,replace(convert(varchar,convert(Money, ar_h4.words),1),'.00','') AS hex4_words
      ,replace(convert(varchar,convert(Money, ar_h4.words_goal),1),'.00','') AS hex4_goal
      ,CASE
        WHEN CONVERT(FLOAT,ROUND((ar_h4.words / ar_h4.words_goal * 100),1)) > 100 THEN 100
        ELSE CONVERT(FLOAT,ROUND((ar_h4.words / ar_h4.words_goal * 100),1))
       END AS hex4_pct_goal
      ,ROUND((CONVERT(FLOAT,ar_h4.N_passed) / CONVERT(FLOAT,ar_h4.N_total) * 100),1) AS hex4_pct_passing
      ,ar_h4.mastery_fiction AS hex4_accuracy_fiction
      ,ar_h4.mastery_nonfiction AS hex4_accuracy_nonfiction      
      ,ar_h4.mastery AS hex4_accuracy_all
        --Hex 5
      ,replace(convert(varchar,convert(Money, ar_h5.words),1),'.00','') AS hex5_words
      ,replace(convert(varchar,convert(Money, ar_h5.words_goal),1),'.00','') AS hex5_goal
      ,CASE
        WHEN CONVERT(FLOAT,ROUND((ar_h5.words / ar_h5.words_goal * 100),1)) > 100 THEN 100
        ELSE CONVERT(FLOAT,ROUND((ar_h5.words / ar_h5.words_goal * 100),1))
       END AS hex5_pct_goal
      ,ROUND((CONVERT(FLOAT,ar_h5.N_passed) / CONVERT(FLOAT,ar_h5.N_total) * 100),1) AS hex5_pct_passing
      ,ar_h5.mastery_fiction AS hex5_accuracy_fiction
      ,ar_h5.mastery_nonfiction AS hex5_accuracy_nonfiction
      ,ar_h5.mastery AS hex5_accuracy_all
        --Hex 6
      ,replace(convert(varchar,convert(Money, ar_h6.words),1),'.00','') AS hex6_words
      ,replace(convert(varchar,convert(Money, ar_h6.words_goal),1),'.00','') AS hex6_goal
      ,CASE
        WHEN CONVERT(FLOAT,ROUND((ar_h6.words / ar_h6.words_goal * 100),1)) > 100 THEN 100
        ELSE CONVERT(FLOAT,ROUND((ar_h6.words / ar_h6.words_goal * 100),1))
       END AS hex6_pct_goal
      ,ROUND((CONVERT(FLOAT,ar_h6.N_passed) / CONVERT(FLOAT,ar_h6.N_total) * 100),1) AS hex6_pct_passing
      ,ar_h6.mastery_fiction AS hex6_accuracy_fiction
      ,ar_h6.mastery_nonfiction AS hex6_accuracy_nonfiction
      ,ar_h6.mastery AS hex6_accuracy_all

      ,map_goals.keep_up_goal
      ,map_goals.keep_up_rit
      ,map_goals.rutgers_ready_goal
      ,map_goals.rutgers_ready_rit
      
FROM roster

--ENR
LEFT OUTER JOIN PS$course_enrollments#static enr
  ON roster.studentid = enr.studentid
 AND enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 AND enr.credittype IN ('ENG','READ')
 AND enr.dateenrolled <= CONVERT(DATE,GETDATE())
 AND enr.dateleft >= CONVERT(DATE,GETDATE()) 

--CURTERM  
LEFT OUTER JOIN curterm
  ON roster.schoolid = curterm.schoolid  

--GRADES
LEFT OUTER JOIN KIPP_NJ..GRADES$DETAIL#MS gr WITH(NOLOCK)
  ON roster.studentid = gr.studentid
 AND gr.credittype LIKE '%ENG%'
LEFT OUTER JOIN KIPP_NJ..GRADES$detail_long_term#MS gr_cur WITH(NOLOCK)
  ON roster.studentid = gr_cur.studentid
 AND curterm.alt_name = gr_cur.term
 AND gr_cur.credittype LIKE '%ENG%'

--HW
LEFT OUTER JOIN KIPP_NJ..GRADES$elements ele WITH(NOLOCK)
  ON roster.studentid = ele.studentid
 AND gr.course_number = ele.course_number
 AND ele.pgf_type = 'H'
 AND ele.yearid = LEFT(dbo.fn_Global_Term_Id(), 2)

--F&P
LEFT OUTER JOIN LIT$test_events#identifiers fp_cur WITH(NOLOCK)
  ON roster.STUDENTID = fp_cur.studentid
 AND fp_cur.achv_curr_all = 1
LEFT OUTER JOIN LIT$test_events#identifiers fp_base WITH(NOLOCK)
  ON roster.STUDENTID = fp_base.studentid
 AND fp_base.achv_base_yr = 1
 AND fp_base.academic_year = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN LIT$test_events#identifiers fp_dna_curr WITH(NOLOCK)
  ON roster.STUDENTID = fp_dna_curr.studentid
 AND fp_dna_curr.dna_all = 1
 AND fp_dna_curr.academic_year = dbo.fn_Global_Academic_Year()

--RIT, NWEA LEXILE
LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
  ON roster.studentid = base.studentid
 AND base.year = dbo.fn_Global_Academic_Year()
 AND base.measurementscale = 'Reading'
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers#static map_fall WITH(NOLOCK)
  ON roster.studentid = map_fall.ps_studentid
 AND map_fall.measurementscale = 'Reading'
 AND map_fall.map_year_academic = dbo.fn_Global_Academic_Year()
 AND map_fall.fallwinterspring = 'Fall'
 AND map_fall.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers#static map_winter WITH(NOLOCK)
  ON roster.studentid = map_winter.ps_studentid
 AND map_winter.measurementscale = 'Reading'
 AND map_winter.map_year_academic = dbo.fn_Global_Academic_Year()
 AND map_winter.fallwinterspring = 'Winter'
 AND map_winter.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers#static map_spr WITH(NOLOCK)
  ON roster.studentid = map_spr.ps_studentid
 AND map_spr.measurementscale = 'Reading'
 AND map_spr.map_year_academic = (dbo.fn_Global_Academic_Year() - 1)
 AND map_spr.fallwinterspring = 'Spring'
 AND map_spr.rn = 1
LEFT OUTER JOIN cur_rit
  ON roster.studentid = cur_rit.ps_studentid 

LEFT OUTER JOIN readlive rl_base WITH(NOLOCK)
  ON roster.studentid = rl_base.studentid 
 AND rl_base.rn_base = 1
 AND rl_base.yearid = KIPP_NJ.dbo.fn_Global_Term_ID()
LEFT OUTER JOIN readlive rl_cur WITH(NOLOCK)
  ON roster.studentid = rl_cur.studentid 
 AND rl_cur.rn_cur = 1

--AR
--current
LEFT OUTER JOIN KIPP_NJ..[AR$progress_to_goals_long#static] ar_cur WITH(NOLOCK)
  ON roster.studentid = ar_cur.studentid
 AND ar_cur.time_period_name = curterm.time_per_name
 AND ar_cur.yearid = dbo.fn_Global_Term_Id() 
--year
LEFT OUTER JOIN KIPP_NJ..[AR$progress_to_goals_long#static] ar_year WITH(NOLOCK)
  ON roster.studentid = ar_year.studentid
 AND ar_year.time_period_name = 'Year'
 AND ar_year.yearid = dbo.fn_Global_Term_Id()
--individual hex 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_h1 WITH (NOLOCK)
  ON roster.studentid = ar_h1.studentid 
 AND ar_h1.time_period_name = 'RT1'
 AND ar_h1.yearid = dbo.fn_Global_Term_Id()
 AND ar_h1.words_goal > 0
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_h2 WITH (NOLOCK)
  ON roster.studentid = ar_h2.studentid
 AND ar_h2.time_period_name = 'RT2'
 AND ar_h2.yearid = dbo.fn_Global_Term_Id() 
 AND ar_h2.words_goal > 0
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_h3 WITH (NOLOCK)
  ON roster.studentid = ar_h3.studentid
 AND ar_h3.time_period_name = 'RT3'
 AND ar_h3.yearid = dbo.fn_Global_Term_Id() 
 AND ar_h3.words_goal > 0
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_h4 WITH (NOLOCK)
  ON roster.studentid = ar_h4.studentid
 AND ar_h4.time_period_name = 'RT4'
 AND ar_h4.yearid = dbo.fn_Global_Term_Id()  
 AND ar_h4.words_goal > 0
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_h5 WITH (NOLOCK)
  ON roster.studentid = ar_h5.studentid
 AND ar_h5.time_period_name = 'RT5'
 AND ar_h5.yearid = dbo.fn_Global_Term_Id()  
 AND ar_h5.words_goal > 0
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_h6 WITH (NOLOCK)
  ON roster.studentid = ar_h6.studentid
 AND ar_h6.time_period_name = 'RT6'
 AND ar_h6.yearid = dbo.fn_Global_Term_Id()
 AND ar_h6.words_goal > 0

LEFT OUTER JOIN map_goals
  ON roster.studentid = map_goals.studentid