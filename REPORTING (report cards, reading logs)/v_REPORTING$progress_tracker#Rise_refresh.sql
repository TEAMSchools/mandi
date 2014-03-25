--only shows 5 core credit types
--dependent on grades$wide_credittype#MS > grades$detail_placeholder#MS

USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_tracker#Rise_refresh AS
WITH roster AS
     (
      SELECT s.id
            ,s.student_number
            ,s.schoolid
            ,s.lastfirst
            ,s.grade_level
            ,s.team
            ,cs.advisor       
            ,cs.SPEDLEP
            ,s.gender
            ,s.mother
            ,s.father       
            ,s.home_phone
            ,cs.mother_cell
            ,cs.mother_home
            ,cs.father_cell
            ,cs.father_home
            ,cs.guardianemail AS contactemail
      FROM STUDENTS s WITH (NOLOCK)
      LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
        ON s.id = cs.studentid
      WHERE s.schoolid = 73252
        AND s.enroll_status = 0
        --AND s.id = 4686
     )
       
SELECT ROW_NUMBER() OVER(
           ORDER BY roster.grade_level, roster.lastfirst)  AS Count
      ,roster.*
       
--ATTENDANCE
      --yr
      ,att_counts.absences_total           AS Y1_absences_total
      ,att_counts.absences_undoc           AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
      ,att_counts.tardies_total            AS Y1_tardies_total
      ,att_counts.tardies_T10              AS Y1_tardies_t10
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total
      --cur   
      ,att_counts.cur_absences_total           AS curterm_absences_total
      ,att_counts.cur_absences_undoc           AS curterm_absences_undoc
      ,ROUND(att_pct.cur_att_pct_total,0)      AS curterm_att_pct_total
      ,ROUND(att_pct.cur_att_pct_undoc,0)      AS curterm_att_pct_undoc      
      ,att_counts.cur_tardies_total            AS curterm_tardies_total
      ,att_counts.cur_tardies_T10              AS curterm_tardies_t10
      ,ROUND(att_pct.cur_tardy_pct_total,0)    AS curterm_tardy_pct_total

--PROMOTIONAL STATUS
      ,promo.attendance_points
      ,ROUND(promo.y1_att_pts_pct,1) AS ATT_POINTS_PCT
      ,promo.att_string
      ,promo.promo_status_overall      
      ,promo.GPA_Promo_Status_Grades
      ,promo.promo_status_att
      ,promo.promo_status_hw
      ,promo.days_to_perfect

--GPA
      ,CONVERT(FLOAT,gpa.gpa_t1) AS gpa_t1
      ,gpa.GPA_T1_Rank_G AS GPA_T1_RANK
      ,CONVERT(FLOAT,gpa.gpa_t2) AS gpa_t2
      ,gpa.GPA_T2_Rank_G AS GPA_T2_RANK
      ,CONVERT(FLOAT,gpa.GPA_t3) AS gpa_t3
      ,gpa.GPA_T3_Rank_G AS GPA_T3_RANK
      ,CONVERT(FLOAT,gpa.gpa_y1) AS gpa_y1       
      ,gpa.GPA_Y1_Rank_G AS GPA_Y1_RANK
      ,gpa.elements
      ,gpa.num_failing
      ,gpa.failing

--COURSE GRADES
      ,grades.rc1_course_number AS ENGLISH_course_number
      ,grades.rc1_credittype AS ENGLISH_credittype
      ,grades.rc1_course_name AS ENGLISH_course_name
      ,grades.rc1_credit_hours_T1 AS ENGLISH_credit_hours_T1
      ,grades.rc1_credit_hours_T2 AS ENGLISH_credit_hours_T2
      ,grades.rc1_credit_hours_T3 AS ENGLISH_credit_hours_T3
      ,grades.rc1_credit_hours_Y1 AS ENGLISH_credit_hours_Y1
      ,grades.rc1_teacher_last AS ENGLISH_teacher_last
      ,grades.rc1_teacher_lastfirst AS ENGLISH_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc1_t1) AS ENGLISH_t1
      ,CONVERT(FLOAT,grades.rc1_t2) AS ENGLISH_t2
      ,CONVERT(FLOAT,grades.rc1_t3) AS ENGLISH_t3
      ,CONVERT(FLOAT,grades.rc1_y1) AS ENGLISH_y1
      ,grades.rc1_t1_ltr AS ENGLISH_t1_ltr
      ,grades.rc1_t2_ltr AS ENGLISH_t2_ltr
      ,grades.rc1_t3_ltr AS ENGLISH_t3_ltr
      ,grades.rc1_y1_ltr AS ENGLISH_y1_ltr
      ,grades.rc1_t1_enr_sectionid AS ENGLISH_t1_enr_sectionid
      ,grades.rc1_t2_enr_sectionid AS ENGLISH_t2_enr_sectionid
      ,grades.rc1_t2_enr_sectionid AS ENGLISH_t3_enr_sectionid
      ,grades.rc1_gpa_points_t1 AS ENGLISH_gpa_points_t1
      ,grades.rc1_gpa_points_t2 AS ENGLISH_gpa_points_t2
      ,grades.rc1_gpa_points_t3 AS ENGLISH_gpa_points_t3
      ,grades.rc1_gpa_points_y1 AS ENGLISH_gpa_points_y1
      ,grades.rc1_weighted_points_t1 AS ENGLISH_weighted_points_t1
      ,grades.rc1_weighted_points_t2 AS ENGLISH_weighted_points_t2
      ,grades.rc1_weighted_points_t3 AS ENGLISH_weighted_points_t3
      ,grades.rc1_weighted_points_y1 AS ENGLISH_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc1_H1)  AS ENGLISH_H1 
      ,CONVERT(FLOAT,grades.rc1_H2)  AS ENGLISH_H2 
      ,CONVERT(FLOAT,grades.rc1_H3)  AS ENGLISH_H3 
      ,CONVERT(FLOAT,grades.rc1_HY1) AS ENGLISH_HY1
      ,CONVERT(FLOAT,grades.rc1_Q1)  AS ENGLISH_Q1 
      ,CONVERT(FLOAT,grades.rc1_Q2)  AS ENGLISH_Q2 
      ,CONVERT(FLOAT,grades.rc1_Q3)  AS ENGLISH_Q3 
      ,CONVERT(FLOAT,grades.rc1_QY1) AS ENGLISH_QY1
      ,CONVERT(FLOAT,grades.rc1_A1) AS ENGLISH_A1
      ,CONVERT(FLOAT,grades.rc1_A2) AS ENGLISH_A2
      ,CONVERT(FLOAT,grades.rc1_A3) AS ENGLISH_A3
      
      ,grades.rc2_course_number AS RHET_course_number
      ,grades.rc2_credittype AS RHET_credittype
      ,grades.rc2_course_name AS RHET_course_name
      ,grades.rc2_credit_hours_T1 AS RHET_credit_hours_T1
      ,grades.rc2_credit_hours_T2 AS RHET_credit_hours_T2
      ,grades.rc2_credit_hours_T3 AS RHET_credit_hours_T3
      ,grades.rc2_credit_hours_Y1 AS RHET_credit_hours_Y1
      ,grades.rc2_teacher_last AS RHET_teacher_last
      ,grades.rc2_teacher_lastfirst AS RHET_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc2_t1) AS RHET_t1
      ,CONVERT(FLOAT,grades.rc2_t2) AS RHET_t2
      ,CONVERT(FLOAT,grades.rc2_t3) AS RHET_t3
      ,CONVERT(FLOAT,grades.rc2_y1) AS RHET_y1
      ,grades.rc2_t1_ltr AS RHET_t1_ltr
      ,grades.rc2_t2_ltr AS RHET_t2_ltr
      ,grades.rc2_t3_ltr AS RHET_t3_ltr
      ,grades.rc2_y1_ltr AS RHET_y1_ltr
      ,grades.rc2_t1_enr_sectionid AS RHET_t1_enr_sectionid
      ,grades.rc2_t2_enr_sectionid AS RHET_t2_enr_sectionid
      ,grades.rc2_t2_enr_sectionid AS RHET_t3_enr_sectionid
      ,grades.rc2_gpa_points_t1 AS RHET_gpa_points_t1
      ,grades.rc2_gpa_points_t2 AS RHET_gpa_points_t2
      ,grades.rc2_gpa_points_t3 AS RHET_gpa_points_t3
      ,grades.rc2_gpa_points_y1 AS RHET_gpa_points_y1
      ,grades.rc2_weighted_points_t1 AS RHET_weighted_points_t1
      ,grades.rc2_weighted_points_t2 AS RHET_weighted_points_t2
      ,grades.rc2_weighted_points_t3 AS RHET_weighted_points_t3
      ,grades.rc2_weighted_points_y1 AS RHET_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc2_H1)  AS RHET_H1 
      ,CONVERT(FLOAT,grades.rc2_H2)  AS RHET_H2 
      ,CONVERT(FLOAT,grades.rc2_H3)  AS RHET_H3 
      ,CONVERT(FLOAT,grades.rc2_HY1) AS RHET_HY1
      ,CONVERT(FLOAT,grades.rc2_Q1)  AS RHET_Q1 
      ,CONVERT(FLOAT,grades.rc2_Q2)  AS RHET_Q2 
      ,CONVERT(FLOAT,grades.rc2_Q3)  AS RHET_Q3 
      ,CONVERT(FLOAT,grades.rc2_QY1) AS RHET_QY1
      ,CONVERT(FLOAT,grades.rc2_A1) AS RHET_A1
      ,CONVERT(FLOAT,grades.rc2_A2) AS RHET_A2
      ,CONVERT(FLOAT,grades.rc2_A3) AS RHET_A3
      
      ,grades.rc3_course_number AS MATH_course_number
      ,grades.rc3_credittype AS MATH_credittype
      ,grades.rc3_course_name AS MATH_course_name
      ,grades.rc3_credit_hours_T1 AS MATH_credit_hours_T1
      ,grades.rc3_credit_hours_T2 AS MATH_credit_hours_T2
      ,grades.rc3_credit_hours_T3 AS MATH_credit_hours_T3
      ,grades.rc3_credit_hours_Y1 AS MATH_credit_hours_Y1
      ,grades.rc3_teacher_last AS MATH_teacher_last
      ,grades.rc3_teacher_lastfirst AS MATH_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc3_t1) AS MATH_t1
      ,CONVERT(FLOAT,grades.rc3_t2) AS MATH_t2
      ,CONVERT(FLOAT,grades.rc3_t3) AS MATH_t3
      ,CONVERT(FLOAT,grades.rc3_y1) AS MATH_y1
      ,grades.rc3_t1_ltr AS MATH_t1_ltr
      ,grades.rc3_t2_ltr AS MATH_t2_ltr
      ,grades.rc3_t3_ltr AS MATH_t3_ltr
      ,grades.rc3_y1_ltr AS MATH_y1_ltr
      ,grades.rc3_t1_enr_sectionid AS MATH_t1_enr_sectionid
      ,grades.rc3_t2_enr_sectionid AS MATH_t2_enr_sectionid
      ,grades.rc3_t2_enr_sectionid AS MATH_t3_enr_sectionid
      ,grades.rc3_gpa_points_t1 AS MATH_gpa_points_t1
      ,grades.rc3_gpa_points_t2 AS MATH_gpa_points_t2
      ,grades.rc3_gpa_points_t3 AS MATH_gpa_points_t3
      ,grades.rc3_gpa_points_y1 AS MATH_gpa_points_y1
      ,grades.rc3_weighted_points_t1 AS MATH_weighted_points_t1
      ,grades.rc3_weighted_points_t2 AS MATH_weighted_points_t2
      ,grades.rc3_weighted_points_t3 AS MATH_weighted_points_t3
      ,grades.rc3_weighted_points_y1 AS MATH_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc3_H1)  AS MATH_H1 
      ,CONVERT(FLOAT,grades.rc3_H2)  AS MATH_H2 
      ,CONVERT(FLOAT,grades.rc3_H3)  AS MATH_H3 
      ,CONVERT(FLOAT,grades.rc3_HY1) AS MATH_HY1
      ,CONVERT(FLOAT,grades.rc3_Q1)  AS MATH_Q1 
      ,CONVERT(FLOAT,grades.rc3_Q2)  AS MATH_Q2 
      ,CONVERT(FLOAT,grades.rc3_Q3)  AS MATH_Q3 
      ,CONVERT(FLOAT,grades.rc3_QY1) AS MATH_QY1
      ,CONVERT(FLOAT,grades.rc3_A1) AS MATH_A1
      ,CONVERT(FLOAT,grades.rc3_A2) AS MATH_A2
      ,CONVERT(FLOAT,grades.rc3_A3) AS MATH_A3
      
      ,grades.rc4_course_number AS SCIENCE_course_number
      ,grades.rc4_credittype AS SCIENCE_credittype
      ,grades.rc4_course_name AS SCIENCE_course_name
      ,grades.rc4_credit_hours_T1 AS SCIENCE_credit_hours_T1
      ,grades.rc4_credit_hours_T2 AS SCIENCE_credit_hours_T2
      ,grades.rc4_credit_hours_T3 AS SCIENCE_credit_hours_T3
      ,grades.rc4_credit_hours_Y1 AS SCIENCE_credit_hours_Y1
      ,grades.rc4_teacher_last AS SCIENCE_teacher_last
      ,grades.rc4_teacher_lastfirst AS SCIENCE_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc4_t1) AS SCIENCE_t1
      ,CONVERT(FLOAT,grades.rc4_t2) AS SCIENCE_t2
      ,CONVERT(FLOAT,grades.rc4_t3) AS SCIENCE_t3
      ,CONVERT(FLOAT,grades.rc4_y1) AS SCIENCE_y1
      ,grades.rc4_t1_ltr AS SCIENCE_t1_ltr
      ,grades.rc4_t2_ltr AS SCIENCE_t2_ltr
      ,grades.rc4_t3_ltr AS SCIENCE_t3_ltr
      ,grades.rc4_y1_ltr AS SCIENCE_y1_ltr
      ,grades.rc4_t1_enr_sectionid AS SCIENCE_t1_enr_sectionid
      ,grades.rc4_t2_enr_sectionid AS SCIENCE_t2_enr_sectionid
      ,grades.rc4_t2_enr_sectionid AS SCIENCE_t3_enr_sectionid
      ,grades.rc4_gpa_points_t1 AS SCIENCE_gpa_points_t1
      ,grades.rc4_gpa_points_t2 AS SCIENCE_gpa_points_t2
      ,grades.rc4_gpa_points_t3 AS SCIENCE_gpa_points_t3
      ,grades.rc4_gpa_points_y1 AS SCIENCE_gpa_points_y1
      ,grades.rc4_weighted_points_t1 AS SCIENCE_weighted_points_t1
      ,grades.rc4_weighted_points_t2 AS SCIENCE_weighted_points_t2
      ,grades.rc4_weighted_points_t3 AS SCIENCE_weighted_points_t3
      ,grades.rc4_weighted_points_y1 AS SCIENCE_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc4_H1)  AS SCIENCE_H1 
      ,CONVERT(FLOAT,grades.rc4_H2)  AS SCIENCE_H2 
      ,CONVERT(FLOAT,grades.rc4_H3)  AS SCIENCE_H3 
      ,CONVERT(FLOAT,grades.rc4_HY1) AS SCIENCE_HY1
      ,CONVERT(FLOAT,grades.rc4_Q1)  AS SCIENCE_Q1 
      ,CONVERT(FLOAT,grades.rc4_Q2)  AS SCIENCE_Q2 
      ,CONVERT(FLOAT,grades.rc4_Q3)  AS SCIENCE_Q3 
      ,CONVERT(FLOAT,grades.rc4_QY1) AS SCIENCE_QY1
      ,CONVERT(FLOAT,grades.rc4_A1) AS SCIENCE_A1
      ,CONVERT(FLOAT,grades.rc4_A2) AS SCIENCE_A2
      ,CONVERT(FLOAT,grades.rc4_A3) AS SCIENCE_A3
      
      ,grades.rc5_course_number AS SOC_course_number
      ,grades.rc5_credittype AS SOC_credittype
      ,grades.rc5_course_name AS SOC_course_name
      ,grades.rc5_credit_hours_T1 AS SOC_credit_hours_T1
      ,grades.rc5_credit_hours_T2 AS SOC_credit_hours_T2
      ,grades.rc5_credit_hours_T3 AS SOC_credit_hours_T3
      ,grades.rc5_credit_hours_Y1 AS SOC_credit_hours_Y1
      ,grades.rc5_teacher_last AS SOC_teacher_last
      ,grades.rc5_teacher_lastfirst AS SOC_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc5_t1) AS SOC_t1
      ,CONVERT(FLOAT,grades.rc5_t2) AS SOC_t2
      ,CONVERT(FLOAT,grades.rc5_t3) AS SOC_t3
      ,CONVERT(FLOAT,grades.rc5_y1) AS SOC_y1
      ,grades.rc5_t1_ltr AS SOC_t1_ltr
      ,grades.rc5_t2_ltr AS SOC_t2_ltr
      ,grades.rc5_t3_ltr AS SOC_t3_ltr
      ,grades.rc5_y1_ltr AS SOC_y1_ltr
      ,grades.rc5_t1_enr_sectionid AS SOC_t1_enr_sectionid
      ,grades.rc5_t2_enr_sectionid AS SOC_t2_enr_sectionid
      ,grades.rc5_t2_enr_sectionid AS SOC_t3_enr_sectionid
      ,grades.rc5_gpa_points_t1 AS SOC_gpa_points_t1
      ,grades.rc5_gpa_points_t2 AS SOC_gpa_points_t2
      ,grades.rc5_gpa_points_t3 AS SOC_gpa_points_t3
      ,grades.rc5_gpa_points_y1 AS SOC_gpa_points_y1
      ,grades.rc5_weighted_points_t1 AS SOC_weighted_points_t1
      ,grades.rc5_weighted_points_t2 AS SOC_weighted_points_t2
      ,grades.rc5_weighted_points_t3 AS SOC_weighted_points_t3
      ,grades.rc5_weighted_points_y1 AS SOC_weighted_points_y1
      ,CONVERT(FLOAT,grades.rc5_H1)  AS SOC_H1 
      ,CONVERT(FLOAT,grades.rc5_H2)  AS SOC_H2 
      ,CONVERT(FLOAT,grades.rc5_H3)  AS SOC_H3 
      ,CONVERT(FLOAT,grades.rc5_HY1) AS SOC_HY1
      ,CONVERT(FLOAT,grades.rc5_Q1)  AS SOC_Q1 
      ,CONVERT(FLOAT,grades.rc5_Q2)  AS SOC_Q2 
      ,CONVERT(FLOAT,grades.rc5_Q3)  AS SOC_Q3 
      ,CONVERT(FLOAT,grades.rc5_QY1) AS SOC_QY1
      ,CONVERT(FLOAT,grades.rc5_A1) AS SOC_A1
      ,CONVERT(FLOAT,grades.rc5_A2) AS SOC_A2
      ,CONVERT(FLOAT,grades.rc5_A3) AS SOC_A3
      
      ,((CONVERT(FLOAT,grades.rc1_y1) 
         + CONVERT(FLOAT,grades.rc2_y1) 
         + CONVERT(FLOAT,grades.rc3_y1) 
         + CONVERT(FLOAT,grades.rc4_y1) 
         + CONVERT(FLOAT,grades.rc5_y1)) / 5) AS Core_Avg
      ,CONVERT(FLOAT,grades.HY_all) AS HW_Avg
      ,CONVERT(FLOAT,grades.QY_all) AS HW_Q_Avg      

--Literacy tracking
--MAP$comprehensive#identifiers
--LIT$FP_test_events_long#identifiers#static

     --Lexile (from MAP)
     --update terms in JOIN
     ,lex_base.RITtoReadingScore AS BASE_LEX
     ,lex_curr.rittoreadingscore AS CUR_LEX
       --GLQ
     ,CASE
       WHEN lex_base.RITtoReadingScore  = 'BR' THEN 'Pre-K'
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
       WHEN lex_curr.RITtoReadingScore  = 'BR' THEN 'Pre-K'
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
     --update terms in JOIN
     ,CASE
       WHEN fp_base.letter_level IS NOT NULL THEN fp_base.letter_level
       ELSE fp_curr.letter_level
      END AS start_letter
     ,fp_curr.letter_level AS end_letter
       --GLQ
     ,CASE
       WHEN fp_base.GLEQ IS NOT NULL THEN fp_base.GLEQ
       ELSE fp_curr.GLEQ
      END AS Start_GLEQ
     ,fp_curr.GLEQ AS End_GLEQ
     ,(fp_curr.GLEQ - CASE WHEN fp_base.GLEQ IS NOT NULL THEN fp_base.GLEQ ELSE fp_curr.GLEQ END) AS GLEQ_Growth
       --Level #
     ,CASE
       WHEN fp_base.level_number IS NOT NULL THEN fp_base.level_number
       ELSE fp_curr.level_number
      END AS [Start_#]
     ,fp_curr.level_number AS [End_#]
     ,(fp_curr.level_number - CASE WHEN fp_base.level_number IS NOT NULL THEN fp_base.level_number ELSE fp_curr.level_number END) AS [Levels_grown]
      
--Accelerated Reader
--update terms in JOIN
--AR year
     ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
     ,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr      
     ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
     --,CONVERT(FLOAT,ar_yr.mastery) AS mastery_yr
     ,NULL AS ONTRACK_WORDS_YR
     
     --AR current
     --current trimester = current HEX + previous HEX
     ,replace(convert(varchar,convert(Money, ar_curr.words + ar_curr2.words),1),'.00','') AS words_read_cur_term
     ,replace(convert(varchar,convert(Money, ar_curr.words_goal + ar_curr2.words_goal),1),'.00','') AS words_goal_cur_term
     ,ar_curr2.rank_words_grade_in_school AS words_rank_cur_term_in_grade
     --,CONVERT(FLOAT,ar_curr2.mastery) AS mastery_curr
      
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
       WHEN ar_curr2.stu_status_words = 'On Track' THEN 'Yes!'
       WHEN ar_curr2.stu_status_words = 'Off Track' THEN 'No'
       WHEN ((ar_curr.words_goal + ar_curr2.words_goal) - (ar_curr.words + ar_curr2.words)) > 0 THEN 'Missed Goal'
       ELSE ar_curr2.stu_status_words
      END AS stu_status_words_cur_term
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN ((ar_curr.words_goal + ar_curr2.words_goal) - (ar_curr.words + ar_curr2.words)) <= 0 THEN NULL 
        ELSE ((ar_curr.words_goal + ar_curr2.words_goal) - (ar_curr.words + ar_curr2.words))
       END,0) AS INT)),1),'.00','') AS words_needed_cur_term
     ,gpa.Y1_Dem AS IN_GRADE_DENOM
      
--MAP scores
--MAP$reading_wide
--MAP$math_wide
      --MAP reading -- add a new block for each test year, delete oldest
        --13-14
      ,map_all.spr_2014_read_pctle
      ,map_all.w_2014_READ_pctle AS w_2013_read_pctle
      ,map_all.f_2013_read_pctle      
      ,map_all.spr_2014_read_rit
      ,map_all.w_2014_READ_RIT AS w_2013_read_rit                  
      ,map_all.f_2013_read_rit                  
        --12-13
      ,map_all.spr_2013_read_pctle
      ,map_all.f_2012_read_pctle
      ,map_all.spr_2013_read_rit
      ,map_all.f_2012_read_rit                  
        --11-12
      ,map_all.spr_2012_read_pctle
      ,map_all.f_2011_read_pctle
      ,map_all.spr_2012_read_rit
      ,map_all.f_2011_read_rit            
        --10-11
      ,map_all.spr_2011_read_pctle
      ,map_all.f_2010_read_pctle
      ,map_all.spr_2011_read_rit
      ,map_all.f_2010_read_rit      
            
      --MAP math -- add a new block for each test year, delete oldest
        --13-14
      ,map_all.spr_2014_math_pctle
      ,map_all.w_2014_MATH_pctle AS w_2013_math_pctle
      ,map_all.f_2013_math_pctle      
      ,map_all.spr_2014_math_rit
      ,map_all.w_2014_MATH_RIT AS w_2013_math_rit
      ,map_all.f_2013_math_rit            
        --12-13
      ,map_all.spr_2013_math_pctle
      ,map_all.f_2012_math_pctle
      ,map_all.spr_2013_math_rit
      ,map_all.f_2012_math_rit      
        --11-12
      ,map_all.spr_2012_math_pctle
      ,map_all.f_2011_math_pctle      
      ,map_all.spr_2012_math_rit
      ,map_all.f_2011_math_rit      
        --10-11
      ,map_all.spr_2011_math_pctle
      ,map_all.f_2010_math_pctle
      ,map_all.spr_2011_math_rit
      ,map_all.f_2010_math_rit      
      
      --MAP langauge -- add a new block for each test year, delete oldest
        --13-14
      ,map_all.spr_2014_lang_pctle
      ,map_all.w_2014_LANG_pctle AS w_2013_lang_pctle
      ,map_all.f_2013_lang_pctle
      ,map_all.spr_2014_lang_rit
      ,map_all.w_2014_lang_rit AS w_2013_lang_rit
      ,map_all.f_2013_lang_rit            
        --12-13
      ,map_all.spr_2013_lang_pctle
      ,map_all.f_2012_lang_pctle
      ,map_all.spr_2013_lang_rit
      ,map_all.f_2012_lang_rit      
        --11-12
      ,map_all.spr_2012_lang_pctle
      ,map_all.f_2011_lang_pctle      
      ,map_all.spr_2012_lang_rit
      ,map_all.f_2011_lang_rit      
        --10-11
      ,map_all.spr_2011_lang_pctle
      ,map_all.f_2010_lang_pctle
      ,map_all.spr_2011_lang_rit
      ,map_all.f_2010_lang_rit      
      
      --MAP science gen -- add a new block for each test year, delete oldest
        --13-14
      ,map_all.spr_2014_gen_pctle
      ,map_all.w_2014_GEN_pctle AS w_2013_gen_pctle
      ,map_all.f_2013_gen_pctle
      ,map_all.spr_2014_gen_rit
      ,map_all.w_2014_GEN_RIT AS w_2013_gen_rit
      ,map_all.f_2013_gen_rit            
        --12-13
      ,map_all.spr_2013_gen_pctle
      ,map_all.f_2012_gen_pctle
      ,map_all.spr_2013_gen_rit
      ,map_all.f_2012_gen_rit      
        --11-12
      ,map_all.spr_2012_gen_pctle
      ,map_all.f_2011_gen_pctle      
      ,map_all.spr_2012_gen_rit
      ,map_all.f_2011_gen_rit      
        --10-11
      ,map_all.spr_2011_gen_pctle
      ,map_all.f_2010_gen_pctle
      ,map_all.spr_2011_gen_rit
      ,map_all.f_2010_gen_rit      
      
      --MAP cp -- add a new block for each test year, delete oldest      
        --12-13
      ,map_all.spr_2013_cp_pctle
      ,map_all.f_2012_cp_pctle
      ,map_all.spr_2013_cp_rit
      ,map_all.f_2012_cp_rit      
        --11-12
      ,map_all.spr_2012_cp_pctle
      ,map_all.f_2011_cp_pctle      
      ,map_all.spr_2012_cp_rit
      ,map_all.f_2011_cp_rit      
        --10-11
      ,map_all.spr_2011_cp_pctle
      ,map_all.f_2010_cp_pctle
      ,map_all.spr_2011_cp_rit
      ,map_all.f_2010_cp_rit 

--NJASK scores
--NJASK$ela_wide
--NJASK$math_wide
      
      --ELA scores -- add a new line for each test year, delete oldest
      ,njask_ela.score_2013 AS ela_score_2013
      ,njask_ela.score_2012 AS ela_score_2012
      ,njask_ela.score_2011 AS ela_score_2011      
      ,njask_ela.Score_2010 AS ela_score_2010      
      --ELA proficiency -- add a new line for each test year, delete oldest
      ,njask_ela.prof_2013 AS ela_prof_2013
      ,njask_ela.prof_2012 AS ela_prof_2012
      ,njask_ela.prof_2011 AS ela_prof_2011      
      ,njask_ela.Prof_2010 AS ela_prof_2010
      
      --Math scores -- add a new line for each test year, delete oldest
      ,njask_math.score_2013 AS math_score_2013
      ,njask_math.score_2012 AS math_score_2012
      ,njask_math.score_2011 AS math_score_2011
      ,njask_math.Score_2010 AS math_score_2010
      --Math proficiency -- add a new line for each test year, delete oldest
      ,njask_math.prof_2013 AS math_prof_2013
      ,njask_math.prof_2012 AS math_prof_2012
      ,njask_math.prof_2011 AS math_prof_2011      
      ,njask_math.Prof_2010 AS math_prof_2010
      
      --Math grade level -- add a new line for each test year, delete oldest
      ,njask_math.gr_lev_2013 AS njask_gr_lev_2013
      ,njask_math.gr_lev_2012 AS njask_gr_lev_2012
      ,njask_math.gr_lev_2011 AS njask_gr_lev_2011      
      ,njask_math.gr_lev_2010 AS njask_gr_lev_2010
      
--DISCIPLINE
--DISC$log#static
      ,disc_recent.disc_01_date_reported
      ,disc_recent.disc_01_given_by
      ,CASE
        WHEN disc_recent.disc_01_subject IS NULL THEN disc_recent.disc_01_incident 
        ELSE disc_recent.disc_01_subject
       END AS disc_01_incident
      ,disc_recent.disc_02_date_reported
      ,disc_recent.disc_02_given_by
      ,CASE 
        WHEN disc_recent.disc_02_subject IS NULL THEN disc_recent.disc_02_incident 
        ELSE disc_recent.disc_02_subject
       END AS disc_02_incident
      ,disc_recent.disc_03_date_reported
      ,disc_recent.disc_03_given_by
      ,CASE
        WHEN disc_recent.disc_03_subject IS NULL THEN disc_recent.disc_03_incident 
        ELSE disc_recent.disc_03_subject
       END AS disc_03_incident
      ,disc_recent.disc_04_date_reported
      ,disc_recent.disc_04_given_by
      ,CASE
        WHEN disc_recent.disc_04_subject IS NULL THEN disc_recent.disc_04_incident 
        ELSE disc_recent.disc_04_subject
       END AS disc_04_incident
      ,disc_recent.disc_05_date_reported
      ,disc_recent.disc_05_given_by
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
      ,ISNULL(disc_count.detentions,0) AS Y1_detentions      
      ,ISNULL(disc_count.rt1_detentions,0) AS t1_detentions
      ,ISNULL(disc_count.rt2_detentions,0) AS t2_detentions      
      ,ISNULL(disc_count.rt3_detentions,0) AS t3_detentions
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.bench,0) ELSE ISNULL(disc_count.choices,0) END AS Y1_bench_choices      
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt1_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T1_bench_choices
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt2_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T2_bench_choices
      ,CASE WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.rt3_bench,0) ELSE ISNULL(disc_count.rt1_choices,0) END AS T3_bench_choices

--Extracurriculars
--RutgersReady..XC$activities_wide
      ,xc.Fall_1 AS xc_Fall_1
      ,xc.Fall_2 AS xc_Fall_2
      ,xc.Winter_1 AS xc_Winter_1
      ,xc.Winter_2 AS xc_Winter_2
      ,xc.Spring_1 AS xc_Spring_1
      ,xc.Spring_2 AS xc_Spring_2
      ,xc.[Winter-Spring_1] AS xc_WinterSpring_1
      ,xc.[Winter-Spring_2] AS xc_WinterSpring_2
      ,xc.[Year-Round_1] AS xc_YearRound_1
      ,xc.[Year-Round_2] AS xc_YearRound_2
      ,CASE WHEN xc.activity_hash IS NULL THEN 'None' ELSE xc.activity_hash END AS activity_hash
      
FROM roster WITH (NOLOCK)

--Attendance
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts WITH (NOLOCK)
  ON roster.id = att_counts.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.id = att_pct.id
LEFT OUTER JOIN ATT_MEM$membership_counts membership_counts WITH (NOLOCK)
  ON roster.id = membership_counts.id

--Grades & GPA
LEFT OUTER JOIN GRADES$wide_credit_core#MS grades WITH (NOLOCK)
  ON roster.ID = grades.studentid
LEFT OUTER JOIN GPA$detail#Rise gpa WITH (NOLOCK)
  ON roster.id = gpa.studentid
LEFT OUTER JOIN REPORTING$promo_status#Rise promo WITH (NOLOCK)
  ON roster.id = promo.studentid
  
--LITERACY -- upadate parameters for current term
  --F&P
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_base WITH (NOLOCK)
  ON roster.student_number = fp_base.STUDENT_NUMBER
 AND fp_base.year = 2013
 AND fp_base.achv_base = 1
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_curr WITH (NOLOCK)
  ON roster.student_number = fp_curr.STUDENT_NUMBER
 --AND fp_curr.year = 2013
 AND fp_curr.achv_curr_all = 1
  --LEXILE
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_base WITH (NOLOCK)
  ON roster.student_number = lex_base.StudentID
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.rn_base = 1
 AND lex_base.map_year_academic = 2013
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_curr WITH (NOLOCK)
  ON roster.student_number = lex_curr.StudentID
 AND lex_curr.MeasurementScale = 'Reading'
 AND lex_curr.rn_curr = 1
 AND lex_curr.map_year_academic = 2013
  
--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.id = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.id = ar_curr.studentid 
 AND ar_curr.time_period_name = 'RT5'
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr2 WITH (NOLOCK)
  ON roster.id = ar_curr2.studentid 
 AND ar_curr2.time_period_name = 'RT6'
 AND ar_curr2.yearid = dbo.fn_Global_Term_Id()

--MAP
LEFT OUTER JOIN MAP$wide_all map_all WITH (NOLOCK)
  ON roster.id = map_all.studentid
  
--NJASK
LEFT OUTER JOIN NJASK$ELA_WIDE njask_ela WITH (NOLOCK)
  ON roster.id = njask_ela.studentid
 AND njask_ela.schoolid = 73252
 AND njask_ela.rn = 1
LEFT OUTER JOIN NJASK$MATH_WIDE njask_math WITH (NOLOCK)
  ON roster.id = njask_math.studentid
 AND njask_math.schoolid = 73252

--Discipline
LEFT OUTER JOIN DISC$recent_incidents_wide disc_recent WITH (NOLOCK)
  ON roster.id = disc_recent.studentid
LEFT OUTER JOIN DISC$counts_wide disc_count WITH (NOLOCK)
  ON roster.id = disc_count.base_studentid
  
--XC
LEFT OUTER JOIN RutgersReady..XC$activities_wide xc WITH(NOLOCK)
  ON roster.STUDENT_NUMBER = xc.student_number
 AND xc.yearid = dbo.fn_Global_Term_Id()  