USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#Rise AS
WITH roster AS
     (SELECT s.student_number AS base_student_number
            ,s.id AS base_studentid
            ,s.lastfirst AS stu_lastfirst
            ,s.first_name AS stu_firstname
            ,s.last_name AS stu_lastname
            ,c.grade_level AS stu_grade_level
            ,s.team AS travel_group            
      FROM KIPP_NJ..COHORT$comprehensive_long#static c      
      JOIN KIPP_NJ..STUDENTS s
        ON c.studentid = s.id
       AND s.enroll_status = 0
       --AND s.ID = 2484
       --AND s.ID IN (,2484)
       --AND s.ID BETWEEN 2000 AND 3000
      WHERE year = 2013
        AND c.rn = 1        
        AND c.schoolid = 73252
     )

    ,info AS
    (SELECT s.id
           ,s.web_id
           ,s.web_password
           ,s.student_web_id
           ,s.student_web_password
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
           ,local.guardianemail
           ,cs.SPEDLEP AS SPED
           ,cs.lunch_balance AS lunch_balance
     FROM KIPP_NJ..CUSTOM_STUDENTS cs
     JOIN KIPP_NJ..STUDENTS s
       ON cs.studentid = s.id
      AND s.enroll_status = 0
     JOIN KIPP_NJ..PS$local_emails local
       ON cs.studentid = local.studentid
    )       

SELECT roster.*
      ,info.*
      
--Course Grades
--GRADES$wide_all
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last            
      ,gr_wide.rc1_t1_ltr AS rc1_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc1_T1,0) AS rc1_cur_term_pct --change field name for current term
      /*
      ,gr_wide.rc1_T1_ltr AS rc1_T1_term_ltr      
      ,gr_wide.rc1_T2_ltr AS rc1_T2_term_ltr
      ,gr_wide.rc1_T3_ltr AS rc1_T3_term_ltr
      ,ROUND(gr_wide.rc1_T1,0) AS rc1_T1_term_pct
      ,ROUND(gr_wide.rc1_T2,0) AS rc1_T2_term_pct
      ,ROUND(gr_wide.rc1_T3,0) AS rc1_T3_term_pct
      */
      ,ROUND(gr_wide.rc1_y1,0) AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      
      ,gr_wide.rc2_course_name
      ,gr_wide.rc2_teacher_last            
      ,gr_wide.rc2_t1_ltr AS rc2_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc2_T1,0) AS rc2_cur_term_pct --change field name for current term
      /*
      ,gr_wide.rc2_T1_ltr AS rc2_T1_term_ltr      
      ,gr_wide.rc2_T2_ltr AS rc2_T2_term_ltr
      ,gr_wide.rc2_T3_ltr AS rc2_T3_term_ltr
      ,ROUND(gr_wide.rc2_T1,0) AS rc2_T1_term_pct
      ,ROUND(gr_wide.rc2_T2,0) AS rc2_T2_term_pct
      ,ROUND(gr_wide.rc2_T3,0) AS rc2_T3_term_pct
      */
      ,ROUND(gr_wide.rc2_y1,0) AS rc2_y1_pct
      ,gr_wide.rc2_y1_ltr
      
      ,gr_wide.rc3_course_name
      ,gr_wide.rc3_teacher_last            
      ,gr_wide.rc3_t1_ltr AS rc3_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc3_T1,0) AS rc3_cur_term_pct --change field name for current term
      /*
      ,gr_wide.rc3_T1_ltr AS rc3_T1_term_ltr      
      ,gr_wide.rc3_T2_ltr AS rc3_T2_term_ltr
      ,gr_wide.rc3_T3_ltr AS rc3_T3_term_ltr
      ,ROUND(gr_wide.rc3_T1,0) AS rc3_T1_term_pct
      ,ROUND(gr_wide.rc3_T2,0) AS rc3_T2_term_pct
      ,ROUND(gr_wide.rc3_T3,0) AS rc3_T3_term_pct
      */
      ,ROUND(gr_wide.rc3_y1,0) AS rc3_y1_pct
      ,gr_wide.rc3_y1_ltr
      
      ,gr_wide.rc4_course_name
      ,gr_wide.rc4_teacher_last            
      ,gr_wide.rc4_t1_ltr AS rc4_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc4_T1,0) AS rc4_cur_term_pct --change field name for current term
      /*
      ,gr_wide.rc4_T1_ltr AS rc4_T1_term_ltr      
      ,gr_wide.rc4_T2_ltr AS rc4_T2_term_ltr
      ,gr_wide.rc4_T3_ltr AS rc4_T3_term_ltr
      ,ROUND(gr_wide.rc4_T1,0) AS rc4_T1_term_pct
      ,ROUND(gr_wide.rc4_T2,0) AS rc4_T2_term_pct
      ,ROUND(gr_wide.rc4_T3,0) AS rc4_T3_term_pct
      */
      ,ROUND(gr_wide.rc4_y1,0) AS rc4_y1_pct
      ,gr_wide.rc4_y1_ltr
      
      ,gr_wide.rc5_course_name
      ,gr_wide.rc5_teacher_last            
      ,gr_wide.rc5_t1_ltr AS rc5_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc5_T1,0) AS rc5_cur_term_pct --change field name for current term
      /*
      ,gr_wide.rc5_T1_ltr AS rc5_T1_term_ltr      
      ,gr_wide.rc5_T2_ltr AS rc5_T2_term_ltr
      ,gr_wide.rc5_T3_ltr AS rc5_T3_term_ltr
      ,ROUND(gr_wide.rc5_T1,0) AS rc5_T1_term_pct
      ,ROUND(gr_wide.rc5_T2,0) AS rc5_T2_term_pct
      ,ROUND(gr_wide.rc5_T3,0) AS rc5_T3_term_pct
      */
      ,ROUND(gr_wide.rc5_y1,0) AS rc5_y1_pct
      ,gr_wide.rc5_y1_ltr
      
      ,gr_wide.rc6_course_name
      ,gr_wide.rc6_teacher_last            
      ,gr_wide.rc6_t1_ltr AS rc6_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc6_T1,0) AS rc6_cur_term_pct --change field name for current term
      /*
      ,gr_wide.rc6_T1_ltr AS rc6_T1_term_ltr     
      ,gr_wide.rc6_T2_ltr AS rc6_T2_term_ltr
      ,gr_wide.rc6_T3_ltr AS rc6_T3_term_ltr
      ,ROUND(gr_wide.rc6_T1,0) AS rc6_T1_term_pct
      ,ROUND(gr_wide.rc6_T2,0) AS rc6_T2_term_pct
      ,ROUND(gr_wide.rc6_T3,0) AS rc6_T3_term_pct
      */
      ,ROUND(gr_wide.rc6_y1,0) AS rc6_y1_pct
      ,gr_wide.rc6_y1_ltr
      
      ,gr_wide.rc7_course_name
      ,gr_wide.rc7_teacher_last            
      ,gr_wide.rc7_t1_ltr AS rc7_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc7_T1,0) AS rc7_cur_term_pct --change field name for current term
      /*
      ,gr_wide.rc7_T1_ltr AS rc7_T1_term_ltr      
      ,gr_wide.rc7_T2_ltr AS rc7_T2_term_ltr
      ,gr_wide.rc7_T3_ltr AS rc7_T3_term_ltr
      ,ROUND(gr_wide.rc7_T1,0) AS rc7_T1_term_pct
      ,ROUND(gr_wide.rc7_T2,0) AS rc7_T2_term_pct
      ,ROUND(gr_wide.rc7_T3,0) AS rc7_T3_term_pct
      */
      ,ROUND(gr_wide.rc7_y1,0) AS rc7_y1_pct
      ,gr_wide.rc7_y1_ltr
      
      /*
      ,gr_wide.rc8_course_name
      ,gr_wide.rc8_teacher_last            
      ,gr_wide.rc8_t1_ltr AS rc8_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc8_T1,0) AS rc8_cur_term_pct --change field name for current term
      ,gr_wide.rc8_T1_ltr AS rc8_T1_term_ltr
      ,gr_wide.rc8_T2_ltr AS rc8_T2_term_ltr
      ,gr_wide.rc8_T3_ltr AS rc8_T3_term_ltr
      ,ROUND(gr_wide.rc8_T1,0) AS rc8_T1_term_pct
      ,ROUND(gr_wide.rc8_T2,0) AS rc8_T2_term_pct
      ,ROUND(gr_wide.rc8_T3,0) AS rc8_T3_term_pct
      ,ROUND(gr_wide.rc8_y1,0) AS rc8_y1_pct
      ,gr_wide.rc8_y1_ltr
      
      ,gr_wide.rc9_course_name
      ,gr_wide.rc9_teacher_last            
      ,gr_wide.rc9_t1_ltr AS rc9_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc9_T1,0) AS rc9_cur_term_pct --change field name for current term
      ,gr_wide.rc9_T1_ltr AS rc9_T1_term_ltr
      ,gr_wide.rc9_T2_ltr AS rc9_T2_term_ltr
      ,gr_wide.rc9_T3_ltr AS rc9_T3_term_ltr
      ,ROUND(gr_wide.rc9_T1,0) AS rc9_T1_term_pct
      ,ROUND(gr_wide.rc9_T2,0) AS rc9_T2_term_pct
      ,ROUND(gr_wide.rc9_T3,0) AS rc9_T3_term_pct
      ,ROUND(gr_wide.rc9_y1,0) AS rc9_y1_pct
      ,gr_wide.rc9_y1_ltr
      
      ,gr_wide.rc10_course_name
      ,gr_wide.rc10_teacher_last            
      ,gr_wide.rc10_t1_ltr AS rc10_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc10_T1,0) AS rc10_cur_term_pct --change field name for current term
      ,gr_wide.rc10_T1_ltr AS rc10_T1_term_ltr
      ,gr_wide.rc10_T2_ltr AS rc10_T2_term_ltr
      ,gr_wide.rc10_T3_ltr AS rc10_T3_term_ltr
      ,ROUND(gr_wide.rc10_T1,0) AS rc10_T1_term_pct
      ,ROUND(gr_wide.rc10_T2,0) AS rc10_T2_term_pct
      ,ROUND(gr_wide.rc10_T3,0) AS rc10_T3_term_pct
      ,ROUND(gr_wide.rc10_y1,0) AS rc10_y1_pct
      ,gr_wide.rc10_y1_ltr
      */

      --current term component averages -- change term number (e.g. H1) on component fields for current term
      --H
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_H1  END AS rc1_cur_hw_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_H1  END AS rc2_cur_hw_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_H1  END AS rc3_cur_hw_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_H1  END AS rc4_cur_hw_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_H1  END AS rc5_cur_hw_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_H1  END AS rc6_cur_hw_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_H1  END AS rc7_cur_hw_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_H1  END AS rc8_cur_hw_pct
      --,CASE WHEN gr_wide.rc9_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc9_H1  END AS rc9_cur_hw_pct
      --,CASE WHEN gr_wide.rc10_credittype = 'COCUR' THEN NULL ELSE gr_wide.rc10_H1 END AS rc10_cur_hw_pct      
      --A
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_A1  END AS rc1_cur_assess_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_A1  END AS rc2_cur_assess_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_A1  END AS rc3_cur_assess_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_A1  END AS rc4_cur_assess_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_A1  END AS rc5_cur_assess_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_A1  END AS rc6_cur_assess_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_A1  END AS rc7_cur_assess_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_A1  END AS rc8_cur_assess_pct
      --,CASE WHEN gr_wide.rc9_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc9_A1  END AS rc9_cur_assess_pct
      --,CASE WHEN gr_wide.rc10_credittype = 'COCUR' THEN NULL ELSE gr_wide.rc10_A1 END AS rc10_cur_assess_pct      
      --Q
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_Q1  END AS rc1_cur_qual_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_Q1  END AS rc2_cur_qual_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_Q1  END AS rc3_cur_qual_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_Q1  END AS rc4_cur_qual_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_Q1  END AS rc5_cur_qual_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_Q1  END AS rc6_cur_qual_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_Q1  END AS rc7_cur_qual_pct
      --,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_Q1  END AS rc8_cur_qual_pct
      --,CASE WHEN gr_wide.rc9_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc9_Q1  END AS rc9_cur_qual_pct
      --,CASE WHEN gr_wide.rc10_credittype = 'COCUR' THEN NULL ELSE gr_wide.rc10_Q1 END AS rc10_cur_qual_pct
      --All classes element averages
      ,gr_wide.HY_all AS homework_year_avg
      ,gr_wide.QY_all AS homework_qual_year_avg
      ,gr_wide.AY_all AS assess_year_avg

--Attendance
--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts
      --year
      ,att_counts.absences_total           AS Y1_absences_total
      ,att_counts.absences_undoc           AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
      ,att_counts.tardies_total            AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total
      
      --current term -- change field name
      ,att_counts.RT1_absences_total        AS curterm_absences_total
      ,att_counts.RT1_absences_undoc        AS curterm_absences_undoc
      ,ROUND(att_pct.RT1_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.RT1_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.RT1_tardies_total         AS curterm_tardies_total
      ,ROUND(att_pct.RT1_tardy_pct_total,0) AS curterm_tardy_pct_total

--GPA
--GPA$detail#Rise
      ,rise_gpa.gpa_Y1
      ,rise_gpa.GPA_Y1_Rank_G
      ,rise_gpa.Y1_Dem
      
      --change field name for current term
      ,rise_gpa.gpa_T1 AS gpa_curterm
            
      /*
      --Unused fields
      ,rise_gpa.gpa_T#_rank AS gpa_curterm_rank
      ,rise_gpa.GPA_T#_Rank_G
      ,rise_gpa.elements
      ,rise_gpa.num_failing
      ,rise_gpa.failing
      */
      
--Promotional Criteria
--REPORTING$promo_status#TEAM
      ,promo.attendance_points
      ,promo.att_string
      ,promo.promo_status_overall
      ,promo.GPA_Promo_Status_Grades  
      ,promo.promo_status_att
      ,promo.promo_status_hw

--MAP scores
--MAP$reading_wide
--MAP$math_wide
     
      --MAP reading -- add a new block for each test year, delete oldest
        --13-14
      --,map_read.spring_2014_percentile AS spr_2014_read_pctle
      ,map_read.fall_2013_percentile AS f_2013_read_pctle
      --,map_read.spring_2014_rit AS spr_2014_read_rit
      ,map_read.fall_2013_rit AS f_2013_read_rit            
      --,map_read.spring_2014_percentile - map_read.fall_2013_percentile AS f2s_2013_14_read_pctle_chg
      ,map_read.fall_2013_percentile - map_read.spring_2013_percentile AS sum_2013_read_pctle_chg
        --12-13
      ,map_read.spring_2013_percentile AS spr_2013_read_pctle
      ,map_read.fall_2012_percentile   AS f_2012_read_pctle
      ,map_read.spring_2013_rit AS spr_2013_read_rit
      ,map_read.fall_2012_rit   AS f_2012_read_rit            
      ,map_read.spring_2013_percentile - map_read.fall_2012_percentile AS f2s_2012_13_read_pctle_chg
      ,map_read.fall_2012_percentile - map_read.spring_2012_percentile AS sum_2012_read_pctle_chg
        --11-12
      ,map_read.spring_2012_percentile AS spr_2012_read_pctle
      ,map_read.fall_2011_percentile   AS f_2011_read_pctle
      ,map_read.spring_2012_rit AS spr_2012_read_rit
      ,map_read.fall_2011_rit   AS f_2011_read_rit            
      ,map_read.spring_2012_percentile - map_read.fall_2011_percentile AS f2s_2011_12_read_pctle_chg
      ,map_read.fall_2011_percentile - map_read.spring_2011_percentile AS sum_2011_read_pctle_chg
        --10-11
      ,map_read.spring_2011_percentile AS spr_2011_read_pctle
      ,map_read.fall_2010_percentile   AS f_2010_read_pctle
      ,map_read.spring_2011_rit AS spr_2011_read_rit
      ,map_read.fall_2010_rit   AS f_2010_read_rit
      ,map_read.spring_2011_percentile - map_read.fall_2010_percentile AS f2s_2010_11_read_pctle_chg      
            
      --MAP math -- add a new block for each test year, delete oldest
        --13-14
      --,map_math.spring_2014_percentile AS spr_2014_math_pctle
      ,map_math.fall_2013_percentile AS f_2013_math_pctle
      --,map_math.spring_2014_rit AS spr_2014_math_rit
      ,map_math.fall_2013_rit AS f_2013_math_rit      
      --,map_math.spring_2014_percentile - map_math.fall_2013_percentile AS f2s_2013_14_math_pctle_chg
      ,map_math.fall_2013_percentile - map_math.spring_2013_percentile AS sum_2013_math_pctle_chg
        --12-13
      ,map_math.spring_2013_percentile AS spr_2013_math_pctle
      ,map_math.fall_2012_percentile AS f_2012_math_pctle
      ,map_math.spring_2013_rit AS spr_2013_math_rit
      ,map_math.fall_2012_rit AS f_2012_math_rit      
      ,map_math.spring_2013_percentile - map_math.fall_2012_percentile AS f2s_2012_13_math_pctle_chg
      ,map_math.fall_2012_percentile - map_math.spring_2012_percentile AS sum_2012_math_pctle_chg
        --11-12
      ,map_math.spring_2012_percentile AS spr_2012_math_pctle
      ,map_math.fall_2011_percentile AS f_2011_math_pctle      
      ,map_math.spring_2012_rit AS spr_2012_math_rit
      ,map_math.fall_2011_rit AS f_2011_math_rit      
      ,map_math.spring_2012_percentile - map_math.fall_2011_percentile AS f2s_2011_12_math_pctle_chg
      ,map_math.fall_2011_percentile - map_math.spring_2011_percentile AS sum_2011_math_pctle_chg
        --10-11
      ,map_math.spring_2011_percentile AS spr_2011_math_pctle
      ,map_math.fall_2010_percentile AS f_2010_math_pctle
      ,map_math.spring_2011_rit AS spr_2011_math_rit
      ,map_math.fall_2010_rit AS f_2010_math_rit
      ,map_math.spring_2011_percentile - map_math.fall_2010_percentile AS f2s_2010_11_math_pctle_chg      

--Literacy tracking
--MAP$comprehensive#identifiers
--LIT$FP_test_events_long#identifiers#static

     --F&P
     --update terms in JOIN
     ,fp_base.letter_level AS fp_letter_base
     ,fp_curr.letter_level AS fp_letter_curr
       --GLQ
     ,CASE 
       WHEN fp_curr.letter_level = 'AA' THEN '0'
       WHEN fp_curr.letter_level = 'A' THEN '.3'
       WHEN fp_curr.letter_level = 'B' THEN '.5'
       WHEN fp_curr.letter_level = 'C' THEN '.7'
       WHEN fp_curr.letter_level = 'D' THEN '1'
       WHEN fp_curr.letter_level = 'E' THEN '1.2'
       WHEN fp_curr.letter_level = 'F' THEN '1.4'
       WHEN fp_curr.letter_level = 'G' THEN '1.6'
       WHEN fp_curr.letter_level = 'H' THEN '1.8'
       WHEN fp_curr.letter_level = 'I' THEN '2'
       WHEN fp_curr.letter_level = 'J' THEN '2.2'
       WHEN fp_curr.letter_level = 'K' THEN '2.4'
       WHEN fp_curr.letter_level = 'L' THEN '2.6'
       WHEN fp_curr.letter_level = 'M' THEN '2.8'
       WHEN fp_curr.letter_level = 'N' THEN '3'
       WHEN fp_curr.letter_level = 'O' THEN '3.5'
       WHEN fp_curr.letter_level = 'P' THEN '3.8'
       WHEN fp_curr.letter_level = 'Q' THEN '4'
       WHEN fp_curr.letter_level = 'R' THEN '4.5'
       WHEN fp_curr.letter_level = 'S' THEN '4.8'
       WHEN fp_curr.letter_level = 'T' THEN '5'
       WHEN fp_curr.letter_level = 'U' THEN '5.5'
       WHEN fp_curr.letter_level = 'V' THEN '6'
       WHEN fp_curr.letter_level = 'W' THEN '6.3'
       WHEN fp_curr.letter_level = 'X' THEN '6.7'
       WHEN fp_curr.letter_level = 'Y' THEN '7'
       WHEN fp_curr.letter_level = 'Z' THEN '7.5'
       WHEN fp_curr.letter_level = 'Z+' THEN '8' 
       ELSE NULL
      END AS fp_curr_GLQ
     ,CASE WHEN fp_base.letter_level = 'AA' THEN '0'
       WHEN fp_base.letter_level = 'A' THEN '.3'
       WHEN fp_base.letter_level = 'B' THEN '.5'
       WHEN fp_base.letter_level = 'C' THEN '.7'
       WHEN fp_base.letter_level = 'D' THEN '1'
       WHEN fp_base.letter_level = 'E' THEN '1.2'
       WHEN fp_base.letter_level = 'F' THEN '1.4'
       WHEN fp_base.letter_level = 'G' THEN '1.6'
       WHEN fp_base.letter_level = 'H' THEN '1.8'
       WHEN fp_base.letter_level = 'I' THEN '2'
       WHEN fp_base.letter_level = 'J' THEN '2.2'
       WHEN fp_base.letter_level = 'K' THEN '2.4'
       WHEN fp_base.letter_level = 'L' THEN '2.6'
       WHEN fp_base.letter_level = 'M' THEN '2.8'
       WHEN fp_base.letter_level = 'N' THEN '3'
       WHEN fp_base.letter_level = 'O' THEN '3.5'
       WHEN fp_base.letter_level = 'P' THEN '3.8'
       WHEN fp_base.letter_level = 'Q' THEN '4'
       WHEN fp_base.letter_level = 'R' THEN '4.5'
       WHEN fp_base.letter_level = 'S' THEN '4.8'
       WHEN fp_base.letter_level = 'T' THEN '5'
       WHEN fp_base.letter_level = 'U' THEN '5.5'
       WHEN fp_base.letter_level = 'V' THEN '6'
       WHEN fp_base.letter_level = 'W' THEN '6.3'
       WHEN fp_base.letter_level = 'X' THEN '6.7'
       WHEN fp_base.letter_level = 'Y' THEN '7'
       WHEN fp_base.letter_level = 'Z' THEN '7.5'
       WHEN fp_base.letter_level = 'Z+' THEN '8' 
       ELSE NULL
      END AS fp_base_GLQ     
     
     --Lexile (from MAP)
     --update terms in JOIN
     ,CASE
       WHEN lex_fall.RITtoReadingScore = 'BR' THEN 'Beginning Reader'
       ELSE lex_fall.RITtoReadingScore
      END AS lexile_base
     --,lex_fall.RITtoReadingMin AS lexile_base_min
     --,lex_fall.RITtoReadingMax AS lexile_base_max     
       --GLQ
     ,CASE
       WHEN lex_fall.RITtoReadingScore  = 'BR' THEN 'Beginning Reader'
       WHEN lex_fall.RITtoReadingScore <= 100  THEN 'K'
       WHEN lex_fall.RITtoReadingScore <= 300  AND lex_fall.RITtoReadingScore > 100  THEN '1st'
       WHEN lex_fall.RITtoReadingScore <= 500  AND lex_fall.RITtoReadingScore > 300  THEN '2nd'
       WHEN lex_fall.RITtoReadingScore <= 600  AND lex_fall.RITtoReadingScore > 500  THEN '3rd'
       WHEN lex_fall.RITtoReadingScore <= 700  AND lex_fall.RITtoReadingScore > 600  THEN '4th'
       WHEN lex_fall.RITtoReadingScore <= 800  AND lex_fall.RITtoReadingScore > 700  THEN '5th'
       WHEN lex_fall.RITtoReadingScore <= 900  AND lex_fall.RITtoReadingScore > 800  THEN '6th'
       WHEN lex_fall.RITtoReadingScore <= 1000 AND lex_fall.RITtoReadingScore > 900  THEN '7th'
       WHEN lex_fall.RITtoReadingScore <= 1100 AND lex_fall.RITtoReadingScore > 1000 THEN '8th'
       WHEN lex_fall.RITtoReadingScore <= 1200 AND lex_fall.RITtoReadingScore > 1100 THEN '9th'
       WHEN lex_fall.RITtoReadingScore <= 1300 AND lex_fall.RITtoReadingScore > 1200 THEN '10th'
       WHEN lex_fall.RITtoReadingScore <= 1400 AND lex_fall.RITtoReadingScore > 1300 THEN '11th'
       WHEN lex_fall.RITtoReadingScore  > 1400 THEN '12th'
       ELSE NULL
      END AS lexile_base_GLQ
      

--NJASK scores
--NJASK$ela_wide
--NJASK$math_wide

      --Test name -- add a new line for each test year, delete oldest
      ,CASE WHEN njask_ela.score_2013 IS NOT NULL OR njask_math.score_2013 IS NOT NULL 
            THEN 'NJASK | Gr '+ njask_ela.gr_lev_2013 + ' | 2013' ELSE NULL END AS NJASK_13_Name
      ,CASE WHEN njask_ela.score_2012 IS NOT NULL OR njask_math.score_2012 IS NOT NULL 
            THEN 'NJASK | Gr '+ njask_ela.gr_lev_2012 + ' | 2012' ELSE NULL END AS NJASK_12_Name
      ,CASE WHEN njask_ela.score_2011 IS NOT NULL OR njask_math.score_2011 IS NOT NULL 
            THEN 'NJASK | Gr '+ njask_ela.gr_lev_2011 + ' | 2011' ELSE NULL END AS NJASK_11_Name      
      
      --ELA scores -- add a new line for each test year, delete oldest
      ,njask_ela.score_2013 AS ela_score_2013
      ,njask_ela.score_2012 AS ela_score_2012
      ,njask_ela.score_2011 AS ela_score_2011      
      --ELA proficiency -- add a new line for each test year, delete oldest
      ,'(' + njask_ela.prof_2013 + ')' AS ela_prof_2013
      ,'(' + njask_ela.prof_2012 + ')' AS ela_prof_2012
      ,'(' + njask_ela.prof_2011 + ')' AS ela_prof_2011      

      --Math scores -- add a new line for each test year, delete oldest
      ,njask_math.score_2013 AS math_score_2013
      ,njask_math.score_2012 AS math_score_2012
      ,njask_math.score_2011 AS math_score_2011      
      --Math proficiency -- add a new line for each test year, delete oldest
      ,'(' + njask_math.prof_2013 + ')' AS math_prof_2013
      ,'(' + njask_math.prof_2012 + ')' AS math_prof_2012
      ,'(' + njask_math.prof_2011 + ')' AS math_prof_2011

--Ed Tech
--AR$progress_to_goals_long#static

      --Accelerated Reader
      --update terms in JOIN
      --AR year
      ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
      ,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr      
      ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
      ,ar_yr.mastery AS mastery_yr
      
      --AR current
      ,replace(convert(varchar,convert(Money, ar_curr.words),1),'.00','') AS words_read_cur_term
      ,replace(convert(varchar,convert(Money, ar_curr.words_goal),1),'.00','') AS words_goal_cur_term
      ,ar_curr.rank_words_grade_in_school AS words_rank_cur_term_in_grade
      ,ar_curr.mastery AS mastery_curr
       
       --AR progress
         --to year goal      
      ,CASE
        WHEN ar_yr.stu_status_words = 'On Track' THEN 'Yes!'
        WHEN ar_yr.stu_status_words = 'Off Track' THEN 'No'
        ELSE ar_yr.stu_status_words
       END AS stu_status_words_yr      
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, CAST(ROUND(
          CASE
           WHEN ((ar_curr.words_goal * 6) - ar_yr.words) <= 0 THEN NULL 
           ELSE (ar_curr.words_goal * 6) - ar_yr.words
          END
             ,0) AS INT)),1),'.00','') AS words_needed_yr
       --to term goal       
      ,CASE
        WHEN ar_curr.stu_status_words = 'On Track' THEN 'Yes!'
        WHEN ar_curr.stu_status_words = 'Off Track' THEN 'No'
        ELSE ar_curr.stu_status_words
       END AS stu_status_words_cur_term      
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, CAST(ROUND(
          CASE
           WHEN (ar_curr.words_goal - ar_curr.words) <= 0 THEN NULL 
           ELSE ar_curr.words_goal - ar_curr.words
          END
             ,0) AS INT)),1),'.00','') AS words_needed_cur_term

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
       --upadate fieldnames for current term
      ,ISNULL(disc_count.rt1_silent_lunches,0) AS cur_silent_lunches
      ,ISNULL(disc_count.rt1_detentions,0) AS cur_detentions
      ,CASE
        WHEN roster.stu_grade_level <= 6 THEN ISNULL(disc_count.rt1_bench,0)
        ELSE ISNULL(disc_count.rt1_choices,0)
       END AS bench_choices_cur

/* NOT USED FOR PROGRESS REPORTS
--Comments
--PS$comments_gradebook
      ,comment_rc1.teacher_comment AS rc1_comment
      ,comment_rc2.teacher_comment AS rc2_comment
      ,comment_rc3.teacher_comment AS rc3_comment
      ,comment_rc4.teacher_comment AS rc4_comment
      ,comment_rc5.teacher_comment AS rc5_comment
      ,comment_rc6.teacher_comment AS rc6_comment
--*/

FROM roster
--INFO
LEFT OUTER JOIN info
  ON roster.base_studentid = info.id

--GRADES
LEFT OUTER JOIN GRADES$wide_all#MS gr_wide
  ON roster.base_studentid = gr_wide.studentid

--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts
  ON roster.base_studentid = att_counts.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct
  ON roster.base_studentid = att_pct.id

--GPA
LEFT OUTER JOIN GPA$detail#Rise rise_gpa
  ON roster.base_studentid = rise_gpa.studentid

--PROMO STATUS  
LEFT OUTER JOIN REPORTING$promo_status#Rise promo
  ON roster.base_studentid = promo.studentid
--ORDER BY stu_grade_level, travel_group, stu_lastfirst

--MAP
LEFT OUTER JOIN MAP$reading_wide map_read
  ON roster.base_student_number = map_read.studentid
LEFT OUTER JOIN MAP$math_wide map_math
  ON roster.base_student_number = map_math.studentid
  
--LITERACY -- upadate parameters for current term
  --F&P
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_base
  ON roster.base_student_number = fp_base.STUDENT_NUMBER
 AND fp_base.year = 2013
 AND fp_base.rn_asc = 1
LEFT OUTER JOIN LIT$FP_test_events_long#identifiers#static fp_curr
  ON roster.base_student_number = fp_curr.STUDENT_NUMBER
 AND fp_curr.year = 2013
 AND fp_curr.rn_desc = 1
  --LEXILE
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_fall
  ON roster.base_student_number = lex_fall.StudentID
 AND lex_fall.MeasurementScale = 'Reading'
 AND lex_fall.fallwinterspring = 'Fall'
 AND lex_fall.map_year_academic = 2013
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_spring
  ON roster.base_student_number = lex_spring.StudentID
 AND lex_spring.MeasurementScale = 'Reading'
 AND lex_spring.fallwinterspring = 'Spring'
 AND lex_spring.map_year_academic = 2013
  
--NJASK
LEFT OUTER JOIN NJASK$ELA_WIDE njask_ela 
  ON roster.base_studentid = njask_ela.id
 AND njask_ela.schoolid = 73252
LEFT OUTER JOIN NJASK$MATH_WIDE njask_math
  ON roster.base_studentid = njask_math.id
 AND njask_math.schoolid = 73252

--DISCIPLINE
LEFT OUTER JOIN DISC$counts_wide disc_count
  ON roster.base_studentid = disc_count.base_studentid
LEFT OUTER JOIN DISC$recent_incidents_wide disc_recent
  ON roster.base_studentid = disc_recent.base_studentid

--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr
  ON roster.base_studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = 2300
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr
  ON roster.base_studentid = ar_curr.studentid 
 AND ar_curr.time_period_name = 'RT1'
 AND ar_curr.yearid = 2300


/* NOT USED FOR PROGRESS REPORTS
--GRADEBOOK COMMMENTS -- upadate fieldname and parameter for current term
LEFT OUTER JOIN PS$comments_gradebooks comment_rc1
  ON gr_wide.rc1_T1_enr_sectionid = comment_rc1.sectionid
 AND gr_wide.studentid = comment_rc1.studentid
 AND comment_rc1.finalgradename = 'T1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc2
  ON gr_wide.rc2_T1_enr_sectionid = comment_rc2.sectionid
 AND gr_wide.studentid = comment_rc2.studentid
 AND comment_rc2.finalgradename = 'T1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc3
  ON gr_wide.rc3_T1_enr_sectionid = comment_rc3.sectionid
 AND gr_wide.studentid = comment_rc3.studentid
 AND comment_rc3.finalgradename = 'T1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc4
  ON gr_wide.rc4_T1_enr_sectionid = comment_rc4.sectionid
 AND gr_wide.studentid = comment_rc4.studentid
 AND comment_rc4.finalgradename = 'T1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc5
  ON gr_wide.rc5_T1_enr_sectionid = comment_rc5.sectionid
 AND gr_wide.studentid = comment_rc5.studentid
 AND comment_rc5.finalgradename = 'T1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc6
  ON gr_wide.rc6_T1_enr_sectionid = comment_rc6.sectionid
 AND gr_wide.studentid = comment_rc6.studentid
 AND comment_rc6.finalgradename = 'T1'
--*/