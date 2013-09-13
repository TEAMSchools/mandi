--buttslol
create or replace view team_checkpoint as

--06/19 Set to T3 EOY Term Reporting


select distinct s.student_number as base_student_number
      ,s.id as base_studentid
      ,s.lastfirst as stu_lastfirst
      ,s.first_name as stu_firstname
      ,s.last_name as stu_lastname
      ,s.grade_level as stu_grade_level
      ,s.team as travel_group

      ,custom_students.advisor
      ,custom_students.advisor_email
      ,custom_students.advisor_cell

      ,attendance_counts.absences_total as Y1_absences_total
      ,attendance_counts.absences_undoc as Y1_absences_undoc
      ,round(attendance_percentages.Y1_att_pct_total,0) as Y1_att_pct_total
      ,round(attendance_percentages.Y1_att_pct_undoc,0) as Y1_att_pct_undoc
      
      ,attendance_counts.tardies_total as Y1_tardies_total
      ,round(attendance_percentages.Y1_tardy_pct_total,0) as Y1_tardy_pct_total
      
      ,attendance_counts.RT3_absences_total as curterm_absences_total
      ,attendance_counts.RT3_absences_undoc as curterm_absences_undoc
      ,round(attendance_percentages.RT3_att_pct_total,0) as curterm_att_pct_total
      ,round(attendance_percentages.RT3_att_pct_undoc,0) as curterm_att_pct_undoc
      
      ,attendance_counts.RT3_tardies_total as curterm_tardies_total
      ,round(attendance_percentages.RT3_tardy_pct_total,0) as curterm_tardy_pct_total

-- checksheet average goes here   
      ,promo.promo_status_overall
      ,promo.promo_status_att
      ,promo.promo_status_grades

      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last
      ,round(gr_wide.rc1_T1,0) as rc1_T1_term_pct
      ,gr_wide.rc1_T3_ltr as rc1_cur_term_ltr
      ,round(gr_wide.rc1_T3,0) as rc1_cur_term_pct
      ,round(gr_wide.rc1_T2,0) as rc1_T2_term_pct
      ,gr_wide.rc1_y1 as rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      
      ,gr_wide.rc2_course_name
      ,gr_wide.rc2_teacher_last
      ,round(gr_wide.rc2_t1,0) as rc2_T1_term_pct
      ,gr_wide.rc2_T3_ltr as rc2_cur_term_ltr
      ,round(gr_wide.rc2_T3,0) as rc2_cur_term_pct      
      ,round(gr_wide.rc2_T2,0) as rc2_T2_term_pct
      ,gr_wide.rc2_y1 as rc2_y1_pct
      ,gr_wide.rc2_y1_ltr
      
      ,gr_wide.rc3_course_name
      ,gr_wide.rc3_teacher_last
      ,round(gr_wide.rc3_T1,0) as rc3_T1_term_pct
      ,gr_wide.rc3_T3_ltr as rc3_cur_term_ltr
      ,round(gr_wide.rc3_T3,0) as rc3_cur_term_pct      
      ,round(gr_wide.rc3_T2,0) as rc3_T2_term_pct
      ,gr_wide.rc3_y1 as rc3_y1_pct
      ,gr_wide.rc3_y1_ltr

      ,gr_wide.rc4_course_name
      ,gr_wide.rc4_teacher_last
      ,round(gr_wide.rc4_T1,0) as rc4_T1_term_pct
      ,gr_wide.rc4_T3_ltr as rc4_cur_term_ltr
      ,round(gr_wide.rc4_T3,0) as rc4_cur_term_pct       
      ,round(gr_wide.rc4_T2,0) as rc4_T2_term_pct
      ,gr_wide.rc4_y1 as rc4_y1_pct
      ,gr_wide.rc4_y1_ltr
      
      ,gr_wide.rc5_course_name
      ,gr_wide.rc5_teacher_last
      ,round(gr_wide.rc5_T1,0) as rc5_T1_term_pct
      ,gr_wide.rc5_T3_ltr as rc5_cur_term_ltr
      ,round(gr_wide.rc5_T3,0) as rc5_cur_term_pct 
      ,round(gr_wide.rc5_T2,0) as rc5_T2_term_pct
      ,gr_wide.rc5_y1 as rc5_y1_pct
      ,gr_wide.rc5_y1_ltr
      
      ,gr_wide.rc6_course_name
      ,gr_wide.rc6_teacher_last
      ,round(gr_wide.rc6_t1,0) as rc6_T1_term_pct
      ,gr_wide.rc6_T3_ltr as rc6_cur_term_ltr
      ,round(gr_wide.rc6_T3,0) as rc6_cur_term_pct       
      ,round(gr_wide.rc6_T2,0) as rc6_T2_term_pct
      ,gr_wide.rc6_y1 as rc6_y1_pct
      ,gr_wide.rc6_y1_ltr
      
      ,gr_wide.rc7_course_name
      ,gr_wide.rc7_teacher_last
      ,round(gr_wide.rc7_t1,0) as rc7_T1_term_pct
      ,gr_wide.rc7_T3_ltr as rc7_cur_term_ltr
      ,round(gr_wide.rc7_T3,0) as rc7_cur_term_pct    
      ,round(gr_wide.rc7_T2,0) as rc7_T2_term_pct
      ,gr_wide.rc7_y1 as rc7_y1_pct
      ,gr_wide.rc7_y1_ltr
      
      ,gr_wide.rc8_course_name
      ,gr_wide.rc8_teacher_last
      ,round(gr_wide.rc8_T1,0) as rc8_T1_term_pct
      ,gr_wide.rc8_T3_ltr as rc8_cur_term_ltr
      ,round(gr_wide.rc8_T3,0) as rc8_cur_term_pct          
      ,round(gr_wide.rc8_T2,0) as rc8_T2_term_pct
      ,gr_wide.rc8_y1 as rc8_y1_pct
      ,gr_wide.rc8_y1_ltr

      ,gr_wide.rc9_course_name
      ,gr_wide.rc9_teacher_last
      ,round(gr_wide.rc9_t1,0) as rc9_T1_term_pct
      ,gr_wide.rc9_T3_ltr as rc9_cur_term_ltr
      ,round(gr_wide.rc9_T3,0) as rc9_cur_term_pct          
      ,round(gr_wide.rc9_T2,0) as rc9_T2_term_pct
      ,gr_wide.rc9_y1 as rc9_y1_pct
      ,gr_wide.rc9_y1_ltr
      
      ,gr_wide.rc10_course_name
      ,gr_wide.rc10_teacher_last
      ,round(gr_wide.rc10_t1,0) as rc10_T1_term_pct
      ,gr_wide.rc10_T3_ltr as rc10_cur_term_ltr
      ,round(gr_wide.rc10_T3,0) as rc10_cur_term_pct          
      ,round(gr_wide.rc10_T2,0) as rc10_T2_term_pct
      ,gr_wide.rc10_y1 as rc10_y1_pct
      ,gr_wide.rc10_y1_ltr      
      
      ,case when gr_wide.rc1_credittype = 'COCUR' then null else gr_wide.rc1_H3 end as rc1_cur_hw_pct
      ,case when gr_wide.rc2_credittype = 'COCUR' then null else gr_wide.rc2_H3 end as rc2_cur_hw_pct
      ,case when gr_wide.rc3_credittype = 'COCUR' then null else gr_wide.rc3_H3 end as rc3_cur_hw_pct
      ,case when gr_wide.rc4_credittype = 'COCUR' then null else gr_wide.rc4_H3 end as rc4_cur_hw_pct
      ,case when gr_wide.rc5_credittype = 'COCUR' then null else gr_wide.rc5_H3 end as rc5_cur_hw_pct
      ,case when gr_wide.rc6_credittype = 'COCUR' then null else gr_wide.rc6_H3 end as rc6_cur_hw_pct
      ,case when gr_wide.rc7_credittype = 'COCUR' then null else gr_wide.rc7_H3 end as rc7_cur_hw_pct
      ,case when gr_wide.rc8_credittype = 'COCUR' then null else gr_wide.rc8_H3 end as rc8_cur_hw_pct
      
      ,case when gr_wide.rc1_credittype = 'COCUR' then null else gr_wide.rc1_A3 end as rc1_cur_assess_pct
      ,case when gr_wide.rc2_credittype = 'COCUR' then null else gr_wide.rc2_A3 end as rc2_cur_assess_pct  
      ,case when gr_wide.rc3_credittype = 'COCUR' then null else gr_wide.rc3_A3 end as rc3_cur_assess_pct  
      ,case when gr_wide.rc4_credittype = 'COCUR' then null else gr_wide.rc4_A3 end as rc4_cur_assess_pct  
      ,case when gr_wide.rc5_credittype = 'COCUR' then null else gr_wide.rc5_A3 end as rc5_cur_assess_pct  
      ,case when gr_wide.rc6_credittype = 'COCUR' then null else gr_wide.rc6_A3 end as rc6_cur_assess_pct  
      ,case when gr_wide.rc7_credittype = 'COCUR' then null else gr_wide.rc7_A3 end as rc7_cur_assess_pct  
      ,case when gr_wide.rc8_credittype = 'COCUR' then null else gr_wide.rc8_A3 end as rc8_cur_assess_pct
           
      ,comment_rc1.teacher_comment as rc1_comment
      ,comment_rc2.teacher_comment as rc2_comment
      ,comment_rc3.teacher_comment as rc3_comment
      ,comment_rc4.teacher_comment as rc4_comment
      ,comment_rc5.teacher_comment as rc5_comment
      ,comment_rc6.teacher_comment as rc6_comment
           
      ,team_gpa.gpa_T3_weighted_all as  gpa_curterm_all
      ,team_gpa.gpa_T3_weighted_core as gpa_curterm_core
      
      ,team_gpa.gpa_Y1_weighted_all as gpa_y1_all
      ,team_gpa.gpa_Y1_weighted_core as gpa_y1_core
      
      ,s.web_id
      ,s.web_password
      ,s.student_web_id
      ,s.student_web_password
/*      
      ,ar_goals.words_read_yr
      ,ar_goals.words_goal_yr
      --,ar_goals.ontrack_words_yr
      ,case when (ar_goals.ontrack_words_yr - ar_goals.words_read_yr) <= 0 then null 
            else ar_goals.ontrack_words_yr - ar_goals.words_read_yr end as words_needed_yr
      ,ar_goals.words_rank_yr_in_grade
      ,ar_goals.in_grade_denom
      ,ar_goals.stu_status_words_yr
      --words read cur term
      --goal words cur term
      --on track cur term
      --words needed cur term
      --,ar_goals.quiz_avg
*/      
      ,s.street
      ,s.city
      ,s.home_phone
      
      ,custom_students.mother_cell
      ,case when custom_students.mother_home is null then custom_students.mother_day else custom_students.mother_home end as mother_daytime
      ,custom_students.father_cell
      ,case when custom_students.father_home is null then custom_students.father_day else custom_students.father_home end as father_daytime
      ,local_emails.contactemail
      
      --,fss.totalbalance as lunch_balance_owed
      
      --this field is used for end of term Report card comments.  refer to the 
      --join to y_rc_advisor_comments below. -AM2
      ,comments.teacher_comment as advisor_comment
      
     ,case when njask_ela.score_2012 is not null or njask_ela.score_2012 is not null 
            then 'NJASK | Gr '|| njask_ela.gr_lev_2012 || ' | 2012' else null end as NJASK_12_Name
      ,case when njask_ela.score_2011 is not null or njask_ela.score_2011 is not null 
            then 'NJASK | Gr '|| njask_ela.gr_lev_2011 || ' | 2011' else null end as NJASK_11_Name
      ,case when njask_ela.score_2010 is not null or njask_ela.score_2010 is not null 
            then 'NJASK | Gr '|| njask_ela.gr_lev_2010 || ' | 2010' else null end as NJASK_10_Name
      ,case when njask_ela.score_2009 is not null or njask_ela.score_2009 is not null 
            then 'NJASK | Gr '|| njask_ela.gr_lev_2009 || ' | 2009' else null end as NJASK_09_Name           
  --    ,case when njask_ela.score_2008 is not null or njask_ela.score_2008 is not null 
  --          then 'NJASK | Gr '|| njask_ela.gr_lev_2008 || ' | 2008' else null end as NJASK_08_Name   
            
      ,case when njask_ela.score_2012 is not null then njask_ela.score_2012 else null end as ela_score_2012
      ,case when njask_ela.prof_2012 is not null then '('|| njask_ela.prof_2012 ||')' else null end as ela_prof_2012
            
      ,case when njask_ela.score_2011 is not null then njask_ela.score_2011 else null end as ela_score_2011
      ,case when njask_ela.prof_2011 is not null then '('|| njask_ela.prof_2011 ||')' else null end as ela_prof_2011
      
      ,case when njask_ela.score_2010 is not null then njask_ela.score_2010 else null end as ela_score_2010
      ,case when njask_ela.prof_2010 is not null then '('|| njask_ela.prof_2010 ||')' else null end as ela_prof_2010
      
      ,case when njask_ela.score_2009 is not null then njask_ela.score_2009  else null end as ela_score_2009     
      ,case when njask_ela.prof_2009 is not null then '('|| njask_ela.prof_2009 ||')' else null end as ela_prof_2009  

   --   ,case when njask_ela.score_2008 is not null then  njask_ela.score_2008  else null end as ela_score_2008     
   --   ,case when njask_ela.prof_2008 is not null then '('|| njask_ela.prof_2008 ||')' else null end as ela_prof_2008  
      
      ,case when njask_math.score_2012 is not null then  njask_math.score_2012  else null end as math_score_2012
      ,case when njask_math.prof_2012 is not null then '('|| njask_math.prof_2012 ||')' else null end as math_prof_2012

      ,case when njask_math.score_2011 is not null then  njask_math.score_2011  else null end as math_score_2011
      ,case when njask_math.prof_2011 is not null then '('|| njask_math.prof_2011 ||')' else null end as math_prof_2011
      
      ,case when njask_math.score_2010 is not null then njask_math.score_2010 else null end as math_score_2010
      ,case when njask_math.prof_2010 is not null then '('|| njask_math.prof_2010 ||')' else null end as math_prof_2010
      
      ,case when njask_math.score_2009 is not null then  njask_math.score_2009  else null end as math_score_2009     
      ,case when njask_math.prof_2009 is not null then '('|| njask_math.prof_2009 ||')' else null end as math_prof_2009  

  --    ,case when njask_math.score_2008 is not null then  njask_math.score_2008 else null end as math_score_2008     
  --    ,case when njask_math.prof_2008 is not null then '('|| njask_math.prof_2008 ||')' else null end as math_prof_2008  
         
      ,njask_ela.gr_lev_2012 as njask_gr_lev_2012   
      ,njask_ela.gr_lev_2011 as njask_gr_lev_2011
      ,njask_ela.gr_lev_2010 as njask_gr_lev_2010
      ,njask_ela.gr_lev_2009 as njask_gr_lev_2009
  --    ,njask_ela.gr_lev_2008 as njask_gr_lev_2008

      ,map_read.spring_2013_percentile as spr_2013_read_pctle
      ,map_read.fall_2012_percentile as f_2012_read_pctle
      ,map_read.spring_2013_rit as spr_2013_read_rit
      ,map_read.fall_2012_rit as f_2012_read_rit      
      ,map_read.spring_2013_percentile - map_read.fall_2012_percentile as f2s_2012_13_read_pctle_chg
      ,map_read.fall_2012_percentile - map_read.spring_2012_percentile as sum_2012_read_pctle_chg
 
      ,map_read.spring_2012_percentile as spr_2012_read_pctle
      ,map_read.fall_2011_percentile as f_2011_read_pctle
      ,map_read.spring_2012_rit as spr_2012_read_rit
      ,map_read.fall_2011_rit as f_2011_read_rit      
      ,map_read.spring_2012_percentile - map_read.fall_2011_percentile as f2s_2011_12_read_pctle_chg
      ,map_read.fall_2011_percentile - map_read.spring_2011_percentile as sum_2011_read_pctle_chg

      
      ,map_read.spring_2011_percentile as spr_2011_read_pctle
      ,map_read.fall_2010_percentile as f_2010_read_pctle
      ,map_read.spring_2011_rit as spr_2011_read_rit
      ,map_read.fall_2010_rit as f_2010_read_rit      
      ,map_read.spring_2011_percentile - map_read.fall_2010_percentile as f2s_2010_11_read_pctle_chg
      ,map_read.fall_2010_percentile - map_read.spring_2010_percentile as sum_2010_read_pctle_chg

      ,map_read.spring_2010_percentile as spr_2010_read_pctle
      ,map_read.fall_2009_percentile as f_2009_read_pctle
      ,map_read.spring_2010_rit as spr_2010_read_rit
      ,map_read.fall_2009_rit as f_2009_read_rit
      ,map_read.spring_2010_percentile - map_read.fall_2009_percentile as f2s_2009_10_read_pctle_chg
      ,map_read.fall_2009_percentile - map_read.spring_2009_percentile as sum_2009_read_pctle_chg
      
      ,map_read.spring_2009_percentile as spr_2009_read_pctle
      ,map_read.fall_2008_percentile as f_2008_read_pctle
      ,map_read.spring_2009_rit as spr_2009_read_rit
      ,map_read.fall_2008_rit as f_2008_read_rit
      ,map_read.spring_2009_percentile - map_read.fall_2008_percentile as f2s_2008_09_read_pctle_chg

      ,map_math.spring_2013_percentile as spr_2013_math_pctle
      ,map_math.fall_2012_percentile as f_2012_math_pctle
      ,map_math.spring_2013_rit as spr_2013_math_rit
      ,map_math.fall_2012_rit as f_2012_math_rit      
      ,map_math.spring_2013_percentile - map_math.fall_2012_percentile as f2s_2012_13_math_pctle_chg
      ,map_math.fall_2012_percentile - map_math.spring_2012_percentile as sum_2012_math_pctle_chg
      
      ,map_math.spring_2012_percentile as spr_2012_math_pctle
      ,map_math.fall_2011_percentile as f_2011_math_pctle
      ,map_math.spring_2012_rit as spr_2012_math_rit
      ,map_math.fall_2011_rit as f_2011_math_rit      
      ,map_math.spring_2012_percentile - map_math.fall_2011_percentile as f2s_2011_12_math_pctle_chg
      ,map_math.fall_2011_percentile - map_math.spring_2011_percentile as sum_2011_math_pctle_chg
      
      ,map_math.spring_2011_percentile as spr_2011_math_pctle
      ,map_math.fall_2010_percentile as f_2010_math_pctle
      ,map_math.spring_2011_rit as spr_2011_math_rit
      ,map_math.fall_2010_rit as f_2010_math_rit      
      ,map_math.spring_2011_percentile - map_math.fall_2010_percentile as f2s_2010_11_math_pctle_chg
      ,map_math.fall_2010_percentile - map_math.spring_2010_percentile as sum_2010_math_pctle_chg

      ,map_math.spring_2010_percentile as spr_2010_math_pctle
      ,map_math.fall_2009_percentile as f_2009_math_pctle
      ,map_math.spring_2010_rit as spr_2010_math_rit
      ,map_math.fall_2009_rit as f_2009_math_rit
      ,map_math.spring_2010_percentile - map_math.fall_2009_percentile as f2s_2009_10_math_pctle_chg
      ,map_math.fall_2009_percentile - map_math.spring_2009_percentile as sum_2009_math_pctle_chg
      
      ,map_math.spring_2009_percentile as spr_2009_math_pctle
      ,map_math.fall_2008_percentile as f_2008_math_pctle
      ,map_math.spring_2009_rit as spr_2009_math_rit
      ,map_math.fall_2008_rit as f_2008_math_rit      
      ,map_math.spring_2009_percentile - map_math.fall_2008_percentile as f2s_2008_09_math_pctle_chg
/*
      ,fp.current_letter
      ,case when fp.current_letter = 'AA' then '0'
        when fp.current_letter = 'A' then '.3'
        when fp.current_letter = 'B' then '.5'
        when fp.current_letter = 'C' then '.7'
        when fp.current_letter = 'D' then '1'
        when fp.current_letter = 'E' then '1.2'
        when fp.current_letter = 'F' then '1.4'
        when fp.current_letter = 'G' then '1.6'
        when fp.current_letter = 'H' then '1.8'
        when fp.current_letter = 'I' then '2'
        when fp.current_letter = 'J' then '2.2'
        when fp.current_letter = 'K' then '2.4'
        when fp.current_letter = 'L' then '2.6'
        when fp.current_letter = 'M' then '2.8'
        when fp.current_letter = 'N' then '3'
        when fp.current_letter = 'O' then '3.5'
        when fp.current_letter = 'P' then '3.8'
        when fp.current_letter = 'Q' then '4'
        when fp.current_letter = 'R' then '4.5'
        when fp.current_letter = 'S' then '4.8'
        when fp.current_letter = 'T' then '5'
        when fp.current_letter = 'U' then '5.5'
        when fp.current_letter = 'V' then '6'
        when fp.current_letter = 'W' then '6.3'
        when fp.current_letter = 'X' then '6.7'
        when fp.current_letter = 'Y' then '7'
        when fp.current_letter = 'Z' then '7.5'
        when fp.current_letter = 'Z+' then '8' 
        else null end as GLEQ_Current_Letter
      ,fp.baseline_letter
      ,case when fp.baseline_letter = 'AA' then '0'
        when fp.baseline_letter = 'A' then '.3'
        when fp.baseline_letter = 'B' then '.5'
        when fp.baseline_letter = 'C' then '.7'
        when fp.baseline_letter = 'D' then '1'
        when fp.baseline_letter = 'E' then '1.2'
        when fp.baseline_letter = 'F' then '1.4'
        when fp.baseline_letter = 'G' then '1.6'
        when fp.baseline_letter = 'H' then '1.8'
        when fp.baseline_letter = 'I' then '2'
        when fp.baseline_letter = 'J' then '2.2'
        when fp.baseline_letter = 'K' then '2.4'
        when fp.baseline_letter = 'L' then '2.6'
        when fp.baseline_letter = 'M' then '2.8'
        when fp.baseline_letter = 'N' then '3'
        when fp.baseline_letter = 'O' then '3.5'
        when fp.baseline_letter = 'P' then '3.8'
        when fp.baseline_letter = 'Q' then '4'
        when fp.baseline_letter = 'R' then '4.5'
        when fp.baseline_letter = 'S' then '4.8'
        when fp.baseline_letter = 'T' then '5'
        when fp.baseline_letter = 'U' then '5.5'
        when fp.baseline_letter = 'V' then '6'
        when fp.baseline_letter = 'W' then '6.3'
        when fp.baseline_letter = 'X' then '6.7'
        when fp.baseline_letter = 'Y' then '7'
        when fp.baseline_letter = 'Z' then '7.5'
        when fp.baseline_letter = 'Z+' then '8' 
        else null end as GLEQ_baseline_letter
*/     
    --   ,ar.words_goal_cycle
    --   ,ar_goals.on_track_words_cycle
    --   ,ar_goals.words_goal_yr
    --   ,ar_goals.words_goal_RT1
    --   ,ar.quiz_mastery_current_cycle
    --   ,ar.books_current_cycle
    --   ,ar.words_current_cycle
    --   ,ar_goals.words_read_RT1
    -- ,ar.cycle_status
     --  ,ar.days_denominator - ar.days_used as ar_cycle_days_remaining
     --  ,ar.class_rank
      -- ,ar.in_grade_denom as ar_rank_denominator
      -- ,ar.current_cycle_abbreviation
      -- ,ar.words_read_yr
     
      , sri_base_11.lexile as base_sri
      , sri_current.lexile as cur_sri
      
      ,case
         when sri_base_11.lexile <= 100 then 'K'
         when sri_base_11.lexile <= 300 and sri_base_11.lexile > 100 then '1st'
         when sri_base_11.lexile <= 500 and sri_base_11.lexile > 300 then '2nd'
         when sri_base_11.lexile <= 600 and sri_base_11.lexile > 500 then '3rd'
         when sri_base_11.lexile <= 700 and sri_base_11.lexile > 600 then '4th'
         when sri_base_11.lexile <= 800 and sri_base_11.lexile > 700 then '5th'
         when sri_base_11.lexile <= 900 and sri_base_11.lexile > 800 then '6th'
         when sri_base_11.lexile <= 1000 and sri_base_11.lexile > 900 then '7th'
         when sri_base_11.lexile <= 1100 and sri_base_11.lexile > 1000 then '8th'
         when sri_base_11.lexile <= 1200 and sri_base_11.lexile > 1100 then '9th'
         when sri_base_11.lexile <= 1300 and sri_base_11.lexile > 1200 then '10th'
         when sri_base_11.lexile <= 1400 and sri_base_11.lexile > 1300 then '11th'
         when sri_base_11.lexile > 1400 then '12th'
         else null
       end as base_sri_GLQ_starting
      
      ,case
         when sri_current.lexile <= 100 then 'K'
         when sri_current.lexile <= 300 and sri_current.lexile > 100 then '1st'
         when sri_current.lexile <= 500 and sri_current.lexile > 300 then '2nd'
         when sri_current.lexile <= 600 and sri_current.lexile > 500 then '3rd'
         when sri_current.lexile <= 700 and sri_current.lexile > 600 then '4th'
         when sri_current.lexile <= 800 and sri_current.lexile > 700 then '5th'
         when sri_current.lexile <= 900 and sri_current.lexile > 800 then '6th'
         when sri_current.lexile <= 1000 and sri_current.lexile > 900 then '7th'
         when sri_current.lexile <= 1100 and sri_current.lexile > 1000 then '8th'
         when sri_current.lexile <= 1200 and sri_current.lexile > 1100 then '9th'
         when sri_current.lexile <= 1300 and sri_current.lexile > 1200 then '10th'
         when sri_current.lexile <= 1400 and sri_current.lexile > 1300 then '11th'
         when sri_current.lexile > 1400 then '12th'
         else null
      end as base_sri_GLQ_current
  
       ,custom_students.SPEDLEP as SPED
       ,custom_students.lunch_balance AS lunch_balance
       ,gr_wide.rc1_T1_ltr as rc1_T1_term_ltr
       ,gr_wide.rc2_T1_ltr as rc2_T1_term_ltr
       ,gr_wide.rc3_T1_ltr as rc3_T1_term_ltr
       ,gr_wide.rc4_T1_ltr as rc4_T1_term_ltr
       ,gr_wide.rc5_T1_ltr as rc5_T1_term_ltr
       ,gr_wide.rc6_T1_ltr as rc6_T1_term_ltr
       ,gr_wide.rc7_T1_ltr as rc7_T1_term_ltr
       ,gr_wide.rc8_T1_ltr as rc8_T1_term_ltr
       ,gr_wide.rc9_T1_ltr as rc9_T1_term_ltr
       ,gr_wide.rc10_T1_ltr as rc10_T1_term_ltr
       
       ,promo.attendance_points 
       
from students@PS_TEAM s
left outer join custom_students on s.id = custom_students.studentid
left outer join attendance_counts on s.id = attendance_counts.id
left outer join ATT_MEM$ATT_PERCENTAGES attendance_percentages on s.id = attendance_percentages.id

left outer join PROMO$STATUS#TEAM promo on s.id = promo.studentid

left outer join GRADES$WIDE_ALL#TEAM gr_wide on s.id = gr_wide.studentid

--to roll over to t2 - change the gr_wide.rc1_t2_enr_sectionid to gr_wide.rc1_t2_enr_sectionid and the finalgradename to 'T2'
left outer join local_gradebook_comments comment_rc1 on gr_wide.rc1_t3_enr_sectionid = comment_rc1.sectionid
            and gr_wide.studentid = comment_rc1.studentid and comment_rc1.finalgradename = 'T3'
left outer join local_gradebook_comments comment_rc2 on gr_wide.rc2_t3_enr_sectionid = comment_rc2.sectionid
            and gr_wide.studentid = comment_rc2.studentid and comment_rc2.finalgradename = 'T3'
left outer join local_gradebook_comments comment_rc3 on gr_wide.rc3_t3_enr_sectionid = comment_rc3.sectionid
            and gr_wide.studentid = comment_rc3.studentid and comment_rc3.finalgradename = 'T3'
left outer join local_gradebook_comments comment_rc4 on gr_wide.rc4_t3_enr_sectionid = comment_rc4.sectionid
            and gr_wide.studentid = comment_rc4.studentid and comment_rc4.finalgradename = 'T3'
left outer join local_gradebook_comments comment_rc5 on gr_wide.rc5_t3_enr_sectionid = comment_rc5.sectionid
            and gr_wide.studentid = comment_rc5.studentid and comment_rc5.finalgradename = 'T3'
left outer join local_gradebook_comments comment_rc6 on gr_wide.rc6_T3_enr_sectionid = comment_rc6.sectionid
            and gr_wide.studentid = comment_rc6.studentid and comment_rc6.finalgradename = 'T3'

left outer join MAP$READING_WIDE map_read on to_char(s.student_number) = map_read.studentid
left outer join MAP$MATH_WIDE map_math on to_char(s.student_number) = map_math.studentid

--left outer join fp on s.student_number = fp.student_number


left outer join NJASK$ELA_WIDE njask_ela on s.id = njask_ela.id
left outer join NJASK$MATH_WIDE njask_math on s.id = njask_math.id 

left outer join GPA$DETAIL#TEAM team_gpa on s.id = team_gpa.studentid

--left outer join AR$PROGRESS_TO_GOALS ar_goals on s.id = ar_goals.studentid

left outer join local_emails on s.id = local_emails.studentid

--left outer join fss on s.student_number = fss.student_number

--left outer join rlog$detail#team ar on s.id = ar.core_sn

--comment/uncomment the view for the advisor comments as needed.  at NCA advisor comments only
--used for end of term Report cards. remember to update the finalgradename as appropriate! -AM2
left outer join y_rc_advisor_comments comments on s.id = comments.id 
                                              and comments.finalgradename = 'T3' 
left outer join sri_testing_history sri_base_11 on to_char(s.student_number) = sri_base_11.base_student_number 
            and sri_base_11.full_cycle_name = 'Summer School 12-13' and sri_base_11.rn_cycle = 1

left outer join sri_testing_history sri_current on to_char(s.student_number) = sri_current.base_student_number 
           and sri_current.rn_lifetime = 1
where s.schoolid = 133570965 and s.enroll_status = 0
order by stu_grade_level, travel_group, stu_lastfirst