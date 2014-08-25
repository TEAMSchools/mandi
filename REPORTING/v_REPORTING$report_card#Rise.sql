USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#Rise AS

WITH curterm AS (
  SELECT time_per_name
        ,alt_name
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND academic_year = 2014
    AND schoolid = 73252
    AND start_date <= GETDATE()
    AND end_date >= GETDATE()
 )

,roster AS (
  SELECT s.student_number AS base_student_number
        ,s.id AS base_studentid
        ,s.lastfirst AS stu_lastfirst
        ,s.first_name AS stu_firstname
        ,s.last_name AS stu_lastname
        ,co.grade_level AS stu_grade_level
        ,s.team AS travel_group            
        ,s.web_id
        ,CASE WHEN s.web_password LIKE '{B64}%' THEN 'Changed By User' ELSE s.web_password END AS web_password
        ,s.student_web_id
        ,CASE WHEN s.student_web_password LIKE '{B64}%' THEN 'Changed By User' ELSE s.student_web_password END AS student_web_password
        ,s.street
        ,s.city
        ,s.home_phone
        ,cs.advisor
        ,cs.advisor_email
        ,cs.advisor_cell
        ,cs.mother_cell
        ,CASE WHEN cs.mother_home is NULL THEN cs.mother_day ELSE cs.mother_home END AS mother_daytime
        ,cs.father_cell
        ,CASE WHEN cs.father_home is NULL THEN cs.father_day ELSE cs.father_home END AS father_daytime
        ,cs.guardianemail           
        ,cs.SPEDLEP AS SPED
        ,cs.lunch_balance AS lunch_balance
        ,curterm.alt_name AS curterm
  FROM KIPP_NJ..COHORT$comprehensive_long#static co  WITH (NOLOCK)    
  JOIN curterm
    ON 1 = 1
  JOIN KIPP_NJ..STUDENTS s  WITH (NOLOCK)
    ON co.studentid = s.id
   AND s.enroll_status = 0
  LEFT OUTER JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH (NOLOCK)
    ON co.studentid = cs.studentid
  WHERE co.year = dbo.fn_Global_Academic_Year()
    AND co.rn = 1        
    AND co.schoolid = 73252
 )

SELECT roster.*
      
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

    /*--current term component averages--*/       
      --All classes element averages for the year
      ,gr_wide.HY_all AS homework_year_avg
      ,gr_wide.QY_all AS homework_qual_year_avg
      ,gr_wide.AY_all AS assess_year_avg       
       
      /*--UPDATE FIELD FOR CURRENT TERM--*//*--ACTIVATE code block--*/
     --T1--
      /*
      --H
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_H1  END AS rc1_cur_hw_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_H1  END AS rc2_cur_hw_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_H1  END AS rc3_cur_hw_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_H1  END AS rc4_cur_hw_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_H1  END AS rc5_cur_hw_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_H1  END AS rc6_cur_hw_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_H1  END AS rc7_cur_hw_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_H1  END AS rc8_cur_hw_pct
      --A
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_A1  END AS rc1_cur_assess_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_A1  END AS rc2_cur_assess_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_A1  END AS rc3_cur_assess_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_A1  END AS rc4_cur_assess_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_A1  END AS rc5_cur_assess_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_A1  END AS rc6_cur_assess_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_A1  END AS rc7_cur_assess_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_A1  END AS rc8_cur_assess_pct
      --Q
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_Q1  END AS rc1_cur_qual_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_Q1  END AS rc2_cur_qual_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_Q1  END AS rc3_cur_qual_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_Q1  END AS rc4_cur_qual_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_Q1  END AS rc5_cur_qual_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_Q1  END AS rc6_cur_qual_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_Q1  END AS rc7_cur_qual_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_Q1  END AS rc8_cur_qual_pct
      --*/
    
    --T2--
      /*
      --H
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_H2  END AS rc1_cur_hw_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_H2  END AS rc2_cur_hw_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_H2  END AS rc3_cur_hw_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_H2  END AS rc4_cur_hw_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_H2  END AS rc5_cur_hw_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_H2  END AS rc6_cur_hw_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_H2  END AS rc7_cur_hw_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_H2  END AS rc8_cur_hw_pct
      --A
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_A2  END AS rc1_cur_assess_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_A2  END AS rc2_cur_assess_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_A2  END AS rc3_cur_assess_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_A2  END AS rc4_cur_assess_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_A2  END AS rc5_cur_assess_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_A2  END AS rc6_cur_assess_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_A2  END AS rc7_cur_assess_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_A2  END AS rc8_cur_assess_pct
      --Q
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_Q2  END AS rc1_cur_qual_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_Q2  END AS rc2_cur_qual_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_Q2  END AS rc3_cur_qual_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_Q2  END AS rc4_cur_qual_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_Q2  END AS rc5_cur_qual_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_Q2  END AS rc6_cur_qual_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_Q2  END AS rc7_cur_qual_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_Q2  END AS rc8_cur_qual_pct
      --*/
      
    --T3--
      --/*
       --H
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_H3  END AS rc1_cur_hw_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_H3  END AS rc2_cur_hw_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_H3  END AS rc3_cur_hw_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_H3  END AS rc4_cur_hw_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_H3  END AS rc5_cur_hw_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_H3  END AS rc6_cur_hw_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_H3  END AS rc7_cur_hw_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_H3  END AS rc8_cur_hw_pct
      --A
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_A3  END AS rc1_cur_assess_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_A3  END AS rc2_cur_assess_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_A3  END AS rc3_cur_assess_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_A3  END AS rc4_cur_assess_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_A3  END AS rc5_cur_assess_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_A3  END AS rc6_cur_assess_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_A3  END AS rc7_cur_assess_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_A3  END AS rc8_cur_assess_pct
      --Q
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_Q3  END AS rc1_cur_qual_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_Q3  END AS rc2_cur_qual_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_Q3  END AS rc3_cur_qual_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_Q3  END AS rc4_cur_qual_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_Q3  END AS rc5_cur_qual_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_Q3  END AS rc6_cur_qual_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_Q3  END AS rc7_cur_qual_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_Q3  END AS rc8_cur_qual_pct
      --*/

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
      /*--UPDATE FIELD to current term--*//*--ACTIVATE code block--*/
      /*
      --T1--
      ,att_counts.RT1_absences_total        AS curterm_absences_total
      ,att_counts.RT1_absences_undoc        AS curterm_absences_undoc
      ,ROUND(att_pct.RT1_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.RT1_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.RT1_tardies_total         AS curterm_tardies_total
      ,ROUND(att_pct.RT1_tardy_pct_total,0) AS curterm_tardy_pct_total
      --*/
      
      /*
      --T2--
      ,att_counts.RT2_absences_total        AS curterm_absences_total
      ,att_counts.RT2_absences_undoc        AS curterm_absences_undoc
      ,ROUND(att_pct.RT2_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.RT2_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.RT2_tardies_total         AS curterm_tardies_total
      ,ROUND(att_pct.RT2_tardy_pct_total,0) AS curterm_tardy_pct_total
      --*/
      
      --/*
      --T3--
      ,att_counts.RT3_abs_all AS curterm_absences_total
      ,att_counts.RT3_a AS curterm_absences_undoc
      ,ROUND(att_pct.RT3_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.RT3_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.RT3_t_all AS curterm_tardies_total
      ,ROUND(att_pct.RT3_tardy_pct_total,0) AS curterm_tardy_pct_total
      --*/

--GPA
--GPA$detail#Rise
    /*--Year--*/      
      ,rise_gpa.GPA_y1_all AS gpa_Y1
      ,rise_gpa.rank_gr_y1_all AS GPA_Y1_Rank_G
      ,rise_gpa.n_gr AS Y1_Dem
   
   /*--Current Term--*/
      /*--UPDATE FIELD FOR CURRENT TERM--*/
      --,rise_gpa.GPA_t1_all gpa_curterm
      --,rise_gpa.GPA_t2_all AS gpa_curterm
      ,rise_gpa.GPA_t3_all AS gpa_curterm
      
--Promotional Criteria
--REPORTING$promo_status#TEAM
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
      ,map_all.spr_2015_read_rit
      ,map_all.f_2014_read_rit            
      --,map_all.spring_2015_percentile - map_all.fall_2014_percentile AS f2s_2014_14_read_pctle_chg
      ,map_all.f_2014_read_pctle - map_all.spr_2014_read_pctle AS sum_2014_read_pctle_chg
      -- 13-14
      ,map_all.spr_2014_read_pctle
      ,map_all.f_2013_read_pctle
      ,map_all.spr_2014_read_rit
      ,map_all.f_2013_read_rit            
      --,map_all.spring_2014_percentile - map_all.fall_2013_percentile AS f2s_2013_14_read_pctle_chg
      ,map_all.f_2013_read_pctle - map_all.spr_2013_read_pctle AS sum_2013_read_pctle_chg
      -- 12-13
      ,map_all.spr_2013_read_pctle
      ,map_all.f_2012_read_pctle
      ,map_all.spr_2013_read_rit
      ,map_all.f_2012_read_rit            
      ,map_all.spr_2013_read_pctle - map_all.f_2012_read_pctle AS f2s_2012_13_read_pctle_chg
      ,map_all.f_2012_read_pctle - map_all.spr_2012_read_pctle AS sum_2012_read_pctle_chg
      -- 11-12
      ,map_all.spr_2012_read_pctle
      ,map_all.f_2011_read_pctle
      ,map_all.spr_2012_read_rit
      ,map_all.f_2011_read_rit            
      ,map_all.spr_2012_read_pctle - map_all.f_2011_read_pctle AS f2s_2011_12_read_pctle_chg
      ,map_all.f_2011_read_pctle - map_all.spr_2011_read_pctle AS sum_2011_read_pctle_chg
        
      --MAP math
      -- 14-15
      ,map_all.spr_2015_math_pctle
      ,map_all.f_2014_math_pctle
      ,map_all.spr_2015_math_rit
      ,map_all.f_2014_math_rit      
      -- 13-14
      ,map_all.spr_2014_math_pctle
      ,map_all.f_2013_math_pctle
      ,map_all.spr_2014_math_rit
      ,map_all.f_2013_math_rit      
      --,map_all.spring_2014_percentile - map_all.fall_2013_percentile AS f2s_2013_14_math_pctle_chg
      ,map_all.f_2013_math_pctle - map_all.spr_2013_math_pctle AS sum_2013_math_pctle_chg
      -- 12-13
      ,map_all.spr_2013_math_pctle
      ,map_all.f_2012_math_pctle
      ,map_all.spr_2013_math_rit
      ,map_all.f_2012_math_rit      
      ,map_all.spr_2013_math_pctle - map_all.f_2012_math_pctle AS f2s_2012_13_math_pctle_chg
      ,map_all.f_2012_math_pctle - map_all.spr_2012_math_pctle AS sum_2012_math_pctle_chg
      -- 11-12
      ,map_all.spr_2012_math_pctle
      ,map_all.f_2011_math_pctle
      ,map_all.spr_2012_math_rit
      ,map_all.f_2011_math_rit      
      ,map_all.spr_2012_math_pctle - map_all.f_2011_math_pctle AS f2s_2011_12_math_pctle_chg
      ,map_all.f_2011_math_pctle - map_all.spr_2011_math_pctle AS sum_2011_math_pctle_chg

--Literacy tracking
--MAP$comprehensive#identifiers
--LIT$FP_test_events_long#identifiers#static

     --F&P
     --update terms in JOIN
     ,fp_base.read_lvl AS fp_letter_base
     ,fp_curr.read_lvl AS fp_letter_curr
     --GLEQ     
     ,fp_base.GLEQ AS fp_base_GLQ
     ,fp_curr.GLEQ AS fp_curr_GLQ
     
     --Lexile (from MAP)     
     --BASE
     ,CASE
       WHEN lex_base.RITtoReadingScore = 'BR' THEN 'Pre-K'
       ELSE lex_base.RITtoReadingScore
      END AS lexile_base          
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
      END AS lexile_base_GLQ
     --CUR
     ,CASE
       WHEN lex_cur.RITtoReadingScore = 'BR' THEN 'Pre-K'
       ELSE lex_cur.RITtoReadingScore
      END AS lexile_cur     
     ,CASE
       WHEN lex_cur.RITtoReadingScore  = 'BR' THEN 'Pre-K'
       WHEN lex_cur.RITtoReadingScore <= 100  THEN 'K'
       WHEN lex_cur.RITtoReadingScore <= 300  AND lex_cur.RITtoReadingScore > 100  THEN '1st'
       WHEN lex_cur.RITtoReadingScore <= 500  AND lex_cur.RITtoReadingScore > 300  THEN '2nd'
       WHEN lex_cur.RITtoReadingScore <= 600  AND lex_cur.RITtoReadingScore > 500  THEN '3rd'
       WHEN lex_cur.RITtoReadingScore <= 700  AND lex_cur.RITtoReadingScore > 600  THEN '4th'
       WHEN lex_cur.RITtoReadingScore <= 800  AND lex_cur.RITtoReadingScore > 700  THEN '5th'
       WHEN lex_cur.RITtoReadingScore <= 900  AND lex_cur.RITtoReadingScore > 800  THEN '6th'
       WHEN lex_cur.RITtoReadingScore <= 1000 AND lex_cur.RITtoReadingScore > 900  THEN '7th'
       WHEN lex_cur.RITtoReadingScore <= 1100 AND lex_cur.RITtoReadingScore > 1000 THEN '8th'
       WHEN lex_cur.RITtoReadingScore <= 1200 AND lex_cur.RITtoReadingScore > 1100 THEN '9th'
       WHEN lex_cur.RITtoReadingScore <= 1300 AND lex_cur.RITtoReadingScore > 1200 THEN '10th'
       WHEN lex_cur.RITtoReadingScore <= 1400 AND lex_cur.RITtoReadingScore > 1300 THEN '11th'
       WHEN lex_cur.RITtoReadingScore  > 1400 THEN '12th'
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
--update terms in JOIN
   --AR totals
     --year
     ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
     ,replace(convert(varchar,convert(Money, ar_yr.words_goal),1),'.00','') AS words_goal_yr      
     ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
     ,ar_yr.mastery AS mastery_yr
     
     --current
     --current trimester = current HEX + previous HEX
     ,replace(convert(varchar,convert(Money, ar_curr.words + ar_curr2.words),1),'.00','') AS words_read_cur_term
     ,replace(convert(varchar,convert(Money, ar_curr.words_goal + ar_curr2.words_goal),1),'.00','') AS words_goal_cur_term
     ,ar_curr2.rank_words_grade_in_school AS words_rank_cur_term_in_grade
     ,ar_curr2.mastery AS mastery_curr
      
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
       ELSE ar_curr2.stu_status_words
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
        WHEN roster.stu_grade_level <= 6 THEN 'Bench'
        ELSE 'Choices'
       END AS bench_choices_label
      ,CASE
        WHEN roster.stu_grade_level <= 6 THEN ISNULL(disc_count.bench,0)
        ELSE ISNULL(disc_count.choices,0)
       END AS bench_choices_yr
      ,CASE
        WHEN (disc_count.iss + disc_count.oss) > 0 THEN 'Yes'
        ELSE 'No'
       END AS ISS_OSS
      
      /*--UPDATE FIELD FOR CURRENT TERM--*/      
      --T1--
      /*
      ,ISNULL(disc_count.rt1_silent_lunches,0) AS cur_silent_lunches
      ,ISNULL(disc_count.rt1_detentions,0) AS cur_detentions
      ,CASE
        WHEN roster.stu_grade_level <= 6 THEN ISNULL(disc_count.rt1_bench,0)
        ELSE ISNULL(disc_count.rt1_choices,0)
       END AS bench_choices_cur
      --*/
      
      --T2--
      /*
      ,ISNULL(disc_count.rt2_silent_lunches,0) AS cur_silent_lunches
      ,ISNULL(disc_count.rt2_detentions,0) AS cur_detentions
      ,CASE
        WHEN roster.stu_grade_level <= 6 THEN ISNULL(disc_count.rt2_bench,0)
        ELSE ISNULL(disc_count.rt2_choices,0)
       END AS bench_choices_cur
      --*/
            
      --T3--
      --/*
      ,ISNULL(disc_count.rt3_silent_lunches,0) AS cur_silent_lunches
      ,ISNULL(disc_count.rt3_detentions,0) AS cur_detentions
      ,CASE
        WHEN roster.stu_grade_level <= 6 THEN ISNULL(disc_count.rt3_bench,0)
        ELSE ISNULL(disc_count.rt3_choices,0)
       END AS bench_choices_cur
      --*/       

--Comments
--PS$comments_gradebook
      /*--NOT USED FOR PROGRESS REPORTS--*/
      --/*
      ,comment_rc1.teacher_comment AS rc1_comment
      ,comment_rc2.teacher_comment AS rc2_comment
      ,comment_rc3.teacher_comment AS rc3_comment
      ,comment_rc4.teacher_comment AS rc4_comment
      ,comment_rc5.teacher_comment AS rc5_comment
      ,comment_rc6.teacher_comment AS rc6_comment
      ,comment_rc7.teacher_comment AS rc7_comment
      ,comment_rc8.teacher_comment AS rc8_comment
      --*/

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

FROM roster WITH (NOLOCK)

--GRADES
LEFT OUTER JOIN GRADES$wide_all#MS gr_wide WITH (NOLOCK)
  ON roster.base_studentid = gr_wide.studentid

--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts WITH (NOLOCK)
  ON roster.base_studentid = att_counts.studentid
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.base_studentid = att_pct.studentid

--GPA
LEFT OUTER JOIN GPA$detail#MS rise_gpa WITH (NOLOCK)
  ON roster.base_studentid = rise_gpa.studentid

--PROMO STATUS  
LEFT OUTER JOIN REPORTING$promo_status#MS promo WITH (NOLOCK)
  ON roster.base_studentid = promo.studentid

--MAP
LEFT OUTER JOIN MAP$wide_all map_all WITH (NOLOCK)
  ON roster.base_studentid = map_all.studentid
  
--LITERACY -- upadate parameters for current term
--F&P
LEFT OUTER JOIN LIT$test_events#identifiers fp_base WITH (NOLOCK)
  ON roster.base_student_number = fp_base.student_number
 AND fp_base.academic_year = dbo.fn_Global_Academic_Year()
 AND fp_base.achv_base_yr = 1
LEFT OUTER JOIN LIT$test_events#identifiers fp_curr WITH (NOLOCK)
  ON roster.base_student_number = fp_curr.student_number 
 AND fp_curr.achv_curr_all = 1
--LEXILE
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_base WITH (NOLOCK)
  ON roster.base_student_number = lex_base.studentid
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.rn_base = 1
 AND lex_base.map_year_academic = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_cur WITH (NOLOCK)
  ON roster.base_student_number = lex_cur.studentid
 AND lex_cur.MeasurementScale = 'Reading'
 AND lex_cur.rn_curr = 1
 AND lex_cur.map_year_academic = dbo.fn_Global_Academic_Year()
  
--NJASK
LEFT OUTER JOIN NJASK$ELA_WIDE njask_ela WITH (NOLOCK)
  ON roster.base_studentid = njask_ela.studentid
 AND njask_ela.schoolid = 73252
 AND njask_ela.rn = 1
LEFT OUTER JOIN NJASK$MATH_WIDE njask_math WITH (NOLOCK)
  ON roster.base_studentid = njask_math.studentid
 AND njask_math.schoolid = 73252

--DISCIPLINE
LEFT OUTER JOIN DISC$counts_wide disc_count WITH (NOLOCK)
  ON roster.base_studentid = disc_count.base_studentid
LEFT OUTER JOIN DISC$recent_incidents_wide disc_recent WITH (NOLOCK)
  ON roster.base_studentid = disc_recent.studentid

--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.base_studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.base_studentid = ar_curr.studentid 
 AND ar_curr.time_period_name = 'RT5'  /*--UPDATE FIELD FOR CURRENT TERM--*/
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr2 WITH (NOLOCK)
  ON roster.base_studentid = ar_curr2.studentid 
 AND ar_curr2.time_period_name = 'RT6'  /*--UPDATE FIELD FOR CURRENT TERM--*/
 AND ar_curr2.yearid = dbo.fn_Global_Term_Id()

--/*
/*--NOT USED FOR PROGRESS REPORTS--*/
--GRADEBOOK COMMMENTS -- 
/*--UPDATE FIELD FOR CURRENT TERM--*//*--UPDATE PARAMETERS FOR CURRENT TERM--*/
LEFT OUTER JOIN PS$comments#static comment_rc1 WITH (NOLOCK)
  ON gr_wide.rc1_T3_enr_sectionid = comment_rc1.sectionid
 AND gr_wide.studentid = comment_rc1.id
 AND comment_rc1.finalgradename = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_rc2 WITH (NOLOCK)
  ON gr_wide.rc2_T3_enr_sectionid = comment_rc2.sectionid
 AND gr_wide.studentid = comment_rc2.id
 AND comment_rc2.finalgradename = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_rc3 WITH (NOLOCK)
  ON gr_wide.rc3_T3_enr_sectionid = comment_rc3.sectionid
 AND gr_wide.studentid = comment_rc3.id
 AND comment_rc3.finalgradename = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_rc4 WITH (NOLOCK)
  ON gr_wide.rc4_T3_enr_sectionid = comment_rc4.sectionid
 AND gr_wide.studentid = comment_rc4.id
 AND comment_rc4.finalgradename = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_rc5 WITH (NOLOCK)
  ON gr_wide.rc5_T3_enr_sectionid = comment_rc5.sectionid
 AND gr_wide.studentid = comment_rc5.id
 AND comment_rc5.finalgradename = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_rc6 WITH (NOLOCK)
  ON gr_wide.rc6_T3_enr_sectionid = comment_rc6.sectionid
 AND gr_wide.studentid = comment_rc6.id
 AND comment_rc6.finalgradename = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_rc7 WITH (NOLOCK)
  ON gr_wide.rc7_T3_enr_sectionid = comment_rc7.sectionid
 AND gr_wide.studentid = comment_rc7.id
 AND comment_rc7.finalgradename = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_rc8 WITH (NOLOCK)
  ON gr_wide.rc8_T3_enr_sectionid = comment_rc8.sectionid
 AND gr_wide.studentid = comment_rc8.id
 AND comment_rc8.finalgradename = roster.curterm
/*--UPDATE FIELD FOR CURRENT TERM--*//*--UPDATE PARAMETERS FOR CURRENT TERM--*/
--*/

LEFT OUTER JOIN RutgersReady..XC$activities_wide xc WITH(NOLOCK)
  ON roster.base_student_number = xc.student_number
 AND xc.yearid = dbo.fn_Global_Term_Id() /*--UPDATE FIELD FOR CURRENT TERM--*/
