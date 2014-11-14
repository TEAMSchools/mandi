USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card_term#ES AS

WITH roster AS (
 SELECT co.STUDENTID
       ,co.STUDENT_NUMBER      
       ,co.LASTFIRST       
       ,co.FIRST_NAME
       ,REPLACE(co.GRADE_LEVEL, 0 ,'K') AS grade_level
       ,co.SCHOOLID
       ,co.school_name
       ,co.TEAM       
 FROM COHORT$identifiers_long#static co WITH(NOLOCK) 
 WHERE co.YEAR = dbo.fn_Global_Academic_Year()
   AND co.GRADE_LEVEL < 5
   AND co.RN = 1
   AND co.enroll_status = 0
 )

,curterm AS (
  SELECT DISTINCT 'RT' + CONVERT(VARCHAR,(RIGHT(time_per_name,1) - 1)) AS time_per_name                 
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND school_level = 'ES'
    --AND start_date <= GETDATE()
    --AND end_date >= GETDATE()
    AND start_date <= '2014-12-02' -- testing
    AND end_date >= '2014-12-02' -- testing
 )

,reporting_term AS (
  SELECT schoolid
        ,time_per_name
        ,alt_name AS term                
  FROM REPORTING$dates WITH(NOLOCK)    
  WHERE academic_year = dbo.fn_Global_Academic_Year()
    AND identifier = 'RT'    
    AND school_level = 'ES'
    AND time_per_name = (SELECT time_per_name FROM curterm WITH(NOLOCK))
 )

,attendance AS (
  SELECT studentid
        ,CONVERT(VARCHAR,[abs_all]) + ' (' + CONVERT(VARCHAR,([AD] + [AE])) + ')' AS absences
        ,CONVERT(VARCHAR,[T_all]) + ' (' + CONVERT(VARCHAR,[TE]) + ')' AS tardies
        ,ROUND([trip_abs],1) AS trip_absences
        ,CONVERT(VARCHAR,[LE]) + ' (' + CONVERT(VARCHAR,[LEX]) + ')' AS early_dismiss
        ,CASE WHEN ROUND(trip_abs,1) >= 5 THEN 'Off Track' ELSE 'On Track' END AS trip_status
  FROM
      (  
       SELECT att.studentid
             ,att.code
             ,att.value        
       FROM ATT_MEM$attendance_counts_long att WITH(NOLOCK)  
       WHERE term = (SELECT time_per_name FROM curterm WITH(NOLOCK))
      ) sub

  PIVOT(
    MAX(value)
    FOR code IN ([abs_all]
                ,[AD]
                ,[AE]
                ,[T_all]
                ,[TE]
                ,[LE]
                ,[LEX]
                ,[trip_abs])
   ) p
 )

,behavior AS (
  SELECT sub.studentid
        ,sub.ontrack_sept
        ,sub.ontrack_oct
        ,sub.ontrack_nov
        ,sub.ontrack_dec
        ,sub.ontrack_jan
        ,sub.ontrack_feb
        ,sub.ontrack_mar
        ,sub.ontrack_apr
        ,sub.ontrack_may
        ,sub.ontrack_jun
        ,ROUND((CONVERT(FLOAT,yr.purple_pink_yr) / CASE WHEN n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,n_color_yr) END) * 100,0) AS purple_pink_pct_yr
        ,ROUND((CONVERT(FLOAT,yr.green_yr) / CASE WHEN n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,n_color_yr) END) * 100,0) AS green_pct_yr
        ,ROUND((CONVERT(FLOAT,yr.yellow_yr) / CASE WHEN n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,n_color_yr) END) * 100,0) AS yellow_pct_yr
        ,ROUND((CONVERT(FLOAT,yr.orange_yr) / CASE WHEN n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,n_color_yr) END) * 100,0) AS orange_pct_yr
        ,ROUND((CONVERT(FLOAT,yr.red_yr) / CASE WHEN n_color_yr = 0 THEN NULL ELSE CONVERT(FLOAT,n_color_yr) END) * 100,0) AS red_pct_yr
        ,yr.hw_pct_yr
        ,REPLACE(CONVERT(VARCHAR,yr.hw_complete_yr),'.0','') + '/' + CONVERT(VARCHAR,yr.n_hw_yr) AS hw_complete_yr
        ,REPLACE(CONVERT(VARCHAR,yr.hw_missing_yr),'.0','') + '/' + CONVERT(VARCHAR,yr.n_hw_yr) AS hw_missing_yr
  FROM
      (
       SELECT studentid
             ,[September] AS ontrack_sept
             ,[October] AS ontrack_oct
             ,[November] AS ontrack_nov
             ,[December] AS ontrack_dec
             ,[January] AS ontrack_jan
             ,[February] AS ontrack_feb
             ,[March] AS ontrack_mar
             ,[April] AS ontrack_apr
             ,[May] AS ontrack_may
             ,[June] AS ontrack_jun
       FROM
           ( 
            SELECT mth.studentid
                  ,mth.month
                  ,mth.pct_ontrack_mth      
            FROM ES_DAILY$tracking_totals mth WITH(NOLOCK)
            WHERE mth.month IS NOT NULL
           ) sub
       PIVOT(
         MAX(sub.pct_ontrack_mth)
         FOR sub.month IN ([September]
                          ,[October]
                          ,[November]
                          ,[December]
                          ,[January]
                          ,[February]
                          ,[March]
                          ,[April]
                          ,[May]
                          ,[June])
        ) p
      ) sub
  LEFT OUTER JOIN ES_DAILY$tracking_totals yr WITH(NOLOCK)
    ON sub.studentid = yr.studentid
   AND yr.month IS NULL
   AND yr.week_num IS NULL  
 )

,reading_level AS (
  SELECT sub.studentid
        ,[DR_goal_lvl]
        ,[DR_lvl_hash]        
        ,[T1_goal_lvl]
        ,[T1_lvl_hash]        
        ,[T2_goal_lvl]
        ,[T2_lvl_hash]        
        ,[T3_goal_lvl]
        ,[T3_lvl_hash]        
        ,[EOY_goal_lvl]
        ,[EOY_lvl_hash]        
        ,cur.lvl_num - dr_lvl_num AS levels_grown
  FROM
      (
       SELECT studentid
             ,[DR_goal_lvl]
             ,[DR_lvl_hash]
             ,[DR_lvl_num]
             ,[T1_goal_lvl]
             ,[T1_lvl_hash]
             ,[T1_lvl_num]
             ,[T2_goal_lvl]
             ,[T2_lvl_hash]
             ,[T2_lvl_num]
             ,[T3_goal_lvl]
             ,[T3_lvl_hash]
             ,[T3_lvl_num]
             ,[EOY_goal_lvl]
             ,[EOY_lvl_hash]
             ,[EOY_lvl_num]
       FROM
           (
            SELECT studentid
                  ,test_round + '_' + field AS pivot_hash
                  ,value
            FROM
                (
                 SELECT studentid
                       ,test_round
                       ,CASE
                         WHEN read_lvl = indep_lvl THEN CONVERT(VARCHAR,read_lvl)
                         ELSE CONVERT(VARCHAR,read_lvl + ' (' + indep_lvl + ')') 
                        END AS lvl_hash
                       ,CONVERT(VARCHAR,goal_lvl) AS goal_lvl
                       ,CONVERT(VARCHAR,lvl_num) AS lvl_num
                 FROM LIT$achieved_by_round#static WITH(NOLOCK)
                 WHERE grade_level < 5
                   AND academic_year = dbo.fn_Global_Academic_Year()
                   AND test_round IN (
                                      SELECT DISTINCT time_per_name
                                      FROM REPORTING$dates WITH(NOLOCK)
                                      WHERE identifier = 'LIT'
                                        AND academic_year = dbo.fn_Global_Academic_Year()
                                        AND school_level = 'ES'
                                        AND start_date <= GETDATE()
                                     )
                ) sub
            UNPIVOT(
              value
              FOR field IN (lvl_hash
                           ,goal_lvl
                           ,lvl_num)
             ) u
           ) sub
       PIVOT(
         MAX(value)
         FOR pivot_hash IN ([DR_goal_lvl]
                           ,[DR_lvl_hash]
                           ,[DR_lvl_num]
                           ,[T1_goal_lvl]
                           ,[T1_lvl_hash]
                           ,[T1_lvl_num]
                           ,[T2_goal_lvl]
                           ,[T2_lvl_hash]
                           ,[T2_lvl_num]
                           ,[T3_goal_lvl]
                           ,[T3_lvl_hash]
                           ,[T3_lvl_num]
                           ,[EOY_goal_lvl]
                           ,[EOY_lvl_hash]
                           ,[EOY_lvl_num])
        ) p
      ) sub
  LEFT OUTER JOIN LIT$test_events#identifiers cur WITH(NOLOCK)
    ON sub.studentid = cur.studentid
   AND cur.achv_curr_all = 1
 )

SELECT r.studentid
      ,r.student_number
      ,r.LASTFIRST      
      ,r.FIRST_NAME
      ,r.GRADE_LEVEL
      ,r.SCHOOLID
      ,r.school_name
      ,r.TEAM      
      ,rt.term          
      -- attendance
      ,att.absences      
      ,att.tardies      
      ,att.early_dismiss      
      ,att.trip_absences
      ,att.trip_status        
      -- behavior
      ,bhv.ontrack_sept
      ,bhv.ontrack_oct
      ,bhv.ontrack_nov
      ,bhv.ontrack_dec
      ,bhv.ontrack_jan
      ,bhv.ontrack_feb
      ,bhv.ontrack_mar
      ,bhv.ontrack_apr
      ,bhv.ontrack_may
      ,bhv.ontrack_jun
      ,bhv.purple_pink_pct_yr
      ,bhv.green_pct_yr
      ,bhv.yellow_pct_yr
      ,bhv.orange_pct_yr
      ,bhv.red_pct_yr
      ,bhv.hw_pct_yr
      ,bhv.hw_complete_yr
      ,bhv.hw_missing_yr            
      -- word work
      ,ROUND(sw.pct_correct_yr,0) AS sw_pct_yr      
      ,ROUND(sp.pct_correct_yr,0) AS sp_average_yr      
      ,ROUND(vocab.pct_correct_yr,0) AS v_average_yr
      -- STEP
      ,rs.[DR_goal_lvl]
      ,rs.[DR_lvl_hash]      
      ,rs.[T1_goal_lvl]
      ,rs.[T1_lvl_hash]      
      ,rs.[T2_goal_lvl]
      ,rs.[T2_lvl_hash]      
      ,rs.[T3_goal_lvl]
      ,rs.[T3_lvl_hash]      
      ,rs.[EOY_goal_lvl]
      ,rs.[EOY_lvl_hash]      
      ,rs.levels_grown
      -- TA % of standards
      ,ta.COMP_pct_stds_mastered
      ,ta.MATH_pct_stds_mastered
      ,ta.PERF_pct_stds_mastered
      ,ta.PHON_pct_stds_mastered
      ,ta.HUM_pct_stds_mastered
      ,ta.SCI_pct_stds_mastered
      ,ta.SPAN_pct_stds_mastered
      ,ta.VIZ_pct_stds_mastered
      ,ta.RHET_pct_stds_mastered      
      -- TA objectives
      -- math
      ,ta.MATH_TA_obj_1
      ,ta.MATH_TA_obj_2
      ,ta.MATH_TA_obj_3
      ,ta.MATH_TA_obj_4
      ,ta.MATH_TA_obj_5
      ,ta.MATH_TA_obj_6
      ,ta.MATH_TA_obj_7
      ,ta.MATH_TA_obj_8
      ,ta.MATH_TA_obj_9
      ,ta.MATH_TA_obj_10
      ,ta.MATH_TA_obj_11
      ,ta.MATH_TA_obj_12
      ,ta.MATH_TA_obj_13
      ,ta.MATH_TA_obj_14
      ,ta.MATH_TA_obj_15
      -- reading comp
      ,ta.COMP_TA_obj_1
      ,ta.COMP_TA_obj_2
      ,ta.COMP_TA_obj_3
      ,ta.COMP_TA_obj_4
      ,ta.COMP_TA_obj_5
      ,ta.COMP_TA_obj_6
      ,ta.COMP_TA_obj_7
      ,ta.COMP_TA_obj_8
      ,ta.COMP_TA_obj_9
      ,ta.COMP_TA_obj_10
      ,ta.COMP_TA_obj_11
      ,ta.COMP_TA_obj_12
      ,ta.COMP_TA_obj_13
      ,ta.COMP_TA_obj_14
      ,ta.COMP_TA_obj_15
      -- phonics
      ,ta.PHON_TA_obj_1
      ,ta.PHON_TA_obj_2
      ,ta.PHON_TA_obj_3
      ,ta.PHON_TA_obj_4
      ,ta.PHON_TA_obj_5
      ,ta.PHON_TA_obj_6
      ,ta.PHON_TA_obj_7
      ,ta.PHON_TA_obj_8
      ,ta.PHON_TA_obj_9
      ,ta.PHON_TA_obj_10
      ,ta.PHON_TA_obj_11
      ,ta.PHON_TA_obj_12
      ,ta.PHON_TA_obj_13
      ,ta.PHON_TA_obj_14
      ,ta.PHON_TA_obj_15
      -- writing
      ,ta.RHET_TA_obj_1
      ,ta.RHET_TA_obj_2
      ,ta.RHET_TA_obj_3
      ,ta.RHET_TA_obj_4
      ,ta.RHET_TA_obj_5
      ,ta.RHET_TA_obj_6
      ,ta.RHET_TA_obj_7
      ,ta.RHET_TA_obj_8
      ,ta.RHET_TA_obj_9
      ,ta.RHET_TA_obj_10
      ,ta.RHET_TA_obj_11
      ,ta.RHET_TA_obj_12      
      -- specials
      ,ta.PERF_TA_obj_1
      ,ta.PERF_TA_obj_2
      ,ta.PERF_TA_obj_3
      ,ta.PERF_TA_obj_4
      ,ta.PERF_TA_obj_5      
      ,ta.HUM_TA_obj_1
      ,ta.HUM_TA_obj_2
      ,ta.HUM_TA_obj_3
      ,ta.HUM_TA_obj_4
      ,ta.HUM_TA_obj_5          
      ,ta.SCI_TA_obj_1
      ,ta.SCI_TA_obj_2
      ,ta.SCI_TA_obj_3
      ,ta.SCI_TA_obj_4
      ,ta.SCI_TA_obj_5      
      ,ta.SPAN_TA_obj_1
      ,ta.SPAN_TA_obj_2
      ,ta.SPAN_TA_obj_3
      ,ta.SPAN_TA_obj_4
      ,ta.SPAN_TA_obj_5      
      ,ta.VIZ_TA_obj_1
      ,ta.VIZ_TA_obj_2
      ,ta.VIZ_TA_obj_3
      ,ta.VIZ_TA_obj_4
      ,ta.VIZ_TA_obj_5      
      -- TA proficiency
      -- math
      ,ta.MATH_TA_prof_1
      ,ta.MATH_TA_prof_2
      ,ta.MATH_TA_prof_3
      ,ta.MATH_TA_prof_4
      ,ta.MATH_TA_prof_5
      ,ta.MATH_TA_prof_6
      ,ta.MATH_TA_prof_7
      ,ta.MATH_TA_prof_8
      ,ta.MATH_TA_prof_9
      ,ta.MATH_TA_prof_10
      ,ta.MATH_TA_prof_11
      ,ta.MATH_TA_prof_12
      ,ta.MATH_TA_prof_13
      ,ta.MATH_TA_prof_14
      ,ta.MATH_TA_prof_15
      -- reading comp
      ,ta.COMP_TA_prof_1
      ,ta.COMP_TA_prof_2
      ,ta.COMP_TA_prof_3
      ,ta.COMP_TA_prof_4
      ,ta.COMP_TA_prof_5
      ,ta.COMP_TA_prof_6
      ,ta.COMP_TA_prof_7
      ,ta.COMP_TA_prof_8
      ,ta.COMP_TA_prof_9
      ,ta.COMP_TA_prof_10
      ,ta.COMP_TA_prof_11
      ,ta.COMP_TA_prof_12
      ,ta.COMP_TA_prof_13
      ,ta.COMP_TA_prof_14
      ,ta.COMP_TA_prof_15
      -- phonics
      ,ta.PHON_TA_prof_1
      ,ta.PHON_TA_prof_2
      ,ta.PHON_TA_prof_3
      ,ta.PHON_TA_prof_4
      ,ta.PHON_TA_prof_5
      ,ta.PHON_TA_prof_6
      ,ta.PHON_TA_prof_7
      ,ta.PHON_TA_prof_8
      ,ta.PHON_TA_prof_9
      ,ta.PHON_TA_prof_10
      ,ta.PHON_TA_prof_11
      ,ta.PHON_TA_prof_12
      ,ta.PHON_TA_prof_13
      ,ta.PHON_TA_prof_14
      ,ta.PHON_TA_prof_15
      -- writing
      ,ta.RHET_TA_prof_1
      ,ta.RHET_TA_prof_2
      ,ta.RHET_TA_prof_3
      ,ta.RHET_TA_prof_4
      ,ta.RHET_TA_prof_5
      ,ta.RHET_TA_prof_6
      ,ta.RHET_TA_prof_7
      ,ta.RHET_TA_prof_8
      ,ta.RHET_TA_prof_9
      ,ta.RHET_TA_prof_10
      ,ta.RHET_TA_prof_11
      ,ta.RHET_TA_prof_12      
      -- specials
      ,ta.PERF_TA_prof_1
      ,ta.PERF_TA_prof_2
      ,ta.PERF_TA_prof_3
      ,ta.PERF_TA_prof_4
      ,ta.PERF_TA_prof_5      
      ,ta.HUM_TA_prof_1
      ,ta.HUM_TA_prof_2
      ,ta.HUM_TA_prof_3
      ,ta.HUM_TA_prof_4
      ,ta.HUM_TA_prof_5          
      ,ta.SCI_TA_prof_1
      ,ta.SCI_TA_prof_2
      ,ta.SCI_TA_prof_3
      ,ta.SCI_TA_prof_4
      ,ta.SCI_TA_prof_5      
      ,ta.SPAN_TA_prof_1
      ,ta.SPAN_TA_prof_2
      ,ta.SPAN_TA_prof_3
      ,ta.SPAN_TA_prof_4
      ,ta.SPAN_TA_prof_5      
      ,ta.VIZ_TA_prof_1
      ,ta.VIZ_TA_prof_2
      ,ta.VIZ_TA_prof_3
      ,ta.VIZ_TA_prof_4
      ,ta.VIZ_TA_prof_5
      --comments
      ,comm.ela_comment
      ,comm.humanities_comment
      ,comm.math_comment
      ,comm.perfarts_comment
      ,comm.sci_comment
      ,comm.socskills_comment
      ,comm.span_comment
      ,comm.viz_comment
      ,comm.writing_comment
      --ARFR
      ,arfr.ARFR_reason
      --social skills

FROM roster r WITH(NOLOCK)
JOIN curterm WITH(NOLOCK)
  ON 1 = 1
LEFT OUTER JOIN reporting_term rt WITH(NOLOCK)
  ON r.schoolid = rt.schoolid
LEFT OUTER JOIN attendance att WITH(NOLOCK)
  ON r.STUDENTID = att.studentid
LEFT OUTER JOIN behavior bhv WITH(NOLOCK)
  ON r.studentid = bhv.studentid
LEFT OUTER JOIN LIT$sight_word_totals sw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sw.student_number
  AND sw.listweek_num = 'Week_01'
LEFT OUTER JOIN LIT$spelling_totals sp WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sp.student_number
 AND sp.listweek_num = 'Week_01'
LEFT OUTER JOIN LIT$vocab_totals vocab WITH(NOLOCK)
  ON r.STUDENT_NUMBER = vocab.student_number
 AND vocab.listweek_num = 'Week_01'
LEFT OUTER JOIN ILLUMINATE$TA_scores_wide ta WITH(NOLOCK)
  ON r.STUDENTID = ta.student_number
 AND rt.term = ta.term
LEFT OUTER JOIN reading_level rs WITH(NOLOCK)
  ON r.studentid = rs.studentid
LEFT OUTER JOIN REPORTING$report_card_comments#ES comm WITH(NOLOCK)
  ON r.student_number = comm.student_number
 AND rt.term = comm.term
LEFT OUTER JOIN REPORTING$ARFR_reasons#ES arfr WITH(NOLOCK)
  ON r.student_number = arfr.student_number
 AND rt.term = arfr.term
 AND arfr.academic_year = dbo.fn_Global_Academic_Year()