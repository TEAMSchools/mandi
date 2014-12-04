USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#Rise AS

WITH cur_hex AS (
  SELECT CASE 
          WHEN RIGHT(time_per_name, 1) IN (1, 3, 5) THEN 'RT' + RIGHT(time_per_name, 1)
          ELSE 'RT' + CONVERT(VARCHAR,RIGHT(time_per_name, 1) - 1)
         END AS hex_a
        ,CASE 
          WHEN RIGHT(time_per_name, 1) IN (1, 3, 5) THEN 'RT' + CONVERT(VARCHAR,RIGHT(time_per_name, 1) + 1)
          ELSE 'RT' + RIGHT(time_per_name, 1)
         END AS hex_b
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE academic_year = dbo.fn_Global_Academic_Year()
    AND schoolid = 73252
    AND identifier = 'HEX'
    AND start_date <= GETDATE()
    AND end_date >= GETDATE()
 )

SELECT roster.student_number AS base_student_number
      ,roster.studentid AS base_studentid
      ,roster.lastfirst AS stu_lastfirst
      ,roster.first_name AS stu_firstname
      ,roster.last_name AS stu_lastname
      ,roster.grade_level AS stu_grade_level
      ,roster.TEAM AS travel_group
      ,roster.FAMILY_WEB_ID AS web_id
      ,roster.FAMILY_WEB_PASSWORD AS web_password
      ,roster.student_web_id
      ,roster.STUDENT_WEB_PASSWORD
      ,roster.street
      ,roster.CITY
      ,roster.home_phone
      ,roster.advisor
      ,roster.advisor_email
      ,roster.advisor_cell
      ,roster.mother_cell
      ,COALESCE(roster.mother_home, roster.mother_day) AS mother_daytime
      ,roster.father_cell
      ,COALESCE(roster.father_home, roster.father_day) AS father_daytime
      ,roster.guardianemail
      ,roster.SPEDLEP AS SPED
      ,roster.lunch_balance      
      ,curterm.alt_name AS curterm
      ,REPLACE(curterm.alt_name, 'T', 'Trimester ') AS curterm_long
      ,DATENAME(MONTH,GETDATE()) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())) + ', ' + CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) AS today_text
      
--Course Grades
--GRADES$wide_all

    /*--RC1--*/
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last
      ,ROUND(gr_wide.rc1_y1,0) AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr      
    
      ,ROUND(gr_wide.rc1_t1,0) AS rc1_t1_term_pct
      ,ROUND(gr_wide.rc1_t2,0) AS rc1_t2_term_pct
      ,ROUND(gr_wide.rc1_t3,0) AS rc1_t3_term_pct      
      
    /*--RC2--*/
      ,gr_wide.RC2_course_name
      ,gr_wide.RC2_teacher_last
      ,ROUND(gr_wide.RC2_y1,0) AS RC2_y1_pct
      ,gr_wide.RC2_y1_ltr      
    
      ,ROUND(gr_wide.RC2_t1,0) AS RC2_t1_term_pct
      ,ROUND(gr_wide.RC2_t2,0) AS RC2_t2_term_pct
      ,ROUND(gr_wide.RC2_t3,0) AS RC2_t3_term_pct
      
    /*--RC3--*/
      ,gr_wide.RC3_course_name
      ,gr_wide.RC3_teacher_last
      ,ROUND(gr_wide.RC3_y1,0) AS RC3_y1_pct
      ,gr_wide.RC3_y1_ltr      
    
      ,ROUND(gr_wide.RC3_t1,0) AS RC3_t1_term_pct
      ,ROUND(gr_wide.RC3_t2,0) AS RC3_t2_term_pct
      ,ROUND(gr_wide.RC3_t3,0) AS RC3_t3_term_pct      

    /*--RC4--*/
      ,gr_wide.RC4_course_name
      ,gr_wide.RC4_teacher_last
      ,ROUND(gr_wide.RC4_y1,0) AS RC4_y1_pct
      ,gr_wide.RC4_y1_ltr      
    
      ,ROUND(gr_wide.RC4_t1,0) AS RC4_t1_term_pct
      ,ROUND(gr_wide.RC4_t2,0) AS RC4_t2_term_pct
      ,ROUND(gr_wide.RC4_t3,0) AS RC4_t3_term_pct      

    /*--RC5--*/
      ,gr_wide.RC5_course_name
      ,gr_wide.RC5_teacher_last
      ,ROUND(gr_wide.RC5_y1,0) AS RC5_y1_pct
      ,gr_wide.RC5_y1_ltr      
    
      ,ROUND(gr_wide.RC5_t1,0) AS RC5_t1_term_pct
      ,ROUND(gr_wide.RC5_t2,0) AS RC5_t2_term_pct
      ,ROUND(gr_wide.RC5_t3,0) AS RC5_t3_term_pct      
      
    /*--RC6--*/
      ,gr_wide.RC6_course_name
      ,gr_wide.RC6_teacher_last
      ,ROUND(gr_wide.RC6_y1,0) AS RC6_y1_pct
      ,gr_wide.RC6_y1_ltr
      
      ,ROUND(gr_wide.RC6_t1,0) AS RC6_t1_term_pct
      ,ROUND(gr_wide.RC6_t2,0) AS RC6_t2_term_pct
      ,ROUND(gr_wide.RC6_t3,0) AS RC6_t3_term_pct
      
    /*--RC7--*/
      ,gr_wide.RC7_course_name
      ,gr_wide.RC7_teacher_last
      ,ROUND(gr_wide.RC7_y1,0) AS RC7_y1_pct
      ,gr_wide.RC7_y1_ltr
    
      ,ROUND(gr_wide.RC7_t1,0) AS RC7_t1_term_pct
      ,ROUND(gr_wide.RC7_t2,0) AS RC7_t2_term_pct
      ,ROUND(gr_wide.RC7_t3,0) AS RC7_t3_term_pct    
      
    /*--RC8--*/
      ,gr_wide.RC8_course_name
      ,gr_wide.RC8_teacher_last
      ,ROUND(gr_wide.RC8_y1,0) AS RC8_y1_pct
      ,gr_wide.RC8_y1_ltr
      
      ,ROUND(gr_wide.RC8_t1,0) AS RC8_t1_term_pct
      ,ROUND(gr_wide.RC8_t2,0) AS RC8_t2_term_pct
      ,ROUND(gr_wide.RC8_t3,0) AS RC8_t3_term_pct    

    /*-- Current term RC grades --*/
      ,ROUND(rc.rc1,0) AS rc1_curterm_pct
      ,ROUND(rc.rc2,0) AS rc2_curterm_pct
      ,ROUND(rc.rc3,0) AS rc3_curterm_pct
      ,ROUND(rc.rc4,0) AS rc4_curterm_pct
      ,ROUND(rc.rc5,0) AS rc5_curterm_pct
      ,ROUND(rc.rc6,0) AS rc6_curterm_pct
      ,ROUND(rc.rc7,0) AS rc7_curterm_pct
      ,ROUND(rc.rc8,0) AS rc8_curterm_pct

    /*--current term component averages--*/       
      --All classes element averages for the year
      ,gr_wide.HY_all AS homework_year_avg
      ,gr_wide.QY_all AS homework_qual_year_avg
      ,gr_wide.AY_all AS assess_year_avg             

      --H
      ,ele.rc1_H AS rc1_cur_hw_pct
      ,ele.rc2_H AS rc2_cur_hw_pct
      ,ele.rc3_H AS rc3_cur_hw_pct
      ,ele.rc4_H AS rc4_cur_hw_pct
      ,ele.rc5_H AS rc5_cur_hw_pct
      ,ele.rc6_H AS rc6_cur_hw_pct
      ,ele.rc7_H AS rc7_cur_hw_pct
      ,ele.rc8_H AS rc8_cur_hw_pct
      --S
      ,ele.rc1_S AS rc1_cur_s_pct
      ,ele.rc2_S AS rc2_cur_s_pct
      ,ele.rc3_S AS rc3_cur_s_pct
      ,ele.rc4_S AS rc4_cur_s_pct
      ,ele.rc5_S AS rc5_cur_s_pct
      ,ele.rc6_S AS rc6_cur_s_pct
      ,ele.rc7_S AS rc7_cur_s_pct
      ,ele.rc8_S AS rc8_cur_s_pct      
      --Q
      ,ele.rc1_Q AS rc1_cur_qual_pct
      ,ele.rc2_Q AS rc2_cur_qual_pct
      ,ele.rc3_Q AS rc3_cur_qual_pct
      ,ele.rc4_Q AS rc4_cur_qual_pct
      ,ele.rc5_Q AS rc5_cur_qual_pct
      ,ele.rc6_Q AS rc6_cur_qual_pct
      ,ele.rc7_Q AS rc7_cur_qual_pct
      ,ele.rc8_Q AS rc8_cur_qual_pct

--Attendance & Tardies
--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts      
    
    /*--Year--*/
      ,att_counts.y1_abs_all AS Y1_absences_total
      ,att_counts.y1_a AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
      ,att_counts.y1_t_all AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total      

    /*--Current--*/      
      --/*
      --CUR--
      ,att_counts.CUR_ABS_ALL        AS curterm_absences_total
      ,att_counts.CUR_A        AS curterm_absences_undoc
      ,ROUND(att_pct.cur_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.cur_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.CUR_T_ALL         AS curterm_tardies_total
      ,ROUND(att_pct.cur_tardy_pct_total,0) AS curterm_tardy_pct_total
      --*/

--GPA
--GPA$detail#MS
    /*--Year--*/      
      ,gpa.GPA_y1_all AS gpa_Y1
      ,gpa.rank_gr_y1_all AS GPA_Y1_Rank_G
      ,gpa.n_gr AS Y1_Dem
   
   /*--Current Term--*/
      ,gpa_long.GPA_all AS gpa_curterm
      
--Promotional Criteria
--REPORTING$promo_status#MS
      ,promo.y1_att_pts_pct
      ,promo.attendance_points      
      ,promo.promo_overall_rise AS promo_status_overall
      ,promo.promo_grades_gpa_rise AS GPA_Promo_Status_Grades  
      ,promo.promo_att_rise AS promo_status_att
      ,promo.promo_hw_rise AS promo_status_hw

--MAP scores
--MAP$wide_all     
      --MAP reading      
      -- 14-15
      ,map_all.spr_2015_read_pctle
      ,map_all.f_2014_read_pctle
      -- 13-14
      ,map_all.spr_2014_read_pctle
      ,map_all.f_2013_read_pctle
      -- 12-13
      ,map_all.spr_2013_read_pctle
      ,map_all.f_2012_read_pctle
      -- 11-12
      ,map_all.spr_2012_read_pctle
      ,map_all.f_2011_read_pctle
        
      --MAP math
      -- 14-15
      ,map_all.spr_2015_math_pctle
      ,map_all.f_2014_math_pctle
      -- 13-14
      ,map_all.spr_2014_math_pctle
      ,map_all.f_2013_math_pctle
      -- 12-13
      ,map_all.spr_2013_math_pctle
      ,map_all.f_2012_math_pctle
      -- 11-12
      ,map_all.spr_2012_math_pctle
      ,map_all.f_2011_math_pctle

      --MAP science
      -- 14-15
      ,map_all.spr_2015_gen_pctle
      ,map_all.f_2014_gen_pctle
      -- 13-14
      ,map_all.spr_2014_gen_pctle
      ,map_all.f_2013_gen_pctle
      -- 12-13
      ,map_all.spr_2013_gen_pctle
      ,map_all.f_2012_gen_pctle
      -- 11-12
      ,map_all.spr_2012_gen_pctle
      ,map_all.f_2011_gen_pctle

      --MAP science
      -- 14-15
      ,map_all.spr_2015_lang_pctle
      ,map_all.f_2014_lang_pctle
      -- 13-14
      ,map_all.spr_2014_lang_pctle
      ,map_all.f_2013_lang_pctle
      -- 12-13
      ,map_all.spr_2013_lang_pctle
      ,map_all.f_2012_lang_pctle
      -- 11-12
      ,map_all.spr_2012_lang_pctle
      ,map_all.f_2011_lang_pctle

--Literacy tracking
--MAP$comprehensive#identifiers
--LIT$FP_test_events_long#identifiers#static

     --F&P     
     ,fp_base.read_lvl AS fp_letter_base
     ,fp_curr.read_lvl AS fp_letter_curr
     --GLEQ     
     ,ROUND(fp_base.GLEQ,1) AS fp_base_GLQ
     ,ROUND(fp_curr.GLEQ,1) AS fp_curr_GLQ
     
     --Lexile (from MAP)     
     --BASE
     ,CASE
       WHEN lex_base.lexile_score = 'BR' THEN 'Pre-K'
       ELSE lex_base.lexile_score
      END AS lexile_base          
     ,CASE
       WHEN lex_base.lexile_score  = 'BR' THEN 'Pre-K'
       WHEN lex_base.lexile_score <= 100  THEN 'K'
       WHEN lex_base.lexile_score <= 300  AND lex_base.lexile_score > 100  THEN '1st'
       WHEN lex_base.lexile_score <= 500  AND lex_base.lexile_score > 300  THEN '2nd'
       WHEN lex_base.lexile_score <= 600  AND lex_base.lexile_score > 500  THEN '3rd'
       WHEN lex_base.lexile_score <= 700  AND lex_base.lexile_score > 600  THEN '4th'
       WHEN lex_base.lexile_score <= 800  AND lex_base.lexile_score > 700  THEN '5th'
       WHEN lex_base.lexile_score <= 900  AND lex_base.lexile_score > 800  THEN '6th'
       WHEN lex_base.lexile_score <= 1000 AND lex_base.lexile_score > 900  THEN '7th'
       WHEN lex_base.lexile_score <= 1100 AND lex_base.lexile_score > 1000 THEN '8th'
       WHEN lex_base.lexile_score <= 1200 AND lex_base.lexile_score > 1100 THEN '9th'
       WHEN lex_base.lexile_score <= 1300 AND lex_base.lexile_score > 1200 THEN '10th'
       WHEN lex_base.lexile_score <= 1400 AND lex_base.lexile_score > 1300 THEN '11th'
       WHEN lex_base.lexile_score  > 1400 THEN '12th'
       ELSE NULL
      END AS lexile_base_GLQ
     --CUR
     ,CASE
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) = 'BR' THEN 'Pre-K'
       ELSE COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score)
      END AS lexile_cur     
     ,CASE
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score)  = 'BR' THEN 'Pre-K'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 100  THEN 'K'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 300  AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 100  THEN '1st'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 500  AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 300  THEN '2nd'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 600  AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 500  THEN '3rd'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 700  AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 600  THEN '4th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 800  AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 700  THEN '5th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 900  AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 800  THEN '6th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 1000 AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 900  THEN '7th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 1100 AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 1000 THEN '8th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 1200 AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 1100 THEN '9th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 1300 AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 1200 THEN '10th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) <= 1400 AND COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score) > 1300 THEN '11th'
       WHEN COALESCE(lex_cur.RITtoReadingScore, lex_base.lexile_score)  > 1400 THEN '12th'
       ELSE NULL
      END AS lexile_cur_GLQ      

--NJASK scores
--NJASK$ela_wide
--NJASK$math_wide
/*-- UPDATE FIELD FOR CURRENT YEAR --*/
      --Test name
      ,CASE WHEN njask_ela.score_2014 IS NOT NULL OR njask_math.score_2014 IS NOT NULL 
            THEN 'NJASK | Gr '+ njask_ela.gr_lev_2014 + ' | 2014' ELSE NULL END AS NJASK_14_Name
      ,CASE WHEN njask_ela.score_2013 IS NOT NULL OR njask_math.score_2013 IS NOT NULL 
            THEN 'NJASK | Gr '+ njask_ela.gr_lev_2013 + ' | 2013' ELSE NULL END AS NJASK_13_Name
      ,CASE WHEN njask_ela.score_2012 IS NOT NULL OR njask_math.score_2012 IS NOT NULL 
            THEN 'NJASK | Gr '+ njask_ela.gr_lev_2012 + ' | 2012' ELSE NULL END AS NJASK_12_Name
      ,CASE WHEN njask_ela.score_2011 IS NOT NULL OR njask_math.score_2011 IS NOT NULL 
            THEN 'NJASK | Gr '+ njask_ela.gr_lev_2011 + ' | 2011' ELSE NULL END AS NJASK_11_Name      
      
      --ELA scores
      ,njask_ela.score_2014 AS ela_score_2014
      ,njask_ela.score_2013 AS ela_score_2013
      ,njask_ela.score_2012 AS ela_score_2012
      ,njask_ela.score_2011 AS ela_score_2011      
      --ELA proficiency
      ,'(' + njask_ela.prof_2014 + ')' AS ela_prof_2014
      ,'(' + njask_ela.prof_2013 + ')' AS ela_prof_2013
      ,'(' + njask_ela.prof_2012 + ')' AS ela_prof_2012
      ,'(' + njask_ela.prof_2011 + ')' AS ela_prof_2011      

      --Math scores
      ,njask_math.score_2014 AS math_score_2014
      ,njask_math.score_2013 AS math_score_2013
      ,njask_math.score_2012 AS math_score_2012
      ,njask_math.score_2011 AS math_score_2011      
      --Math proficiency
      ,'(' + njask_math.prof_2014 + ')' AS math_prof_2014
      ,'(' + njask_math.prof_2013 + ')' AS math_prof_2013
      ,'(' + njask_math.prof_2012 + ')' AS math_prof_2012
      ,'(' + njask_math.prof_2011 + ')' AS math_prof_2011
--*/

--Accelerated Reader
--CURRENT = combination of hexemeters valid for current trimester
   --AR totals
     --year
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_yr.words),1),'.00','') AS words_read_yr
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_yr.words_goal),1),'.00','') AS words_goal_yr      
     ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
     ,ar_yr.mastery AS mastery_yr
     
     --current
     --current trimester = current HEX + previous HEX
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_curr.words + ar_curr2.words),1),'.00','') AS words_read_cur_term
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, ar_curr.words_goal + ar_curr2.words_goal),1),'.00','') AS words_goal_cur_term
     ,CASE 
       WHEN curterm.time_per_name = ar_curr.time_period_name THEN ar_curr.rank_words_grade_in_school
       WHEN curterm.time_per_name = ar_curr2.time_period_name THEN ar_curr2.rank_words_grade_in_school
       ELSE NULL
      END AS words_rank_cur_term_in_grade
     ,COALESCE(ar_curr2.mastery, ar_curr.mastery) AS mastery_curr
      
    --AR progress
      --to year goal      
     ,CASE
       WHEN ar_yr.words_goal - ar_yr.words <= 0 THEN 'Met Goal'
       WHEN ar_yr.stu_status_words = 'On Track' THEN 'Yes!'
       WHEN ar_yr.stu_status_words ='Off Track' THEN 'No'
       ELSE ar_yr.stu_status_words
      END AS stu_status_words_yr   
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN (ar_yr.words_goal - ar_yr.words) <= 0 THEN NULL 
        ELSE (ar_yr.words_goal - ar_yr.words)
       END,0) AS INT)),1),'.00','') AS words_needed_yr
      --to term goal
     ,CASE
       WHEN ((ar_curr.words_goal + ar_curr2.words_goal) - (ar_curr.words + ar_curr2.words)) <= 0 THEN 'Met Goal'
       WHEN ar_curr.stu_status_words IN ('On Track','Met Goal') AND ar_curr2.stu_status_words IN ('On Track','Met Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('On Track','Met Goal') AND ar_curr2.stu_status_words IN ('Off Track','Missed Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('Off Track','Missed Goal') AND ar_curr2.stu_status_words IN ('On Track','Met Goal') THEN 'Yes!'
       WHEN ar_curr.stu_status_words IN ('Off Track','Missed Goal') AND ar_curr2.stu_status_words IN ('Off Track','Missed Goal') THEN 'No'              
       ELSE COALESCE(ar_curr2.stu_status_words, ar_curr.stu_status_words)
      END AS stu_status_words_cur_term
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(ROUND(
       CASE
        WHEN ((ar_curr.words_goal + ar_curr2.words_goal) - (ar_curr.words + ar_curr2.words)) <= 0 THEN NULL
        ELSE ((ar_curr.words_goal + ar_curr2.words_goal) - (ar_curr.words + ar_curr2.words))
       END,0) AS INT)),1),'.00','') AS words_needed_cur_term

--Discipline
--DISC$counts_wide
--DISC$recent_incidents_wide
  
      --Recent Incidents
      ,CAST(disc_recent.disc_01_date_reported AS DATE) AS disc_01_date_reported
      ,disc_recent.disc_01_given_by
      ,CASE
        WHEN disc_recent.disc_01_subject IS NULL THEN disc_recent.disc_01_incident 
        ELSE disc_recent.disc_01_subject
       END AS disc_01_incident
            
      ,CAST(disc_recent.disc_02_date_reported AS DATE) AS disc_02_date_reported
      ,disc_recent.disc_02_given_by
      ,CASE
        WHEN disc_recent.disc_02_subject IS NULL THEN disc_recent.disc_02_incident 
        ELSE disc_recent.disc_02_subject
       END AS disc_02_incident
            
      ,CAST(disc_recent.disc_03_date_reported AS DATE) AS disc_03_date_reported
      ,disc_recent.disc_03_given_by
      ,CASE 
        WHEN disc_recent.disc_03_subject IS NULL THEN disc_recent.disc_03_incident 
        ELSE disc_recent.disc_03_subject
       END AS disc_03_incident
            
      ,CAST(disc_recent.disc_04_date_reported AS DATE) AS disc_04_date_reported
      ,disc_recent.disc_04_given_by
      ,CASE
        WHEN disc_recent.disc_04_subject IS NULL THEN disc_recent.disc_04_incident 
        ELSE disc_recent.disc_04_subject
       END AS disc_04_incident
            
      ,CAST(disc_recent.disc_05_date_reported AS DATE) AS disc_05_date_reported
      ,disc_recent.disc_05_given_by
      ,CASE
        WHEN disc_recent.disc_05_subject IS NULL THEN disc_recent.disc_05_incident 
        ELSE disc_recent.disc_05_subject
       END AS disc_05_incident
      
      --Discipline Counts
      ,ISNULL(disc_count.silent_lunches,0) AS silent_lunches
      ,ISNULL(disc_count.detentions,0) AS detentions
      ,CASE
        WHEN roster.grade_level <= 6 THEN 'Bench'
        ELSE 'Choices'
       END AS bench_choices_label
      ,CASE
        WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.bench,0)
        ELSE ISNULL(disc_count.choices,0)
       END AS bench_choices_yr
      ,CASE
        WHEN (disc_count.iss + disc_count.oss) > 0 THEN 'Yes'
        ELSE 'No'
       END AS ISS_OSS      
      ,ISNULL(disc_count.cur_silent_lunches,0) AS cur_silent_lunches
      ,ISNULL(disc_count.cur_detentions,0) AS cur_detentions
      ,CASE
        WHEN roster.grade_level <= 6 THEN ISNULL(disc_count.cur_bench,0)
        ELSE ISNULL(disc_count.cur_choices,0)
       END AS bench_choices_cur      

--Extracurriculars
--from the RutgersReady DB (RutgersReady..XC$activities_wide)      
      ,xc.Fall_1 
      ,xc.Fall_2
      ,xc.Winter_1
      ,xc.Winter_2
      ,xc.Spring_1
      ,xc.Spring_2
      ,xc.[Winter-Spring_1]
      ,xc.[Winter-Spring_2]
      ,xc.[Year-Round_1]
      ,xc.[Year-Round_2]      

FROM COHORT$identifiers_long#static roster WITH(NOLOCK)
JOIN REPORTING$dates curterm WITH(NOLOCK)
  ON roster.schoolid = curterm.schoolid
 AND curterm.identifier = 'RT'
 AND curterm.academic_year = dbo.fn_Global_Academic_Year()
 AND curterm.start_date <= CONVERT(DATE,GETDATE())
 AND curterm.end_date >= CONVERT(DATE,GETDATE())

--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts#static att_counts WITH (NOLOCK)
  ON roster.studentid = att_counts.studentid
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.studentid = att_pct.studentid

--GRADES & GPA
LEFT OUTER JOIN GRADES$wide_all#MS#static gr_wide WITH (NOLOCK)
  ON roster.studentid = gr_wide.studentid
LEFT OUTER JOIN GRADES$rc_grades_by_term rc WITH(NOLOCK)
  ON roster.studentid = rc.studentid
 AND curterm.alt_name = rc.term
LEFT OUTER JOIN GRADES$rc_elements_by_term ele WITH(NOLOCK)
  ON roster.studentid = ele.studentid
 AND curterm.alt_name = ele.term
LEFT OUTER JOIN GPA$detail#MS gpa WITH (NOLOCK)
  ON roster.studentid = gpa.studentid
LEFT OUTER JOIN GPA$detail_long gpa_long WITH(NOLOCK)
  ON roster.studentid = gpa_long.studentid
 AND curterm.alt_name = gpa_long.term

--PROMO STATUS  
LEFT OUTER JOIN REPORTING$promo_status#MS promo WITH (NOLOCK)
  ON roster.studentid = promo.studentid

--MAP
LEFT OUTER JOIN MAP$wide_all#static map_all WITH (NOLOCK)
  ON roster.studentid = map_all.studentid
  
--LITERACY
--F&P
LEFT OUTER JOIN LIT$test_events#identifiers fp_base WITH (NOLOCK)
  ON roster.student_number = fp_base.student_number
 AND fp_base.academic_year = dbo.fn_Global_Academic_Year()
 AND fp_base.achv_base_yr = 1
LEFT OUTER JOIN LIT$test_events#identifiers fp_curr WITH (NOLOCK)
  ON roster.student_number = fp_curr.student_number 
 AND fp_curr.achv_curr_all = 1
--LEXILE
LEFT OUTER JOIN MAP$best_baseline#static lex_base WITH (NOLOCK)
  ON roster.studentid = lex_base.studentid
 AND lex_base.MeasurementScale = 'Reading' 
 AND lex_base.year = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_cur WITH (NOLOCK)
  ON roster.student_number = lex_cur.studentid
 AND lex_cur.MeasurementScale = 'Reading'
 AND lex_cur.rn_curr = 1
 AND lex_cur.map_year_academic = dbo.fn_Global_Academic_Year()
  
--NJASK
LEFT OUTER JOIN NJASK$ELA_WIDE njask_ela WITH (NOLOCK)
  ON roster.studentid = njask_ela.studentid
 AND njask_ela.schoolid = 73252
 AND njask_ela.rn = 1
LEFT OUTER JOIN NJASK$MATH_WIDE njask_math WITH (NOLOCK)
  ON roster.studentid = njask_math.studentid
 AND njask_math.schoolid = 73252
 AND njask_math.rn = 1

--DISCIPLINE
LEFT OUTER JOIN DISC$counts_wide disc_count WITH (NOLOCK)
  ON roster.studentid = disc_count.studentid
LEFT OUTER JOIN DISC$recent_incidents_wide disc_recent WITH (NOLOCK)
  ON roster.studentid = disc_recent.studentid
 AND disc_recent.log_type = 'Discipline'

--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.studentid = ar_curr.studentid 
 AND ar_curr.time_period_name = (SELECT hex_a FROM cur_hex WITH(NOLOCK))
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr2 WITH (NOLOCK)
  ON roster.studentid = ar_curr2.studentid 
 AND ar_curr2.time_period_name = (SELECT hex_b FROM cur_hex WITH(NOLOCK))
 AND ar_curr2.yearid = dbo.fn_Global_Term_Id()

--Rise XC
LEFT OUTER JOIN KIPP_NJ..XC$activities_wide xc WITH(NOLOCK)
  ON roster.student_number = xc.student_number
 AND xc.yearid = dbo.fn_Global_Term_Id()

WHERE roster.year = dbo.fn_Global_Academic_Year()
  AND roster.rn = 1        
  AND roster.schoolid = 73252
  AND roster.enroll_status = 0