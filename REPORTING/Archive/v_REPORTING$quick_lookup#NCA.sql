USE KIPP_NJ
GO

ALTER VIEW REPORTING$quick_lookup#NCA AS

SELECT s.student_number AS SN
      ,s.lastfirst AS Name
      ,s.grade_level AS Gr
      ,s.Advisor
      ,s.Gender
      ,s.SPEDLEP AS SPED

      --GPA      
      ,nca_gpa.GPA_term_RT1 AS GPA_Q1
      ,nca_GPA.GPA_term_RT2 AS GPA_Q2
      ,nca_GPA.GPA_term_RT3 AS GPA_Q3
      ,nca_GPA.GPA_term_RT4 AS GPA_Q4
      ,nca_GPA.GPA_semester_S1 AS GPA_S1
      ,nca_GPA.GPA_semester_S2 AS GPA_S2
      ,nca_GPA.GPA_y1_CUR AS GPA_Y1      
      --cumulative GPA
      ,gpa_cumulative.cumulative_Y1_gpa AS GPA_cum
      

--Attendance      
      --absences
      ,att.ABS_all_counts_yr AS Abs_Y1
      ,ROUND(((att.MEM_counts_yr - att.ABS_all_counts_yr) / att.MEM_counts_yr) * 100, 0) AS Abs_Y1_Pct      
      ,att_wide.ABS_all_counts_term_RT1 AS Abs_Q1
      ,att_wide.ABS_all_counts_term_RT2 AS Abs_Q2
      ,att_wide.ABS_all_counts_term_RT3 AS Abs_Q3
      ,att_wide.ABS_all_counts_term_RT4 AS Abs_Q4
      ,ROUND(((att_wide.MEM_counts_term_RT1 - att_wide.ABS_all_counts_term_RT1) / att_wide.MEM_counts_term_RT1) * 100, 0) AS Abs_Q1_Pct
      ,ROUND(((att_wide.MEM_counts_term_RT2 - att_wide.ABS_all_counts_term_RT2) / att_wide.MEM_counts_term_RT2) * 100, 0) AS Abs_Q2_Pct
      ,ROUND(((att_wide.MEM_counts_term_RT3 - att_wide.ABS_all_counts_term_RT3) / att_wide.MEM_counts_term_RT3) * 100, 0) AS Abs_Q3_Pct
      ,ROUND(((att_wide.MEM_counts_term_RT4 - att_wide.ABS_all_counts_term_RT4) / att_wide.MEM_counts_term_RT4) * 100, 0) AS Abs_Q4_Pct
      --tardies
      ,att.TDY_ALL_counts_yr AS T_Y1
      ,ROUND((att.TDY_all_counts_yr / att.MEM_counts_yr) * 100, 0) AS T_Y1_Pct
      ,att_wide.TDY_all_counts_term_RT1 AS T_Q1
      ,att_wide.TDY_all_counts_term_RT2 AS T_Q2
      ,att_wide.TDY_all_counts_term_RT3 AS T_Q3
      ,att_wide.TDY_all_counts_term_RT4 AS T_Q4
      ,ROUND((att_wide.TDY_all_counts_term_RT1 / att_wide.MEM_counts_term_RT1) * 100, 0) AS T_Q1_Pct
      ,ROUND((att_wide.TDY_all_counts_term_RT2 / att_wide.MEM_counts_term_RT2) * 100, 0) AS T_Q2_Pct
      ,ROUND((att_wide.TDY_all_counts_term_RT3 / att_wide.MEM_counts_term_RT3) * 100, 0) AS T_Q3_Pct
      ,ROUND((att_wide.TDY_all_counts_term_RT4 / att_wide.MEM_counts_term_RT4) * 100, 0) AS T_Q4_Pct

--Behavior      
      /* merits */
      ,m_wide.n_logs_y1 + p_wide.n_logs_y1 AS M_Y1_total
      ,m_wide.n_logs_y1 AS M_Y1_teacher
      ,p_wide.n_logs_Y1 AS M_Y1_perfect
      ,m_wide.n_logs_RT1 + p_wide.n_logs_RT1 AS M_Q1_total
      ,m_wide.n_logs_RT2 + p_wide.n_logs_RT2 AS M_Q2_total
      ,m_wide.n_logs_RT3 + p_wide.n_logs_RT3 AS M_Q3_total
      ,m_wide.n_logs_RT4 + p_wide.n_logs_RT4 AS M_Q4_total
      /* merits by type */
      ,m_wide.n_logs_RT1 AS M_Q1_teacher
      ,p_wide.n_logs_RT1 AS M_Q1_perfect
      ,m_wide.n_logs_RT2 AS M_Q2_teacher
      ,p_wide.n_logs_RT2 AS M_Q2_perfect
      ,m_wide.n_logs_RT3 AS M_Q3_teacher
      ,p_wide.n_logs_RT3 AS M_Q3_perfect
      ,m_wide.n_logs_RT4 AS M_Q4_teacher
      ,p_wide.n_logs_RT4 AS M_Q4_perfect
      /* demerits */
      ,d_wide.n_logs_y1 AS Demerits_Y1
      ,d_wide.n_logs_RT1 AS Demerits_Q1
      ,d_wide.n_logs_RT2 AS Demerits_Q2
      ,d_wide.n_logs_RT3 AS Demerits_Q3
      ,d_wide.n_logs_RT4 AS Demerits_Q4
      /* detentions */
      ,dt_wide.n_logs_Y1 AS Detentions_Y1
      ,dt_wide.n_logs_RT1 AS Detentions_Q1
      ,dt_wide.n_logs_RT2 AS Detentions_Q2
      ,dt_wide.n_logs_RT3 AS Detentions_Q3
      ,dt_wide.n_logs_RT4 AS Detentions_Q4

--Reading
      ,ar_Q1.points AS AR_Pts_Q1
      ,ar_q2.points AS AR_Pts_Q2
      ,ar_q3.points AS AR_Pts_Q3
      ,ar_q4.points AS AR_Pts_Q4
      ,ar_yr.points AS AR_Pts_Yr
      ,ar_Q1.words AS AR_Words_Q1
      ,ar_q2.words AS AR_Words_Q2
      ,ar_q3.words AS AR_Words_Q3      
      ,ar_q4.words AS AR_Words_Q4
      ,ar_yr.words AS AR_Words_Yr
      --Lexile
      ,lex_base.rittoreadingscore AS Lexile_base
      ,lex_cur.rittoreadingscore AS Lexile_current
      --,lex_base.testpercentile AS map_pctl_base
      --,lex_cur.testpercentile AS map_pctl_curterm

FROM COHORT$identifiers_long#static s WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates curterm WITH(NOLOCK)
  ON s.schoolid = curterm.schoolid
 AND s.year = curterm.academic_year 
 AND CONVERT(DATE,GETDATE()) BETWEEN curterm.start_date AND curterm.end_date
 AND curterm.identifier = 'RT' 

/* MERITS & DEMERITS */
LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_wide#static m_wide WITH(NOLOCK)
  ON s.student_number = m_wide.student_number
 AND s.year = m_wide.academic_year 
 AND m_wide.logtypeid = 3023
LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_wide#static d_wide WITH(NOLOCK)
  ON s.student_number = d_wide.student_number
 AND s.year = d_wide.academic_year 
 AND d_wide.logtypeid = 3223
LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_wide#static p_wide WITH(NOLOCK)
  ON s.student_number = p_wide.student_number
 AND s.year = p_wide.academic_year 
 AND p_wide.logtype = 'Perfect Weeks'
LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_wide#static dt_wide WITH(NOLOCK)
  ON s.student_number = dt_wide.student_number
 AND s.year = dt_wide.academic_year 
 AND dt_wide.logtypeid = -100000

/* ATTENDANCE */
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static att WITH(NOLOCK)
  ON s.studentid = att.studentid
 AND s.year = att.academic_year
 AND curterm.alt_name = att.term
LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_wide#static att_wide WITH(NOLOCK)
  ON s.studentid = att_wide.studentid
 AND s.year = att_wide.academic_year

/* GRADES & GPA */
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_wide#static nca_gpa WITH (NOLOCK)
  ON s.student_number = nca_gpa.student_number
 AND s.year = nca_gpa.academic_year
 AND curterm.alt_name = nca_gpa.term
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_cumulative#static gpa_cumulative WITH (NOLOCK)
  ON s.studentid = gpa_cumulative.studentid
 AND s.schoolid = gpa_cumulative.schoolid
          
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON s.studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q1 WITH (NOLOCK)
  ON s.studentid = ar_q1.studentid 
 AND ar_q1.time_period_name = 'RT1'
 AND ar_q1.yearid = dbo.fn_Global_Term_Id() 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q2 WITH (NOLOCK)
  ON s.studentid = ar_q2.studentid
 AND ar_q2.time_period_name = 'RT2'
 AND ar_q2.yearid = dbo.fn_Global_Term_Id() 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q3 WITH (NOLOCK)
  ON s.studentid = ar_q3.studentid
 AND ar_q3.time_period_name = 'RT3'
 AND ar_q3.yearid = dbo.fn_Global_Term_Id() 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q4 WITH (NOLOCK)
  ON s.studentid = ar_q4.studentid
 AND ar_q4.time_period_name = 'RT4'
 AND ar_q4.yearid = dbo.fn_Global_Term_Id()                    

LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_cur WITH (NOLOCK)
  ON s.student_number = lex_cur.student_number
 AND s.year = lex_cur.academic_year
 AND lex_cur.measurementscale  = 'Reading' 
 AND lex_cur.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_base WITH (NOLOCK)
  ON s.student_number = lex_base.student_number
 AND s.year = lex_base.academic_year
 AND lex_base.measurementscale  = 'Reading' 
 AND lex_base.rn_base = 1

WHERE s.schoolid = 73253
  AND s.enroll_status = 0
  AND s.year = dbo.fn_Global_Academic_Year()
  AND s.rn = 1