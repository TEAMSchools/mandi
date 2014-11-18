USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#TEAM AS

WITH curterm AS (
  SELECT time_per_name
        ,alt_name AS term
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND academic_year = 2014
    AND schoolid = 133570965
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
        ,cs.DEFAULT_FAMILY_WEB_PASSWORD AS web_password
        ,s.student_web_id
        ,cs.DEFAULT_STUDENT_WEB_PASSWORD AS student_web_password
        ,s.street
        ,s.city
        ,s.home_phone
        ,cs.advisor
        ,cs.advisor_email
        ,cs.advisor_cell
        ,cs.mother_cell
        ,COALESCE(cs.mother_home, cs.mother_day) AS mother_daytime
        ,cs.father_cell
        ,COALESCE(cs.father_home, cs.father_day) AS father_daytime
        ,blobs.guardianemail           
        ,cs.SPEDLEP AS SPED
        ,cs.lunch_balance AS lunch_balance
        ,curterm.term AS curterm
        ,REPLACE(curterm.term, 'T', 'Trimester ') AS curterm_long
        ,DATENAME(MONTH,GETDATE()) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())) + ', ' + CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) AS today_text
  FROM KIPP_NJ..COHORT$comprehensive_long#static co  WITH (NOLOCK)    
  JOIN curterm
    ON 1 = 1
  JOIN KIPP_NJ..STUDENTS s  WITH (NOLOCK)
    ON co.studentid = s.id
   AND s.enroll_status = 0
  LEFT OUTER JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH (NOLOCK)
    ON co.studentid = cs.studentid
  LEFT OUTER JOIN PS$student_BLObs#static blobs WITH(NOLOCK)
    ON co.studentid = blobs.studentid
  WHERE co.year = dbo.fn_Global_Academic_Year()
    AND co.rn = 1        
    AND co.schoolid = 133570965
 )

,comments AS (
  SELECT sec.schoolid
        ,sec.studentid
        ,sec.student_number
        ,sec.course_number
        ,sec.sectionid
        ,sec.term
        ,comm.teacher_comment
        ,comm.advisor_comment
  FROM GRADES$sections_by_term sec WITH(NOLOCK)
  JOIN PS$comments#static comm WITH(NOLOCK)
    ON sec.studentid = comm.studentid
   AND sec.course_number = comm.course_number
   AND sec.sectionid = comm.sectionid
   AND sec.term = comm.term
  WHERE sec.term IN (SELECT term FROM curterm)
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
       
      /*--UPDATE FIELD FOR CURRENT TERM--*//*--ACTIVATE code block--*/
     --T1--
      --/*
      --H
      ,gr_wide.rc1_H1 AS rc1_cur_hw_pct
      ,gr_wide.rc2_H1 AS rc2_cur_hw_pct
      ,gr_wide.rc3_H1 AS rc3_cur_hw_pct
      ,gr_wide.rc4_H1 AS rc4_cur_hw_pct
      ,gr_wide.rc5_H1 AS rc5_cur_hw_pct
      ,gr_wide.rc6_H1 AS rc6_cur_hw_pct
      ,gr_wide.rc7_H1 AS rc7_cur_hw_pct
      ,gr_wide.rc8_H1 AS rc8_cur_hw_pct
      --S
      ,gr_wide.rc1_S1 AS rc1_cur_s_pct
      ,gr_wide.rc2_S1 AS rc2_cur_s_pct
      ,gr_wide.rc3_S1 AS rc3_cur_s_pct
      ,gr_wide.rc4_S1 AS rc4_cur_s_pct
      ,gr_wide.rc5_S1 AS rc5_cur_s_pct
      ,gr_wide.rc6_S1 AS rc6_cur_s_pct
      ,gr_wide.rc7_S1 AS rc7_cur_s_pct
      ,gr_wide.rc8_S1 AS rc8_cur_s_pct            
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
      --S
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_S2  END AS rc1_cur_s_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_S2  END AS rc2_cur_s_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_S2  END AS rc3_cur_s_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_S2  END AS rc4_cur_s_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_S2  END AS rc5_cur_s_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_S2  END AS rc6_cur_s_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_S2  END AS rc7_cur_s_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_S2  END AS rc8_cur_s_pct            
      --*/
      
    --T3--
      /*
       --H
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_H3  END AS rc1_cur_hw_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_H3  END AS rc2_cur_hw_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_H3  END AS rc3_cur_hw_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_H3  END AS rc4_cur_hw_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_H3  END AS rc5_cur_hw_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_H3  END AS rc6_cur_hw_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_H3  END AS rc7_cur_hw_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_H3  END AS rc8_cur_hw_pct
      --S
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_S3  END AS rc1_cur_s_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_S3  END AS rc2_cur_s_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_S3  END AS rc3_cur_s_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_S3  END AS rc4_cur_s_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_S3  END AS rc5_cur_s_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_S3  END AS rc6_cur_s_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_S3  END AS rc7_cur_s_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_S3  END AS rc8_cur_s_pct      
      --*/

--Attendance & Tardies
--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts      
    
    /*--Year--*/
      ,att_counts.y1_abs_all AS Y1_absences_total
      ,att_counts.y1_a AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0) AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0) AS Y1_att_pct_undoc      
      ,att_counts.y1_t_all AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total      

    /*--Current--*/      
      --/*
      --CUR--
      ,att_counts.CUR_ABS_ALL AS curterm_absences_total
      ,att_counts.CUR_A AS curterm_absences_undoc
      ,ROUND(att_pct.cur_att_pct_total,0) AS curterm_att_pct_total
      ,ROUND(att_pct.cur_att_pct_undoc,0) AS curterm_att_pct_undoc      
      ,att_counts.CUR_T_ALL AS curterm_tardies_total
      ,ROUND(att_pct.cur_tardy_pct_total,0) AS curterm_tardy_pct_total
      --*/
      
      /* BY TERM == IN CASE YOU NEED IT */
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
      /*
      --T3--
      ,att_counts.RT3_abs_all AS curterm_absences_total
      ,att_counts.RT3_a AS curterm_absences_undoc
      ,ROUND(att_pct.RT3_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.RT3_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.RT3_t_all AS curterm_tardies_total
      ,ROUND(att_pct.RT3_tardy_pct_total,0) AS curterm_tardy_pct_total
      --*/

--GPA
--GPA$detail#MS
    /*--Year--*/      
      ,gpa.GPA_y1_all AS gpa_Y1_all
      ,gpa.GPA_y1_core AS gpa_y1_core
      ,gpa.rank_gr_y1_all AS GPA_Y1_Rank_G
      ,gpa.n_gr AS Y1_Dem   
   /*--Current Term--*/      
      ,gpa_long.GPA_all AS gpa_curterm_all
      ,gpa_long.GPA_core AS gpa_curterm_core
      
--Promotional Criteria      
--REPORTING$promo_status#MS
      ,promo.promo_overall_team AS promo_status_overall
      ,promo.promo_att_team AS promo_status_att
      ,promo.promo_grades_team AS promo_status_grades
      ,promo.attendance_points 
      ,promo.y1_att_pts_pct

/*

--MAP scores
--MAP$wide_all     
/*-- UPDATE FIELDS FOR CURRENT YEAR --*/
     
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
     --GLQ
     ,fp_curr.GLEQ AS fp_curr_GLQ
     ,fp_base.GLEQ AS fp_base_GLQ
     
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
--*/

/*
--Comments
--PS$comments_gradebook
      ,comment_rc1.teacher_comment AS rc1_comment
      ,comment_rc2.teacher_comment AS rc2_comment
      ,comment_rc3.teacher_comment AS rc3_comment
      ,comment_rc4.teacher_comment AS rc4_comment
      ,comment_rc5.teacher_comment AS rc5_comment
      ,comment_rc6.teacher_comment AS rc6_comment
      ,comment_rc7.teacher_comment AS rc7_comment
      ,comment_rc8.teacher_comment AS rc8_comment
      ,comment_rc9.teacher_comment AS rc9_comment
      ,comment_rc10.teacher_comment AS rc10_comment
      --for end of term report card comments
      ,comment_adv.advisor_comment  AS advisor_comment
--*/

FROM roster

--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts WITH (NOLOCK)
  ON roster.base_studentid = att_counts.studentid
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.base_studentid = att_pct.studentid

--GRADES & GPA
LEFT OUTER JOIN GRADES$wide_all#MS#static gr_wide WITH (NOLOCK)
  ON roster.base_studentid = gr_wide.studentid
LEFT OUTER JOIN GRADES$rc_grades_by_term rc WITH(NOLOCK)
  ON roster.base_studentid = rc.studentid
 AND roster.curterm = rc.term
LEFT OUTER JOIN GPA$detail#MS gpa WITH (NOLOCK)
  ON roster.base_studentid = gpa.studentid
LEFT OUTER JOIN GPA$detail_long gpa_long WITH(NOLOCK)
  ON roster.base_studentid = gpa_long.studentid
 AND roster.curterm = gpa_long.term

--PROMO STATUS  
LEFT OUTER JOIN REPORTING$promo_status#MS promo WITH (NOLOCK)
  ON roster.base_studentid = promo.studentid

/*
--MAP
LEFT OUTER JOIN MAP$wide_all map_all WITH (NOLOCK)
  ON roster.base_studentid = map_all.studentid
  
--LITERACY
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
 AND njask_ela.schoolid = 133570965
 AND njask_ela.rn = 1
LEFT OUTER JOIN NJASK$MATH_WIDE njask_math WITH (NOLOCK)
  ON roster.base_studentid = njask_math.studentid
 AND njask_math.schoolid = 133570965


--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.base_studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.base_studentid = ar_curr.studentid 
 AND ar_curr.time_period_name = 'RT2'
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()

--GRADEBOOK COMMMENTS
LEFT OUTER JOIN comments comment_rc1 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc1.studentid
 AND gr_wide.rc1_course_number = comment_rc1.course_number
 AND comment_rc1.term = roster.curterm
LEFT OUTER JOIN comments comment_rc2 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc2.studentid
 AND gr_wide.rc2_course_number = comment_rc2.course_number
 AND comment_rc2.term = roster.curterm
LEFT OUTER JOIN comments comment_rc3 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc3.studentid
 AND gr_wide.rc3_course_number = comment_rc3.course_number
 AND comment_rc3.term = roster.curterm
LEFT OUTER JOIN comments comment_rc4 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc4.studentid
 AND gr_wide.rc4_course_number = comment_rc4.course_number
 AND comment_rc4.term = roster.curterm
LEFT OUTER JOIN comments comment_rc5 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc5.studentid
 AND gr_wide.rc5_course_number = comment_rc5.course_number
 AND comment_rc5.term = roster.curterm
LEFT OUTER JOIN comments comment_rc6 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc6.studentid
 AND gr_wide.rc6_course_number = comment_rc6.course_number
 AND comment_rc6.term = roster.curterm
LEFT OUTER JOIN comments comment_rc7 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc7.studentid
 AND gr_wide.rc7_course_number = comment_rc7.course_number
 AND comment_rc7.term = roster.curterm
LEFT OUTER JOIN comments comment_rc8 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc8.studentid
 AND gr_wide.rc8_course_number = comment_rc8.course_number
 AND comment_rc8.term = roster.curterm
LEFT OUTER JOIN comments comment_rc9 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc9.studentid
 AND gr_wide.rc9_course_number = comment_rc9.course_number
 AND comment_rc9.term = roster.curterm
LEFT OUTER JOIN comments comment_rc10 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc10.studentid
 AND gr_wide.rc10_course_number = comment_rc10.course_number
 AND comment_rc10.term = roster.curterm
LEFT OUTER JOIN comments comment_adv WITH (NOLOCK)
  ON roster.base_studentid = comment_adv.studentid
 AND comment_adv.course_number = 'HR'
 AND comment_adv.term = roster.curterm 
--*/