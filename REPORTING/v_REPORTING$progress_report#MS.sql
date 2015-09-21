USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_report#MS AS

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
      ,gpa.GPA_y1_all + ' (' + gpa.rank_gr_y1_all + '/' + gpa.n_gr + ')' AS gpa_Y1     
      ,gpa_long.GPA_all AS gpa_curterm

      /* Attendance & Tardies - ATT_MEM$attendance_percentages, ATT_MEM$attendance_counts */    
      ,CONCAT(att_counts.y1_abs_all, ' - ', ROUND(att_pct.Y1_att_pct_total,0), '%') AS Y1_absences_total
      ,CONCAT(att_counts.y1_t_all, ' - ', ROUND(att_pct.Y1_tardy_pct_total,0), '%') AS Y1_tardies_total
      ,CONCAT(att_counts.CUR_ABS_ALL, ' - ', ROUND(att_pct.cur_att_pct_total,0), '%') AS curterm_absences_total      
      ,CONCAT(att_counts.CUR_T_ALL, ' - ', ROUND(att_pct.cur_tardy_pct_total,0), '%') AS curterm_tardies_total
      
      /*Promotional Criteria - REPORTING$promo_status#MS*/
      ,promo.y1_att_pts_pct
      ,promo.attendance_points      
      ,CASE
        WHEN co.schoolid = 73252 THEN promo.promo_overall_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_overall_team
       END AS promo_status_overall
      ,CASE
        WHEN co.schoolid = 73252 THEN promo.promo_grades_gpa_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_grades_team
       END AS GPA_Promo_Status_Grades  
      ,CASE
        WHEN co.schoolid = 73252 THEN promo.promo_att_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_att_team
       END AS promo_status_att
      ,CASE
        WHEN co.schoolid = 73252 THEN promo.promo_hw_rise 
        WHEN co.schoolid = 133570965 THEN promo.promo_hw_team
       END AS promo_status_hw

      /* Blended Learning */
      /*Accelerated Reader*/
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar.Y1_words_read), 1), '.00', '') AS AR_Y1_words_read
      ,NULL AS AR_Y1_goal
      ,NULL AS AR_Y1_status
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar.CUR_words_read), 1), '.00', '') AS AR_CUR_words_read 
      ,NULL AS AR_CUR_goal
      ,NULL AS AR_CUR_status
      /* ST Math */
      ,NULL AS ST_Y1_progress
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
FROM COHORT$identifiers_long#static co WITH (NOLOCK)    
JOIN REPORTING$dates curterm WITH(NOLOCK)
  ON co.schoolid = curterm.schoolid
 AND curterm.identifier = 'RT'   
 AND CONVERT(DATE,GETDATE()) BETWEEN curterm.start_date AND curterm.end_date   
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$CMA_scores_wide#static cma WITH(NOLOCK)
  ON co.student_number = cma.student_number
 AND co.year = cma.academic_year
/*GRADES & GPA*/
LEFT OUTER JOIN GRADES$wide_all#MS#static gr_wide WITH(NOLOCK)
  ON co.studentid = gr_wide.studentid
LEFT OUTER JOIN GRADES$rc_grades_by_term rc WITH(NOLOCK)
  ON co.studentid = rc.studentid
 AND REPLACE(curterm.alt_name,'Q','T') = rc.term  /* this needs to be fixed once we update the grades refresh */
--LEFT OUTER JOIN GRADES$rc_elements_by_term ele WITH(NOLOCK)
--  ON co.studentid = ele.studentid
-- AND curterm.alt_name = ele.term
LEFT OUTER JOIN GPA$detail#MS gpa WITH(NOLOCK)
  ON co.studentid = gpa.studentid
LEFT OUTER JOIN GPA$detail_long gpa_long WITH(NOLOCK)
  ON co.studentid = gpa_long.studentid
 AND REPLACE(curterm.alt_name,'Q','T') = gpa_long.term /* this needs to be fixed once we update the grades refresh */
/*ATTENDANCE*/
LEFT OUTER JOIN ATT_MEM$attendance_counts#static att_counts WITH(NOLOCK)
  ON co.studentid = att_counts.studentid
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH(NOLOCK)
  ON co.studentid = att_pct.studentid
/*PROMO STATUS*/
LEFT OUTER JOIN REPORTING$promo_status#MS promo WITH(NOLOCK)
  ON co.studentid = promo.studentid
--/*DISCIPLINE*/
--LEFT OUTER JOIN DISC$counts_wide disc_count WITH(NOLOCK)
--  ON co.studentid = disc_count.studentid
/*ED TECH*/
/*ACCELERATED READER*/
LEFT OUTER JOIN KIPP_NJ..AR$progress_wide ar WITH(NOLOCK)
  ON co.student_number = ar.student_number
/* XC */
LEFT OUTER JOIN KIPP_NJ..XC$activities_wide xc WITH(NOLOCK)
  ON co.student_number = xc.student_number
 AND xc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1        
  AND co.schoolid IN (73252, 133570965, 179902)
  AND co.enroll_status = 0