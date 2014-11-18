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
      ,nca_GPA.GPA_q1 AS GPA_Q1
      ,nca_GPA.GPA_q2 AS GPA_Q2
      ,nca_GPA.GPA_q3 AS GPA_Q3
      ,nca_GPA.GPA_q4 AS GPA_Q4
      ,nca_GPA.GPA_S1
      ,nca_GPA.GPA_S2
      ,nca_GPA.GPA_y1 AS GPA_Y1      
      --cumulative GPA
      ,GPA_cum.cumulative_Y1_GPA AS GPA_cum
      --,GPA_cumulative.audit_trail AS cumulative_GPA_audit_trail

--Attendance      
      --absences
      ,att.Y1_ABS_ALL AS Abs_Y1
      ,ROUND(att_Pct.y1_att_Pct_total,0) AS Abs_Y1_Pct      
      ,att.RT1_abs_all AS Abs_Q1
      ,att.RT2_abs_all AS Abs_Q2
      ,att.RT3_abs_all AS Abs_Q3
      ,att.RT4_abs_all AS Abs_Q4
      ,ROUND(att_Pct.rt1_att_Pct_total,0) AS Abs_Q1_Pct
      ,ROUND(att_Pct.rt2_att_Pct_total,0) AS Abs_Q2_Pct
      ,ROUND(att_Pct.rt3_att_Pct_total,0) AS Abs_Q3_Pct
      ,ROUND(att_Pct.rt4_att_Pct_total,0) AS Abs_Q4_Pct      
      --tardies
      ,att.Y1_T_ALL AS T_Y1
      ,ROUND(att_Pct.y1_tardy_Pct_total,0) AS T_Y1_Pct
      ,att.RT1_t_all AS T_Q1
      ,att.RT2_t_all AS T_Q2
      ,att.RT3_t_all AS T_Q3
      ,att.RT4_t_all AS T_Q4
      ,ROUND(att_Pct.rt1_tardy_Pct_total,0) AS T_Q1_Pct
      ,ROUND(att_Pct.rt2_tardy_Pct_total,0) AS T_Q2_Pct
      ,ROUND(att_Pct.rt3_tardy_Pct_total,0) AS T_Q3_Pct
      ,ROUND(att_Pct.rt4_tardy_Pct_total,0) AS T_Q4_Pct

--Behavior      
      --merits
      ,merits.total_merits_y1 AS M_Y1_total
      ,merits.teacher_merits_y1 AS M_Y1_teacher
      ,merits.perfect_week_merits_y1 AS M_Y1_perfect
      ,merits.total_merits_rt1 AS M_Q1_total
      ,merits.total_merits_rt2 AS M_Q2_total
      ,merits.total_merits_rt3 AS M_Q3_total
      ,merits.total_merits_rt4 AS M_Q4_total            
      --merits by type
      ,merits.teacher_merits_rt1 AS M_Q1_teacher
      ,merits.perfect_week_merits_rt1 AS M_Q1_perfect
      ,merits.teacher_merits_rt2 AS M_Q2_teacher
      ,merits.perfect_week_merits_rt2 AS M_Q2_perfect
      ,merits.teacher_merits_rt3 AS M_Q3_teacher
      ,merits.perfect_week_merits_rt3 AS M_Q3_perfect
      ,merits.teacher_merits_rt4 AS M_Q4_teacher
      ,merits.perfect_week_merits_rt4 AS M_Q4_perfect
      --demerits      
      ,merits.total_demerits_y1 AS Demerits_Y1
      ,merits.total_demerits_rt1 AS Demerits_Q1
      ,merits.total_demerits_rt2 AS Demerits_Q2
      ,merits.total_demerits_rt3 AS Demerits_Q3
      ,merits.total_demerits_rt4 AS Demerits_Q4
      ,merits.detention_y1 AS Detentions_Y1
      ,merits.detention_rt1 AS Detentions_Q1
      ,merits.detention_rt2 AS Detentions_Q2
      ,merits.detention_rt3 AS Detentions_Q3
      ,merits.detention_rt4 AS Detentions_Q4

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
LEFT OUTER JOIN DISC$culture_counts#NCA merits WITH (NOLOCK)
  ON s.studentid = merits.studentid
LEFT OUTER JOIN ATT_MEM$attendance_counts att WITH (NOLOCK)
  ON s.studentid = att.studentid
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON s.studentid = att_pct.studentid
LEFT OUTER JOIN GRADES$wide_all#NCA#static gr_wide WITH (NOLOCK)
  ON s.studentid = gr_wide.studentid
LEFT OUTER JOIN GPA$detail#NCA nca_GPA WITH (NOLOCK)
  ON s.studentid = nca_GPA.studentid
LEFT OUTER JOIN GPA$cumulative GPA_cum WITH (NOLOCK)
  ON s.studentid = GPA_cum.studentid
 AND s.schoolid = GPA_cum.schoolid                 
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
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers lex_cur WITH (NOLOCK)
  ON s.studentid = lex_cur.ps_studentid
 AND lex_cur.measurementscale  = 'Reading'
 AND lex_cur.map_year_academic = dbo.fn_Global_Academic_Year()
 AND lex_cur.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers lex_base WITH (NOLOCK)
  ON s.studentid = lex_base.ps_studentid
 AND lex_base.measurementscale  = 'Reading'
 AND lex_base.map_year_academic = dbo.fn_Global_Academic_Year()
 AND lex_base.rn_base = 1
WHERE s.schoolid = 73253
  AND s.enroll_status = 0
  AND s.year = dbo.fn_Global_Academic_Year()
  AND s.rn = 1