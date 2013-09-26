USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#NCA AS
WITH roster AS
     (SELECT s.student_number AS base_student_number
            ,s.id AS base_studentid
            ,s.lastfirst AS stu_lastfirst
            ,s.first_name AS stu_firstname
            ,s.last_name AS stu_lastname
            ,c.grade_level AS stu_grade_level            
      FROM KIPP_NJ..COHORT$comprehensive_long#static c      
      JOIN KIPP_NJ..STUDENTS s
        ON c.studentid = s.id
       AND s.enroll_status = 0
       --AND s.ID = 3551
       --AND s.ID IN (3551,3358)
       --AND s.ID BETWEEN 3000 AND 4000
      WHERE year = 2013
        AND c.rn = 1        
        AND c.schoolid = 73253
     )

    ,info AS
    (SELECT s.id AS nomerge_id
           ,s.web_id
           ,s.web_password
           ,s.student_web_id
           ,s.student_web_password
           ,s.street
           ,s.city
           ,s.home_phone
           ,cs.advisor
           ,cs.advisor_email
           ,cs.advisor_cell
           ,cs.mother_cell
           ,CASE WHEN cs.mother_home is NULL THEN cs.mother_day ELSE cs.mother_home END AS mother_daytime
           ,cs.father_cell
           ,CASE WHEN cs.father_home is NULL THEN cs.father_day ELSE cs.father_home END AS father_daytime
           ,local.guardianemail
           ,cs.SPEDLEP AS SPED
           ,cs.lunch_balance AS lunch_balance
     FROM KIPP_NJ..CUSTOM_STUDENTS cs
     JOIN KIPP_NJ..STUDENTS s
       ON cs.studentid = s.id
      AND s.enroll_status = 0
     JOIN KIPP_NJ..PS$local_emails local
       ON cs.studentid = local.studentid
    )       

SELECT roster.*
      ,info.*
      
--Attendance
--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts
      --year
      ,att_counts.absences_total           AS Y1_absences_total
      ,att_counts.absences_undoc           AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
      ,att_counts.tardies_total            AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total
      
      --current term -- change field name
      ,att_counts.RT1_absences_total        AS curterm_absences_total
      ,att_counts.RT1_absences_undoc        AS curterm_absences_undoc
      ,ROUND(att_pct.RT1_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.RT1_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.RT1_tardies_total         AS curterm_tardies_total
      ,ROUND(att_pct.RT1_tardy_pct_total,0) AS curterm_tardy_pct_total
      
--GPA
--GPA$detail#nca
--GPA$cumulative#NCA
      --current SY
      ,nca_gpa.GPA_Q1 AS gpa_curterm --change field name for current term
      ,nca_gpa.gpa_Y1
      --cumulative      
      ,gpa_cumulative.cumulative_Y1_gpa
      --,gpa_cumulative.audit_trail AS cumulative_gpa_audit_trail
      
--Course Grades
--GRADES$wide_all
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last            
      ,gr_wide.rc1_q1_ltr AS rc1_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc1_q1,0) AS rc1_cur_term_pct                 --change field name for current term
      ,gr_wide.rc1_gpa_points_Q1 AS rc1_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc1_y1 >= 70 THEN gr_wide.rc1_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc1_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc1_q1_ltr AS rc1_q1_term_ltr      
      ,gr_wide.rc1_q2_ltr AS rc1_q2_term_ltr
      ,gr_wide.rc1_q3_ltr AS rc1_q3_term_ltr
      ,gr_wide.rc1_q4_ltr AS rc1_q4_term_ltr
      ,ROUND(gr_wide.rc1_q1,0) AS rc1_q1_term_pct
      ,ROUND(gr_wide.rc1_q2,0) AS rc1_q2_term_pct
      ,ROUND(gr_wide.rc1_q3,0) AS rc1_q3_term_pct
      ,ROUND(gr_wide.rc1_q4,0) AS rc1_q4_term_pct
      */
      ,ROUND(gr_wide.rc1_y1,0) AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      ,gr_wide.rc1_gpa_points_Y1
      ,gr_wide.rc1_credit_hours_Y1

      ,gr_wide.rc2_course_name
      ,gr_wide.rc2_teacher_last            
      ,gr_wide.rc2_q1_ltr AS rc2_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc2_q1,0) AS rc2_cur_term_pct                 --change field name for current term
      ,gr_wide.rc2_gpa_points_Q1 AS rc2_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc2_y1 >= 70 THEN gr_wide.rc2_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc2_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc2_q1_ltr AS rc2_q1_term_ltr      
      ,gr_wide.rc2_q2_ltr AS rc2_q2_term_ltr
      ,gr_wide.rc2_q3_ltr AS rc2_q3_term_ltr
      ,gr_wide.rc2_q4_ltr AS rc2_q4_term_ltr
      ,ROUND(gr_wide.rc2_q1,0) AS rc2_q1_term_pct
      ,ROUND(gr_wide.rc2_q2,0) AS rc2_q2_term_pct
      ,ROUND(gr_wide.rc2_q3,0) AS rc2_q3_term_pct
      ,ROUND(gr_wide.rc2_q4,0) AS rc2_q4_term_pct
      */
      ,ROUND(gr_wide.rc2_y1,0) AS rc2_y1_pct
      ,gr_wide.rc2_y1_ltr
      ,gr_wide.rc2_gpa_points_Y1
      ,gr_wide.rc2_credit_hours_Y1
 
      ,gr_wide.rc3_course_name
      ,gr_wide.rc3_teacher_last            
      ,gr_wide.rc3_q1_ltr AS rc3_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc3_q1,0) AS rc3_cur_term_pct                 --change field name for current term
      ,gr_wide.rc3_gpa_points_Q1 AS rc3_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc3_y1 >= 70 THEN gr_wide.rc3_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc3_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc3_q1_ltr AS rc3_q1_term_ltr      
      ,gr_wide.rc3_q2_ltr AS rc3_q2_term_ltr
      ,gr_wide.rc3_q3_ltr AS rc3_q3_term_ltr
      ,gr_wide.rc3_q4_ltr AS rc3_q4_term_ltr
      ,ROUND(gr_wide.rc3_q1,0) AS rc3_q1_term_pct
      ,ROUND(gr_wide.rc3_q2,0) AS rc3_q2_term_pct
      ,ROUND(gr_wide.rc3_q3,0) AS rc3_q3_term_pct
      ,ROUND(gr_wide.rc3_q4,0) AS rc3_q4_term_pct
      */
      ,ROUND(gr_wide.rc3_y1,0) AS rc3_y1_pct
      ,gr_wide.rc3_y1_ltr
      ,gr_wide.rc3_gpa_points_Y1
      ,gr_wide.rc3_credit_hours_Y1
      
      ,gr_wide.rc4_course_name
      ,gr_wide.rc4_teacher_last            
      ,gr_wide.rc4_q1_ltr AS rc4_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc4_q1,0) AS rc4_cur_term_pct                 --change field name for current term
      ,gr_wide.rc4_gpa_points_Q1 AS rc4_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc4_y1 >= 70 THEN gr_wide.rc4_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc4_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc4_q1_ltr AS rc4_q1_term_ltr      
      ,gr_wide.rc4_q2_ltr AS rc4_q2_term_ltr
      ,gr_wide.rc4_q3_ltr AS rc4_q3_term_ltr
      ,gr_wide.rc4_q4_ltr AS rc4_q4_term_ltr
      ,ROUND(gr_wide.rc4_q1,0) AS rc4_q1_term_pct
      ,ROUND(gr_wide.rc4_q2,0) AS rc4_q2_term_pct
      ,ROUND(gr_wide.rc4_q3,0) AS rc4_q3_term_pct
      ,ROUND(gr_wide.rc4_q4,0) AS rc4_q4_term_pct
      */
      ,ROUND(gr_wide.rc4_y1,0) AS rc4_y1_pct
      ,gr_wide.rc4_y1_ltr
      ,gr_wide.rc4_gpa_points_Y1
      ,gr_wide.rc4_credit_hours_Y1
      
      ,gr_wide.rc5_course_name
      ,gr_wide.rc5_teacher_last            
      ,gr_wide.rc5_q1_ltr AS rc5_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc5_q1,0) AS rc5_cur_term_pct                 --change field name for current term
      ,gr_wide.rc5_gpa_points_Q1 AS rc5_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc5_y1 >= 70 THEN gr_wide.rc5_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc5_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc5_q1_ltr AS rc5_q1_term_ltr      
      ,gr_wide.rc5_q2_ltr AS rc5_q2_term_ltr
      ,gr_wide.rc5_q3_ltr AS rc5_q3_term_ltr
      ,gr_wide.rc5_q4_ltr AS rc5_q4_term_ltr
      ,ROUND(gr_wide.rc5_q1,0) AS rc5_q1_term_pct
      ,ROUND(gr_wide.rc5_q2,0) AS rc5_q2_term_pct
      ,ROUND(gr_wide.rc5_q3,0) AS rc5_q3_term_pct
      ,ROUND(gr_wide.rc5_q4,0) AS rc5_q4_term_pct
      */
      ,ROUND(gr_wide.rc5_y1,0) AS rc5_y1_pct
      ,gr_wide.rc5_y1_ltr
      ,gr_wide.rc5_gpa_points_Y1
      ,gr_wide.rc5_credit_hours_Y1
      
      ,gr_wide.rc6_course_name
      ,gr_wide.rc6_teacher_last            
      ,gr_wide.rc6_q1_ltr AS rc6_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc6_q1,0) AS rc6_cur_term_pct                 --change field name for current term
      ,gr_wide.rc6_gpa_points_Q1 AS rc6_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc6_y1 >= 70 THEN gr_wide.rc6_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc6_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc6_q1_ltr AS rc6_q1_term_ltr      
      ,gr_wide.rc6_q2_ltr AS rc6_q2_term_ltr
      ,gr_wide.rc6_q3_ltr AS rc6_q3_term_ltr
      ,gr_wide.rc6_q4_ltr AS rc6_q4_term_ltr
      ,ROUND(gr_wide.rc6_q1,0) AS rc6_q1_term_pct
      ,ROUND(gr_wide.rc6_q2,0) AS rc6_q2_term_pct
      ,ROUND(gr_wide.rc6_q3,0) AS rc6_q3_term_pct
      ,ROUND(gr_wide.rc6_q4,0) AS rc6_q4_term_pct
      */
      ,ROUND(gr_wide.rc6_y1,0) AS rc6_y1_pct
      ,gr_wide.rc6_y1_ltr
      ,gr_wide.rc6_gpa_points_Y1
      ,gr_wide.rc6_credit_hours_Y1

      ,gr_wide.rc7_course_name
      ,gr_wide.rc7_teacher_last            
      ,gr_wide.rc7_q1_ltr AS rc7_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc7_q1,0) AS rc7_cur_term_pct                 --change field name for current term
      ,gr_wide.rc7_gpa_points_Q1 AS rc7_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc7_y1 >= 70 THEN gr_wide.rc7_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc7_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc7_q1_ltr AS rc7_q1_term_ltr      
      ,gr_wide.rc7_q2_ltr AS rc7_q2_term_ltr
      ,gr_wide.rc7_q3_ltr AS rc7_q3_term_ltr
      ,gr_wide.rc7_q4_ltr AS rc7_q4_term_ltr
      ,ROUND(gr_wide.rc7_q1,0) AS rc7_q1_term_pct
      ,ROUND(gr_wide.rc7_q2,0) AS rc7_q2_term_pct
      ,ROUND(gr_wide.rc7_q3,0) AS rc7_q3_term_pct
      ,ROUND(gr_wide.rc7_q4,0) AS rc7_q4_term_pct
      */
      ,ROUND(gr_wide.rc7_y1,0) AS rc7_y1_pct
      ,gr_wide.rc7_y1_ltr
      ,gr_wide.rc7_gpa_points_Y1
      ,gr_wide.rc7_credit_hours_Y1

      ,gr_wide.rc8_course_name
      ,gr_wide.rc8_teacher_last            
      ,gr_wide.rc8_q1_ltr AS rc8_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc8_q1,0) AS rc8_cur_term_pct                 --change field name for current term
      ,gr_wide.rc8_gpa_points_Q1 AS rc8_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc8_y1 >= 70 THEN gr_wide.rc8_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc8_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc8_q1_ltr AS rc8_q1_term_ltr      
      ,gr_wide.rc8_q2_ltr AS rc8_q2_term_ltr
      ,gr_wide.rc8_q3_ltr AS rc8_q3_term_ltr
      ,gr_wide.rc8_q4_ltr AS rc8_q4_term_ltr
      ,ROUND(gr_wide.rc8_q1,0) AS rc8_q1_term_pct
      ,ROUND(gr_wide.rc8_q2,0) AS rc8_q2_term_pct
      ,ROUND(gr_wide.rc8_q3,0) AS rc8_q3_term_pct
      ,ROUND(gr_wide.rc8_q4,0) AS rc8_q4_term_pct
      */
      ,ROUND(gr_wide.rc8_y1,0) AS rc8_y1_pct
      ,gr_wide.rc8_y1_ltr
      ,gr_wide.rc8_gpa_points_Y1
      ,gr_wide.rc8_credit_hours_Y1
      
      ,gr_wide.rc9_course_name
      ,gr_wide.rc9_teacher_last            
      ,gr_wide.rc9_q1_ltr AS rc9_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc9_q1,0) AS rc9_cur_term_pct                 --change field name for current term
      ,gr_wide.rc9_gpa_points_Q1 AS rc9_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc9_y1 >= 70 THEN gr_wide.rc9_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc9_earned_crhrs                                     --change field name for current term
      /*
      ,gr_wide.rc9_q1_ltr AS rc9_q1_term_ltr      
      ,gr_wide.rc9_q2_ltr AS rc9_q2_term_ltr
      ,gr_wide.rc9_q3_ltr AS rc9_q3_term_ltr
      ,gr_wide.rc9_q4_ltr AS rc9_q4_term_ltr
      ,ROUND(gr_wide.rc9_q1,0) AS rc9_q1_term_pct
      ,ROUND(gr_wide.rc9_q2,0) AS rc9_q2_term_pct
      ,ROUND(gr_wide.rc9_q3,0) AS rc9_q3_term_pct
      ,ROUND(gr_wide.rc9_q4,0) AS rc9_q4_term_pct
      */      
      ,ROUND(gr_wide.rc9_y1,0) AS rc9_y1_pct
      ,gr_wide.rc9_y1_ltr
      ,gr_wide.rc9_gpa_points_Y1
      ,gr_wide.rc9_credit_hours_Y1
      
      ,gr_wide.rc10_course_name
      ,gr_wide.rc10_teacher_last            
      ,gr_wide.rc10_q1_ltr AS rc10_cur_term_ltr                      --change field name for current term
      ,ROUND(gr_wide.rc10_q1,0) AS rc10_cur_term_pct                 --change field name for current term
      ,gr_wide.rc10_gpa_points_Q1 AS rc10_cur_term_gpa_points        --change field name for current term
      ,CASE
        WHEN gr_wide.rc10_y1 >= 70 THEN gr_wide.rc10_credit_hours_Y1 --change field name for current term
        ELSE NULL
       END AS rc10_earned_crhrs                                      --change field name for current term
      /*
      ,gr_wide.rc10_q1_ltr AS rc10_q1_term_ltr      
      ,gr_wide.rc10_q2_ltr AS rc10_q2_term_ltr
      ,gr_wide.rc10_q3_ltr AS rc10_q3_term_ltr
      ,gr_wide.rc10_q4_ltr AS rc10_q4_term_ltr
      ,ROUND(gr_wide.rc10_q1,0) AS rc10_q1_term_pct
      ,ROUND(gr_wide.rc10_q2,0) AS rc10_q2_term_pct
      ,ROUND(gr_wide.rc10_q3,0) AS rc10_q3_term_pct
      ,ROUND(gr_wide.rc10_q4,0) AS rc10_q4_term_pct
      */
      ,ROUND(gr_wide.rc10_y1,0) AS rc10_y1_pct
      ,gr_wide.rc10_y1_ltr
      ,gr_wide.rc10_gpa_points_Y1
      ,gr_wide.rc10_credit_hours_Y1

      --current term component averages -- change term number (e.g. H1) on component fields for current term
      --H
      ,gr_wide.rc1_H1  AS rc1_cur_hw_pct
      ,gr_wide.rc2_H1  AS rc2_cur_hw_pct
      ,gr_wide.rc3_H1  AS rc3_cur_hw_pct
      ,gr_wide.rc4_H1  AS rc4_cur_hw_pct
      ,gr_wide.rc5_H1  AS rc5_cur_hw_pct
      ,gr_wide.rc6_H1  AS rc6_cur_hw_pct
      ,gr_wide.rc7_H1  AS rc7_cur_hw_pct
      ,gr_wide.rc8_H1  AS rc8_cur_hw_pct
      ,gr_wide.rc9_H1  AS rc9_cur_hw_pct
      ,gr_wide.rc10_H1 AS rc10_cur_hw_pct      
      --A
      ,gr_wide.rc1_A1  AS rc1_cur_a_pct
      ,gr_wide.rc2_A1  AS rc2_cur_a_pct
      ,gr_wide.rc3_A1  AS rc3_cur_a_pct
      ,gr_wide.rc4_A1  AS rc4_cur_a_pct
      ,gr_wide.rc5_A1  AS rc5_cur_a_pct
      ,gr_wide.rc6_A1  AS rc6_cur_a_pct
      ,gr_wide.rc7_A1  AS rc7_cur_a_pct
      ,gr_wide.rc8_A1  AS rc8_cur_a_pct
      ,gr_wide.rc9_A1  AS rc9_cur_a_pct
      ,gr_wide.rc10_A1 AS rc10_cur_a_pct
      --CW
      ,gr_wide.rc1_C1  AS rc1_cur_cw_pct
      ,gr_wide.rc2_c1  AS rc2_cur_cw_pct
      ,gr_wide.rc3_c1  AS rc3_cur_cw_pct
      ,gr_wide.rc4_c1  AS rc4_cur_cw_pct
      ,gr_wide.rc5_c1  AS rc5_cur_cw_pct
      ,gr_wide.rc6_c1  AS rc6_cur_cw_pct
      ,gr_wide.rc7_c1  AS rc7_cur_cw_pct
      ,gr_wide.rc8_c1  AS rc8_cur_cw_pct
      ,gr_wide.rc9_c1  AS rc9_cur_cw_pct
      ,gr_wide.rc10_c1 AS rc10_cur_cw_pct
      --P
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
      --E1
      ,gr_wide.rc1_E1  AS rc1_exam
      ,gr_wide.rc2_E1  AS rc2_exam
      ,gr_wide.rc3_E1  AS rc3_exam
      ,gr_wide.rc4_E1  AS rc4_exam
      ,gr_wide.rc5_E1  AS rc5_exam
      ,gr_wide.rc6_E1  AS rc6_exam
      ,gr_wide.rc7_E1  AS rc7_exam
      ,gr_wide.rc8_E1  AS rc8_exam
      ,gr_wide.rc9_E1  AS rc9_exam
      ,gr_wide.rc10_E1 AS rc10_exam
      --E2
      ,gr_wide.rc1_E2  AS rc1_exam2
      ,gr_wide.rc2_E2  AS rc2_exam2
      ,gr_wide.rc3_E2  AS rc3_exam2
      ,gr_wide.rc4_E2  AS rc4_exam2
      ,gr_wide.rc5_E2  AS rc5_exam2
      ,gr_wide.rc6_E2  AS rc6_exam2
      ,gr_wide.rc7_E2  AS rc7_exam2
      ,gr_wide.rc8_E2  AS rc8_exam2
      ,gr_wide.rc9_E2  AS rc9_exam2
      ,gr_wide.rc10_E2 AS rc10_exam2

      --YTD absents and tardies by class
        --absences
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
        --tardies
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

      --Accelerated Reader      
      --AR year
      ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
      ,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr
      ,ar_yr.points AS points_yr
      
      --AR current
      --update term in JOIN
      ,replace(convert(varchar,convert(Money, ar_curr.words),1),'.00','') AS words_read_cur_term
      ,replace(convert(varchar,convert(Money, ar_curr.words_goal),1),'.00','') AS words_goal_cur_term
       ,ar_curr.points AS points_curterm

--Literacy tracking
--MAP$comprehensive#identifiers
      --Lexile (from MAP) -- update year in JOIN
        --base for year
      ,CASE
        WHEN lex_base.RITtoReadingScore = 'BR' THEN 'Beginning Reader'
        ELSE lex_base.RITtoReadingScore
       END AS lexile_base
      --,lex_fall.RITtoReadingMin AS lexile_base_min
      --,lex_fall.RITtoReadingMax AS lexile_base_max
      ,lex_base.TestPercentile AS lex_base_pct
        
        --current for year
      ,CASE
        WHEN lex_curr.RITtoReadingScore = 'BR' THEN 'Beginning Reader'
        ELSE lex_curr.RITtoReadingScore
       END AS lexile_curr
      --,lex_curr.RITtoReadingMin AS lexile_curr_min
      --,lex_curr.RITtoReadingMax AS lexile_curr_max
      ,lex_curr.TestPercentile AS lex_curr_pct

--Comments
--PS$comments_gradebook
      ,comment_rc1.teacher_comment  AS rc1_comment
      ,comment_rc2.teacher_comment  AS rc2_comment
      ,comment_rc3.teacher_comment  AS rc3_comment
      ,comment_rc4.teacher_comment  AS rc4_comment
      ,comment_rc5.teacher_comment  AS rc5_comment
      ,comment_rc6.teacher_comment  AS rc6_comment
      ,comment_rc7.teacher_comment  AS rc7_comment
      ,comment_rc8.teacher_comment  AS rc8_comment
      ,comment_rc9.teacher_comment  AS rc9_comment
      ,comment_rc10.teacher_comment AS rc10_comment
      --for end of term report card comments
      ,comment_adv.teacher_comment  AS advisor_comment
    
--Discipline
--DISC$merits_demerits_count#NCA
      --Merits
        --year
      ,merits.teacher_merits_rt1
        + merits.teacher_merits_rt2
        + merits.teacher_merits_rt3
        + merits.teacher_merits_rt4      AS teacher_merits_yr
      ,merits.perfect_week_merits_rt1 
        + merits.perfect_week_merits_rt2 
        + merits.perfect_week_merits_rt3 
        + merits.perfect_week_merits_rt4 AS perfect_week_yr
      ,merits.total_merits_rt1 
        + merits.total_merits_rt2 
        + merits.total_merits_rt3 
        + merits.total_merits_rt4        AS total_merits_yr      
        --current
      ,merits.teacher_merits_rt1         AS teacher_merits_curr -- update field name for current term
      ,merits.perfect_week_merits_rt1    AS perfect_week_curr   -- update field name for current term
      ,merits.total_merits_rt1           AS total_merits_curr   -- update field name for current term
      
      --Demerits
        --year
      ,merits.tier1_demerits_rt1
        + merits.tier1_demerits_rt2
        + merits.tier1_demerits_rt3
        + merits.tier1_demerits_rt4      AS tier1_demerits_yr
        --current -- update field name for current term
      ,merits.tier1_demerits_rt1         AS tier1_demerits_curr -- update field name for current term

FROM roster

--INFO
LEFT OUTER JOIN info
  ON roster.base_studentid = info.nomerge_id
  
--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts
  ON roster.base_studentid = att_counts.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct
  ON roster.base_studentid = att_pct.id
  
--GPA
LEFT OUTER JOIN GPA$detail#NCA nca_gpa
  ON roster.base_studentid = nca_gpa.studentid
LEFT OUTER JOIN GPA$cumulative#NCA gpa_cumulative
  ON roster.base_studentid = gpa_cumulative.studentid
  
--GRADES
LEFT OUTER JOIN GRADES$wide_all#NCA gr_wide
  ON roster.base_studentid = gr_wide.studentid
  
--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr
  ON roster.base_studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr
  ON roster.base_studentid = ar_curr.studentid 
 AND ar_curr.time_period_name = 'RT1' --update every quarter
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()
 
--LITERACY -- upadate parameters for current term
  --LEXILE
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_base
  ON roster.base_student_number = lex_base.StudentID
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.fallwinterspring = 'Fall'
 AND lex_base.map_year_academic = 2013
 AND lex_base.rn_base = 1

LEFT OUTER JOIN MAP$comprehensive#identifiers lex_curr
  ON roster.base_student_number = lex_curr.StudentID
 AND lex_curr.MeasurementScale = 'Reading'
 AND lex_curr.fallwinterspring = 'Fall'
 AND lex_curr.map_year_academic = 2013
 AND lex_curr.rn_curr = 1
 
--GRADEBOOK COMMMENTS -- upadate fieldname and parameter for current term
LEFT OUTER JOIN PS$comments_gradebooks comment_rc1
  ON gr_wide.rc1_Q1_enr_sectionid = comment_rc1.sectionid
 AND gr_wide.studentid = comment_rc1.studentid
 AND comment_rc1.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc2
  ON gr_wide.rc2_Q1_enr_sectionid = comment_rc2.sectionid
 AND gr_wide.studentid = comment_rc2.studentid
 AND comment_rc2.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc3
  ON gr_wide.rc3_q1_enr_sectionid = comment_rc3.sectionid
 AND gr_wide.studentid = comment_rc3.studentid
 AND comment_rc3.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc4
  ON gr_wide.rc4_q1_enr_sectionid = comment_rc4.sectionid
 AND gr_wide.studentid = comment_rc4.studentid
 AND comment_rc4.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc5
  ON gr_wide.rc5_q1_enr_sectionid = comment_rc5.sectionid
 AND gr_wide.studentid = comment_rc5.studentid
 AND comment_rc5.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc6
  ON gr_wide.rc6_q1_enr_sectionid = comment_rc6.sectionid
 AND gr_wide.studentid = comment_rc6.studentid
 AND comment_rc6.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc7
  ON gr_wide.rc7_Q1_enr_sectionid = comment_rc7.sectionid
 AND gr_wide.studentid = comment_rc7.studentid
 AND comment_rc7.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc8
  ON gr_wide.rc8_Q1_enr_sectionid = comment_rc8.sectionid
 AND gr_wide.studentid = comment_rc8.studentid
 AND comment_rc8.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc9
  ON gr_wide.rc9_Q1_enr_sectionid = comment_rc9.sectionid
 AND gr_wide.studentid = comment_rc9.studentid
 AND comment_rc9.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_gradebooks comment_rc10
  ON gr_wide.rc10_Q1_enr_sectionid = comment_rc10.sectionid
 AND gr_wide.studentid = comment_rc10.studentid
 AND comment_rc10.finalgradename = 'Q1'
LEFT OUTER JOIN PS$comments_advisors comment_adv
 ON roster.base_studentid = comment_adv.id
AND comment_adv.finalgradename = 'Q1'

--MERITS & DEMERITS
LEFT OUTER JOIN DISC$merits_demerits_count#NCA merits
  ON roster.base_studentid = merits.studentid