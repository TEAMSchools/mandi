USE KIPP_NJ
GO

ALTER VIEW REPORTING$quick_lookup#NCA AS

SELECT s.student_number AS SN
      ,s.lastfirst AS Name
      ,s.grade_level AS Gr
      ,cs.Advisor
      ,s.Gender
      ,cs.SPEDLEP AS SPED

      --GPA      
      ,nca_GPA.GPA_q1 AS GPA_Q1
      ,nca_GPA.GPA_q2 AS GPA_Q2
      ,nca_GPA.GPA_q3 AS GPA_Q3
      ,nca_GPA.GPA_q4 AS GPA_Q4
      ,nca_GPA.GPA_y1 AS GPA_Y1      
      --cumulative GPA
      ,GPA_cum.cumulative_Y1_GPA AS GPA_cum
      --,GPA_cumulative.audit_trail AS cumulative_GPA_audit_trail

--Attendance      
      --absences
      ,att.absences_total AS Abs_Y1
      ,ROUND(att_Pct.y1_att_Pct_total,0) AS Abs_Y1_Pct      
      ,att.RT1_absences_total AS Abs_Q1
      ,att.RT2_absences_total AS Abs_Q2
      ,att.RT3_absences_total AS Abs_Q3
      ,att.RT4_absences_total AS Abs_Q4
      ,ROUND(att_Pct.rt1_att_Pct_total,0) AS Abs_Q1_Pct
      ,ROUND(att_Pct.rt2_att_Pct_total,0) AS Abs_Q2_Pct
      ,ROUND(att_Pct.rt3_att_Pct_total,0) AS Abs_Q3_Pct
      ,ROUND(att_Pct.rt4_att_Pct_total,0) AS Abs_Q4_Pct      
      --tardies
      ,att.tardies_total AS T_Y1
      ,ROUND(att_Pct.y1_tardy_Pct_total,0) AS T_Y1_Pct
      ,att.RT1_tardies_total AS T_Q1
      ,att.RT2_tardies_total AS T_Q2
      ,att.RT3_tardies_total AS T_Q3
      ,att.RT4_tardies_total AS T_Q4
      ,ROUND(att_Pct.rt1_tardy_Pct_total,0) AS T_Q1_Pct
      ,ROUND(att_Pct.rt2_tardy_Pct_total,0) AS T_Q2_Pct
      ,ROUND(att_Pct.rt3_tardy_Pct_total,0) AS T_Q3_Pct
      ,ROUND(att_Pct.rt4_tardy_Pct_total,0) AS T_Q4_Pct

--Behavior      
      --merits
      ,merits.total_merits AS M_Y1_total
      ,merits.teacher_merits AS M_Y1_teacher
      ,merits.perfect_week_merits AS M_Y1_perfect
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
      ,merits.total_tier1_demerits AS Demerits_Y1
      ,merits.tier1_demerits_rt1 AS Demerits_Q1
      ,merits.tier1_demerits_rt2 AS Demerits_Q2
      ,merits.tier1_demerits_rt3 AS Demerits_Q3
      ,merits.tier1_demerits_rt4 AS Demerits_Q4
      ,dcounts.detentions AS Detentions_Y1
      ,dcounts.rt1_detentions AS Detentions_Q1
      ,dcounts.rt2_detentions AS Detentions_Q2
      ,dcounts.rt3_detentions AS Detentions_Q3
      ,dcounts.rt4_detentions AS Detentions_Q4

--Reading
      ,ar.AR_Pts_Q1
      ,ar.AR_Pts_Q2
      ,ar.AR_Pts_Q3
      ,ar.AR_Pts_Q4
      ,ar.AR_Pts_Yr
      ,ar.AR_Words_Q1
      ,ar.AR_Words_Q2
      ,ar.AR_Words_Q3      
      ,ar.AR_Words_Q4
      ,ar.AR_Words_Yr
      --Lexile
      ,lex_base.rittoreadingscore AS Lexile_base
      ,lex_cur.rittoreadingscore AS Lexile_current
      --,lex_base.testpercentile AS map_pctl_base
      --,lex_cur.testpercentile AS map_pctl_curterm

/*      
      ,null AS Grades
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last
      ,gr_wide.rc1_y1 AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      ,gr_wide.rc2_course_name
      ,gr_wide.rc2_teacher_last
      ,gr_wide.rc2_y1 AS rc2_y1_pct
      ,gr_wide.rc2_y1_ltr      
      ,gr_wide.rc3_course_name
      ,gr_wide.rc3_teacher_last
      ,gr_wide.rc3_y1 AS rc3_y1_pct
      ,gr_wide.rc3_y1_ltr      
      ,gr_wide.rc4_course_name
      ,gr_wide.rc4_teacher_last
      ,gr_wide.rc4_y1 AS rc4_y1_pct
      ,gr_wide.rc4_y1_ltr      
      ,gr_wide.rc5_course_name
      ,gr_wide.rc5_teacher_last
      ,gr_wide.rc5_y1 AS rc5_y1_pct
      ,gr_wide.rc5_y1_ltr      
      ,gr_wide.rc6_course_name
      ,gr_wide.rc6_teacher_last
      ,gr_wide.rc6_y1 AS rc6_y1_pct
      ,gr_wide.rc6_y1_ltr      
      ,gr_wide.rc7_course_name
      ,gr_wide.rc7_teacher_last
      ,gr_wide.rc7_y1 AS rc7_y1_pct
      ,gr_wide.rc7_y1_ltr      
      ,gr_wide.rc8_course_name
      ,gr_wide.rc8_teacher_last
      ,gr_wide.rc8_y1 AS rc8_y1_pct
      ,gr_wide.rc8_y1_ltr      
      ,gr_wide.rc9_course_name
      ,gr_wide.rc9_teacher_last
      ,gr_wide.rc9_y1 AS rc9_y1_pct
      ,gr_wide.rc9_y1_ltr      
      ,gr_wide.rc10_course_name
      ,gr_wide.rc10_teacher_last
      ,gr_wide.rc10_y1 AS rc10_y1_pct
      ,gr_wide.rc10_y1_ltr
      ,gr_wide.rc1_h1  AS rc1_cur_hw_pct
      ,gr_wide.rc2_h1  AS rc2_cur_hw_pct
      ,gr_wide.rc3_h1  AS rc3_cur_hw_pct
      ,gr_wide.rc4_h1  AS rc4_cur_hw_pct
      ,gr_wide.rc5_h1  AS rc5_cur_hw_pct
      ,gr_wide.rc6_h1  AS rc6_cur_hw_pct
      ,gr_wide.rc7_h1  AS rc7_cur_hw_pct
      ,gr_wide.rc8_h1  AS rc8_cur_hw_pct
      ,gr_wide.rc9_h1  AS rc9_cur_hw_pct
      ,gr_wide.rc10_h1 AS rc10_cur_hw_pct      
      ,gr_wide.rc1_a1   AS rc1_cur_a_pct
      ,gr_wide.rc2_a1   AS rc2_cur_a_pct
      ,gr_wide.rc3_a1   AS rc3_cur_a_pct
      ,gr_wide.rc4_a1   AS rc4_cur_a_pct
      ,gr_wide.rc5_a1   AS rc5_cur_a_pct
      ,gr_wide.rc6_a1   AS rc6_cur_a_pct
      ,gr_wide.rc7_a1   AS rc7_cur_a_pct
      ,gr_wide.rc8_a1   AS rc8_cur_a_pct
      ,gr_wide.rc9_a1   AS rc9_cur_a_pct
      ,gr_wide.rc10_a1  AS rc10_cur_a_pct
      ,gr_wide.rc1_c1  AS rc1_cur_cw_pct
      ,gr_wide.rc2_c1  AS rc2_cur_cw_pct
      ,gr_wide.rc3_c1  AS rc3_cur_cw_pct
      ,gr_wide.rc4_c1  AS rc4_cur_cw_pct
      ,gr_wide.rc5_c1  AS rc5_cur_cw_pct
      ,gr_wide.rc6_c1  AS rc6_cur_cw_pct
      ,gr_wide.rc7_c1  AS rc7_cur_cw_pct
      ,gr_wide.rc8_c1  AS rc8_cur_cw_pct
      ,gr_wide.rc9_c1  AS rc9_cur_cw_pct
      ,gr_wide.rc10_c1 AS rc10_cur_cw_pct      
      ,gr_wide.rc1_p1  AS rc1_cur_p_pct
      ,gr_wide.rc2_p1  AS rc2_cur_p_pct
      ,gr_wide.rc3_p1  AS rc3_cur_p_pct
      ,gr_wide.rc4_p1  AS rc4_cur_p_pct
      ,gr_wide.rc5_p1  AS rc5_cur_p_pct
      ,gr_wide.rc6_p1  AS rc6_cur_p_pct
      ,gr_wide.rc7_p1  AS rc7_cur_p_pct
      ,gr_wide.rc8_p1  AS rc8_cur_p_pct
      ,gr_wide.rc9_p1  AS rc9_cur_p_pct
      ,gr_wide.rc10_p1 AS rc10_cur_p_pct
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
--*/      
FROM STUDENTS s WITH (NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
  ON s.id = cs.studentid
LEFT OUTER JOIN DISC$merits_demerits_count#NCA merits WITH (NOLOCK)
  ON s.id = merits.studentid
LEFT OUTER JOIN DISC$counts_wide dcounts WITH (NOLOCK)
  ON s.ID = dcounts.base_studentid
LEFT OUTER JOIN ATT_MEM$attendance_counts att WITH (NOLOCK)
  ON s.id = att.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON s.id = att_pct.id
LEFT OUTER JOIN GRADES$wide_all#NCA gr_wide WITH (NOLOCK)
  ON s.id = gr_wide.studentid
LEFT OUTER JOIN GPA$detail#NCA nca_GPA WITH (NOLOCK)
  ON s.id = nca_GPA.studentid
LEFT OUTER JOIN GPA$cumulative GPA_cum WITH (NOLOCK)
  ON s.id = GPA_cum.studentid
 AND s.schoolid = GPA_cum.schoolid
LEFT OUTER JOIN (
                 SELECT s.id
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
                       ,ROW_NUMBER() OVER
                          (PARTITION BY s.lastfirst
                           ORDER BY s.lastfirst) AS rn
                 FROM STUDENTS s WITH (NOLOCK)
                 LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
                   ON s.id = ar_yr.studentid 
                  AND ar_yr.time_period_name = 'Year'
                  AND ar_yr.yearid = dbo.fn_Global_Term_Id()
                 LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q1 WITH (NOLOCK)
                   ON s.id = ar_q1.studentid 
                  AND ar_q1.time_period_name = 'RT1'
                  AND ar_q1.yearid = dbo.fn_Global_Term_Id() 
                 LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q2 WITH (NOLOCK)
                   ON s.id = ar_q2.studentid
                  AND ar_q2.time_period_name = 'RT2'
                  AND ar_q2.yearid = dbo.fn_Global_Term_Id() 
                 LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q3 WITH (NOLOCK)
                   ON s.id = ar_q3.studentid
                  AND ar_q3.time_period_name = 'RT3'
                  AND ar_q3.yearid = dbo.fn_Global_Term_Id() 
                 LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q4 WITH (NOLOCK)
                   ON s.id = ar_q4.studentid
                  AND ar_q4.time_period_name = 'RT4'
                  AND ar_q4.yearid = dbo.fn_Global_Term_Id() 
                 WHERE s.SCHOOLID = 73253
                   AND s.ENROLL_STATUS = 0
                ) ar
  ON s.id = ar.id
 AND ar.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers lex_cur WITH (NOLOCK)
  ON s.id = lex_cur.ps_studentid
 AND lex_cur.measurementscale  = 'Reading'
 AND lex_cur.map_year_academic = dbo.fn_Global_Academic_Year()
 AND lex_cur.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers lex_base WITH (NOLOCK)
  ON s.id = lex_base.ps_studentid
 AND lex_base.measurementscale  = 'Reading'
 AND lex_base.map_year_academic = dbo.fn_Global_Academic_Year()
 AND lex_base.rn_base = 1

/*
LEFT OUTER JOIN sri_testing_history sri_base_11
  ON to_char(s.student_number) = sri_base_11.base_student_number
 AND sri_base_11.full_cycle_name = 'Baseline 12-13' and sri_base_11.rn_cycle = 1 
 AND s.schoolid = sri_base_11.schoolid
LEFT OUTER JOIN sri_testing_history sri_current
  ON to_char(s.student_number) = sri_current.base_student_number 
 AND sri_current.rn_lifetime = 1
 AND s.schoolid = sri_current.schoolid
--*/
WHERE s.schoolid = 73253
  AND s.enroll_status = 0