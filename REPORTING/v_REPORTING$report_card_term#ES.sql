USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card_term#ES AS

WITH curterm AS (
  SELECT DISTINCT 'RT' + CONVERT(VARCHAR,(CONVERT(INT,RIGHT(time_per_name, 1)) - 1)) AS time_per_name                 
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND school_level = 'ES'
    AND start_date <= '2015-02-25'
    AND end_date >= '2015-02-25'
    --AND start_date <= CONVERT(DATE,GETDATE())
    --AND end_date >= CONVERT(DATE,GETDATE())    
 )

,roster AS (
 SELECT co.STUDENTID
       ,co.STUDENT_NUMBER      
       ,co.LASTFIRST       
       ,co.FIRST_NAME
       ,CASE WHEN co.GRADE_LEVEL = 0 THEN 'K' ELSE CONVERT(VARCHAR,co.grade_level) END AS grade_level
       ,co.SCHOOLID
       ,co.school_name
       ,co.TEAM       
       ,dt.time_per_name
       ,dt.alt_name AS term
 FROM COHORT$identifiers_long#static co WITH(NOLOCK) 
 JOIN REPORTING$dates dt WITH(NOLOCK)    
   ON co.schoolid = dt.schoolid    
  AND dt.academic_year = dbo.fn_Global_Academic_Year()
  AND identifier = 'RT'      
  AND time_per_name = (SELECT time_per_name FROM curterm WITH(NOLOCK))
 WHERE co.YEAR = dbo.fn_Global_Academic_Year()
   AND co.GRADE_LEVEL < 5
   AND co.RN = 1
   AND co.enroll_status = 0
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
            FROM ES_DAILY$tracking_totals#static mth WITH(NOLOCK)
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
  LEFT OUTER JOIN ES_DAILY$tracking_totals#static yr WITH(NOLOCK)
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
                         WHEN schoolid = 73255 THEN CONVERT(VARCHAR,read_lvl)
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
                                        --AND start_date <= GETDATE()
                                        AND start_date <= '2015-02-25'
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

,social_skills AS (
  SELECT student_number
        ,MAX([soc_skill_descr_1]) AS [soc_skill_descr_1]
        ,MAX([soc_skill_descr_2]) AS [soc_skill_descr_2]
        ,MAX([soc_skill_descr_3]) AS [soc_skill_descr_3]
        ,MAX([soc_skill_descr_4]) AS [soc_skill_descr_4]
        ,MAX([soc_skill_descr_5]) AS [soc_skill_descr_5]
        ,MAX([soc_skill_descr_6]) AS [soc_skill_descr_6]
        ,MAX([soc_skill_T1_score_1]) AS [soc_skill_T1_score_1]
        ,MAX([soc_skill_T1_score_2]) AS [soc_skill_T1_score_2]
        ,MAX([soc_skill_T1_score_3]) AS [soc_skill_T1_score_3]
        ,MAX([soc_skill_T1_score_4]) AS [soc_skill_T1_score_4]
        ,MAX([soc_skill_T1_score_5]) AS [soc_skill_T1_score_5]
        ,MAX([soc_skill_T1_score_6]) AS [soc_skill_T1_score_6]
        ,MAX([soc_skill_T2_score_1]) AS [soc_skill_T2_score_1]
        ,MAX([soc_skill_T2_score_2]) AS [soc_skill_T2_score_2]
        ,MAX([soc_skill_T2_score_3]) AS [soc_skill_T2_score_3]
        ,MAX([soc_skill_T2_score_4]) AS [soc_skill_T2_score_4]
        ,MAX([soc_skill_T2_score_5]) AS [soc_skill_T2_score_5]
        ,MAX([soc_skill_T2_score_6]) AS [soc_skill_T2_score_6]
        ,MAX([soc_skill_T3_score_1]) AS [soc_skill_T3_score_1]
        ,MAX([soc_skill_T3_score_2]) AS [soc_skill_T3_score_2]
        ,MAX([soc_skill_T3_score_3]) AS [soc_skill_T3_score_3]
        ,MAX([soc_skill_T3_score_4]) AS [soc_skill_T3_score_4]
        ,MAX([soc_skill_T3_score_5]) AS [soc_skill_T3_score_5]
        ,MAX([soc_skill_T3_score_6]) AS [soc_skill_T3_score_6]
  FROM ILLUMINATE$social_skills#ES WITH(NOLOCK)
  PIVOT(
    MAX(soc_skill)
    FOR descr_pivot_hash IN ([soc_skill_descr_1]
                            ,[soc_skill_descr_2]
                            ,[soc_skill_descr_3]
                            ,[soc_skill_descr_4]
                            ,[soc_skill_descr_5]
                            ,[soc_skill_descr_6])
   ) p1
  PIVOT(
    MAX(score)
    FOR score_pivot_hash IN ([soc_skill_T1_score_1]
                            ,[soc_skill_T1_score_2]
                            ,[soc_skill_T1_score_3]
                            ,[soc_skill_T1_score_4]
                            ,[soc_skill_T1_score_5]
                            ,[soc_skill_T1_score_6]
                            ,[soc_skill_T2_score_1]
                            ,[soc_skill_T2_score_2]
                            ,[soc_skill_T2_score_3]
                            ,[soc_skill_T2_score_4]
                            ,[soc_skill_T2_score_5]
                            ,[soc_skill_T2_score_6]
                            ,[soc_skill_T3_score_1]
                            ,[soc_skill_T3_score_2]
                            ,[soc_skill_T3_score_3]
                            ,[soc_skill_T3_score_4]
                            ,[soc_skill_T3_score_5]
                            ,[soc_skill_T3_score_6])
   ) p2
  GROUP BY student_number
 )

SELECT r.studentid
      ,r.student_number
      ,r.LASTFIRST      
      ,r.FIRST_NAME
      ,r.GRADE_LEVEL
      ,r.SCHOOLID
      ,r.school_name
      ,r.TEAM      
      ,r.term          
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
      ,wr.RHET_pct_stds_mastered      
            
      -- math
       -- objectives
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
       -- proficiency
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

      -- reading comp
       -- objectives
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
       -- proficiency
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
      
      -- phonics
       -- objectives
      ,ta.PHON_TA_obj_1
      ,ta.PHON_TA_obj_2
      ,ta.PHON_TA_obj_3
      ,ta.PHON_TA_obj_4
      ,ta.PHON_TA_obj_5
      --,ta.PHON_TA_obj_6
      --,ta.PHON_TA_obj_7
      --,ta.PHON_TA_obj_8
      --,ta.PHON_TA_obj_9
      --,ta.PHON_TA_obj_10
       -- proficiency
      ,ta.PHON_TA_prof_1
      ,ta.PHON_TA_prof_2
      ,ta.PHON_TA_prof_3
      ,ta.PHON_TA_prof_4
      ,ta.PHON_TA_prof_5
      --,ta.PHON_TA_prof_6
      --,ta.PHON_TA_prof_7
      --,ta.PHON_TA_prof_8
      --,ta.PHON_TA_prof_9
      --,ta.PHON_TA_prof_10
      
      -- writing
       -- objectives
      ,wr.RHET_TA_obj_1
      ,wr.RHET_TA_obj_2
      ,wr.RHET_TA_obj_3
      ,wr.RHET_TA_obj_4
      ,wr.RHET_TA_obj_5
      ,wr.RHET_TA_obj_6
      ,wr.RHET_TA_obj_7
      ,wr.RHET_TA_obj_8
      ,wr.RHET_TA_obj_9
      ,wr.RHET_TA_obj_10
      ,wr.RHET_TA_narr_obj
      ,wr.RHET_TA_info_obj
      ,wr.RHET_TA_op_obj
       -- proficiency
      ,wr.RHET_TA_prof_1
      ,wr.RHET_TA_prof_2
      ,wr.RHET_TA_prof_3
      ,wr.RHET_TA_prof_4
      ,wr.RHET_TA_prof_5
      ,wr.RHET_TA_prof_6
      ,wr.RHET_TA_prof_7
      ,wr.RHET_TA_prof_8
      ,wr.RHET_TA_prof_9
      ,wr.RHET_TA_prof_10
      ,wr.RHET_TA_narr_prof
      ,wr.RHET_TA_info_prof
      ,wr.RHET_TA_op_prof
      
      -- specials
       -- objectives
      ,ta.PERF_TA_obj_1
      ,ta.PERF_TA_obj_2
      ,ta.PERF_TA_obj_3
      ,ta.PERF_TA_obj_4
      ,ta.PERF_TA_obj_5      
      ,ta.PERF_TA_obj_6      
      ,ta.PERF_TA_obj_7      
      ,ta.PERF_TA_obj_8      
      ,ta.PERF_TA_obj_9      
      ,ta.PERF_TA_obj_10      
      ,ta.PERF_TA_obj_11
      ,ta.HUM_TA_obj_1
      ,ta.HUM_TA_obj_2
      ,ta.HUM_TA_obj_3
      ,ta.HUM_TA_obj_4
      ,ta.HUM_TA_obj_5          
      --,ta.HUM_TA_obj_6          
      --,ta.HUM_TA_obj_7          
      --,ta.HUM_TA_obj_8          
      --,ta.HUM_TA_obj_9          
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
      ,ta.VIZ_TA_obj_6      
      ,ta.VIZ_TA_obj_7
       -- proficiency
      ,ta.PERF_TA_prof_1
      ,ta.PERF_TA_prof_2
      ,ta.PERF_TA_prof_3
      ,ta.PERF_TA_prof_4
      ,ta.PERF_TA_prof_5      
      ,ta.PERF_TA_prof_6      
      ,ta.PERF_TA_prof_7      
      ,ta.PERF_TA_prof_8      
      ,ta.PERF_TA_prof_9     
      ,ta.PERF_TA_prof_10
      ,ta.PERF_TA_prof_11
      ,ta.HUM_TA_prof_1
      ,ta.HUM_TA_prof_2
      ,ta.HUM_TA_prof_3
      ,ta.HUM_TA_prof_4
      ,ta.HUM_TA_prof_5          
      --,ta.HUM_TA_prof_6          
      --,ta.HUM_TA_prof_7          
      --,ta.HUM_TA_prof_8          
      --,ta.HUM_TA_prof_9          
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
      ,ta.VIZ_TA_prof_6
      ,ta.VIZ_TA_prof_7
      ,ta.DANCE_TA_obj_1
      ,ta.DANCE_TA_prof_1      
      ,ta.DANCE_pct_stds_mastered
            
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
      ,comm.dance_comment
      
      --ARFR
      ,arfr.ARFR_reason
      
      --social skills
      ,soc.soc_skill_descr_1
      ,soc.soc_skill_descr_2
      ,soc.soc_skill_descr_3
      ,soc.soc_skill_descr_4
      ,soc.soc_skill_descr_5
      ,soc.soc_skill_descr_6
      ,soc.soc_skill_T1_score_1
      ,soc.soc_skill_T1_score_2
      ,soc.soc_skill_T1_score_3
      ,soc.soc_skill_T1_score_4
      ,soc.soc_skill_T1_score_5
      ,soc.soc_skill_T1_score_6
      ,soc.soc_skill_T2_score_1
      ,soc.soc_skill_T2_score_2
      ,soc.soc_skill_T2_score_3
      ,soc.soc_skill_T2_score_4
      ,soc.soc_skill_T2_score_5
      ,soc.soc_skill_T2_score_6
      ,soc.soc_skill_T3_score_1
      ,soc.soc_skill_T3_score_2
      ,soc.soc_skill_T3_score_3
      ,soc.soc_skill_T3_score_4
      ,soc.soc_skill_T3_score_5
      ,soc.soc_skill_T3_score_6
FROM roster r WITH(NOLOCK)
/*--JOIN curterm WITH(NOLOCK)
--  ON 1 = 1
--LEFT OUTER JOIN reporting_term rt WITH(NOLOCK)
--  ON r.schoolid = rt.schoolid*/
LEFT OUTER JOIN attendance att WITH(NOLOCK)
  ON r.STUDENTID = att.studentid
LEFT OUTER JOIN behavior bhv WITH(NOLOCK)
  ON r.studentid = bhv.studentid
LEFT OUTER JOIN LIT$sight_word_totals#static sw WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sw.student_number
  AND sw.listweek_num = 'Week_01'
LEFT OUTER JOIN LIT$spelling_totals#static sp WITH(NOLOCK)
  ON r.STUDENT_NUMBER = sp.student_number
 AND sp.listweek_num = 'Week_01'
LEFT OUTER JOIN LIT$vocab_totals#static vocab WITH(NOLOCK)
  ON r.STUDENT_NUMBER = vocab.student_number
 AND vocab.listweek_num = 'Week_01'
LEFT OUTER JOIN ILLUMINATE$TA_scores_wide#static ta WITH(NOLOCK)
  ON r.student_number = ta.student_number
 AND r.term = ta.term
LEFT OUTER JOIN ILLUMINATE$TA_writing_scores_wide#static wr WITH(NOLOCK)
  ON r.student_number = wr.student_number
 AND r.term = wr.term
LEFT OUTER JOIN reading_level rs WITH(NOLOCK)
  ON r.studentid = rs.studentid
LEFT OUTER JOIN REPORTING$report_card_comments#ES comm WITH(NOLOCK)
  ON r.student_number = comm.student_number
 AND r.term = comm.term
LEFT OUTER JOIN REPORTING$ARFR_reasons#ES arfr WITH(NOLOCK)
  ON r.student_number = arfr.student_number
 AND r.term = arfr.term
 AND arfr.academic_year = dbo.fn_Global_Academic_Year() 
LEFT OUTER JOIN social_skills soc WITH(NOLOCK)
  ON r.student_number = soc.student_number