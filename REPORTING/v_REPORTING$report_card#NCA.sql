USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#NCA AS

WITH curterm AS (
  SELECT alt_name
        ,time_per_name
        ,ROW_NUMBER() OVER(
          ORDER BY end_date DESC) AS term_rn
  FROM KIPP_NJ..REPORTING$dates curterm WITH(NOLOCK)
  WHERE curterm.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
   AND curterm.schoolid = 73253
   --AND CONVERT(DATE,GETDATE()) > curterm.end_date
   AND curterm.identifier = 'RT' 
 )

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
      
      ,curterm.term_rn
      ,curterm.alt_name AS curterm
      ,curterm.time_per_name AS rt
      ,CONVERT(VARCHAR,DATENAME(MONTH,GETDATE())) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())) + ', ' + CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) AS today_words

      /* Attendance & Tardies */    
      /* counts */
      ,att_counts.ABS_all_counts_yr AS Y1_absences_total
      ,ISNULL(att_counts.A_counts_yr,0) AS Y1_absences_undoc
      ,att_counts.TDY_all_counts_yr AS Y1_tardies_total
      ,att_counts.ABS_all_counts_term AS curterm_absences_total
      ,ISNULL(att_counts.A_counts_term,0) AS curterm_absences_undoc
      ,att_counts.TDY_all_counts_term AS curterm_tardies_total
      
       /* GPA */      
      ,nca_gpa.gpa_term AS gpa_curterm
      ,nca_gpa.gpa_Y1
      ,gpa_cumulative.cumulative_Y1_gpa
      
      /* Course Grades */
      /*--rc01--*/
      ,gr_wide.rc01_course_name AS rc1_course_name
      ,gr_wide.rc01_teacher_name AS rc1_teacher_name
      ,LEFT(rc01_teacher_name, (CHARINDEX(',', rc01_teacher_name) - 1)) AS rc1_teacher_last      
      ,gr_wide.rc01_rt1_term_grade_percent AS rc1_q1_term_pct
      ,gr_wide.rc01_rt2_term_grade_percent AS rc1_q2_term_pct
      ,gr_wide.rc01_rt3_term_grade_percent AS rc1_q3_term_pct
      ,gr_wide.rc01_rt4_term_grade_percent AS rc1_q4_term_pct            
      ,gr_wide.rc01_e1_grade_percent AS rc1_exam
      ,gr_wide.rc01_e2_grade_percent AS rc1_exam2
      ,gr_wide.rc01_y1_grade_percent AS rc1_y1_pct
      ,gr_wide.rc01_y1_grade_letter AS rc1_y1_ltr
      ,gr_wide.rc01_credit_hours AS rc1_credit_hours_Y1      

      /*--rc02--*/
      ,gr_wide.rc02_course_name AS rc2_course_name
      ,gr_wide.rc02_teacher_name AS rc2_teacher_name
      ,LEFT(rc02_teacher_name, (CHARINDEX(',', rc02_teacher_name) - 1)) AS rc2_teacher_last
      ,gr_wide.rc02_rt1_term_grade_percent AS rc2_q1_term_pct
      ,gr_wide.rc02_rt2_term_grade_percent AS rc2_q2_term_pct
      ,gr_wide.rc02_rt3_term_grade_percent AS rc2_q3_term_pct
      ,gr_wide.rc02_rt4_term_grade_percent AS rc2_q4_term_pct            
      ,gr_wide.rc02_e1_grade_percent AS rc2_exam
      ,gr_wide.rc02_e2_grade_percent AS rc2_exam2
      ,gr_wide.rc02_y1_grade_percent AS rc2_y1_pct
      ,gr_wide.rc02_y1_grade_letter AS rc2_y1_ltr
      ,gr_wide.rc02_credit_hours AS rc2_credit_hours_Y1      

      /*--rc03--*/
      ,gr_wide.rc03_course_name AS rc3_course_name
      ,gr_wide.rc03_teacher_name AS rc3_teacher_name
      ,LEFT(rc03_teacher_name, (CHARINDEX(',', rc03_teacher_name) - 1)) AS rc3_teacher_last
      ,gr_wide.rc03_rt1_term_grade_percent AS rc3_q1_term_pct
      ,gr_wide.rc03_rt2_term_grade_percent AS rc3_q2_term_pct
      ,gr_wide.rc03_rt3_term_grade_percent AS rc3_q3_term_pct
      ,gr_wide.rc03_rt4_term_grade_percent AS rc3_q4_term_pct            
      ,gr_wide.rc03_e1_grade_percent AS rc3_exam
      ,gr_wide.rc03_e2_grade_percent AS rc3_exam2
      ,gr_wide.rc03_y1_grade_percent AS rc3_y1_pct
      ,gr_wide.rc03_y1_grade_letter AS rc3_y1_ltr
      ,gr_wide.rc03_credit_hours AS rc3_credit_hours_Y1      

      /*--rc04--*/
      ,gr_wide.rc04_course_name AS rc4_course_name
      ,gr_wide.rc04_teacher_name AS rc4_teacher_name
      ,LEFT(rc04_teacher_name, (CHARINDEX(',', rc04_teacher_name) - 1)) AS rc4_teacher_last
      ,gr_wide.rc04_rt1_term_grade_percent AS rc4_q1_term_pct
      ,gr_wide.rc04_rt2_term_grade_percent AS rc4_q2_term_pct
      ,gr_wide.rc04_rt3_term_grade_percent AS rc4_q3_term_pct
      ,gr_wide.rc04_rt4_term_grade_percent AS rc4_q4_term_pct            
      ,gr_wide.rc04_e1_grade_percent AS rc4_exam
      ,gr_wide.rc04_e2_grade_percent AS rc4_exam2
      ,gr_wide.rc04_y1_grade_percent AS rc4_y1_pct
      ,gr_wide.rc04_y1_grade_letter AS rc4_y1_ltr
      ,gr_wide.rc04_credit_hours AS rc4_credit_hours_Y1      

      /*--rc05--*/
      ,gr_wide.rc05_course_name AS rc5_course_name
      ,gr_wide.rc05_teacher_name AS rc5_teacher_name
      ,LEFT(rc05_teacher_name, (CHARINDEX(',', rc05_teacher_name) - 1)) AS rc5_teacher_last
      ,gr_wide.rc05_rt1_term_grade_percent AS rc5_q1_term_pct
      ,gr_wide.rc05_rt2_term_grade_percent AS rc5_q2_term_pct
      ,gr_wide.rc05_rt3_term_grade_percent AS rc5_q3_term_pct
      ,gr_wide.rc05_rt4_term_grade_percent AS rc5_q4_term_pct    
      ,gr_wide.rc05_e1_grade_percent AS rc5_exam
      ,gr_wide.rc05_e2_grade_percent AS rc5_exam2        
      ,gr_wide.rc05_y1_grade_percent AS rc5_y1_pct
      ,gr_wide.rc05_y1_grade_letter AS rc5_y1_ltr
      ,gr_wide.rc05_credit_hours AS rc5_credit_hours_Y1      
      
      /*--rc06--*/
      ,gr_wide.rc06_course_name AS rc6_course_name
      ,gr_wide.rc06_teacher_name AS rc6_teacher_name
      ,LEFT(rc06_teacher_name, (CHARINDEX(',', rc06_teacher_name) - 1)) AS rc6_teacher_last
      ,gr_wide.rc06_rt1_term_grade_percent AS rc6_q1_term_pct
      ,gr_wide.rc06_rt2_term_grade_percent AS rc6_q2_term_pct
      ,gr_wide.rc06_rt3_term_grade_percent AS rc6_q3_term_pct
      ,gr_wide.rc06_rt4_term_grade_percent AS rc6_q4_term_pct            
      ,gr_wide.rc06_e1_grade_percent AS rc6_exam
      ,gr_wide.rc06_e2_grade_percent AS rc6_exam2
      ,gr_wide.rc06_y1_grade_percent AS rc6_y1_pct
      ,gr_wide.rc06_y1_grade_letter AS rc6_y1_ltr
      ,gr_wide.rc06_credit_hours AS rc6_credit_hours_Y1      

      /*--rc07--*/
      ,gr_wide.rc07_course_name AS rc7_course_name
      ,gr_wide.rc07_teacher_name AS rc7_teacher_name
      ,LEFT(rc07_teacher_name, (CHARINDEX(',', rc07_teacher_name) - 1)) AS rc7_teacher_last
      ,gr_wide.rc07_rt1_term_grade_percent AS rc7_q1_term_pct
      ,gr_wide.rc07_rt2_term_grade_percent AS rc7_q2_term_pct
      ,gr_wide.rc07_rt3_term_grade_percent AS rc7_q3_term_pct
      ,gr_wide.rc07_rt4_term_grade_percent AS rc7_q4_term_pct     
      ,gr_wide.rc07_e1_grade_percent AS rc7_exam
      ,gr_wide.rc07_e2_grade_percent AS rc7_exam2       
      ,gr_wide.rc07_y1_grade_percent AS rc7_y1_pct
      ,gr_wide.rc07_y1_grade_letter AS rc7_y1_ltr
      ,gr_wide.rc07_credit_hours AS rc7_credit_hours_Y1      
      
      /*--rc08--*/
      ,gr_wide.rc08_course_name AS rc8_course_name
      ,gr_wide.rc08_teacher_name AS rc8_teacher_name
      ,LEFT(rc08_teacher_name, (CHARINDEX(',', rc08_teacher_name) - 1)) AS rc8_teacher_last
      ,gr_wide.rc08_rt1_term_grade_percent AS rc8_q1_term_pct
      ,gr_wide.rc08_rt2_term_grade_percent AS rc8_q2_term_pct
      ,gr_wide.rc08_rt3_term_grade_percent AS rc8_q3_term_pct
      ,gr_wide.rc08_rt4_term_grade_percent AS rc8_q4_term_pct            
      ,gr_wide.rc08_e1_grade_percent AS rc8_exam
      ,gr_wide.rc08_e2_grade_percent AS rc8_exam2
      ,gr_wide.rc08_y1_grade_percent AS rc8_y1_pct
      ,gr_wide.rc08_y1_grade_letter AS rc8_y1_ltr
      ,gr_wide.rc08_credit_hours AS rc8_credit_hours_Y1        

      /*--rc09--*/
      ,gr_wide.rc09_course_name AS rc9_course_name
      ,gr_wide.rc09_teacher_name AS rc9_teacher_name
      ,LEFT(rc09_teacher_name, (CHARINDEX(',', rc09_teacher_name) - 1)) AS rc9_teacher_last
      ,gr_wide.rc09_rt1_term_grade_percent AS rc9_q1_term_pct
      ,gr_wide.rc09_rt2_term_grade_percent AS rc9_q2_term_pct
      ,gr_wide.rc09_rt3_term_grade_percent AS rc9_q3_term_pct
      ,gr_wide.rc09_rt4_term_grade_percent AS rc9_q4_term_pct            
      ,gr_wide.rc09_e1_grade_percent AS rc9_exam
      ,gr_wide.rc09_e2_grade_percent AS rc9_exam2
      ,gr_wide.rc09_y1_grade_percent AS rc9_y1_pct
      ,gr_wide.rc09_y1_grade_letter AS rc9_y1_ltr
      ,gr_wide.rc09_credit_hours AS rc9_credit_hours_Y1      
      
      /*--rc10--*/
      ,gr_wide.rc10_course_name AS rc10_course_name
      ,gr_wide.rc10_teacher_name AS rc10_teacher_name
      ,LEFT(rc10_teacher_name, (CHARINDEX(',', rc10_teacher_name) - 1)) AS rc10_teacher_last
      ,gr_wide.rc10_rt1_term_grade_percent AS rc10_q1_term_pct
      ,gr_wide.rc10_rt2_term_grade_percent AS rc10_q2_term_pct
      ,gr_wide.rc10_rt3_term_grade_percent AS rc10_q3_term_pct
      ,gr_wide.rc10_rt4_term_grade_percent AS rc10_q4_term_pct
      ,gr_wide.rc10_e1_grade_percent AS rc10_exam
      ,gr_wide.rc10_e2_grade_percent AS rc10_exam2            
      ,gr_wide.rc10_y1_grade_percent AS rc10_y1_pct
      ,gr_wide.rc10_y1_grade_letter AS rc10_y1_ltr
      ,gr_wide.rc10_credit_hours AS rc10_credit_hours_Y1      

      /* Current component averages */
      /*--H--*/
      ,ele.rc01_h_cur AS rc1_cur_hw_pct
      ,ele.rc02_h_cur AS rc2_cur_hw_pct
      ,ele.rc03_h_cur AS rc3_cur_hw_pct
      ,ele.rc04_h_cur AS rc4_cur_hw_pct
      ,ele.rc05_h_cur AS rc5_cur_hw_pct
      ,ele.rc06_h_cur AS rc6_cur_hw_pct
      ,ele.rc07_h_cur AS rc7_cur_hw_pct
      ,ele.rc08_h_cur AS rc8_cur_hw_pct
      ,ele.rc09_h_cur AS rc9_cur_hw_pct
      ,ele.rc10_h_cur AS rc10_cur_hw_pct      
      /*--A--*/
      ,ele.rc01_a_cur AS rc1_cur_a_pct
      ,ele.rc02_a_cur AS rc2_cur_a_pct
      ,ele.rc03_a_cur AS rc3_cur_a_pct
      ,ele.rc04_a_cur AS rc4_cur_a_pct
      ,ele.rc05_a_cur AS rc5_cur_a_pct
      ,ele.rc06_a_cur AS rc6_cur_a_pct
      ,ele.rc07_a_cur AS rc7_cur_a_pct
      ,ele.rc08_a_cur AS rc8_cur_a_pct
      ,ele.rc09_a_cur AS rc9_cur_a_pct
      ,ele.rc10_a_cur AS rc10_cur_a_pct
      /*--CW--*/
      ,ele.rc01_c_cur AS rc1_cur_cw_pct
      ,ele.rc02_c_cur AS rc2_cur_cw_pct
      ,ele.rc03_c_cur AS rc3_cur_cw_pct
      ,ele.rc04_c_cur AS rc4_cur_cw_pct
      ,ele.rc05_c_cur AS rc5_cur_cw_pct
      ,ele.rc06_c_cur AS rc6_cur_cw_pct
      ,ele.rc07_c_cur AS rc7_cur_cw_pct
      ,ele.rc08_c_cur AS rc8_cur_cw_pct
      ,ele.rc09_c_cur AS rc9_cur_cw_pct
      ,ele.rc10_c_cur AS rc10_cur_cw_pct
      /*--P--*/
      ,ele.rc01_p_cur AS rc1_cur_p_pct
      ,ele.rc02_p_cur AS rc2_cur_p_pct
      ,ele.rc03_p_cur AS rc3_cur_p_pct
      ,ele.rc04_p_cur AS rc4_cur_p_pct
      ,ele.rc05_p_cur AS rc5_cur_p_pct
      ,ele.rc06_p_cur AS rc6_cur_p_pct
      ,ele.rc07_p_cur AS rc7_cur_p_pct
      ,ele.rc08_p_cur AS rc8_cur_p_pct
      ,ele.rc09_p_cur AS rc9_cur_p_pct
      ,ele.rc10_p_cur AS rc10_cur_p_pct      

      /* attendance by class */      
      ,ccatt.rc01_current_absences AS rc1_current_absences
      ,ccatt.rc02_current_absences AS rc2_current_absences
      ,ccatt.rc03_current_absences AS rc3_current_absences
      ,ccatt.rc04_current_absences AS rc4_current_absences
      ,ccatt.rc05_current_absences AS rc5_current_absences
      ,ccatt.rc06_current_absences AS rc6_current_absences
      ,ccatt.rc07_current_absences AS rc7_current_absences
      ,ccatt.rc08_current_absences AS rc8_current_absences
      ,ccatt.rc09_current_absences AS rc9_current_absences
      ,ccatt.rc10_current_absences AS rc10_current_absences
      ,ccatt.rc01_current_tardies AS rc1_current_tardies
      ,ccatt.rc02_current_tardies AS rc2_current_tardies
      ,ccatt.rc03_current_tardies AS rc3_current_tardies
      ,ccatt.rc04_current_tardies AS rc4_current_tardies
      ,ccatt.rc05_current_tardies AS rc5_current_tardies
      ,ccatt.rc06_current_tardies AS rc6_current_tardies
      ,ccatt.rc07_current_tardies AS rc7_current_tardies
      ,ccatt.rc08_current_tardies AS rc8_current_tardies
      ,ccatt.rc09_current_tardies AS rc9_current_tardies
      ,ccatt.rc10_current_tardies AS rc10_current_tardies
      
      /* Accelerated Reader */      
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_yr.words),1),'.00','') AS words_read_yr
      ,ar_yr.points AS points_yr
      ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,ar_curr.words),1),'.00','') AS words_read_cur_term      
      ,ar_curr.points AS points_curterm      

      /* Lexile */
      /* Base */
      ,COALESCE(REPLACE(map_base.lexile_score, 'BR', 'Beginning Reader'), REPLACE(lex_base.RITtoReadingScore, 'BR', 'Beginning Reader')) AS lexile_base      
      ,COALESCE(map_base.testpercentile, lex_base.TestPercentile) AS lex_base_pct        
      /* Current */
      ,COALESCE(REPLACE(lex_curr.RITtoReadingScore, 'BR', 'Beginning Reader'), REPLACE(map_base.lexile_score, 'BR', 'Beginning Reader')) AS lexile_curr       
      ,COALESCE(lex_curr.TestPercentile, map_base.testpercentile) AS lex_curr_pct

      /* comments */
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
      ,comm.advisor_comment
    
      /* Discipline */
      /* Merits */      
      ,merits.n_logs_yr AS teacher_merits_yr
      ,pw.perfect_week_merits_yr AS perfect_week_yr
      ,ISNULL(merits.n_logs_yr,0) + ISNULL(pw.perfect_week_merits_yr,0) AS total_merits_yr      
      ,merits.n_logs_term AS teacher_merits_curr
      ,pw.perfect_week_merits_term AS perfect_week_curr
      ,ISNULL(merits.n_logs_term,0) + ISNULL(pw.perfect_week_merits_term,0) AS total_merits_curr      
      /* Demerits */      
      ,demerits.n_logs_yr AS total_demerits_y1      
      ,demerits.n_logs_term AS total_demerits_cur

FROM KIPP_NJ..COHORT$identifiers_long#static roster WITH (NOLOCK)
CROSS JOIN curterm WITH(NOLOCK)  

/* ATTENDANCE */
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static att_counts WITH (NOLOCK)
  ON roster.studentid = att_counts.studentid
 AND roster.year = att_counts.academic_year
 AND curterm.alt_name = att_counts.term
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$cc_attendance_totals_wide_course ccatt WITH(NOLOCK)
  ON roster.student_number = ccatt.student_number
 AND curterm.alt_name = ccatt.term
   
/* GRADES & GPA */
LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_wide_course#static gr_wide WITH(NOLOCK)
  ON roster.student_number = gr_wide.student_number
 AND roster.year = gr_wide.academic_year
 AND curterm.alt_name = gr_wide.term
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide_course#static ele WITH(NOLOCK)
  ON roster.student_number = ele.student_number
 AND roster.year = ele.academic_year
 AND curterm.time_per_name = ele.reporting_term
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static nca_gpa WITH (NOLOCK)
  ON roster.student_number = nca_gpa.student_number
 AND roster.year = nca_gpa.academic_year
 AND curterm.alt_name = nca_gpa.term
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_cumulative#static gpa_cumulative WITH (NOLOCK)
  ON roster.studentid = gpa_cumulative.studentid
 AND roster.schoolid = gpa_cumulative.schoolid

/* MERITS & DEMERITS */
LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_long merits WITH(NOLOCK)
  ON roster.student_number = merits.student_number
 AND roster.year = merits.academic_year
 AND curterm.alt_name = merits.term
 AND merits.logtypeid = 3023
LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_long demerits WITH(NOLOCK)
  ON roster.student_number = demerits.student_number
 AND roster.year = demerits.academic_year
 AND curterm.alt_name = demerits.term
 AND demerits.logtypeid = 3223
LEFT OUTER JOIN KIPP_NJ..DISC$perfect_weeks_long pw WITH(NOLOCK)
  ON roster.student_number = pw.student_number
 AND roster.year = pw.academic_year
 AND curterm.time_per_name = pw.rt

/* ACCELERATED READER */
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.studentid = ar_yr.studentid 
 AND roster.year = ar_yr.academic_year
 AND ar_yr.time_period_name = 'Year'  
LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.studentid = ar_curr.studentid 
 AND roster.year = ar_curr.academic_year
 AND curterm.time_per_name = ar_curr.time_period_name

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