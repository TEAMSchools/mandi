USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_report#NCA AS

SELECT roster.schoolid
      ,roster.student_number AS base_student_number
      ,roster.studentid AS base_studentid
      ,roster.lastfirst AS stu_lastfirst
      ,roster.first_name AS stu_firstname
      ,roster.last_name AS stu_lastname
      ,roster.grade_level AS stu_grade_level
      ,roster.FAMILY_WEB_ID AS web_id
      ,roster.FAMILY_WEB_PASSWORD AS web_password
      ,roster.student_web_id AS student_web_id
      ,roster.student_web_password AS student_web_password
      ,roster.street
      ,roster.city
      ,roster.home_phone
      ,roster.advisor
      ,roster.advisor_email
      ,roster.advisor_cell
      ,roster.mother_cell
      ,COALESCE(roster.mother_home, roster.mother_day) AS mother_daytime
      ,roster.father_cell
      ,COALESCE(roster.father_home, roster.father_day) AS father_daytime
      ,roster.GUARDIANEMAIL           
      ,roster.SPEDLEP AS SPED
      ,roster.lunch_balance AS lunch_balance
      ,curterm.alt_name AS curterm
      ,curterm.time_per_name AS rt
      ,CONVERT(VARCHAR,DATENAME(MONTH,GETDATE())) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())) + ', ' + CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) AS today_words

--Attendance & Tardies
--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts      
    
    /*--Year--*/
      ,att_counts.abs_all_counts_yr AS Y1_absences_total
      ,att_counts.a_counts_yr AS Y1_absences_undoc
      ,att_counts.tdy_all_counts_yr AS Y1_tardies_total      

    /*--Current--*/                  
      ,att_counts.abs_all_counts_term AS curterm_absences_total
      ,att_counts.a_counts_term AS curterm_absences_undoc      
      ,att_counts.tdy_all_counts_term AS curterm_tardies_total
      
      
--GPA
--GPA$detail#nca
--GRADES$GPA_cumulative#static
    /*--Academic Year/Current Term--*/      
      ,gpa_long.GPA_all AS gpa_curterm
      ,nca_gpa.gpa_Y1
      /*--Cumulative--*/
      ,gpa_cumulative.cumulative_Y1_gpa      
      
--Course Grades
--GRADES$wide_all
    /*--RC1--*/
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last      
      
      ,ROUND(gr_wide.rc1_q1,0) AS rc1_q1_term_pct
      ,ROUND(gr_wide.rc1_q2,0) AS rc1_q2_term_pct
      ,ROUND(gr_wide.rc1_q3,0) AS rc1_q3_term_pct
      ,ROUND(gr_wide.rc1_q4,0) AS rc1_q4_term_pct
            
      ,ROUND(gr_wide.rc1_y1,0) AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      ,gr_wide.rc1_credit_hours_Y1
      ,gr_wide.rc1_gpa_points_Y1      
      --,CASE WHEN gr_wide.rc1_y1 >= 70 THEN gr_wide.rc1_credit_hours_Y1 ELSE NULL END AS rc1_earned_crhrs

    /*--RC2--*/
      ,gr_wide.RC2_course_name
      ,gr_wide.RC2_teacher_last      
      
      ,ROUND(gr_wide.RC2_q1,0) AS RC2_q1_term_pct
      ,ROUND(gr_wide.RC2_q2,0) AS RC2_q2_term_pct
      ,ROUND(gr_wide.RC2_q3,0) AS RC2_q3_term_pct
      ,ROUND(gr_wide.RC2_q4,0) AS RC2_q4_term_pct
      
      ,ROUND(gr_wide.RC2_y1,0) AS RC2_y1_pct
      ,gr_wide.RC2_y1_ltr
      ,gr_wide.RC2_credit_hours_Y1
      ,gr_wide.RC2_gpa_points_Y1
      --,CASE WHEN gr_wide.RC2_y1 >= 70 THEN gr_wide.RC2_credit_hours_Y1 ELSE NULL END AS RC2_earned_crhrs

    /*--RC3--*/
      ,gr_wide.RC3_course_name
      ,gr_wide.RC3_teacher_last
      
      ,ROUND(gr_wide.RC3_q1,0) AS RC3_q1_term_pct
      ,ROUND(gr_wide.RC3_q2,0) AS RC3_q2_term_pct
      ,ROUND(gr_wide.RC3_q3,0) AS RC3_q3_term_pct
      ,ROUND(gr_wide.RC3_q4,0) AS RC3_q4_term_pct
      
      ,ROUND(gr_wide.RC3_y1,0) AS RC3_y1_pct
      ,gr_wide.RC3_y1_ltr
      ,gr_wide.RC3_credit_hours_Y1
      ,gr_wide.RC3_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC3_y1 >= 70 THEN gr_wide.RC3_credit_hours_Y1 ELSE NULL END AS RC3_earned_crhrs

    /*--RC4--*/
      ,gr_wide.RC4_course_name
      ,gr_wide.RC4_teacher_last
      
      ,ROUND(gr_wide.RC4_q1,0) AS RC4_q1_term_pct
      ,ROUND(gr_wide.RC4_q2,0) AS RC4_q2_term_pct
      ,ROUND(gr_wide.RC4_q3,0) AS RC4_q3_term_pct
      ,ROUND(gr_wide.RC4_q4,0) AS RC4_q4_term_pct
      
      ,ROUND(gr_wide.RC4_y1,0) AS RC4_y1_pct
      ,gr_wide.RC4_y1_ltr
      ,gr_wide.RC4_credit_hours_Y1
      ,gr_wide.RC4_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC4_y1 >= 70 THEN gr_wide.RC4_credit_hours_Y1 ELSE NULL END AS RC4_earned_crhrs

    /*--RC5--*/
      ,gr_wide.RC5_course_name
      ,gr_wide.RC5_teacher_last
      
      ,ROUND(gr_wide.RC5_q1,0) AS RC5_q1_term_pct
      ,ROUND(gr_wide.RC5_q2,0) AS RC5_q2_term_pct
      ,ROUND(gr_wide.RC5_q3,0) AS RC5_q3_term_pct
      ,ROUND(gr_wide.RC5_q4,0) AS RC5_q4_term_pct
      
      ,ROUND(gr_wide.RC5_y1,0) AS RC5_y1_pct
      ,gr_wide.RC5_y1_ltr
      ,gr_wide.RC5_credit_hours_Y1
      ,gr_wide.RC5_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC5_y1 >= 70 THEN gr_wide.RC5_credit_hours_Y1 ELSE NULL END AS RC5_earned_crhrs
      
    /*--RC6--*/
      ,gr_wide.RC6_course_name
      ,gr_wide.RC6_teacher_last
      
      ,ROUND(gr_wide.RC6_q1,0) AS RC6_q1_term_pct
      ,ROUND(gr_wide.RC6_q2,0) AS RC6_q2_term_pct
      ,ROUND(gr_wide.RC6_q3,0) AS RC6_q3_term_pct
      ,ROUND(gr_wide.RC6_q4,0) AS RC6_q4_term_pct
      
      ,ROUND(gr_wide.RC6_y1,0) AS RC6_y1_pct
      ,gr_wide.RC6_y1_ltr
      ,gr_wide.RC6_credit_hours_Y1
      ,gr_wide.RC6_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC6_y1 >= 70 THEN gr_wide.RC6_credit_hours_Y1 ELSE NULL END AS RC6_earned_crhrs      

    /*--RC7--*/
      ,gr_wide.RC7_course_name
      ,gr_wide.RC7_teacher_last
            
      ,ROUND(gr_wide.RC7_q1,0) AS RC7_q1_term_pct
      ,ROUND(gr_wide.RC7_q2,0) AS RC7_q2_term_pct
      ,ROUND(gr_wide.RC7_q3,0) AS RC7_q3_term_pct
      ,ROUND(gr_wide.RC7_q4,0) AS RC7_q4_term_pct
      
      ,ROUND(gr_wide.RC7_y1,0) AS RC7_y1_pct
      ,gr_wide.RC7_y1_ltr
      ,gr_wide.RC7_credit_hours_Y1
      ,gr_wide.RC7_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC7_y1 >= 70 THEN gr_wide.RC7_credit_hours_Y1 ELSE NULL END AS RC7_earned_crhrs
      
    /*--RC8--*/
      ,gr_wide.RC8_course_name
      ,gr_wide.RC8_teacher_last
      
      ,ROUND(gr_wide.RC8_q1,0) AS RC8_q1_term_pct
      ,ROUND(gr_wide.RC8_q2,0) AS RC8_q2_term_pct
      ,ROUND(gr_wide.RC8_q3,0) AS RC8_q3_term_pct
      ,ROUND(gr_wide.RC8_q4,0) AS RC8_q4_term_pct
      
      ,ROUND(gr_wide.RC8_y1,0) AS RC8_y1_pct
      ,gr_wide.RC8_y1_ltr
      ,gr_wide.RC8_credit_hours_Y1
      ,gr_wide.RC8_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC8_y1 >= 70 THEN gr_wide.RC8_credit_hours_Y1 ELSE NULL END AS RC8_earned_crhrs      

    /*--RC9--*/
      ,gr_wide.RC9_course_name
      ,gr_wide.RC9_teacher_last
      
      ,ROUND(gr_wide.RC9_q1,0) AS RC9_q1_term_pct
      ,ROUND(gr_wide.RC9_q2,0) AS RC9_q2_term_pct
      ,ROUND(gr_wide.RC9_q3,0) AS RC9_q3_term_pct
      ,ROUND(gr_wide.RC9_q4,0) AS RC9_q4_term_pct
      
      ,ROUND(gr_wide.RC9_y1,0) AS RC9_y1_pct
      ,gr_wide.RC9_y1_ltr
      ,gr_wide.RC9_credit_hours_Y1
      ,gr_wide.RC9_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC9_y1 >= 70 THEN gr_wide.RC9_credit_hours_Y1 ELSE NULL END AS RC9_earned_crhrs
      
    /*--RC10--*/
      ,gr_wide.RC10_course_name
      ,gr_wide.RC10_teacher_last      
      
      ,ROUND(gr_wide.RC10_q1,0) AS RC10_q1_term_pct
      ,ROUND(gr_wide.RC10_q2,0) AS RC10_q2_term_pct
      ,ROUND(gr_wide.RC10_q3,0) AS RC10_q3_term_pct
      ,ROUND(gr_wide.RC10_q4,0) AS RC10_q4_term_pct      
      
      ,ROUND(gr_wide.RC10_y1,0) AS RC10_y1_pct
      ,gr_wide.RC10_y1_ltr
      ,gr_wide.RC10_credit_hours_Y1
      ,gr_wide.RC10_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC10_y1 >= 70 THEN gr_wide.RC10_credit_hours_Y1 ELSE NULL END AS RC10_earned_crhrs      

      /* Current component averages */
      /*--H--*/
      ,ele.rc1_h AS rc1_cur_hw_pct
      ,ele.rc2_h AS rc2_cur_hw_pct
      ,ele.rc3_H AS rc3_cur_hw_pct
      ,ele.rc4_h AS rc4_cur_hw_pct
      ,ele.rc5_h AS rc5_cur_hw_pct
      ,ele.rc6_h AS rc6_cur_hw_pct
      ,ele.rc7_h AS rc7_cur_hw_pct
      ,ele.rc8_h AS rc8_cur_hw_pct
      ,ele.rc9_h AS rc9_cur_hw_pct
      ,ele.rc10_h AS rc10_cur_hw_pct      
      /*--A--*/
      ,ele.rc1_a AS rc1_cur_a_pct
      ,ele.rc2_a AS rc2_cur_a_pct
      ,ele.rc3_A AS rc3_cur_a_pct
      ,ele.rc4_a AS rc4_cur_a_pct
      ,ele.rc5_a AS rc5_cur_a_pct
      ,ele.rc6_a AS rc6_cur_a_pct
      ,ele.rc7_a AS rc7_cur_a_pct
      ,ele.rc8_a AS rc8_cur_a_pct
      ,ele.rc9_a AS rc9_cur_a_pct
      ,ele.rc10_a AS rc10_cur_a_pct
      /*--CW--*/
      ,ele.rc1_c AS rc1_cur_cw_pct
      ,ele.rc2_c AS rc2_cur_cw_pct
      ,ele.rc3_C AS rc3_cur_cw_pct
      ,ele.rc4_c AS rc4_cur_cw_pct
      ,ele.rc5_c AS rc5_cur_cw_pct
      ,ele.rc6_c AS rc6_cur_cw_pct
      ,ele.rc7_c AS rc7_cur_cw_pct
      ,ele.rc8_c AS rc8_cur_cw_pct
      ,ele.rc9_c AS rc9_cur_cw_pct
      ,ele.rc10_c AS rc10_cur_cw_pct
      /*--P--*/
      ,ele.rc1_p AS rc1_cur_p_pct
      ,ele.rc2_p AS rc2_cur_p_pct
      ,ele.rc3_P AS rc3_cur_p_pct
      ,ele.rc4_p AS rc4_cur_p_pct
      ,ele.rc5_p AS rc5_cur_p_pct
      ,ele.rc6_p AS rc6_cur_p_pct
      ,ele.rc7_p AS rc7_cur_p_pct
      ,ele.rc8_p AS rc8_cur_p_pct
      ,ele.rc9_p AS rc9_cur_p_pct
      ,ele.rc10_p AS rc10_cur_p_pct      
      
      /*** EXAMS **/
      /*--E1--*/ -- Exams
      ,gr_wide.rc1_E1 AS rc1_exam
      ,gr_wide.rc2_E1 AS rc2_exam
      ,gr_wide.rc3_E1 AS rc3_exam
      ,gr_wide.rc4_E1 AS rc4_exam
      ,gr_wide.rc5_E1 AS rc5_exam
      ,gr_wide.rc6_E1 AS rc6_exam
      ,gr_wide.rc7_E1 AS rc7_exam
      ,gr_wide.rc8_E1 AS rc8_exam
      ,gr_wide.rc9_E1 AS rc9_exam
      ,gr_wide.rc10_E1 AS rc10_exam
      /*--E2--*/
      ,gr_wide.rc1_E2 AS rc1_exam2
      ,gr_wide.rc2_E2 AS rc2_exam2
      ,gr_wide.rc3_E2 AS rc3_exam2
      ,gr_wide.rc4_E2 AS rc4_exam2
      ,gr_wide.rc5_E2 AS rc5_exam2
      ,gr_wide.rc6_E2 AS rc6_exam2
      ,gr_wide.rc7_E2 AS rc7_exam2
      ,gr_wide.rc8_E2 AS rc8_exam2
      ,gr_wide.rc9_E2 AS rc9_exam2
      ,gr_wide.rc10_E2 AS rc10_exam2

    /*--YTD absents and tardies by class--*/
       /*--Absences--*/
      ,gr_wide.rc1_current_absences
      ,gr_wide.rc2_current_absences
      ,gr_wide.rc3_current_absences
      ,gr_wide.rc4_current_absences
      ,gr_wide.rc5_current_absences
      ,gr_wide.rc6_current_absences
      ,gr_wide.rc7_current_absences
      ,gr_wide.rc8_current_absences
      ,gr_wide.rc9_current_absences
      ,gr_wide.rc10_current_absences
       /*--Tardies--*/
      ,gr_wide.rc1_current_tardies
      ,gr_wide.rc2_current_tardies
      ,gr_wide.rc3_current_tardies
      ,gr_wide.rc4_current_tardies
      ,gr_wide.rc5_current_tardies
      ,gr_wide.rc6_current_tardies
      ,gr_wide.rc7_current_tardies
      ,gr_wide.rc8_current_tardies
      ,gr_wide.rc9_current_tardies
      ,gr_wide.rc10_current_tardies
      
--Ed Tech
--AR$progress_to_goals_long#static

    /*--Accelerated Reader--*/
      /*--AR year--*/
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_yr.words),1),'.00','') AS words_read_yr
      ,ar_yr.points AS points_yr
      --,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr
      --,ar_yr.points_goal AS points_goal_yr
      
      
      /*--AR current--*/      
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_curr.words),1),'.00','') AS words_read_cur_term      
      ,ar_curr.points AS points_curterm
      --,replace(convert(varchar,convert(Money, ar_curr.words_goal),1),'.00','') AS words_goal_cur_term

--Literacy tracking
--MAP$comprehensive#identifiers
      --Lexile (from MAP)
      --base for year
      ,COALESCE(REPLACE(map_base.lexile_score, 'BR', 'Beginning Reader'), REPLACE(lex_base.RITtoReadingScore, 'BR', 'Beginning Reader')) AS lexile_base      
      ,COALESCE(map_base.testpercentile, lex_base.TestPercentile) AS lex_base_pct
        
      --current for year
      ,COALESCE(REPLACE(lex_curr.RITtoReadingScore, 'BR', 'Beginning Reader'), REPLACE(map_base.lexile_score, 'BR', 'Beginning Reader')) AS lexile_curr       
      ,COALESCE(lex_curr.TestPercentile, map_base.testpercentile) AS lex_curr_pct

--Comments
--PS$comments#static
      ,comm.rc1_comment
      ,comm.rc2_comment
      ,comm.rc3_comment
      ,comm.rc4_comment
      ,comm.rc5_comment
      ,comm.rc6_comment
      ,comm.rc7_comment
      ,comm.rc8_comment
      ,comm.rc9_comment
      ,comm.rc10_comment            
      --,comm.advisor_comment
    
--Discipline
--DISC$merits_demerits_count#NCA
    /*--Merits--*/
       /*--Year--*/
      ,merits.teacher_merits_y1 AS teacher_merits_yr
      ,merits.perfect_week_merits_y1 AS perfect_week_yr
      ,merits.total_merits_y1 AS total_merits_yr
       /*--Current--*/       
      ,merits.teacher_merits_cur AS teacher_merits_curr
      ,merits.perfect_week_merits_cur AS perfect_week_curr
      ,merits.total_merits_cur AS total_merits_curr
      
    /*--Demerits--*/
       /*--Year--*/
      ,merits.total_demerits_y1
       /*--Current--*/       
      ,merits.total_demerits_cur

FROM KIPP_NJ..COHORT$identifiers_long#static roster WITH (NOLOCK)
JOIN KIPP_NJ..REPORTING$dates curterm WITH(NOLOCK)
  ON roster.schoolid = curterm.schoolid
 AND roster.year = curterm.academic_year 
 AND CONVERT(DATE,GETDATE()) BETWEEN curterm.start_date AND curterm.end_date
 AND curterm.identifier = 'RT' 

/* ATTENDANCE */
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static att_counts WITH (NOLOCK)
  ON roster.studentid = att_counts.studentid
 AND roster.year = att_counts.academic_year
 AND curterm.alt_name = att_counts.term
  
/* GRADES & GPA */
LEFT OUTER JOIN KIPP_NJ..GRADES$wide_all#NCA#static gr_wide WITH(NOLOCK)
  ON roster.studentid = gr_wide.studentid
LEFT OUTER JOIN KIPP_NJ..GRADES$rc_elements_by_term ele WITH(NOLOCK)
  ON roster.studentid = ele.studentid
 AND curterm.alt_name = ele.term
LEFT OUTER JOIN KIPP_NJ..GPA$detail#NCA nca_gpa WITH (NOLOCK)
  ON roster.studentid = nca_gpa.studentid
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_cumulative#static gpa_cumulative WITH (NOLOCK)
  ON roster.studentid = gpa_cumulative.studentid
 AND roster.schoolid = gpa_cumulative.schoolid
LEFT OUTER JOIN KIPP_NJ..GPA$detail_long gpa_long WITH(NOLOCK)
  ON roster.studentid = gpa_long.studentid
 AND curterm.alt_name = gpa_long.term

/* MERITS & DEMERITS */
LEFT OUTER JOIN KIPP_NJ..DISC$culture_counts#NCA merits WITH (NOLOCK)
  ON roster.studentid = merits.studentid

/* ACCELERATED READER */
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.studentid = ar_yr.studentid 
 AND roster.year = ar_yr.academic_year
 AND ar_yr.time_period_name = 'Year'  
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.studentid = ar_curr.studentid 
 AND roster.year = ar_curr.academic_year
 AND ar_curr.time_period_name = curterm.time_per_name 

/* LEXILE */
LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_base WITH (NOLOCK)
  ON roster.studentid = map_base.studentid
 AND roster.year = map_base.year
 AND map_base.MeasurementScale = 'Reading'  
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

/* GRADEBOOK COMMMENTS */
LEFT OUTER JOIN KIPP_NJ..PS$comments_wide#static comm WITH(NOLOCK)
  ON roster.studentid = comm.studentid
 AND curterm.alt_name = comm.term
WHERE roster.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND roster.rn = 1
  AND roster.schoolid = 73253
  AND roster.enroll_status = 0    