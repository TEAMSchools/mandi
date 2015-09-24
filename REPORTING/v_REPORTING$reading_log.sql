USE KIPP_NJ
GO

ALTER VIEW REPORTING$reading_log AS

WITH curhex AS (
  SELECT schoolid
        ,time_per_name
        ,alt_name
        ,start_date
        ,end_date
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
    AND identifier = 'RT'
    AND school_level = 'MS'
 )

,fp AS (
  SELECT STUDENTID
        ,base AS fp_base
        ,COALESCE(curr, base) AS fp_curr
  FROM
      (
       SELECT STUDENTID           
             ,read_lvl
             ,COALESCE(
                CASE 
                 WHEN ROW_NUMBER() OVER(
                        PARTITION BY studentid, academic_year
                          ORDER BY start_date ASC) = 1 THEN 'base'
                 ELSE NULL
                END
               ,CASE
                 WHEN ROW_NUMBER() OVER(
                        PARTITION BY studentid, academic_year
                          ORDER BY start_date DESC) = 1 THEN 'curr' 
                 ELSE NULL
                END) AS pivot_hash
       FROM KIPP_NJ..LIT$achieved_by_round#static WITH(NOLOCK)
       WHERE read_lvl IS NOT NULL
         AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  PIVOT(
    MAX(read_lvl)
    FOR pivot_hash IN ([base],[curr])
   ) p
)

,ar_wide AS (
  SELECT *
  FROM
      (
       SELECT studentid
             ,academic_year
             ,CONCAT(term, '_', field) AS pivot_field
             ,value
       FROM
           (
            SELECT ar_hex.studentid
                  ,ar_hex.academic_year
                  ,REPLACE(ar_hex.time_period_name,'RT','HEX') AS term
                  ,CONVERT(VARCHAR,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_hex.WORDS),1),'.00','')) AS WORDS
                  ,CONVERT(VARCHAR,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_hex.WORDS_GOAL),1),'.00','')) AS GOAL
                  ,CONVERT(VARCHAR,CASE
                    WHEN CONVERT(FLOAT,ROUND((ar_hex.words / ar_hex.words_goal * 100),1)) > 100 THEN 100 
                    ELSE CONVERT(FLOAT,ROUND((ar_hex.words / ar_hex.words_goal * 100),1))
                   END) AS pct_goal
                  ,CONVERT(VARCHAR,ROUND((CONVERT(FLOAT,ar_hex.N_passed) / CONVERT(FLOAT,ar_hex.N_total) * 100),1)) AS pct_passing
                  ,CONVERT(VARCHAR,ar_hex.mastery_fiction) AS accuracy_fiction
                  ,CONVERT(VARCHAR,ar_hex.mastery_nonfiction) AS accuracy_nonfiction
                  ,CONVERT(VARCHAR,ar_hex.mastery) AS accuracy_all           
            FROM KIPP_NJ..AR$progress_to_goals_long#static ar_hex WITH (NOLOCK)  
            WHERE ar_hex.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
              AND ar_hex.time_period_name != 'Year'
              AND ar_hex.words_goal > 0
           ) sub
       UNPIVOT(
         value
         FOR field IN (words
                      ,goal
                      ,pct_goal
                      ,pct_passing
                      ,accuracy_fiction
                      ,accuracy_nonfiction
                      ,accuracy_all)
        ) u
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([HEX1_accuracy_all]
                       ,[HEX1_accuracy_fiction]
                       ,[HEX1_accuracy_nonfiction]
                       ,[HEX1_GOAL]
                       ,[HEX1_pct_goal]
                       ,[HEX1_pct_passing]
                       ,[HEX1_WORDS]
                       ,[HEX2_accuracy_all]
                       ,[HEX2_accuracy_fiction]
                       ,[HEX2_accuracy_nonfiction]
                       ,[HEX2_GOAL]
                       ,[HEX2_pct_goal]
                       ,[HEX2_pct_passing]
                       ,[HEX2_WORDS]
                       ,[HEX3_accuracy_all]
                       ,[HEX3_accuracy_fiction]
                       ,[HEX3_accuracy_nonfiction]
                       ,[HEX3_GOAL]
                       ,[HEX3_pct_goal]
                       ,[HEX3_pct_passing]
                       ,[HEX3_WORDS]
                       ,[HEX4_accuracy_all]
                       ,[HEX4_accuracy_fiction]
                       ,[HEX4_accuracy_nonfiction]
                       ,[HEX4_GOAL]
                       ,[HEX4_pct_goal]
                       ,[HEX4_pct_passing]
                       ,[HEX4_WORDS]
                       ,[HEX5_accuracy_all]
                       ,[HEX5_accuracy_fiction]
                       ,[HEX5_accuracy_nonfiction]
                       ,[HEX5_GOAL]
                       ,[HEX5_pct_goal]
                       ,[HEX5_pct_passing]
                       ,[HEX5_WORDS]
                       ,[HEX6_accuracy_all]
                       ,[HEX6_accuracy_fiction]
                       ,[HEX6_accuracy_nonfiction]
                       ,[HEX6_GOAL]
                       ,[HEX6_pct_goal]
                       ,[HEX6_pct_passing]
                       ,[HEX6_WORDS])
   ) p
)

SELECT roster.studentid
      ,roster.student_number
      ,roster.grade_level
      ,roster.schoolid
      ,roster.lastfirst
      ,roster.full_name AS name
      ,roster.school_name AS school     
      ,enr.course_name + '|' + enr.section_number AS enr_hash
      ,enr.course_number
      ,enr.course_name

      /* grades */
      ,gr_cur.term_pct AS cur_term_rdg_gr
      ,gr.Y1 AS y1_rdg_gr
      ,ele.grade AS cur_term_rdg_hw_avg
      ,ele_y1.grade AS y1_rdg_hw_avg
      
      /* F&P */
      ,fp.fp_base AS fp_base_letter
      ,fp.fp_curr AS fp_cur_letter
      
      /* MAP */
      ,base.testritscore AS map_baseline
      ,COALESCE(cur_rit.TestRITScore, base.testritscore) AS cur_RIT
      ,COALESCE(cur_rit.TestPercentile, base.testpercentile) AS cur_RIT_percentile       
      /* Lexile */
      ,base.lexile_score AS lexile_baseline_MAP
      ,map_fall.rittoreadingscore AS lexile_fall
      ,map_winter.rittoreadingscore AS lexile_winter       
      
      /* Readlive = ded */
      ,NULL /*rl_base.wpm*/ AS starting_fluency
      ,NULL /*COALESCE(rl_cur.wpm, rl_base.wpm)*/ AS cur_fluency      
 
       /* AR curterm */
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, AR_CUR.WORDS),1),'.00','') AS HEX_WORDS
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, AR_CUR.WORDS_GOAL),1),'.00','') AS HEX_GOAL
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, CAST(ROUND(AR_CUR.ONTRACK_WORDS,0) AS INT)),1),'.00','') AS HEX_NEEDED
      ,ar_cur.stu_status_words AS hex_on_track
      ,ar_cur.rank_words_grade_in_school AS hex_rank_words
      ,ar_cur.N_passed
      ,ar_cur.N_total      
      ,ar_cur.mastery AS cur_accuracy
      ,ar_cur.mastery_fiction AS cur_accuracy_fiction
      ,ar_cur.mastery_nonfiction AS cur_accuracy_nonfiction

       /* AR yr */
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,AR_YEAR.WORDS),1),'.00','') AS YEAR_WORDS
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,AR_YEAR.WORDS_GOAL),1),'.00','') AS YEAR_GOAL
      ,100 - ar_year.pct_fiction AS year_pct_nf 
      ,ar_year.rank_words_grade_in_school AS year_rank_words      
      ,ar_year.mastery AS accuracy
      ,ar_year.mastery_fiction AS accuracy_fiction
      ,ar_year.mastery_nonfiction AS accuracy_nonfiction
      ,ar_year.n_fiction
      ,ar_year.n_nonfic
      ,ROUND((CONVERT(FLOAT,ar_year.N_passed) / CONVERT(FLOAT,ar_year.N_total) * 100), 1) AS pct_passing_yr
      
      /* AR by hex */
      ,[HEX1_accuracy_all]
      ,[HEX1_accuracy_fiction]
      ,[HEX1_accuracy_nonfiction]
      ,[HEX1_GOAL]
      ,[HEX1_pct_goal]
      ,[HEX1_pct_passing]
      ,[HEX1_WORDS]
      ,[HEX2_accuracy_all]
      ,[HEX2_accuracy_fiction]
      ,[HEX2_accuracy_nonfiction]
      ,[HEX2_GOAL]
      ,[HEX2_pct_goal]
      ,[HEX2_pct_passing]
      ,[HEX2_WORDS]
      ,[HEX3_accuracy_all]
      ,[HEX3_accuracy_fiction]
      ,[HEX3_accuracy_nonfiction]
      ,[HEX3_GOAL]
      ,[HEX3_pct_goal]
      ,[HEX3_pct_passing]
      ,[HEX3_WORDS]
      ,[HEX4_accuracy_all]
      ,[HEX4_accuracy_fiction]
      ,[HEX4_accuracy_nonfiction]
      ,[HEX4_GOAL]
      ,[HEX4_pct_goal]
      ,[HEX4_pct_passing]
      ,[HEX4_WORDS]
      ,[HEX5_accuracy_all]
      ,[HEX5_accuracy_fiction]
      ,[HEX5_accuracy_nonfiction]
      ,[HEX5_GOAL]
      ,[HEX5_pct_goal]
      ,[HEX5_pct_passing]
      ,[HEX5_WORDS]
      ,[HEX6_accuracy_all]
      ,[HEX6_accuracy_fiction]
      ,[HEX6_accuracy_nonfiction]
      ,[HEX6_GOAL]
      ,[HEX6_pct_goal]
      ,[HEX6_pct_passing]
      ,[HEX6_WORDS]        

      /* MAP */
      ,map_goals.keep_up_goal
      ,map_goals.keep_up_rit
      ,map_goals.rutgers_ready_goal
      ,map_goals.rutgers_ready_rit      
FROM KIPP_NJ..COHORT$identifiers_long#static roster WITH(NOLOCK)   
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr
  ON roster.studentid = enr.studentid
 AND roster.year = enr.academic_year
 AND enr.credittype IN ('ENG','READ')
 AND CONVERT(DATE,GETDATE()) BETWEEN enr.dateenrolled AND enr.dateleft
LEFT OUTER JOIN curhex
  ON roster.schoolid = curhex.schoolid  
LEFT OUTER JOIN KIPP_NJ..GRADES$DETAIL#MS gr WITH(NOLOCK)
  ON roster.studentid = gr.studentid
 AND gr.credittype LIKE '%ENG%'
LEFT OUTER JOIN KIPP_NJ..GRADES$detail_long gr_cur WITH(NOLOCK)
  ON roster.studentid = gr_cur.studentid
 AND curhex.alt_name = gr_cur.term
 AND gr_cur.credittype LIKE '%ENG%'
LEFT OUTER JOIN KIPP_NJ..GRADES$elements_long ele WITH(NOLOCK)
  ON roster.studentid = ele.studentid
 AND roster.year = ele.academic_year
 AND curhex.alt_name = ele.term
 AND gr.course_number = ele.course_number  
 AND ele.pgf_type = 'H'
LEFT OUTER JOIN KIPP_NJ..GRADES$elements_long ele_y1 WITH(NOLOCK)
  ON roster.studentid = ele_y1.studentid
 AND roster.year = ele_y1.academic_year 
 AND gr.course_number = ele_y1.course_number  
 AND ele_y1.term = 'Y1'
 AND ele_y1.pgf_type = 'H'
LEFT OUTER JOIN fp
  ON roster.studentid = fp.STUDENTID
LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
  ON roster.studentid = base.studentid
 AND base.year = dbo.fn_Global_Academic_Year()
 AND base.measurementscale = 'Reading'
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_fall WITH(NOLOCK)
  ON roster.student_number = map_fall.student_number
 AND roster.year = map_fall.academic_year
 AND map_fall.measurementscale = 'Reading' 
 AND map_fall.term = 'Fall'
 AND map_fall.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_winter WITH(NOLOCK)
  ON roster.studentid = map_winter.student_number
 AND roster.year = map_winter.academic_year
 AND map_winter.measurementscale = 'Reading' 
 AND map_winter.term = 'Winter'
 AND map_winter.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_spr WITH(NOLOCK)
  ON roster.studentid = map_spr.student_number
 AND roster.year - 1 = map_spr.academic_year
 AND map_spr.measurementscale = 'Reading' 
 AND map_spr.term = 'Spring'
 AND map_spr.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static cur_rit WITH(NOLOCK)
  ON roster.studentid = cur_rit.student_number 
 AND roster.year = cur_rit.academic_year
 AND cur_rit.MeasurementScale = 'Reading'    
 AND cur_rit.rn_curr = 1  
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_cur WITH(NOLOCK)
  ON roster.studentid = ar_cur.studentid
 AND roster.year = ar_cur.academic_year
 AND ar_cur.time_period_name = curhex.time_per_name
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_year WITH(NOLOCK)
  ON roster.studentid = ar_year.studentid
 AND roster.year = ar_year.academic_year
 AND ar_year.time_period_name = 'Year' 
LEFT OUTER JOIN ar_wide WITH (NOLOCK)
  ON roster.studentid = ar_wide.studentid 
LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals map_goals WITH(NOLOCK)      
  ON roster.studentid = map_goals.studentid
 AND roster.year = map_goals.year
 AND map_goals.measurementscale = 'Reading'
WHERE roster.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND roster.schoolid IN (73252, 133570965)
  AND roster.enroll_status = 0    
  AND roster.rn = 1    