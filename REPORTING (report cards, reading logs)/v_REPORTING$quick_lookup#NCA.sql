USE KIPP_NJ
GO

SELECT s.student_number AS SN
      ,s.lastfirst AS Name
      ,s.grade_level AS Gr
      ,cs.Advisor
      ,cs.SPEDLEP AS SPED
      
      --GPA      
      ,nca_GPA.GPA_q1 AS GPA_q1
      ,nca_GPA.GPA_q2 AS GPA_q2
      ,nca_GPA.GPA_q3 AS GPA_q3
      ,nca_GPA.GPA_q4 AS GPA_q4
      ,nca_GPA.GPA_y1 AS GPA_y1      
      
      --cumulative GPA
      ,GPA_cum.cumulative_Y1_GPA AS GPA_cum
--    ,GPA_cumulative.audit_trail AS cumulative_GPA_audit_trail

--Attendance
      --absences
      ,att.absences_total AS abs_y1
      ,round(att_pct.y1_att_pct_total,0) AS abs_y1_pct      
      ,att.RT1_absences_total AS abs_q1
      ,att.RT2_absences_total AS abs_q2
      ,att.RT3_absences_total AS abs_q3
      ,att.RT4_absences_total AS abs_q4
--    ,round(att_pct.rt1_att_pct_total,0) AS abs_q1_pct
--    ,round(att_pct.rt2_att_pct_total,0) AS abs_q2_pct
--    ,round(att_pct.rt3_att_pct_total,0) AS abs_q3_pct
--    ,round(att_pct.rt4_att_pct_total,0) AS abs_q4_pct      
      --tardies
      ,att.tardies_total AS t_y1
      ,round(att_pct.y1_tardy_pct_total,0) AS t_y1_pct
      ,att.RT1_tardies_total AS t_q1
      ,att.RT2_tardies_total AS t_q2
      ,att.RT3_tardies_total AS t_q3
      ,att.RT4_tardies_total AS t_q4
--    ,round(att_pct.rt1_tardy_pct_total,0) AS t_q1_pct
--    ,round(att_pct.rt2_tardy_pct_total,0) AS t_q2_pct
--    ,round(att_pct.rt3_tardy_pct_total,0) AS t_q3_pct
--    ,round(att_pct.rt4_tardy_pct_total,0) AS t_q4_pct

      --merits
      ,merits.total_merits AS m_y1_total
      ,merits.teacher_merits AS m_y1_teacher
      ,merits.perfect_week_merits AS m_y1_perfect
      ,merits.total_merits_rt1 AS m_Q1_total
      ,merits.total_merits_rt2 AS m_Q2_total
      ,merits.total_merits_rt3 AS m_Q3_total
      ,merits.total_merits_rt4 AS m_Q4_total      
      --demerits      
      ,merits.total_tier1_demerits AS demerits_Y1
      ,merits.tier1_demerits_rt1 AS demerits_Q1
      ,merits.tier1_demerits_rt2 AS demerits_Q2
      ,merits.tier1_demerits_rt3 AS demerits_Q3
      ,merits.tier1_demerits_rt4 AS demerits_Q4
      ,null AS Merit_Extended
      ,merits.teacher_merits_rt1 AS m_Q1_teacher
      ,merits.perfect_week_merits_rt1 AS m_Q1_perfect
      ,merits.teacher_merits_rt2 AS m_Q2_teacher
      ,merits.perfect_week_merits_rt2 AS m_Q2_perfect
      ,merits.teacher_merits_rt3 AS m_Q3_teacher
      ,merits.perfect_week_merits_rt3 AS m_Q3_perfect
      ,merits.teacher_merits_rt4 AS m_Q4_teacher
      ,merits.perfect_week_merits_rt4 AS m_Q4_perfect

--placeholders
      ,'Go to Reading Data report' AS AR_PTS_Q1
      ,null AS AR_PTS_Q2
      ,null AS AR_PTS_Q3
      ,null AS AR_PTS_Q4
      ,null AS AR_PTS_YR
      ,null AS AR_WORDS_Q1
      ,null AS AR_WORDS_Q2
      ,null AS AR_WORDS_Q3
      ,null AS AR_WORDS_Q4
      ,null AS AR_WORDS_YR
      ,'Go to Reading Data report' AS sri_lexile_base
      ,null AS sri_pctl_base
      ,null AS sri_lexile_curterm
      ,null AS sri_pctl_curterm
      --AR
/*      
      ,ar_goals.points_earned_rt1 AS AR_PTS_Q1
      ,ar_goals.points_earned_rt2 AS AR_PTS_Q2
      ,ar_goals.points_earned_rt3 AS AR_PTS_Q3
      ,ar_goals.points_earned_rt4 AS AR_PTS_Q4
      ,ar_goals.points_earned_yr  AS AR_PTS_YR
      ,ar_goals.words_read_rt1    AS AR_WORDS_Q1
      ,ar_goals.words_read_rt2    AS AR_WORDS_Q2
      ,ar_goals.words_read_rt3    AS AR_WORDS_Q3
      ,ar_goals.words_read_rt4    AS AR_WORDS_Q4
      ,ar_goals.words_read_yr     AS AR_WORDS_YR
      -- SRI      
      ,sri_base_11.lexile AS sri_lexile_base
      ,sri_base_11.nce AS sri_pctl_base
      ,sri_current.lexile AS sri_lexile_curterm
      ,sri_current.nce AS sri_pctl_curterm
--*/
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
--*/
/*
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
--*/      
/*
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
FROM STUDENTS s   
LEFT OUTER JOIN CUSTOM_STUDENTS cs
  ON s.id = cs.studentid
LEFT OUTER JOIN DISC$merits_demerits_count#NCA merits
  ON s.id = merits.studentid
LEFT OUTER JOIN ATT_MEM$attendance_counts att
  ON s.id = att.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct
  ON s.id = att_pct.id
LEFT OUTER JOIN GRADES$wide_all#NCA gr_wide
  ON s.id = gr_wide.studentid
LEFT OUTER JOIN GPA$detail#NCA nca_GPA
  ON s.id = nca_GPA.studentid
LEFT OUTER JOIN GPA$cumulative GPA_cum
  ON s.id = GPA_cum.studentid
/*
LEFT OUTER JOIN AR$PROGRESS_TO_GOALS ar_goals
  ON s.id = ar_goals.studentid
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
ORDER BY s.grade_level, s.lastfirst