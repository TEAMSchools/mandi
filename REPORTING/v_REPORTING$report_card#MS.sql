USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#MS AS

WITH curterm AS (
  SELECT schoolid
        ,alt_name
        ,time_per_name
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid
             ORDER BY end_date DESC) AS rn
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'   
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND CONVERT(DATE,GETDATE()) >= end_date   
 )     

,lexile_curr AS (
  SELECT student_number
        ,rittoreadingscore
        ,CASE
         WHEN rittoreadingscore  = 'BR' THEN 'Pre-K'
         WHEN rittoreadingscore <= 100  THEN 'K'
         WHEN rittoreadingscore BETWEEN 101 AND 300 THEN '1st'
         WHEN rittoreadingscore BETWEEN 301 AND 500 THEN '2nd'
         WHEN rittoreadingscore BETWEEN 501 AND 600 THEN '3rd'
         WHEN rittoreadingscore BETWEEN 601 AND 700 THEN '4th'
         WHEN rittoreadingscore BETWEEN 701 AND 800 THEN '5th'
         WHEN rittoreadingscore BETWEEN 801 AND 900 THEN '6th'
         WHEN rittoreadingscore BETWEEN 901 AND 1000 THEN '7th'
         WHEN rittoreadingscore BETWEEN 1001 AND 1100 THEN '8th'
         WHEN rittoreadingscore BETWEEN 1101 AND 1200 THEN '9th'
         WHEN rittoreadingscore BETWEEN 1201 AND 1300 THEN '10th'
         WHEN rittoreadingscore BETWEEN 1301 AND 1400 THEN '11th'
         WHEN rittoreadingscore  > 1400 THEN '12th'
        END AS lexile_gleq
  FROM KIPP_NJ..MAP$CDF#identifiers#static WITH(NOLOCK)
  WHERE measurementscale = 'Reading'
    AND rn_curr = 1
 )

SELECT co.student_number
      ,co.year AS academic_year            
      ,co.LASTFIRST      
      ,REPLACE(CONVERT(VARCHAR,co.GRADE_LEVEL),'0','K') AS grade_level
      ,co.SCHOOLID
      ,co.TEAM
      ,co.advisor
      ,co.advisor_cell
      ,co.advisor_email
      ,co.student_web_id
      ,co.student_web_password
      ,co.family_web_id
      ,co.family_web_password
      ,co.LUNCH_BALANCE
      ,CONCAT(co.STREET, ' - ', co.CITY, ', ', co.STATE, ' ', co.ZIP) AS address
      ,co.HOME_PHONE
      ,co.MOTHER AS parent_1_name      
      ,CONCAT(co.MOTHER_CELL + ' / ', co.MOTHER_DAY) AS parent_1_phone
      ,co.FATHER AS parent_2_name
      ,CONCAT(co.FATHER_CELL + ' / ' , co.FATHER_DAY) AS parent_2_phone
      ,REPLACE(CONVERT(NVARCHAR(MAX),co.GUARDIANEMAIL),',','; ') AS guardianemail
      ,curterm.alt_name AS curterm        
      ,FORMAT(GETDATE(),'MMMM dd, yyy') AS today_text 
      
      /*Course Grades - GRADES$wide_all*/
      /*--RC1--*/
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last
      ,CONCAT(ROUND(gr_wide.RC1_y1,0), '    ', gr_wide.RC1_y1_ltr)  AS RC1_y1_pct    
      ,ROUND(gr_wide.rc1_t1,0) AS rc1_t1_term_pct
      ,ROUND(gr_wide.rc1_t2,0) AS rc1_t2_term_pct
      ,ROUND(gr_wide.rc1_t3,0) AS rc1_t3_term_pct            
      /*--RC2--*/
      ,gr_wide.RC2_course_name
      ,gr_wide.RC2_teacher_last
      ,CONCAT(ROUND(gr_wide.RC2_y1,0), '    ', gr_wide.RC2_y1_ltr)  AS RC2_y1_pct    
      ,ROUND(gr_wide.RC2_t1,0) AS RC2_t1_term_pct
      ,ROUND(gr_wide.RC2_t2,0) AS RC2_t2_term_pct
      ,ROUND(gr_wide.RC2_t3,0) AS RC2_t3_term_pct      
      /*--RC3--*/
      ,gr_wide.RC3_course_name
      ,gr_wide.RC3_teacher_last
      ,CONCAT(ROUND(gr_wide.RC3_y1,0), '    ', gr_wide.RC3_y1_ltr)  AS RC3_y1_pct    
      ,ROUND(gr_wide.RC3_t1,0) AS RC3_t1_term_pct
      ,ROUND(gr_wide.RC3_t2,0) AS RC3_t2_term_pct
      ,ROUND(gr_wide.RC3_t3,0) AS RC3_t3_term_pct      
      /*--RC4--*/
      ,gr_wide.RC4_course_name
      ,gr_wide.RC4_teacher_last
      ,CONCAT(ROUND(gr_wide.RC4_y1,0), '    ', gr_wide.RC4_y1_ltr)  AS RC4_y1_pct    
      ,ROUND(gr_wide.RC4_t1,0) AS RC4_t1_term_pct
      ,ROUND(gr_wide.RC4_t2,0) AS RC4_t2_term_pct
      ,ROUND(gr_wide.RC4_t3,0) AS RC4_t3_term_pct      
      /*--RC5--*/
      ,gr_wide.RC5_course_name
      ,gr_wide.RC5_teacher_last
      ,CONCAT(ROUND(gr_wide.RC5_y1,0), '    ', gr_wide.RC5_y1_ltr)  AS RC5_y1_pct    
      ,ROUND(gr_wide.RC5_t1,0) AS RC5_t1_term_pct
      ,ROUND(gr_wide.RC5_t2,0) AS RC5_t2_term_pct
      ,ROUND(gr_wide.RC5_t3,0) AS RC5_t3_term_pct            
      /*--RC6--*/
      ,gr_wide.RC6_course_name
      ,gr_wide.RC6_teacher_last
      ,CONCAT(ROUND(gr_wide.RC6_y1,0), '    ', gr_wide.RC6_y1_ltr)  AS RC6_y1_pct      
      ,ROUND(gr_wide.RC6_t1,0) AS RC6_t1_term_pct
      ,ROUND(gr_wide.RC6_t2,0) AS RC6_t2_term_pct
      ,ROUND(gr_wide.RC6_t3,0) AS RC6_t3_term_pct      
      /*--RC7--*/
      ,gr_wide.RC7_course_name
      ,gr_wide.RC7_teacher_last
      ,CONCAT(ROUND(gr_wide.RC7_y1,0), '    ', gr_wide.RC7_y1_ltr)  AS RC7_y1_pct    
      ,ROUND(gr_wide.RC7_t1,0) AS RC7_t1_term_pct
      ,ROUND(gr_wide.RC7_t2,0) AS RC7_t2_term_pct
      ,ROUND(gr_wide.RC7_t3,0) AS RC7_t3_term_pct      
      /*--RC8--*/
      ,gr_wide.RC8_course_name
      ,gr_wide.RC8_teacher_last
      ,CONCAT(ROUND(gr_wide.RC8_y1,0), '    ', gr_wide.RC8_y1_ltr)  AS RC8_y1_pct            
      ,ROUND(gr_wide.RC8_t1,0) AS RC8_t1_term_pct
      ,ROUND(gr_wide.RC8_t2,0) AS RC8_t2_term_pct
      ,ROUND(gr_wide.RC8_t3,0) AS RC8_t3_term_pct    

      /*-- Current term RC grades --*/
      ,CONCAT(
         gr_wide.RC1_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc1,0)) + '%' + CHAR(10)
        ,gr_wide.RC2_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc2,0)) + '%' + CHAR(10)
        ,gr_wide.RC3_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc3,0)) + '%' + CHAR(10)
        ,gr_wide.RC4_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc4,0)) + '%' + CHAR(10)
        ,gr_wide.RC5_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc5,0)) + '%' + CHAR(10)
        ,gr_wide.RC6_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc6,0)) + '%' + CHAR(10)
        ,gr_wide.RC7_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc7,0)) + '%' + CHAR(10)
        ,gr_wide.RC8_course_name + ': ' + CONVERT(VARCHAR,ROUND(rc.rc8,0)) + '%' + CHAR(10)
        ) AS gr_quick_view

      /*--current term component averages--*/       
      /*All classes element averages for the year*/
      ,CONCAT(
         gr_wide.HY_all + '% Completion'
        ,' / ' + gr_wide.QY_all + '% Quality'
        ) AS homework_year_avg      
      --,gr_wide.AY_all AS assess_year_avg       
       
      --/*H*/
      --,ele.rc1_H AS rc1_cur_hw_pct
      --,ele.rc2_H AS rc2_cur_hw_pct
      --,ele.rc3_H AS rc3_cur_hw_pct
      --,ele.rc4_H AS rc4_cur_hw_pct
      --,ele.rc5_H AS rc5_cur_hw_pct
      --,ele.rc6_H AS rc6_cur_hw_pct
      --,ele.rc7_H AS rc7_cur_hw_pct
      --,ele.rc8_H AS rc8_cur_hw_pct
      --/*S*/
      --,ele.rc1_S AS rc1_cur_s_pct
      --,ele.rc2_S AS rc2_cur_s_pct
      --,ele.rc3_S AS rc3_cur_s_pct
      --,ele.rc4_S AS rc4_cur_s_pct
      --,ele.rc5_S AS rc5_cur_s_pct
      --,ele.rc6_S AS rc6_cur_s_pct
      --,ele.rc7_S AS rc7_cur_s_pct
      --,ele.rc8_S AS rc8_cur_s_pct      
      --/*Q*/
      --,ele.rc1_Q AS rc1_cur_qual_pct
      --,ele.rc2_Q AS rc2_cur_qual_pct
      --,ele.rc3_Q AS rc3_cur_qual_pct
      --,ele.rc4_Q AS rc4_cur_qual_pct
      --,ele.rc5_Q AS rc5_cur_qual_pct
      --,ele.rc6_Q AS rc6_cur_qual_pct
      --,ele.rc7_Q AS rc7_cur_qual_pct
      --,ele.rc8_Q AS rc8_cur_qual_pct     

      /* GPA - GPA$detail#MS*/     
      --,CONVERT(VARCHAR,gpa.GPA_y1_all) + ' (' + CONVERT(VARCHAR,gpa.rank_gr_y1_all) + '/' + CONVERT(VARCHAR,gpa.n_gr) + ')' AS gpa_Y1     
      ,STUFF(REPLACE(LEFT((CONVERT(VARCHAR,gpa.gpa_y1_all) + '00'),4),'.',''), 2, 0, '.') AS gpa_y1
      ,STUFF(REPLACE(LEFT((CONVERT(VARCHAR,gpa_long.GPA_all) + '00'),4),'.',''), 2, 0, '.') AS gpa_curterm
      ,ISNULL(STUFF(REPLACE(LEFT((CONVERT(VARCHAR,gpacum.cumulative_Y1_gpa) + '00'),4),'.',''), 2, 0, '.'), 'n/a') AS gpa_cumulative      

      /* Attendance & Tardies - ATT_MEM$attendance_percentages, ATT_MEM$attendance_counts */    
      ,CONCAT(att_counts.y1_abs_all, ' (', att_counts.y1_AE, ') ', ' - ', ROUND(att_pct.Y1_att_pct_total,0), '%') AS Y1_absences_total
      ,CONCAT(att_counts.rt2_ABS_ALL, ' (', att_counts.RT2_AE, ') ', ' - ', ROUND(att_pct.cur_att_pct_total,0), '%') AS curterm_absences_total /* UPDATE - hardcoded for Q1 */
      
      ,CONCAT(att_counts.y1_t_all, ' (', att_counts.Y1_TE, ') ', ' - ', ROUND(att_pct.Y1_tardy_pct_total,0), '%') AS Y1_tardies_total      
      ,CONCAT(att_counts.rt2_T_ALL, ' (', att_counts.RT2_TE, ') ', ' - ', ROUND(att_pct.rt2_tardy_pct_total,0), '%') AS curterm_tardies_total  /* UPDATE - hardcoded for Q1 */

      ,CONCAT(att_counts.y1_oss, ' (', att_counts.Y1_iss, ')') AS Y1_suspensions_total      
      ,CONCAT(att_counts.rt2_OSS, ' (', att_counts.RT2_iss, ')') AS curterm_suspensions_total  /* UPDATE - hardcoded for Q1 */
      
      /*Promotional Criteria - REPORTING$promo_status#MS*/
      ,promo.y1_att_pts_pct
      ,promo.attendance_points      
      ,CASE
        WHEN co.schoolid IN (73252,179902) THEN promo.promo_overall_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_overall_team
       END AS promo_status_overall
      ,CASE
        WHEN co.schoolid IN (73252, 179902) THEN promo.promo_grades_gpa_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_grades_team
       END AS GPA_Promo_Status_Grades  
      ,CASE
        WHEN co.schoolid IN (73252, 179902) THEN promo.promo_att_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_att_team
       END AS promo_status_att
      ,CASE
        WHEN co.schoolid IN (73252, 179902) THEN promo.promo_hw_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_hw_team
       END AS promo_status_hw

      /* Blended Learning */
      /*Accelerated Reader*/      	     
	     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CONVERT(INT,ar.words)), 1), '.00', '') AS AR_Y1_words_read                        	     
	     ,ar.words_goal AS AR_Y1_goal
      ,ar.stu_status_words AS AR_Y1_status	     
	     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CONVERT(INT,ar2.words)), 1), '.00', '') AS AR_CUR_words_read             
      ,ar2.words_goal AS AR_CUR_goal
      ,ar2.stu_status_words AS AR_CUR_status

      /* ST Math */
      ,ROUND(stm.total_completion,0) AS ST_Y1_progress
      ,NULL AS ST_Y1_goal
      ,NULL AS ST_Y1_status
      ,NULL AS ST_CUR_progress
      ,NULL AS ST_CUR_goal
      ,NULL AS ST_CUR_status

      /*Extracurriculars*/
      ,xc.activity_hash

      /* CMA data*/
      ,cma.MATH_short_title
      ,cma.MATH_percent_correct
      ,cma.ELA_short_title
      ,cma.ELA_percent_correct

      /* comments */
      ,comm.rc1_comment
      ,comm.rc2_comment
      ,comm.rc3_comment
      ,comm.rc4_comment
      ,comm.rc5_comment
      ,comm.rc6_comment
      ,comm.rc7_comment
      ,comm.rc8_comment
      
      /* lit */
      ,lit.boy_read_lvl
      ,lit.boy_gleq
      ,lit.cur_read_lvl
      ,lit.cur_gleq

      ,lexile_base.lexile_score AS lexile_base
      ,CASE
        WHEN lexile_base.lexile_score  = 'BR' THEN 'Pre-K'
        WHEN lexile_base.lexile_score <= 100  THEN 'K'
        WHEN lexile_base.lexile_score BETWEEN 101 AND 300 THEN '1st'
        WHEN lexile_base.lexile_score BETWEEN 301 AND 500 THEN '2nd'
        WHEN lexile_base.lexile_score BETWEEN 501 AND 600 THEN '3rd'
        WHEN lexile_base.lexile_score BETWEEN 601 AND 700 THEN '4th'
        WHEN lexile_base.lexile_score BETWEEN 701 AND 800 THEN '5th'
        WHEN lexile_base.lexile_score BETWEEN 801 AND 900 THEN '6th'
        WHEN lexile_base.lexile_score BETWEEN 901 AND 1000 THEN '7th'
        WHEN lexile_base.lexile_score BETWEEN 1001 AND 1100 THEN '8th'
        WHEN lexile_base.lexile_score BETWEEN 1101 AND 1200 THEN '9th'
        WHEN lexile_base.lexile_score BETWEEN 1201 AND 1300 THEN '10th'
        WHEN lexile_base.lexile_score BETWEEN 1301 AND 1400 THEN '11th'
        WHEN lexile_base.lexile_score  > 1400 THEN '12th'
       END AS lexile_base_gleq
      ,lexile_curr.rittoreadingscore AS lexile_curr
      ,lexile_curr.lexile_gleq AS lexile_curr_gleq      

      /* MAP */
      ,CONVERT(VARCHAR,map_all.Y0_Fall_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_Fall_GEN_percentile) + '%ile)' AS MAP_Y0_FALL_GEN
      ,CONVERT(VARCHAR,map_all.Y0_Fall_LANG_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_Fall_LANG_percentile) + '%ile)' AS MAP_Y0_FALL_LANG
      ,CONVERT(VARCHAR,map_all.Y0_Fall_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_Fall_MATH_percentile) + '%ile)' AS MAP_Y0_FALL_MATH
      ,CONVERT(VARCHAR,map_all.Y0_Fall_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_Fall_READ_percentile) + '%ile)' AS MAP_Y0_FALL_READ
      ,CONVERT(VARCHAR,map_all.Y0_SPRING_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_SPRING_GEN_percentile) + '%ile)' AS MAP_Y0_SPRING_GEN
      ,CONVERT(VARCHAR,map_all.Y0_SPRING_LANG_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_SPRING_LANG_percentile) + '%ile)' AS MAP_Y0_SPRING_LANG
      ,CONVERT(VARCHAR,map_all.Y0_SPRING_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_SPRING_MATH_percentile) + '%ile)' AS MAP_Y0_SPRING_MATH
      ,CONVERT(VARCHAR,map_all.Y0_SPRING_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.Y0_SPRING_READ_percentile) + '%ile)' AS MAP_Y0_SPRING_READ

      ,CONVERT(VARCHAR,map_all.y1_Fall_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_Fall_GEN_percentile) + '%ile)' AS MAP_y1_FALL_GEN
      ,CONVERT(VARCHAR,map_all.y1_Fall_LANG_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_Fall_LANG_percentile) + '%ile)' AS MAP_y1_FALL_LANG
      ,CONVERT(VARCHAR,map_all.y1_Fall_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_Fall_MATH_percentile) + '%ile)' AS MAP_y1_FALL_MATH
      ,CONVERT(VARCHAR,map_all.y1_Fall_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_Fall_READ_percentile) + '%ile)' AS MAP_y1_FALL_READ
      ,CONVERT(VARCHAR,map_all.y1_SPRING_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_SPRING_GEN_percentile) + '%ile)' AS MAP_y1_SPRING_GEN
      ,CONVERT(VARCHAR,map_all.y1_SPRING_LANG_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_SPRING_LANG_percentile) + '%ile)' AS MAP_y1_SPRING_LANG
      ,CONVERT(VARCHAR,map_all.y1_SPRING_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_SPRING_MATH_percentile) + '%ile)' AS MAP_y1_SPRING_MATH
      ,CONVERT(VARCHAR,map_all.y1_SPRING_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.y1_SPRING_READ_percentile) + '%ile)' AS MAP_y1_SPRING_READ

      ,CONVERT(VARCHAR,map_all.y2_Fall_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_Fall_GEN_percentile) + '%ile)' AS MAP_y2_FALL_GEN
      ,CONVERT(VARCHAR,map_all.y2_Fall_LANG_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_Fall_LANG_percentile) + '%ile)' AS MAP_y2_FALL_LANG
      ,CONVERT(VARCHAR,map_all.y2_Fall_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_Fall_MATH_percentile) + '%ile)' AS MAP_y2_FALL_MATH
      ,CONVERT(VARCHAR,map_all.y2_Fall_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_Fall_READ_percentile) + '%ile)' AS MAP_y2_FALL_READ
      ,CONVERT(VARCHAR,map_all.y2_SPRING_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_SPRING_GEN_percentile) + '%ile)' AS MAP_y2_SPRING_GEN
      ,CONVERT(VARCHAR,map_all.y2_SPRING_LANG_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_SPRING_LANG_percentile) + '%ile)' AS MAP_y2_SPRING_LANG
      ,CONVERT(VARCHAR,map_all.y2_SPRING_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_SPRING_MATH_percentile) + '%ile)' AS MAP_y2_SPRING_MATH
      ,CONVERT(VARCHAR,map_all.y2_SPRING_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.y2_SPRING_READ_percentile) + '%ile)' AS MAP_y2_SPRING_READ

      ,CONVERT(VARCHAR,map_all.y3_Fall_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.y3_Fall_GEN_percentile) + '%ile)' AS MAP_y3_FALL_GEN
      ,NULL AS MAP_y3_FALL_LANG
      ,CONVERT(VARCHAR,map_all.y3_Fall_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.y3_Fall_MATH_percentile) + '%ile)' AS MAP_y3_FALL_MATH
      ,CONVERT(VARCHAR,map_all.y3_Fall_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.y3_Fall_READ_percentile) + '%ile)' AS MAP_y3_FALL_READ
      ,CONVERT(VARCHAR,map_all.y3_SPRING_GEN_RIT) + ' (' + CONVERT(VARCHAR,map_all.y3_SPRING_GEN_percentile) + '%ile)' AS MAP_y3_SPRING_GEN
      ,CONVERT(VARCHAR,map_all.y3_SPRING_LANG_RIT) + ' (' + CONVERT(VARCHAR,map_all.y3_SPRING_LANG_percentile) + '%ile)' AS MAP_y3_SPRING_LANG
      ,CONVERT(VARCHAR,map_all.y3_SPRING_MATH_RIT) + ' (' + CONVERT(VARCHAR,map_all.y3_SPRING_MATH_percentile) + '%ile)' AS MAP_y3_SPRING_MATH
      ,CONVERT(VARCHAR,map_all.y3_SPRING_READ_RIT) + ' (' + CONVERT(VARCHAR,map_all.y3_SPRING_READ_percentile) + '%ile)' AS MAP_y3_SPRING_READ

FROM KIPP_NJ..COHORT$identifiers_long#static co WITH (NOLOCK)    
JOIN curterm WITH(NOLOCK)
  ON co.schoolid = curterm.schoolid
 AND curterm.rn = 1 
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_scores_wide#static cma WITH(NOLOCK)
  ON co.student_number = cma.student_number
 AND co.year = cma.academic_year
/*GRADES & GPA*/
LEFT OUTER JOIN KIPP_NJ..GRADES$wide_all#MS#static gr_wide WITH(NOLOCK)
  ON co.studentid = gr_wide.studentid
LEFT OUTER JOIN KIPP_NJ..GRADES$rc_grades_by_term rc WITH(NOLOCK)
  ON co.studentid = rc.studentid
 AND REPLACE(curterm.alt_name,'Q','T') = rc.term  /* this needs to be fixed once we update the grades refresh */
--LEFT OUTER JOIN GRADES$rc_elements_by_term ele WITH(NOLOCK)
--  ON co.studentid = ele.studentid
-- AND curterm.alt_name = ele.term
LEFT OUTER JOIN KIPP_NJ..GPA$detail#MS gpa WITH(NOLOCK)
  ON co.studentid = gpa.studentid
LEFT OUTER JOIN KIPP_NJ..GPA$detail_long gpa_long WITH(NOLOCK)
  ON co.studentid = gpa_long.studentid
 AND REPLACE(curterm.alt_name,'Q','T') = gpa_long.term /* this needs to be fixed once we update the grades refresh */
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_cumulative#static gpacum WITH(NOLOCK)
  ON co.studentid = gpacum.studentid
 AND co.schoolid = gpacum.schoolid
/*ATTENDANCE*/
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts#static att_counts WITH(NOLOCK)
  ON co.studentid = att_counts.studentid
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$att_percentages att_pct WITH(NOLOCK)
  ON co.studentid = att_pct.studentid
/*PROMO STATUS*/
LEFT OUTER JOIN KIPP_NJ..REPORTING$promo_status#MS promo WITH(NOLOCK)
  ON co.studentid = promo.studentid
--/*DISCIPLINE*/
--LEFT OUTER JOIN DISC$counts_wide disc_count WITH(NOLOCK)
--  ON co.studentid = disc_count.studentid
/* ACCELERATED READER */
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
  ON co.student_number = ar.student_number
 AND co.year = ar.academic_year
 AND ar.time_period_name = 'Year'
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar2 WITH(NOLOCK)
  ON co.student_number = ar2.student_number
 AND co.year = ar2.academic_year
 AND REPLACE(curterm.alt_name, 'Q', 'RT') = ar2.time_period_name
/* XC */
LEFT OUTER JOIN KIPP_NJ..XC$activities_wide xc WITH(NOLOCK)
  ON co.student_number = xc.student_number
 AND co.year = xc.academic_year
/* GRADEBOOK COMMMENTS */
LEFT OUTER JOIN KIPP_NJ..PS$comments_wide#static comm WITH(NOLOCK)
  ON co.studentid = comm.studentid
 AND curterm.alt_name = comm.term
/* MAP */
LEFT OUTER JOIN KIPP_NJ..MAP$wide_all#static map_all WITH(NOLOCK)
  ON co.studentid = map_all.studentid
LEFT OUTER JOIN lexile_curr
  ON co.student_number = lexile_curr.student_number
LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static lexile_base
  ON co.studentid = lexile_base.studentid
 AND co.year = lexile_base.year
 AND lexile_base.measurementscale = 'Reading'
/* lit */
LEFT OUTER JOIN KIPP_NJ..LIT$achieved_wide lit WITH(NOLOCK)
  ON co.studentid = lit.studentid
LEFT OUTER JOIN STMATH..summary_by_enrollment stm WITH(NOLOCK)
  ON co.student_number = stm.student_number
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1        
  AND co.schoolid IN (73252, 133570965, 179902)
  AND co.enroll_status = 0