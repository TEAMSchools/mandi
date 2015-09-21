USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#TEAM AS

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

WHERE roster.year = dbo.fn_Global_Academic_Year()
  AND roster.rn = 1        
  AND roster.schoolid = 133570965
  AND roster.enroll_status = 0