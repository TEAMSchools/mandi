USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_tracker#MS AS

SELECT ROW_NUMBER() OVER(PARTITION BY roster.schoolid ORDER BY roster.grade_level, roster.lastfirst) AS [count]      
      ,roster.studentid AS id
      ,roster.student_number
      ,roster.year
      ,roster.schoolid
      ,roster.lastfirst        
      ,roster.grade_level
      ,roster.team
      ,roster.advisor       
      ,roster.SPEDLEP
      ,roster.gender
      ,roster.mother
      ,roster.father       
      ,roster.home_phone
      ,roster.mother_cell
      ,roster.mother_home
      ,roster.father_cell
      ,roster.father_home
      ,roster.guardianemail AS contactemail
      ,COUNT(roster.student_number) OVER(PARTITION BY roster.schoolid, roster.grade_level) AS IN_GRADE_DENOM

      /* ATTENDANCE */
      ,att_counts.ABS_all_counts_yr AS Y1_absences_total
      ,att_counts.A_counts_yr AS Y1_absences_undoc
      ,ROUND((att_counts.ABS_all_counts_yr / att_counts.MEM_counts_yr) * 100, 0) AS Y1_att_pct_total
      ,ROUND((att_counts.A_counts_yr / att_counts.MEM_counts_yr) * 100, 0) AS Y1_att_pct_undoc      
      ,att_counts.TDY_all_counts_yr AS Y1_tardies_total
      ,att_counts.T10_counts_yr AS Y1_tardies_t10
      ,ROUND((att_counts.TDY_all_counts_yr / att_counts.MEM_counts_yr) * 100, 0) AS Y1_tardy_pct_total      
      ,att_counts.ABS_all_counts_term AS curterm_absences_total
      ,att_counts.A_counts_term AS curterm_absences_undoc
      ,ROUND((att_counts.ABS_all_counts_term / att_counts.MEM_counts_yr) * 100, 0) AS curterm_att_pct_total
      ,ROUND((att_counts.A_counts_term / att_counts.MEM_counts_yr) * 100, 0) AS curterm_att_pct_undoc      
      ,att_counts.TDY_all_counts_term AS curterm_tardies_total
      ,att_counts.T10_counts_term AS curterm_tardies_t10
      ,ROUND((att_counts.TDY_all_counts_term / att_counts.MEM_counts_yr) * 100, 0) AS curterm_tardy_pct_total

--PROMOTIONAL STATUS
      ,promo.attendance_points
      ,ROUND(promo.y1_att_pts_pct,1) AS ATT_POINTS_PCT      
      ,promo.days_to_90
      ,promo.promo_overall_team
      ,promo.promo_grades_team
      ,promo.promo_att_team
      ,promo.promo_hw_team
      ,promo.promo_overall_rise
      ,promo.promo_grades_gpa_rise AS promo_grades_rise
      ,promo.promo_att_rise
      ,promo.promo_hw_rise      
      ,promo.n_below_65 AS n_failing_all      
      ,NULL AS elements_all
      ,NULL AS failing_all      

--GPA
      ,CONVERT(FLOAT,gpa.GPA_term_RT1) AS gpa_t1
      ,gpa.GPA_term_rank_RT1 AS GPA_T1_RANK
      ,CONVERT(FLOAT,gpa.GPA_term_Rt2) AS gpa_t2
      ,gpa.GPA_term_rank_Rt2 AS GPA_t2_RANK
      ,CONVERT(FLOAT,gpa.GPA_term_Rt3) AS gpa_t3
      ,gpa.GPA_term_rank_Rt3 AS GPA_t3_RANK
      ,CONVERT(FLOAT,gpa.GPA_term_Rt4) AS gpa_t4
      ,gpa.GPA_term_rank_Rt4 AS GPA_t4_RANK
      ,CONVERT(FLOAT,gpa.GPA_Y1_CUR) AS gpa_y1       
      ,gpa.GPA_y1_rank_CUR AS GPA_Y1_RANK                  

--COURSE GRADES
      ,eng.course_number AS ENGLISH_course_number
      ,eng.credittype AS ENGLISH_credittype
      ,eng.course_name AS ENGLISH_course_name
      ,eng.credit_hours AS ENGLISH_credit_hours_T1
      ,eng.credit_hours AS ENGLISH_credit_hours_T2
      ,eng.credit_hours AS ENGLISH_credit_hours_T3
      ,eng.credit_hours AS ENGLISH_credit_hours_Y1
      ,eng.teacher_name AS ENGLISH_teacher_last
      ,eng.teacher_name AS ENGLISH_teacher_lastfirst
      ,CONVERT(FLOAT,eng.RT1_term_grade_percent) AS ENGLISH_t1
      ,CONVERT(FLOAT,eng.RT2_term_grade_percent) AS ENGLISH_t2
      ,CONVERT(FLOAT,eng.RT3_term_grade_percent) AS ENGLISH_t3
      ,CONVERT(FLOAT,eng.RT4_term_grade_percent) AS ENGLISH_t4
      ,CONVERT(FLOAT,eng.Y1_grade_percent) AS ENGLISH_y1
      ,CONVERT(FLOAT,eng.need_70) AS ENGLISH_need_c
      ,eng.RT1_term_grade_letter AS ENGLISH_t1_ltr
      ,eng.RT2_term_grade_letter AS ENGLISH_t2_ltr
      ,eng.RT3_term_grade_letter AS ENGLISH_t3_ltr
      ,eng.RT4_term_grade_letter AS ENGLISH_t4_ltr
      ,eng.Y1_grade_letter AS ENGLISH_y1_ltr      
      ,eng.sectionid AS ENGLISH_t1_enr_sectionid
      ,eng.sectionid AS ENGLISH_t2_enr_sectionid
      ,eng.sectionid AS ENGLISH_t3_enr_sectionid
      ,NULL AS ENGLISH_gpa_points_t1
      ,NULL AS ENGLISH_gpa_points_t2
      ,NULL AS ENGLISH_gpa_points_t3
      ,NULL AS ENGLISH_gpa_points_y1
      ,NULL AS ENGLISH_weighted_points_t1
      ,NULL AS ENGLISH_weighted_points_t2
      ,NULL AS ENGLISH_weighted_points_t3
      ,NULL AS ENGLISH_weighted_points_y1
      ,CONVERT(FLOAT,eng_cat.H_RT1) AS ENGLISH_H1 
      ,CONVERT(FLOAT,eng_cat.H_RT2) AS ENGLISH_H2 
      ,CONVERT(FLOAT,eng_cat.H_RT3) AS ENGLISH_H3 
      ,CONVERT(FLOAT,eng_cat.H_RT4) AS ENGLISH_H4 
      ,CONVERT(FLOAT,eng_cat.H_Y1) AS ENGLISH_HY1
      ,CONVERT(FLOAT,eng_cat.E_RT1) AS ENGLISH_Q1 
      ,CONVERT(FLOAT,eng_cat.E_RT2) AS ENGLISH_Q2 
      ,CONVERT(FLOAT,eng_cat.E_RT3) AS ENGLISH_Q3 
      ,CONVERT(FLOAT,eng_cat.E_RT4) AS ENGLISH_Q4 
      ,CONVERT(FLOAT,eng_cat.E_Y1) AS ENGLISH_QY1
      ,CONVERT(FLOAT,eng_cat.S_RT1) AS ENGLISH_S1 
      ,CONVERT(FLOAT,eng_cat.S_RT2) AS ENGLISH_S2 
      ,CONVERT(FLOAT,eng_cat.S_RT3) AS ENGLISH_S3 
      ,CONVERT(FLOAT,eng_cat.S_RT4) AS ENGLISH_S4 
      ,CONVERT(FLOAT,eng_cat.S_Y1) AS ENGLISH_SY1
      
      ,NULL AS RHET_course_number
      ,NULL AS RHET_credittype
      ,NULL AS RHET_course_name
      ,NULL AS RHET_credit_hours_T1
      ,NULL AS RHET_credit_hours_T2
      ,NULL AS RHET_credit_hours_T3
      ,NULL AS RHET_credit_hours_Y1
      ,NULL AS RHET_teacher_last
      ,NULL AS RHET_teacher_lastfirst
      ,NULL AS RHET_t1
      ,NULL AS RHET_t2
      ,NULL AS RHET_t3
      ,NULL AS RHET_t4
      ,NULL AS RHET_y1
      ,NULL AS RHET_t1_ltr
      ,NULL AS RHET_t2_ltr
      ,NULL AS RHET_t3_ltr
      ,NULL AS RHET_t4_ltr
      ,NULL AS RHET_y1_ltr
      ,NULL AS RHET_t1_enr_sectionid
      ,NULL AS RHET_t2_enr_sectionid
      ,NULL AS RHET_t3_enr_sectionid
      ,NULL AS RHET_gpa_points_t1
      ,NULL AS RHET_gpa_points_t2
      ,NULL AS RHET_gpa_points_t3
      ,NULL AS RHET_gpa_points_y1
      ,NULL AS RHET_weighted_points_t1
      ,NULL AS RHET_weighted_points_t2
      ,NULL AS RHET_weighted_points_t3
      ,NULL AS RHET_weighted_points_y1
      ,NULL AS RHET_H1 
      ,NULL AS RHET_H2 
      ,NULL AS RHET_H3 
      ,NULL AS RHET_H4 
      ,NULL AS RHET_HY1
      ,NULL AS RHET_Q1 
      ,NULL AS RHET_Q2 
      ,NULL AS RHET_Q3 
      ,NULL AS RHET_Q4 
      ,NULL AS RHET_QY1
      ,NULL AS RHET_S1 
      ,NULL AS RHET_S2 
      ,NULL AS RHET_S3 
      ,NULL AS RHET_S4 
      ,NULL AS RHET_SY1
      
      ,MATH.course_number AS MATH_course_number
      ,MATH.credittype AS MATH_credittype
      ,MATH.course_name AS MATH_course_name
      ,MATH.credit_hours AS MATH_credit_hours_T1
      ,MATH.credit_hours AS MATH_credit_hours_T2
      ,MATH.credit_hours AS MATH_credit_hours_T3
      ,MATH.credit_hours AS MATH_credit_hours_Y1
      ,MATH.teacher_name AS MATH_teacher_last
      ,MATH.teacher_name AS MATH_teacher_lastfirst
      ,CONVERT(FLOAT,MATH.RT1_term_grade_percent) AS MATH_t1
      ,CONVERT(FLOAT,MATH.RT2_term_grade_percent) AS MATH_t2
      ,CONVERT(FLOAT,MATH.RT3_term_grade_percent) AS MATH_t3
      ,CONVERT(FLOAT,MATH.RT4_term_grade_percent) AS MATH_t4
      ,CONVERT(FLOAT,MATH.Y1_grade_percent) AS MATH_y1
      ,MATH.RT1_term_grade_letter AS MATH_t1_ltr
      ,MATH.RT2_term_grade_letter AS MATH_t2_ltr
      ,MATH.RT3_term_grade_letter AS MATH_t3_ltr
      ,MATH.RT4_term_grade_letter AS MATH_t4_ltr
      ,MATH.Y1_grade_letter AS MATH_y1_ltr
      ,CONVERT(FLOAT,math.need_70) AS MATH_need_c
      ,MATH.sectionid AS MATH_t1_enr_sectionid
      ,MATH.sectionid AS MATH_t2_enr_sectionid
      ,MATH.sectionid AS MATH_t3_enr_sectionid
      ,NULL AS MATH_gpa_points_t1
      ,NULL AS MATH_gpa_points_t2
      ,NULL AS MATH_gpa_points_t3
      ,NULL AS MATH_gpa_points_y1
      ,NULL AS MATH_weighted_points_t1
      ,NULL AS MATH_weighted_points_t2
      ,NULL AS MATH_weighted_points_t3
      ,NULL AS MATH_weighted_points_y1
      ,CONVERT(FLOAT,MATH_cat.H_RT1) AS MATH_H1 
      ,CONVERT(FLOAT,MATH_cat.H_RT2) AS MATH_H2 
      ,CONVERT(FLOAT,MATH_cat.H_RT3) AS MATH_H3 
      ,CONVERT(FLOAT,MATH_cat.H_RT4) AS MATH_H4 
      ,CONVERT(FLOAT,MATH_cat.H_Y1) AS MATH_HY1
      ,CONVERT(FLOAT,MATH_cat.E_RT1) AS MATH_Q1 
      ,CONVERT(FLOAT,MATH_cat.E_RT2) AS MATH_Q2 
      ,CONVERT(FLOAT,MATH_cat.E_RT3) AS MATH_Q3 
      ,CONVERT(FLOAT,MATH_cat.E_RT4) AS MATH_Q4 
      ,CONVERT(FLOAT,MATH_cat.E_Y1) AS MATH_QY1
      ,CONVERT(FLOAT,MATH_cat.S_RT1) AS MATH_S1 
      ,CONVERT(FLOAT,MATH_cat.S_RT2) AS MATH_S2 
      ,CONVERT(FLOAT,MATH_cat.S_RT3) AS MATH_S3 
      ,CONVERT(FLOAT,MATH_cat.S_RT4) AS MATH_S4 
      ,CONVERT(FLOAT,MATH_cat.S_Y1) AS MATH_SY1
      
      ,SCIENCE.course_number AS SCIENCE_course_number
      ,SCIENCE.credittype AS SCIENCE_credittype
      ,SCIENCE.course_name AS SCIENCE_course_name
      ,SCIENCE.credit_hours AS SCIENCE_credit_hours_T1
      ,SCIENCE.credit_hours AS SCIENCE_credit_hours_T2
      ,SCIENCE.credit_hours AS SCIENCE_credit_hours_T3
      ,SCIENCE.credit_hours AS SCIENCE_credit_hours_Y1
      ,SCIENCE.teacher_name AS SCIENCE_teacher_last
      ,SCIENCE.teacher_name AS SCIENCE_teacher_lastfirst
      ,CONVERT(FLOAT,SCIENCE.RT1_term_grade_percent) AS SCIENCE_t1
      ,CONVERT(FLOAT,SCIENCE.RT2_term_grade_percent) AS SCIENCE_t2
      ,CONVERT(FLOAT,SCIENCE.RT3_term_grade_percent) AS SCIENCE_t3
      ,CONVERT(FLOAT,SCIENCE.RT4_term_grade_percent) AS SCIENCE_t4
      ,CONVERT(FLOAT,SCIENCE.Y1_grade_percent) AS SCIENCE_y1
      ,CONVERT(FLOAT,SCIENCE.need_70) AS SCIENCE_need_c
      ,SCIENCE.RT1_term_grade_letter AS SCIENCE_t1_ltr
      ,SCIENCE.RT2_term_grade_letter AS SCIENCE_t2_ltr
      ,SCIENCE.RT3_term_grade_letter AS SCIENCE_t3_ltr
      ,SCIENCE.RT4_term_grade_letter AS SCIENCE_t4_ltr
      ,SCIENCE.Y1_grade_letter AS SCIENCE_y1_ltr
      ,SCIENCE.sectionid AS SCIENCE_t1_enr_sectionid
      ,SCIENCE.sectionid AS SCIENCE_t2_enr_sectionid
      ,SCIENCE.sectionid AS SCIENCE_t3_enr_sectionid
      ,NULL AS SCIENCE_gpa_points_t1
      ,NULL AS SCIENCE_gpa_points_t2
      ,NULL AS SCIENCE_gpa_points_t3
      ,NULL AS SCIENCE_gpa_points_y1
      ,NULL AS SCIENCE_weighted_points_t1
      ,NULL AS SCIENCE_weighted_points_t2
      ,NULL AS SCIENCE_weighted_points_t3
      ,NULL AS SCIENCE_weighted_points_y1
      ,CONVERT(FLOAT,SCIENCE_cat.H_RT1) AS SCIENCE_H1 
      ,CONVERT(FLOAT,SCIENCE_cat.H_RT2) AS SCIENCE_H2 
      ,CONVERT(FLOAT,SCIENCE_cat.H_RT3) AS SCIENCE_H3 
      ,CONVERT(FLOAT,SCIENCE_cat.H_RT4) AS SCIENCE_H4 
      ,CONVERT(FLOAT,SCIENCE_cat.H_Y1) AS SCIENCE_HY1
      ,CONVERT(FLOAT,SCIENCE_cat.E_RT1) AS SCIENCE_Q1 
      ,CONVERT(FLOAT,SCIENCE_cat.E_RT2) AS SCIENCE_Q2 
      ,CONVERT(FLOAT,SCIENCE_cat.E_RT3) AS SCIENCE_Q3 
      ,CONVERT(FLOAT,SCIENCE_cat.E_RT4) AS SCIENCE_Q4 
      ,CONVERT(FLOAT,SCIENCE_cat.E_Y1) AS SCIENCE_QY1
      ,CONVERT(FLOAT,SCIENCE_cat.S_RT1) AS SCIENCE_S1 
      ,CONVERT(FLOAT,SCIENCE_cat.S_RT2) AS SCIENCE_S2 
      ,CONVERT(FLOAT,SCIENCE_cat.S_RT3) AS SCIENCE_S3 
      ,CONVERT(FLOAT,SCIENCE_cat.S_RT4) AS SCIENCE_S4 
      ,CONVERT(FLOAT,SCIENCE_cat.S_Y1) AS SCIENCE_SY1
      
      ,SOC.course_number AS SOC_course_number
      ,SOC.credittype AS SOC_credittype
      ,SOC.course_name AS SOC_course_name
      ,SOC.credit_hours AS SOC_credit_hours_T1
      ,SOC.credit_hours AS SOC_credit_hours_T2
      ,SOC.credit_hours AS SOC_credit_hours_T3
      ,SOC.credit_hours AS SOC_credit_hours_Y1
      ,SOC.teacher_name AS SOC_teacher_last
      ,SOC.teacher_name AS SOC_teacher_lastfirst
      ,CONVERT(FLOAT,SOC.RT1_term_grade_percent) AS SOC_t1
      ,CONVERT(FLOAT,SOC.RT2_term_grade_percent) AS SOC_t2
      ,CONVERT(FLOAT,SOC.RT3_term_grade_percent) AS SOC_t3
      ,CONVERT(FLOAT,SOC.RT4_term_grade_percent) AS SOC_t4
      ,CONVERT(FLOAT,SOC.Y1_grade_percent) AS SOC_y1
      ,CONVERT(FLOAT,SOC.need_70) AS SOC_need_c
      ,SOC.RT1_term_grade_letter AS SOC_t1_ltr
      ,SOC.RT2_term_grade_letter AS SOC_t2_ltr
      ,SOC.RT3_term_grade_letter AS SOC_t3_ltr
      ,SOC.RT4_term_grade_letter AS SOC_t4_ltr
      ,SOC.Y1_grade_letter AS SOC_y1_ltr
      ,SOC.sectionid AS SOC_t1_enr_sectionid
      ,SOC.sectionid AS SOC_t2_enr_sectionid
      ,SOC.sectionid AS SOC_t3_enr_sectionid
      ,NULL AS SOC_gpa_points_t1
      ,NULL AS SOC_gpa_points_t2
      ,NULL AS SOC_gpa_points_t3
      ,NULL AS SOC_gpa_points_y1
      ,NULL AS SOC_weighted_points_t1
      ,NULL AS SOC_weighted_points_t2
      ,NULL AS SOC_weighted_points_t3
      ,NULL AS SOC_weighted_points_y1
      ,CONVERT(FLOAT,SOC_cat.H_RT1) AS SOC_H1 
      ,CONVERT(FLOAT,SOC_cat.H_RT2) AS SOC_H2 
      ,CONVERT(FLOAT,SOC_cat.H_RT3) AS SOC_H3 
      ,CONVERT(FLOAT,SOC_cat.H_RT4) AS SOC_H4 
      ,CONVERT(FLOAT,SOC_cat.H_Y1) AS SOC_HY1
      ,CONVERT(FLOAT,SOC_cat.E_RT1) AS SOC_Q1 
      ,CONVERT(FLOAT,SOC_cat.E_RT2) AS SOC_Q2 
      ,CONVERT(FLOAT,SOC_cat.E_RT3) AS SOC_Q3 
      ,CONVERT(FLOAT,SOC_cat.E_RT4) AS SOC_Q4 
      ,CONVERT(FLOAT,SOC_cat.E_Y1) AS SOC_QY1
      ,CONVERT(FLOAT,SOC_cat.S_RT1) AS SOC_S1 
      ,CONVERT(FLOAT,SOC_cat.S_RT2) AS SOC_S2 
      ,CONVERT(FLOAT,SOC_cat.S_RT3) AS SOC_S3 
      ,CONVERT(FLOAT,SOC_cat.S_RT4) AS SOC_S4 
      ,CONVERT(FLOAT,SOC_cat.S_Y1) AS SOC_SY1
      
      ,((CONVERT(FLOAT,ISNULL(eng.y1_grade_percent,0))           
           --+ CONVERT(FLOAT,ISNULL(rhet.y1_grade_percent,0)) 
           + CONVERT(FLOAT,ISNULL(math.y1_grade_percent,0)) 
           + CONVERT(FLOAT,ISNULL(science.y1_grade_percent,0)) 
           + CONVERT(FLOAT,ISNULL(soc.y1_grade_percent,0))) 
           / 
         CASE 
          WHEN (CASE WHEN eng.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END
                  --+ CASE WHEN rhet.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END
                  + CASE WHEN math.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END
                  + CASE WHEN science.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END                    
                  + CASE WHEN soc.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
          ELSE (CASE WHEN eng.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END
                  --+ CASE WHEN rhet.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END
                  + CASE WHEN math.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END
                  + CASE WHEN science.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END
                  + CASE WHEN soc.y1_grade_percent IS NOT NULL THEN 1 ELSE 0 END)
         END) AS core_avg
      ,CONVERT(FLOAT,all_cat.H_Y1) AS HW_Avg
      ,CONVERT(FLOAT,all_cat.E_y1) AS HW_Q_Avg      

--Literacy tracking
--MAP$comprehensive#identifiers
--LIT$FP_test_events_long#identifiers#static

     --Lexile (from MAP)
     --update terms in JOIN
     ,lex_base.RITtoReadingScore AS BASE_LEX
     ,lex_curr.rittoreadingscore AS CUR_LEX
       --GLQ
     ,CASE
       WHEN lex_base.RITtoReadingScore  = 'BR' THEN NULL
       WHEN lex_base.RITtoReadingScore <= 100  THEN 'K'
       WHEN lex_base.RITtoReadingScore <= 300  AND lex_base.RITtoReadingScore > 100  THEN '1st'
       WHEN lex_base.RITtoReadingScore <= 500  AND lex_base.RITtoReadingScore > 300  THEN '2nd'
       WHEN lex_base.RITtoReadingScore <= 600  AND lex_base.RITtoReadingScore > 500  THEN '3rd'
       WHEN lex_base.RITtoReadingScore <= 700  AND lex_base.RITtoReadingScore > 600  THEN '4th'
       WHEN lex_base.RITtoReadingScore <= 800  AND lex_base.RITtoReadingScore > 700  THEN '5th'
       WHEN lex_base.RITtoReadingScore <= 900  AND lex_base.RITtoReadingScore > 800  THEN '6th'
       WHEN lex_base.RITtoReadingScore <= 1000 AND lex_base.RITtoReadingScore > 900  THEN '7th'
       WHEN lex_base.RITtoReadingScore <= 1100 AND lex_base.RITtoReadingScore > 1000 THEN '8th'
       WHEN lex_base.RITtoReadingScore <= 1200 AND lex_base.RITtoReadingScore > 1100 THEN '9th'
       WHEN lex_base.RITtoReadingScore <= 1300 AND lex_base.RITtoReadingScore > 1200 THEN '10th'
       WHEN lex_base.RITtoReadingScore <= 1400 AND lex_base.RITtoReadingScore > 1300 THEN '11th'
       WHEN lex_base.RITtoReadingScore  > 1400 THEN '12th'
       ELSE NULL
      END AS BASE_LEX_GLQ_STARTING
     ,CASE
       WHEN lex_curr.RITtoReadingScore  = 'BR' THEN NULL
       WHEN lex_curr.RITtoReadingScore <= 100  THEN 'K'
       WHEN lex_curr.RITtoReadingScore <= 300  AND lex_curr.RITtoReadingScore > 100  THEN '1st'
       WHEN lex_curr.RITtoReadingScore <= 500  AND lex_curr.RITtoReadingScore > 300  THEN '2nd'
       WHEN lex_curr.RITtoReadingScore <= 600  AND lex_curr.RITtoReadingScore > 500  THEN '3rd'
       WHEN lex_curr.RITtoReadingScore <= 700  AND lex_curr.RITtoReadingScore > 600  THEN '4th'
       WHEN lex_curr.RITtoReadingScore <= 800  AND lex_curr.RITtoReadingScore > 700  THEN '5th'
       WHEN lex_curr.RITtoReadingScore <= 900  AND lex_curr.RITtoReadingScore > 800  THEN '6th'
       WHEN lex_curr.RITtoReadingScore <= 1000 AND lex_curr.RITtoReadingScore > 900  THEN '7th'
       WHEN lex_curr.RITtoReadingScore <= 1100 AND lex_curr.RITtoReadingScore > 1000 THEN '8th'
       WHEN lex_curr.RITtoReadingScore <= 1200 AND lex_curr.RITtoReadingScore > 1100 THEN '9th'
       WHEN lex_curr.RITtoReadingScore <= 1300 AND lex_curr.RITtoReadingScore > 1200 THEN '10th'
       WHEN lex_curr.RITtoReadingScore <= 1400 AND lex_curr.RITtoReadingScore > 1300 THEN '11th'
       WHEN lex_curr.RITtoReadingScore  > 1400 THEN '12th'
       ELSE NULL
      END AS BASE_LEX_GLQ_CURRENT

     --F&P          
     ,COALESCE(fp_base.read_lvl, fp_curr.read_lvl) AS start_letter
     ,fp_curr.read_lvl AS end_letter
     --GLQ
     ,COALESCE(fp_base.GLEQ, fp_curr.GLEQ) AS Start_GLEQ
     ,ROUND(fp_curr.GLEQ,1) AS End_GLEQ
     ,ROUND(fp_curr.GLEQ - COALESCE(fp_base.GLEQ, fp_curr.GLEQ),1) AS GLEQ_Growth
       --Level #
     ,COALESCE(fp_base.lvl_num, fp_curr.lvl_num) AS [Start_#]
     ,fp_curr.lvl_num AS [End_#]
     ,ROUND(fp_curr.lvl_num - COALESCE(fp_base.lvl_num, fp_curr.lvl_num),1) AS [Levels_grown]
      
--Accelerated Reader
--update terms in JOIN
--AR year
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_yr.words),1),'.00','') AS words_read_yr
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_yr.words_goal),1),'.00','') AS words_goal_yr      
     ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
     ,CONVERT(FLOAT,ar_yr.mastery) AS mastery_yr
     ,NULL AS ONTRACK_WORDS_YR
     
     --AR current
     --current trimester = current HEX + previous HEX
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_curr.words)),'.00','') AS words_read_cur_term
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_curr.words_goal)),'.00','') AS words_goal_cur_term
     ,ar_curr.rank_words_grade_in_school AS words_rank_cur_term_in_grade
     --,CONVERT(FLOAT,NULL AS mastery_curr
      
      --AR progress
        --to year goal      
     ,CASE
       WHEN ar_yr.stu_status_words = 'On Track' THEN 'Yes!'
       WHEN ar_yr.stu_status_words = 'Off Track' THEN 'No'
       ELSE ar_yr.stu_status_words
      END AS stu_status_words_yr   
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN ((ar_curr.words_goal * 6) - ar_yr.words) <= 0 THEN NULL 
        ELSE (ar_curr.words_goal * 6) - ar_yr.words
       END,0) AS INT)),1),'.00','') AS words_needed_yr
      --to term goal       
     ,CASE
       WHEN ar_curr.words_goal - ar_curr.words <= 0 THEN 'Met Goal'
       WHEN ar_curr.stu_status_words IN ('On Track','Met Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('On Track','Met Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('Off Track','Missed Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('Off Track','Missed Goal') THEN 'No'              
       ELSE ar_curr.stu_status_words
      END AS stu_status_words_cur_term
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN ar_curr.words_goal - ar_curr.words <= 0 THEN NULL 
        ELSE ar_curr.words_goal - ar_curr.words
       END,0) AS INT)),1),'.00','') AS words_needed_cur_term        
             
     --MAP scores
     ,map_all.Y0_Spring_READ_percentile AS spr_2016_READ_pctle
     ,map_all.Y0_Winter_READ_percentile AS w_2016_READ_pctle
     ,map_all.Y0_Fall_READ_percentile AS f_2015_READ_pctle
     ,map_all.Y0_Spring_READ_RIT AS spr_2016_READ_RIT
     ,map_all.Y0_Winter_READ_RIT AS w_2016_READ_RIT
     ,map_all.Y0_Fall_READ_RIT AS f_2015_READ_RIT

     ,map_all.Y0_Spring_MATH_percentile AS spr_2016_MATH_pctle
     ,map_all.Y0_Winter_MATH_percentile AS w_2016_MATH_pctle
     ,map_all.Y0_Fall_MATH_percentile AS f_2015_MATH_pctle
     ,map_all.Y0_Spring_MATH_RIT AS spr_2016_MATH_RIT
     ,map_all.Y0_Winter_MATH_RIT AS w_2016_MATH_RIT
     ,map_all.Y0_Fall_MATH_RIT AS f_2015_MATH_RIT

     ,map_all.Y0_Spring_LANG_percentile AS spr_2016_LANG_pctle
     ,map_all.Y0_Winter_LANG_percentile AS w_2016_LANG_pctle
     ,map_all.Y0_Fall_LANG_percentile AS f_2015_LANG_pctle
     ,map_all.Y0_Spring_LANG_RIT AS spr_2016_LANG_RIT
     ,map_all.Y0_Winter_LANG_RIT AS w_2016_LANG_RIT
     ,map_all.Y0_Fall_LANG_RIT AS f_2015_LANG_RIT

     ,map_all.Y0_Spring_GEN_percentile AS spr_2016_GEN_pctle
     ,map_all.Y0_Winter_GEN_percentile AS w_2016_GEN_pctle
     ,map_all.Y0_Fall_GEN_percentile AS f_2015_GEN_pctle
     ,map_all.Y0_Spring_GEN_RIT AS spr_2016_GEN_RIT
     ,map_all.Y0_Winter_GEN_RIT AS w_2016_GEN_RIT
     ,map_all.Y0_Fall_GEN_RIT AS f_2015_GEN_RIT


     ,map_all.Y1_Spring_READ_percentile AS spr_2015_READ_pctle
     ,map_all.Y1_Winter_READ_percentile AS w_2015_READ_pctle
     ,map_all.Y1_Fall_READ_percentile AS f_2014_READ_pctle
     ,map_all.Y1_Spring_READ_RIT AS spr_2015_READ_RIT
     ,map_all.Y1_Winter_READ_RIT AS w_2015_READ_RIT
     ,map_all.Y1_Fall_READ_RIT AS f_2014_READ_RIT

     ,map_all.Y1_Spring_MATH_percentile AS spr_2015_MATH_pctle
     ,map_all.Y1_Winter_MATH_percentile AS w_2015_MATH_pctle
     ,map_all.Y1_Fall_MATH_percentile AS f_2014_MATH_pctle
     ,map_all.Y1_Spring_MATH_RIT AS spr_2015_MATH_RIT
     ,map_all.Y1_Winter_MATH_RIT AS w_2015_MATH_RIT
     ,map_all.Y1_Fall_MATH_RIT AS f_2014_MATH_RIT

     ,map_all.Y1_Spring_LANG_percentile AS spr_2015_LANG_pctle
     ,map_all.Y1_Winter_LANG_percentile AS w_2015_LANG_pctle
     ,map_all.Y1_Fall_LANG_percentile AS f_2014_LANG_pctle
     ,map_all.Y1_Spring_LANG_RIT AS spr_2015_LANG_RIT
     ,map_all.Y1_Winter_LANG_RIT AS w_2015_LANG_RIT
     ,map_all.Y1_Fall_LANG_RIT AS f_2014_LANG_RIT

     ,map_all.Y1_Spring_GEN_percentile AS spr_2015_GEN_pctle
     ,map_all.Y1_Winter_GEN_percentile AS w_2015_GEN_pctle
     ,map_all.Y1_Fall_GEN_percentile AS f_2014_GEN_pctle
     ,map_all.Y1_Spring_GEN_RIT AS spr_2015_GEN_RIT
     ,map_all.Y1_Winter_GEN_RIT AS w_2015_GEN_RIT
     ,map_all.Y1_Fall_GEN_RIT AS f_2014_GEN_RIT


     ,map_all.Y2_Spring_READ_percentile AS spr_2014_READ_pctle
     ,map_all.Y2_Winter_READ_percentile AS w_2014_READ_pctle
     ,map_all.Y2_Fall_READ_percentile AS f_2013_READ_pctle
     ,map_all.Y2_Spring_READ_RIT AS spr_2014_READ_RIT
     ,map_all.Y2_Winter_READ_RIT AS w_2014_READ_RIT
     ,map_all.Y2_Fall_READ_RIT AS f_2013_READ_RIT

     ,map_all.Y2_Spring_MATH_percentile AS spr_2014_MATH_pctle
     ,map_all.Y2_Winter_MATH_percentile AS w_2014_MATH_pctle
     ,map_all.Y2_Fall_MATH_percentile AS f_2013_MATH_pctle
     ,map_all.Y2_Spring_MATH_RIT AS spr_2014_MATH_RIT
     ,map_all.Y2_Winter_MATH_RIT AS w_2014_MATH_RIT
     ,map_all.Y2_Fall_MATH_RIT AS f_2013_MATH_RIT

     ,map_all.Y2_Spring_LANG_percentile AS spr_2014_LANG_pctle
     ,map_all.Y2_Winter_LANG_percentile AS w_2014_LANG_pctle
     ,map_all.Y2_Fall_LANG_percentile AS f_2013_LANG_pctle
     ,map_all.Y2_Spring_LANG_RIT AS spr_2014_LANG_RIT
     ,map_all.Y2_Winter_LANG_RIT AS w_2014_LANG_RIT
     ,map_all.Y2_Fall_LANG_RIT AS f_2013_LANG_RIT

     ,map_all.Y2_Spring_GEN_percentile AS spr_2014_GEN_pctle
     ,map_all.Y2_Winter_GEN_percentile AS w_2014_GEN_pctle
     ,map_all.Y2_Fall_GEN_percentile AS f_2013_GEN_pctle
     ,map_all.Y2_Spring_GEN_RIT AS spr_2014_GEN_RIT
     ,map_all.Y2_Winter_GEN_RIT AS w_2014_GEN_RIT
     ,map_all.Y2_Fall_GEN_RIT AS f_2013_GEN_RIT


     ,map_all.Y3_Spring_READ_percentile AS spr_2013_READ_pctle
     ,map_all.Y3_Winter_READ_percentile AS w_2013_READ_pctle
     ,map_all.Y3_Fall_READ_percentile AS f_2012_READ_pctle
     ,map_all.Y3_Spring_READ_RIT AS spr_2013_READ_RIT
     ,map_all.Y3_Winter_READ_RIT AS w_2013_READ_RIT
     ,map_all.Y3_Fall_READ_RIT AS f_2012_READ_RIT

     ,map_all.Y3_Spring_MATH_percentile AS spr_2013_MATH_pctle
     ,map_all.Y3_Winter_MATH_percentile AS w_2013_MATH_pctle
     ,map_all.Y3_Fall_MATH_percentile AS f_2012_MATH_pctle
     ,map_all.Y3_Spring_MATH_RIT AS spr_2013_MATH_RIT
     ,map_all.Y3_Winter_MATH_RIT AS w_2013_MATH_RIT
     ,map_all.Y3_Fall_MATH_RIT AS f_2012_MATH_RIT

     ,map_all.Y3_Spring_LANG_percentile AS spr_2013_LANG_pctle
     ,map_all.Y3_Winter_LANG_percentile AS w_2013_LANG_pctle
     ,NULL AS f_2012_lang_pctle
     ,map_all.Y3_Spring_LANG_RIT AS spr_2013_LANG_RIT
     ,map_all.Y3_Winter_LANG_RIT AS w_2013_LANG_RIT
     ,NULL AS f_2012_lang_RIT

     ,map_all.Y3_Spring_GEN_percentile AS spr_2013_GEN_pctle
     ,map_all.Y3_Winter_GEN_percentile AS w_2013_GEN_pctle
     ,map_all.Y3_Fall_GEN_percentile AS f_2012_GEN_pctle
     ,map_all.Y3_Spring_GEN_RIT AS spr_2013_GEN_RIT
     ,map_all.Y3_Winter_GEN_RIT AS w_2013_GEN_RIT
     ,map_all.Y3_Fall_GEN_RIT AS f_2012_GEN_RIT

     
--NJASK scores
--NJASK$ela_wide
--NJASK$math_wide      
/*--UPDATE FIELDS FOR CURRENT YEAR--*/
--13-14      
      --Grade
      ,NULL AS njask_gr_lev_2014
      --ELA
      ,NULL AS ela_score_2014
      ,NULL AS ela_prof_2014      
      --Math
      ,NULL AS math_score_2014
      ,NULL AS math_prof_2014
--12-13
      --Grade
      ,NULL AS njask_gr_lev_2013
      --ELA
      ,NULL AS ela_score_2013
      ,NULL AS ela_prof_2013      
      --Math
      ,NULL AS math_score_2013
      ,NULL AS math_prof_2013
--11-12      
      --Grade
      ,NULL AS njask_gr_lev_2012
      --ELA
      ,NULL AS ela_score_2012
      ,NULL AS ela_prof_2012      
      --Math
      ,NULL AS math_score_2012
      ,NULL AS math_prof_2012
--10-11
      --Grade
      ,NULL AS njask_gr_lev_2011
      --ELA
      ,NULL AS ela_score_2011
      ,NULL AS ela_prof_2011      
      --Math
      ,NULL AS math_score_2011
      ,NULL AS math_prof_2011      
      
--DISCIPLINE
      ,disc_recent.disc_01_date_reported
      ,disc_recent.disc_01_given_by
      ,disc_recent.DISC_01_subtype
      ,CASE
        WHEN disc_recent.disc_01_subject IS NULL THEN disc_recent.disc_01_incident 
        ELSE disc_recent.disc_01_subject
       END AS disc_01_incident
      ,disc_recent.disc_02_date_reported
      ,disc_recent.disc_02_given_by
      ,disc_recent.DISC_02_subtype
      ,CASE 
        WHEN disc_recent.disc_02_subject IS NULL THEN disc_recent.disc_02_incident 
        ELSE disc_recent.disc_02_subject
       END AS disc_02_incident
      ,disc_recent.disc_03_date_reported
      ,disc_recent.disc_03_given_by
      ,disc_recent.DISC_03_subtype
      ,CASE
        WHEN disc_recent.disc_03_subject IS NULL THEN disc_recent.disc_03_incident 
        ELSE disc_recent.disc_03_subject
       END AS disc_03_incident
      ,disc_recent.disc_04_date_reported
      ,disc_recent.disc_04_given_by
      ,disc_recent.DISC_04_subtype
      ,CASE
        WHEN disc_recent.disc_04_subject IS NULL THEN disc_recent.disc_04_incident 
        ELSE disc_recent.disc_04_subject
       END AS disc_04_incident
      ,disc_recent.disc_05_date_reported
      ,disc_recent.disc_05_given_by
      ,disc_recent.DISC_05_subtype
      ,CASE
        WHEN disc_recent.disc_05_subject IS NULL THEN disc_recent.disc_05_incident 
        ELSE disc_recent.disc_05_subject
       END AS disc_05_incident
            
      ,CASE WHEN roster.grade_level <= 6 THEN 'Bench' ELSE 'Choices' END AS bench_choices_label
      ,CASE WHEN (disc_count.iss + disc_count.oss) > 0 THEN 'Yes' ELSE 'No' END AS ISS_OSS
      ,ISNULL(disc_count.silent_lunches,0) AS Y1_silent_lunches      
      ,ISNULL(disc_count.rt1_silent_lunches,0) AS t1_silent_lunches
      ,ISNULL(disc_count.rt2_silent_lunches,0) AS t2_silent_lunches
      ,ISNULL(disc_count.rt3_silent_lunches,0) AS t3_silent_lunches
      ,ISNULL(disc_count.rt4_silent_lunches,0) AS t4_silent_lunches
      
      ,ISNULL(disc_count.detentions,0) AS Y1_detentions      
      ,ISNULL(disc_count.rt1_detentions,0) AS t1_detentions
      ,ISNULL(disc_count.rt2_detentions,0) AS t2_detentions      
      ,ISNULL(disc_count.rt3_detentions,0) AS t3_detentions
      ,ISNULL(disc_count.rt4_detentions,0) AS t4_detentions
      
      ,ISNULL(disc_count.ISS,0) AS Y1_iss
      ,ISNULL(disc_count.rt1_iss,0) AS t1_iss
      ,ISNULL(disc_count.rt2_iss,0) AS t2_iss      
      ,ISNULL(disc_count.rt3_iss,0) AS t3_iss      
      ,ISNULL(disc_count.rt4_iss,0) AS t4_iss      
      
      ,ISNULL(disc_count.oss,0) AS Y1_oss
      ,ISNULL(disc_count.rt1_oss,0) AS t1_oss
      ,ISNULL(disc_count.rt2_oss,0) AS t2_oss      
      ,ISNULL(disc_count.rt3_oss,0) AS t3_oss      
      ,ISNULL(disc_count.rt4_OSS,0) AS t4_oss      
      
      ,ISNULL(disc_count.bench,0) AS Y1_bench
      ,ISNULL(disc_count.rt1_bench,0) AS t1_bench
      ,ISNULL(disc_count.rt2_bench,0) AS t2_bench      
      ,ISNULL(disc_count.rt3_bench,0) AS t3_bench  
      ,ISNULL(disc_count.rt4_bench,0) AS t4_bench  

      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.bench,0) ELSE ISNULL(disc_count.choices,0) END AS Y1_bench_choices      
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt1_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T1_bench_choices
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt2_bench,0) ELSE ISNULL(disc_count.rt2_choices,0) END AS T2_bench_choices
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt3_bench,0) ELSE ISNULL(disc_count.rt3_choices,0) END AS T3_bench_choices
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt4_bench,0) ELSE ISNULL(disc_count.rt4_choices,0) END AS T4_bench_choices

      -- XC
      ,NULL AS xc_Fall_1
      ,NULL AS xc_Fall_2
      ,NULL AS xc_Winter_1
      ,NULL AS xc_Winter_2
      ,NULL AS xc_Spring_1
      ,NULL AS xc_Spring_2
      ,NULL AS xc_WinterSpring_1
      ,NULL AS xc_WinterSpring_2
      ,NULL AS xc_YearRound_1
      ,NULL AS xc_YearRound_2
      ,ISNULL(xc.activity_hash, 'None') AS activity_hash
      
FROM KIPP_NJ..COHORT$identifiers_long#static roster WITH (NOLOCK)

JOIN KIPP_NJ..REPORTING$dates curterm WITH(NOLOCK)
  ON roster.schoolid = curterm.schoolid
 AND CONVERT(DATE,GETDATE()) BETWEEN curterm.start_date AND curterm.end_date
 AND curterm.identifier = 'RT'    
JOIN KIPP_NJ..REPORTING$dates cur_hex WITH(NOLOCK)
  ON roster.schoolid = cur_hex.schoolid
 AND CONVERT(DATE,GETDATE()) BETWEEN cur_hex.start_date AND cur_hex.end_date
 AND cur_hex.identifier = 'AR'

/* ATTENDANCE */
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static att_counts WITH (NOLOCK)
  ON roster.studentid = att_counts.studentid
 AND roster.year = att_counts.academic_year
 AND curterm.alt_name = att_counts.term
 AND att_counts.MEM_counts_yr > 0

/* GRADES & GPA */
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_wide#static eng WITH(NOLOCK)
  ON roster.student_number = eng.student_number
 AND eng.is_curterm = 1
 AND eng.credittype = 'ENG'
 AND eng.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static eng_cat WITH(NOLOCK)
  ON roster.student_number = eng_cat.student_number
 AND curterm.time_per_name = eng_cat.reporting_term
 AND eng_cat.credittype = 'ENG'
 AND eng_cat.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_wide#static MATH WITH(NOLOCK)
  ON roster.student_number = MATH.student_number
 AND MATH.is_curterm = 1
 AND MATH.credittype = 'MATH'
 AND MATH.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static MATH_cat WITH(NOLOCK)
  ON roster.student_number = MATH_cat.student_number
 AND curterm.time_per_name = MATH_cat.reporting_term
 AND MATH_cat.credittype = 'MATH'
 AND MATH_cat.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_wide#static SCIENCE WITH(NOLOCK)
  ON roster.student_number = SCIENCE.student_number
 AND SCIENCE.is_curterm = 1
 AND SCIENCE.credittype = 'SCI'
 AND SCIENCE.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static SCIENCE_cat WITH(NOLOCK)
  ON roster.student_number = SCIENCE_cat.student_number
 AND curterm.time_per_name = SCIENCE_cat.reporting_term
 AND SCIENCE_cat.credittype = 'SCI'
 AND SCIENCE_cat.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_wide#static SOC WITH(NOLOCK)
  ON roster.student_number = SOC.student_number
 AND SOC.is_curterm = 1
 AND SOC.credittype = 'SOC'
 AND SOC.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static SOC_cat WITH(NOLOCK)
  ON roster.student_number = SOC_cat.student_number
 AND curterm.time_per_name = SOC_cat.reporting_term
 AND SOC_cat.credittype = 'SOC'
 AND SOC_cat.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static all_cat WITH(NOLOCK)
  ON roster.student_number = all_cat.student_number
 AND curterm.time_per_name = all_cat.reporting_term
 AND all_cat.credittype = 'ALL'
 AND all_cat.rn_credittype = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_wide#static gpa WITH (NOLOCK)
  ON roster.student_number = gpa.student_number
 AND roster.year = gpa.academic_year
 AND curterm.alt_name = gpa.term

/* PROMO STATUS */
LEFT OUTER JOIN KIPP_NJ..REPORTING$promo_status#MS promo WITH (NOLOCK)
  ON roster.studentid = promo.studentid
 AND promo.is_curterm = 1
  
/* F&P & LEXILE */
LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static fp_base WITH (NOLOCK)
  ON roster.student_number = fp_base.STUDENT_NUMBER
 AND roster.year = fp_base.academic_year
 AND fp_base.base_yr = 1
 AND fp_base.status = 'Achieved'
LEFT OUTER JOIN KIPP_NJ..LIT$all_test_events#identifiers#static fp_curr WITH (NOLOCK)
  ON roster.student_number = fp_curr.STUDENT_NUMBER 
 AND fp_curr.curr_all = 1
 AND fp_curr.status = 'Achieved'
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_base WITH (NOLOCK)
  ON roster.student_number = lex_base.student_number
 AND roster.year = lex_base.academic_year
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.rn_base = 1 
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_curr WITH (NOLOCK)
  ON roster.student_number = lex_curr.student_number
 AND roster.year = lex_curr.academic_year
 AND lex_curr.MeasurementScale = 'Reading'
 AND lex_curr.rn_curr = 1 
  
/* AR */
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.studentid = ar_yr.studentid 
 AND roster.year = ar_yr.academic_year
 AND ar_yr.time_period_name = 'Year' 
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.studentid = ar_curr.studentid 
 AND roster.year = ar_curr.academic_year
 AND REPLACE(cur_hex.time_per_name,'Round ','Q') = ar_curr.time_period_name 

/* MAP */
LEFT OUTER JOIN KIPP_NJ..MAP$wide_all#static map_all WITH (NOLOCK)
  ON roster.studentid = map_all.studentid
  
/* DISC */
LEFT OUTER JOIN KIPP_NJ..DISC$recent_incidents_wide disc_recent WITH (NOLOCK)
  ON roster.studentid = disc_recent.studentid
 AND disc_recent.log_type = 'Discipline'
LEFT OUTER JOIN KIPP_NJ..DISC$counts_wide disc_count WITH (NOLOCK)
  ON roster.studentid = disc_count.studentid

/* XC */
LEFT OUTER JOIN KIPP_NJ..XC$activities_wide xc WITH(NOLOCK)
  ON roster.STUDENT_NUMBER = xc.student_number
 AND roster.year = xc.academic_year

WHERE ((roster.grade_level BETWEEN 5 AND 8) OR (roster.grade_level = 4 AND roster.schoolid = 73252))
  AND roster.enroll_status = 0
  AND roster.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND roster.rn = 1