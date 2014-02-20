USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#NCA AS
WITH roster AS
     (
      SELECT s.schoolid
            ,s.student_number AS base_student_number
            ,s.id AS base_studentid
            ,s.lastfirst AS stu_lastfirst
            ,s.first_name AS stu_firstname
            ,s.last_name AS stu_lastname
            ,c.grade_level AS stu_grade_level
      FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
      JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
        ON c.studentid = s.id
       AND s.enroll_status = 0
       --AND s.ID = 639
       --AND s.ID IN (3551,3358)
       --AND s.ID BETWEEN 3000 AND 4000
      WHERE year = 2013
        AND c.rn = 1
        AND c.schoolid = 73253
     )

    ,info AS
    (
     SELECT s.id AS nomerge_id
           ,s.web_id
           ,CASE WHEN s.web_password LIKE '{B64}%' THEN 'Changed By User' ELSE s.web_password END AS web_password
           ,s.student_web_id
           ,CASE WHEN s.student_web_password LIKE '{B64}%' THEN 'Changed By User' ELSE s.student_web_password END AS student_web_password
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
           ,cs.GUARDIANEMAIL           
           ,cs.SPEDLEP AS SPED
           ,cs.lunch_balance AS lunch_balance
     FROM KIPP_NJ..STUDENTS s WITH (NOLOCK)
     JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH (NOLOCK)
       ON s.id = cs.studentid
      AND s.enroll_status = 0
      AND s.schoolid = 73253     
    )       

SELECT roster.*
      ,info.*

--Attendance & Tardies
--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts      
       /*--Year--*/
      ,att_counts.absences_total           AS Y1_absences_total
      ,att_counts.absences_undoc           AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
      ,att_counts.tardies_total            AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total      

       /*--Current--*/
      /*--UPDATE FIELD to current term--*/
      ,att_counts.rt3_absences_total        AS curterm_absences_total
      ,att_counts.rt3_absences_undoc        AS curterm_absences_undoc
      ,ROUND(att_pct.rt3_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.rt3_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.rt3_tardies_total         AS curterm_tardies_total
      ,ROUND(att_pct.rt3_tardy_pct_total,0) AS curterm_tardy_pct_total
      
--GPA
--GPA$detail#nca
--GPA$cumulative#NCA
    /*--Academic Year/Current Term--*/
       /*--UPDATE FOR CURRENT TERM--*/
      --,nca_gpa.GPA_Q1 AS gpa_curterm
      --,nca_gpa.GPA_Q2 AS gpa_curterm
      ,nca_gpa.GPA_Q3 AS gpa_curterm
      --,nca_gpa.GPA_Q4 AS gpa_curterm
      ,nca_gpa.gpa_Y1
      /*--Cumulative--*/
      ,gpa_cumulative.cumulative_Y1_gpa
      --,gpa_cumulative.audit_trail AS cumulative_gpa_audit_trail
      
--Course Grades
--GRADES$wide_all
    /*--RC1--*/
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.rc1_q1_ltr AS rc1_cur_term_ltr
      --,gr_wide.rc1_q2_ltr AS rc1_cur_term_ltr
      ,gr_wide.rc1_q3_ltr AS rc1_cur_term_ltr
      --,gr_wide.rc1_q4_ltr AS rc1_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.rc1_q1,0) AS rc1_cur_term_pct
      --,ROUND(gr_wide.rc1_q2,0) AS rc1_cur_term_pct
      ,ROUND(gr_wide.rc1_q3,0) AS rc1_cur_term_pct
      --,ROUND(gr_wide.rc1_q4,0) AS rc1_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.rc1_gpa_points_Q1 AS rc1_cur_term_gpa_points
      --,gr_wide.rc1_gpa_points_Q2 AS rc1_cur_term_gpa_points
      ,gr_wide.rc1_gpa_points_Q3 AS rc1_cur_term_gpa_points
      --,gr_wide.rc1_gpa_points_Q4 AS rc1_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.rc1_q1_ltr AS rc1_q1_term_ltr      
      ,gr_wide.rc1_q2_ltr AS rc1_q2_term_ltr
      ,gr_wide.rc1_q3_ltr AS rc1_q3_term_ltr
      ,gr_wide.rc1_q4_ltr AS rc1_q4_term_ltr
      ,ROUND(gr_wide.rc1_q1,0) AS rc1_q1_term_pct
      ,ROUND(gr_wide.rc1_q2,0) AS rc1_q2_term_pct
      ,ROUND(gr_wide.rc1_q3,0) AS rc1_q3_term_pct
      ,ROUND(gr_wide.rc1_q4,0) AS rc1_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.rc1_y1,0) AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      ,gr_wide.rc1_credit_hours_Y1
      --,gr_wide.rc1_gpa_points_Y1      
      --,CASE WHEN gr_wide.rc1_y1 >= 70 THEN gr_wide.rc1_credit_hours_Y1 ELSE NULL END AS rc1_earned_crhrs

    /*--RC2--*/
      ,gr_wide.RC2_course_name
      ,gr_wide.RC2_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC2_q1_ltr AS RC2_cur_term_ltr
      --,gr_wide.RC2_q2_ltr AS RC2_cur_term_ltr
      ,gr_wide.RC2_q3_ltr AS RC2_cur_term_ltr
      --,gr_wide.RC2_q4_ltr AS RC2_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC2_q1,0) AS RC2_cur_term_pct
      --,ROUND(gr_wide.RC2_q2,0) AS RC2_cur_term_pct
      ,ROUND(gr_wide.RC2_q3,0) AS RC2_cur_term_pct
      --,ROUND(gr_wide.RC2_q4,0) AS RC2_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC2_gpa_points_Q1 AS RC2_cur_term_gpa_points
      --,gr_wide.RC2_gpa_points_Q2 AS RC2_cur_term_gpa_points
      ,gr_wide.RC2_gpa_points_Q3 AS RC2_cur_term_gpa_points
      --,gr_wide.RC2_gpa_points_Q4 AS RC2_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC2_q1_ltr AS RC2_q1_term_ltr      
      ,gr_wide.RC2_q2_ltr AS RC2_q2_term_ltr
      ,gr_wide.RC2_q3_ltr AS RC2_q3_term_ltr
      ,gr_wide.RC2_q4_ltr AS RC2_q4_term_ltr
      ,ROUND(gr_wide.RC2_q1,0) AS RC2_q1_term_pct
      ,ROUND(gr_wide.RC2_q2,0) AS RC2_q2_term_pct
      ,ROUND(gr_wide.RC2_q3,0) AS RC2_q3_term_pct
      ,ROUND(gr_wide.RC2_q4,0) AS RC2_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC2_y1,0) AS RC2_y1_pct
      ,gr_wide.RC2_y1_ltr
      ,gr_wide.RC2_credit_hours_Y1
      --,gr_wide.RC2_gpa_points_Y1
      --,CASE WHEN gr_wide.RC2_y1 >= 70 THEN gr_wide.RC2_credit_hours_Y1 ELSE NULL END AS RC2_earned_crhrs

    /*--RC3--*/
      ,gr_wide.RC3_course_name
      ,gr_wide.RC3_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC3_q1_ltr AS RC3_cur_term_ltr
      --,gr_wide.RC3_q2_ltr AS RC3_cur_term_ltr
      ,gr_wide.RC3_q3_ltr AS RC3_cur_term_ltr
      --,gr_wide.RC3_q4_ltr AS RC3_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC3_q1,0) AS RC3_cur_term_pct
      --,ROUND(gr_wide.RC3_q2,0) AS RC3_cur_term_pct
      ,ROUND(gr_wide.RC3_q3,0) AS RC3_cur_term_pct
      --,ROUND(gr_wide.RC3_q4,0) AS RC3_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC3_gpa_points_Q1 AS RC3_cur_term_gpa_points
      --,gr_wide.RC3_gpa_points_Q2 AS RC3_cur_term_gpa_points
      ,gr_wide.RC3_gpa_points_Q3 AS RC3_cur_term_gpa_points
      --,gr_wide.RC3_gpa_points_Q4 AS RC3_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC3_q1_ltr AS RC3_q1_term_ltr      
      ,gr_wide.RC3_q2_ltr AS RC3_q2_term_ltr
      ,gr_wide.RC3_q3_ltr AS RC3_q3_term_ltr
      ,gr_wide.RC3_q4_ltr AS RC3_q4_term_ltr
      ,ROUND(gr_wide.RC3_q1,0) AS RC3_q1_term_pct
      ,ROUND(gr_wide.RC3_q2,0) AS RC3_q2_term_pct
      ,ROUND(gr_wide.RC3_q3,0) AS RC3_q3_term_pct
      ,ROUND(gr_wide.RC3_q4,0) AS RC3_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC3_y1,0) AS RC3_y1_pct
      ,gr_wide.RC3_y1_ltr
      ,gr_wide.RC3_credit_hours_Y1
      --,gr_wide.RC3_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC3_y1 >= 70 THEN gr_wide.RC3_credit_hours_Y1 ELSE NULL END AS RC3_earned_crhrs

    /*--RC4--*/
      ,gr_wide.RC4_course_name
      ,gr_wide.RC4_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC4_q1_ltr AS RC4_cur_term_ltr
      --,gr_wide.RC4_q2_ltr AS RC4_cur_term_ltr
      ,gr_wide.RC4_q3_ltr AS RC4_cur_term_ltr
      --,gr_wide.RC4_q4_ltr AS RC4_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC4_q1,0) AS RC4_cur_term_pct
      --,ROUND(gr_wide.RC4_q2,0) AS RC4_cur_term_pct
      ,ROUND(gr_wide.RC4_q3,0) AS RC4_cur_term_pct
      --,ROUND(gr_wide.RC4_q4,0) AS RC4_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC4_gpa_points_Q1 AS RC4_cur_term_gpa_points
      --,gr_wide.RC4_gpa_points_Q2 AS RC4_cur_term_gpa_points
      ,gr_wide.RC4_gpa_points_Q3 AS RC4_cur_term_gpa_points
      --,gr_wide.RC4_gpa_points_Q4 AS RC4_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC4_q1_ltr AS RC4_q1_term_ltr      
      ,gr_wide.RC4_q2_ltr AS RC4_q2_term_ltr
      ,gr_wide.RC4_q3_ltr AS RC4_q3_term_ltr
      ,gr_wide.RC4_q4_ltr AS RC4_q4_term_ltr
      ,ROUND(gr_wide.RC4_q1,0) AS RC4_q1_term_pct
      ,ROUND(gr_wide.RC4_q2,0) AS RC4_q2_term_pct
      ,ROUND(gr_wide.RC4_q3,0) AS RC4_q3_term_pct
      ,ROUND(gr_wide.RC4_q4,0) AS RC4_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC4_y1,0) AS RC4_y1_pct
      ,gr_wide.RC4_y1_ltr
      ,gr_wide.RC4_credit_hours_Y1
      --,gr_wide.RC4_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC4_y1 >= 70 THEN gr_wide.RC4_credit_hours_Y1 ELSE NULL END AS RC4_earned_crhrs

    /*--RC5--*/
      ,gr_wide.RC5_course_name
      ,gr_wide.RC5_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC5_q1_ltr AS RC5_cur_term_ltr
      --,gr_wide.RC5_q2_ltr AS RC5_cur_term_ltr
      ,gr_wide.RC5_q3_ltr AS RC5_cur_term_ltr
      --,gr_wide.RC5_q4_ltr AS RC5_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC5_q1,0) AS RC5_cur_term_pct
      --,ROUND(gr_wide.RC5_q2,0) AS RC5_cur_term_pct
      ,ROUND(gr_wide.RC5_q3,0) AS RC5_cur_term_pct
      --,ROUND(gr_wide.RC5_q4,0) AS RC5_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC5_gpa_points_Q1 AS RC5_cur_term_gpa_points
      --,gr_wide.RC5_gpa_points_Q2 AS RC5_cur_term_gpa_points
      ,gr_wide.RC5_gpa_points_Q3 AS RC5_cur_term_gpa_points
      --,gr_wide.RC5_gpa_points_Q4 AS RC5_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC5_q1_ltr AS RC5_q1_term_ltr      
      ,gr_wide.RC5_q2_ltr AS RC5_q2_term_ltr
      ,gr_wide.RC5_q3_ltr AS RC5_q3_term_ltr
      ,gr_wide.RC5_q4_ltr AS RC5_q4_term_ltr
      ,ROUND(gr_wide.RC5_q1,0) AS RC5_q1_term_pct
      ,ROUND(gr_wide.RC5_q2,0) AS RC5_q2_term_pct
      ,ROUND(gr_wide.RC5_q3,0) AS RC5_q3_term_pct
      ,ROUND(gr_wide.RC5_q4,0) AS RC5_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC5_y1,0) AS RC5_y1_pct
      ,gr_wide.RC5_y1_ltr
      ,gr_wide.RC5_credit_hours_Y1
      --,gr_wide.RC5_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC5_y1 >= 70 THEN gr_wide.RC5_credit_hours_Y1 ELSE NULL END AS RC5_earned_crhrs
      
    /*--RC6--*/
      ,gr_wide.RC6_course_name
      ,gr_wide.RC6_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC6_q1_ltr AS RC6_cur_term_ltr
      --,gr_wide.RC6_q2_ltr AS RC6_cur_term_ltr
      ,gr_wide.RC6_q3_ltr AS RC6_cur_term_ltr
      --,gr_wide.RC6_q4_ltr AS RC6_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC6_q1,0) AS RC6_cur_term_pct
      --,ROUND(gr_wide.RC6_q2,0) AS RC6_cur_term_pct
      ,ROUND(gr_wide.RC6_q3,0) AS RC6_cur_term_pct
      --,ROUND(gr_wide.RC6_q4,0) AS RC6_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC6_gpa_points_Q1 AS RC6_cur_term_gpa_points
      --,gr_wide.RC6_gpa_points_Q2 AS RC6_cur_term_gpa_points
      ,gr_wide.RC6_gpa_points_Q3 AS RC6_cur_term_gpa_points
      --,gr_wide.RC6_gpa_points_Q4 AS RC6_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC6_q1_ltr AS RC6_q1_term_ltr      
      ,gr_wide.RC6_q2_ltr AS RC6_q2_term_ltr
      ,gr_wide.RC6_q3_ltr AS RC6_q3_term_ltr
      ,gr_wide.RC6_q4_ltr AS RC6_q4_term_ltr
      ,ROUND(gr_wide.RC6_q1,0) AS RC6_q1_term_pct
      ,ROUND(gr_wide.RC6_q2,0) AS RC6_q2_term_pct
      ,ROUND(gr_wide.RC6_q3,0) AS RC6_q3_term_pct
      ,ROUND(gr_wide.RC6_q4,0) AS RC6_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC6_y1,0) AS RC6_y1_pct
      ,gr_wide.RC6_y1_ltr
      ,gr_wide.RC6_credit_hours_Y1
      --,gr_wide.RC6_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC6_y1 >= 70 THEN gr_wide.RC6_credit_hours_Y1 ELSE NULL END AS RC6_earned_crhrs      

    /*--RC7--*/
      ,gr_wide.RC7_course_name
      ,gr_wide.RC7_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC7_q1_ltr AS RC7_cur_term_ltr
      --,gr_wide.RC7_q2_ltr AS RC7_cur_term_ltr
      ,gr_wide.RC7_q3_ltr AS RC7_cur_term_ltr
      --,gr_wide.RC7_q4_ltr AS RC7_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC7_q1,0) AS RC7_cur_term_pct
      --,ROUND(gr_wide.RC7_q2,0) AS RC7_cur_term_pct
      ,ROUND(gr_wide.RC7_q3,0) AS RC7_cur_term_pct
      --,ROUND(gr_wide.RC7_q4,0) AS RC7_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC7_gpa_points_Q1 AS RC7_cur_term_gpa_points
      --,gr_wide.RC7_gpa_points_Q2 AS RC7_cur_term_gpa_points
      ,gr_wide.RC7_gpa_points_Q3 AS RC7_cur_term_gpa_points
      --,gr_wide.RC7_gpa_points_Q4 AS RC7_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC7_q1_ltr AS RC7_q1_term_ltr      
      ,gr_wide.RC7_q2_ltr AS RC7_q2_term_ltr
      ,gr_wide.RC7_q3_ltr AS RC7_q3_term_ltr
      ,gr_wide.RC7_q4_ltr AS RC7_q4_term_ltr
      ,ROUND(gr_wide.RC7_q1,0) AS RC7_q1_term_pct
      ,ROUND(gr_wide.RC7_q2,0) AS RC7_q2_term_pct
      ,ROUND(gr_wide.RC7_q3,0) AS RC7_q3_term_pct
      ,ROUND(gr_wide.RC7_q4,0) AS RC7_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC7_y1,0) AS RC7_y1_pct
      ,gr_wide.RC7_y1_ltr
      ,gr_wide.RC7_credit_hours_Y1
      --,gr_wide.RC7_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC7_y1 >= 70 THEN gr_wide.RC7_credit_hours_Y1 ELSE NULL END AS RC7_earned_crhrs
      
    /*--RC8--*/
      ,gr_wide.RC8_course_name
      ,gr_wide.RC8_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC8_q1_ltr AS RC8_cur_term_ltr
      --,gr_wide.RC8_q2_ltr AS RC8_cur_term_ltr
      ,gr_wide.RC8_q3_ltr AS RC8_cur_term_ltr
      --,gr_wide.RC8_q4_ltr AS RC8_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC8_q1,0) AS RC8_cur_term_pct
      --,ROUND(gr_wide.RC8_q2,0) AS RC8_cur_term_pct
      ,ROUND(gr_wide.RC8_q3,0) AS RC8_cur_term_pct
      --,ROUND(gr_wide.RC8_q4,0) AS RC8_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC8_gpa_points_Q1 AS RC8_cur_term_gpa_points
      --,gr_wide.RC8_gpa_points_Q2 AS RC8_cur_term_gpa_points
      ,gr_wide.RC8_gpa_points_Q3 AS RC8_cur_term_gpa_points
      --,gr_wide.RC8_gpa_points_Q4 AS RC8_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC8_q1_ltr AS RC8_q1_term_ltr      
      ,gr_wide.RC8_q2_ltr AS RC8_q2_term_ltr
      ,gr_wide.RC8_q3_ltr AS RC8_q3_term_ltr
      ,gr_wide.RC8_q4_ltr AS RC8_q4_term_ltr
      ,ROUND(gr_wide.RC8_q1,0) AS RC8_q1_term_pct
      ,ROUND(gr_wide.RC8_q2,0) AS RC8_q2_term_pct
      ,ROUND(gr_wide.RC8_q3,0) AS RC8_q3_term_pct
      ,ROUND(gr_wide.RC8_q4,0) AS RC8_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC8_y1,0) AS RC8_y1_pct
      ,gr_wide.RC8_y1_ltr
      ,gr_wide.RC8_credit_hours_Y1
      --,gr_wide.RC8_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC8_y1 >= 70 THEN gr_wide.RC8_credit_hours_Y1 ELSE NULL END AS RC8_earned_crhrs      

    /*--RC9--*/
      ,gr_wide.RC9_course_name
      ,gr_wide.RC9_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC9_q1_ltr AS RC9_cur_term_ltr
      --,gr_wide.RC9_q2_ltr AS RC9_cur_term_ltr
      ,gr_wide.RC9_q3_ltr AS RC9_cur_term_ltr
      --,gr_wide.RC9_q4_ltr AS RC9_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC9_q1,0) AS RC9_cur_term_pct
      --,ROUND(gr_wide.RC9_q2,0) AS RC9_cur_term_pct
      ,ROUND(gr_wide.RC9_q3,0) AS RC9_cur_term_pct
      --,ROUND(gr_wide.RC9_q4,0) AS RC9_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC9_gpa_points_Q1 AS RC9_cur_term_gpa_points
      --,gr_wide.RC9_gpa_points_Q2 AS RC9_cur_term_gpa_points
      ,gr_wide.RC9_gpa_points_Q3 AS RC9_cur_term_gpa_points
      --,gr_wide.RC9_gpa_points_Q4 AS RC9_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC9_q1_ltr AS RC9_q1_term_ltr      
      ,gr_wide.RC9_q2_ltr AS RC9_q2_term_ltr
      ,gr_wide.RC9_q3_ltr AS RC9_q3_term_ltr
      ,gr_wide.RC9_q4_ltr AS RC9_q4_term_ltr
      ,ROUND(gr_wide.RC9_q1,0) AS RC9_q1_term_pct
      ,ROUND(gr_wide.RC9_q2,0) AS RC9_q2_term_pct
      ,ROUND(gr_wide.RC9_q3,0) AS RC9_q3_term_pct
      ,ROUND(gr_wide.RC9_q4,0) AS RC9_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC9_y1,0) AS RC9_y1_pct
      ,gr_wide.RC9_y1_ltr
      ,gr_wide.RC9_credit_hours_Y1
      --,gr_wide.RC9_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC9_y1 >= 70 THEN gr_wide.RC9_credit_hours_Y1 ELSE NULL END AS RC9_earned_crhrs
      
    /*--RC10--*/
      ,gr_wide.RC10_course_name
      ,gr_wide.RC10_teacher_last
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,gr_wide.RC10_q1_ltr AS RC10_cur_term_ltr
      --,gr_wide.RC10_q2_ltr AS RC10_cur_term_ltr
      ,gr_wide.RC10_q3_ltr AS RC10_cur_term_ltr
      --,gr_wide.RC10_q4_ltr AS RC10_cur_term_ltr
      
         /*--UPDATE FOR CURRENT TERM--*/
      --,ROUND(gr_wide.RC10_q1,0) AS RC10_cur_term_pct
      --,ROUND(gr_wide.RC10_q2,0) AS RC10_cur_term_pct
      ,ROUND(gr_wide.RC10_q3,0) AS RC10_cur_term_pct
      --,ROUND(gr_wide.RC10_q4,0) AS RC10_cur_term_pct

         /*--UPDATE FOR CURRENT TERM--*/      
      --,gr_wide.RC10_gpa_points_Q1 AS RC10_cur_term_gpa_points
      --,gr_wide.RC10_gpa_points_Q2 AS RC10_cur_term_gpa_points
      ,gr_wide.RC10_gpa_points_Q3 AS RC10_cur_term_gpa_points
      --,gr_wide.RC10_gpa_points_Q4 AS RC10_cur_term_gpa_points
      
      /*/* -- ONLY FOR SHOWING GRADE BY QUARTER -- */
      ,gr_wide.RC10_q1_ltr AS RC10_q1_term_ltr      
      ,gr_wide.RC10_q2_ltr AS RC10_q2_term_ltr
      ,gr_wide.RC10_q3_ltr AS RC10_q3_term_ltr
      ,gr_wide.RC10_q4_ltr AS RC10_q4_term_ltr
      ,ROUND(gr_wide.RC10_q1,0) AS RC10_q1_term_pct
      ,ROUND(gr_wide.RC10_q2,0) AS RC10_q2_term_pct
      ,ROUND(gr_wide.RC10_q3,0) AS RC10_q3_term_pct
      ,ROUND(gr_wide.RC10_q4,0) AS RC10_q4_term_pct
      --*/
      
      ,ROUND(gr_wide.RC10_y1,0) AS RC10_y1_pct
      ,gr_wide.RC10_y1_ltr
      ,gr_wide.RC10_credit_hours_Y1
      --,gr_wide.RC10_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC10_y1 >= 70 THEN gr_wide.RC10_credit_hours_Y1 ELSE NULL END AS RC10_earned_crhrs      

    /*--Current component averages -- UPDATE TERM NUMBER (e.g. H1/H2/H3/H4) on FIELD to current term--*/
      /*--H--*/
      ,gr_wide.rc1_h3  AS rc1_cur_hw_pct
      ,gr_wide.rc2_h3  AS rc2_cur_hw_pct
      ,gr_wide.rc3_h3  AS rc3_cur_hw_pct
      ,gr_wide.rc4_h3  AS rc4_cur_hw_pct
      ,gr_wide.rc5_h3  AS rc5_cur_hw_pct
      ,gr_wide.rc6_h3  AS rc6_cur_hw_pct
      ,gr_wide.rc7_h3  AS rc7_cur_hw_pct
      ,gr_wide.rc8_h3  AS rc8_cur_hw_pct
      ,gr_wide.rc9_h3  AS rc9_cur_hw_pct
      ,gr_wide.rc10_h3 AS rc10_cur_hw_pct      
      /*--A--*/
      ,gr_wide.rc1_a3  AS rc1_cur_a_pct
      ,gr_wide.rc2_a3  AS rc2_cur_a_pct
      ,gr_wide.rc3_a3  AS rc3_cur_a_pct
      ,gr_wide.rc4_a3  AS rc4_cur_a_pct
      ,gr_wide.rc5_a3  AS rc5_cur_a_pct
      ,gr_wide.rc6_a3  AS rc6_cur_a_pct
      ,gr_wide.rc7_a3  AS rc7_cur_a_pct
      ,gr_wide.rc8_a3  AS rc8_cur_a_pct
      ,gr_wide.rc9_a3  AS rc9_cur_a_pct
      ,gr_wide.rc10_a3 AS rc10_cur_a_pct
      /*--CW--*/
      ,gr_wide.rc1_c3  AS rc1_cur_cw_pct
      ,gr_wide.rc2_c3  AS rc2_cur_cw_pct
      ,gr_wide.rc3_c3  AS rc3_cur_cw_pct
      ,gr_wide.rc4_c3  AS rc4_cur_cw_pct
      ,gr_wide.rc5_c3  AS rc5_cur_cw_pct
      ,gr_wide.rc6_c3  AS rc6_cur_cw_pct
      ,gr_wide.rc7_c3  AS rc7_cur_cw_pct
      ,gr_wide.rc8_c3  AS rc8_cur_cw_pct
      ,gr_wide.rc9_c3  AS rc9_cur_cw_pct
      ,gr_wide.rc10_c3 AS rc10_cur_cw_pct
      /*--P--*/
      ,gr_wide.rc1_p3  AS rc1_cur_p_pct
      ,gr_wide.rc2_p3  AS rc2_cur_p_pct
      ,gr_wide.rc3_p3  AS rc3_cur_p_pct
      ,gr_wide.rc4_p3  AS rc4_cur_p_pct
      ,gr_wide.rc5_p3  AS rc5_cur_p_pct
      ,gr_wide.rc6_p3  AS rc6_cur_p_pct
      ,gr_wide.rc7_p3  AS rc7_cur_p_pct
      ,gr_wide.rc8_p3  AS rc8_cur_p_pct
      ,gr_wide.rc9_p3  AS rc9_cur_p_pct
      ,gr_wide.rc10_p3 AS rc10_cur_p_pct
      
      
      /*--E1--*/ -- Exams, do not update
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
      /*--E2--*/
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
      ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
      ,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr
      ,ar_yr.points AS points_yr
      
      /*--AR current--*/
      /*--UPDATE TERM in JOIN--*/
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
        
      /*--UPDATE TERM in JOIN--*/
      --current for year
      ,CASE
        WHEN lex_curr.RITtoReadingScore = 'BR' THEN 'Beginning Reader'
        ELSE lex_curr.RITtoReadingScore
       END AS lexile_curr
      --,lex_curr.RITtoReadingMin AS lexile_curr_min
      --,lex_curr.RITtoReadingMax AS lexile_curr_max
      ,lex_curr.TestPercentile AS lex_curr_pct

--Comments
--PS$comments#static
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
      /*--FOR REPORT CARDS ONLY--*/
      /*
      ,comment_adv.advisor_comment  AS advisor_comment
      --*/
    
--Discipline
--DISC$merits_demerits_count#NCA
    /*--Merits--*/
       /*--Year--*/
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
       /*--Current--*/
       /*--UPDATE FIELD for current term--*/
      ,merits.teacher_merits_RT3         AS teacher_merits_curr
      ,merits.perfect_week_merits_rt3    AS perfect_week_curr
      ,merits.total_merits_rt3           AS total_merits_curr
      
    /*--Demerits--*/
       /*--Year--*/
      ,merits.tier1_demerits_rt1
        + merits.tier1_demerits_rt2
        + merits.tier1_demerits_rt3
        + merits.tier1_demerits_rt4      AS tier1_demerits_yr
       /*--Current--*/
       /*--UPDATE FIELD for current term--*/
      ,merits.tier1_demerits_rt3         AS tier1_demerits_curr

FROM roster WITH (NOLOCK)
LEFT OUTER JOIN info WITH (NOLOCK)
  ON roster.base_studentid = info.nomerge_id


--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts WITH (NOLOCK)
  ON roster.base_studentid = att_counts.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.base_studentid = att_pct.id
  
--GPA
LEFT OUTER JOIN GPA$detail#NCA nca_gpa WITH (NOLOCK)
  ON roster.base_studentid = nca_gpa.studentid
LEFT OUTER JOIN GPA$cumulative gpa_cumulative WITH (NOLOCK)
  ON roster.base_studentid = gpa_cumulative.studentid
 AND roster.schoolid = gpa_cumulative.schoolid
  
--GRADES
LEFT OUTER JOIN GRADES$wide_all#NCA gr_wide WITH (NOLOCK)
  ON roster.base_studentid = gr_wide.studentid

--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.base_studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year' 
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.base_studentid = ar_curr.studentid 
 AND ar_curr.time_period_name = 'RT3' --update every quarter
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()

  --LEXILE
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_base WITH (NOLOCK)
  ON roster.base_student_number = lex_base.StudentID
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.rn_base = 1
 AND lex_base.map_year_academic = 2013
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_curr WITH (NOLOCK)
  ON roster.base_student_number = lex_curr.StudentID
 AND lex_curr.MeasurementScale = 'Reading'
 AND lex_curr.rn_curr = 1
 AND lex_curr.map_year_academic = 2013

--/* 
--GRADEBOOK COMMMENTS -- upadate FIELD and PARAMETER for current term
LEFT OUTER JOIN PS$comments#static comment_rc1 WITH (NOLOCK)
  ON gr_wide.rc1_Q3_enr_sectionid = comment_rc1.sectionid
 AND gr_wide.studentid = comment_rc1.id
 AND comment_rc1.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc2 WITH (NOLOCK)
  ON gr_wide.rc2_Q3_enr_sectionid = comment_rc2.sectionid
 AND gr_wide.studentid = comment_rc2.id
 AND comment_rc2.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc3 WITH (NOLOCK)
  ON gr_wide.rc3_Q3_enr_sectionid = comment_rc3.sectionid
 AND gr_wide.studentid = comment_rc3.id
 AND comment_rc3.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc4 WITH (NOLOCK)
  ON gr_wide.rc4_Q3_enr_sectionid = comment_rc4.sectionid
 AND gr_wide.studentid = comment_rc4.id
 AND comment_rc4.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc5 WITH (NOLOCK)
  ON gr_wide.rc5_Q3_enr_sectionid = comment_rc5.sectionid
 AND gr_wide.studentid = comment_rc5.id
 AND comment_rc5.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc6 WITH (NOLOCK)
  ON gr_wide.rc6_Q3_enr_sectionid = comment_rc6.sectionid
 AND gr_wide.studentid = comment_rc6.id
 AND comment_rc6.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc7 WITH (NOLOCK)
  ON gr_wide.rc7_Q3_enr_sectionid = comment_rc7.sectionid
 AND gr_wide.studentid = comment_rc7.id
 AND comment_rc7.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc8 WITH (NOLOCK)
  ON gr_wide.rc8_Q3_enr_sectionid = comment_rc8.sectionid
 AND gr_wide.studentid = comment_rc8.id
 AND comment_rc8.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc9 WITH (NOLOCK)
  ON gr_wide.rc9_Q3_enr_sectionid = comment_rc9.sectionid
 AND gr_wide.studentid = comment_rc9.id
 AND comment_rc9.finalgradename = 'Q3'
LEFT OUTER JOIN PS$comments#static comment_rc10 WITH (NOLOCK)
  ON gr_wide.rc10_Q3_enr_sectionid = comment_rc10.sectionid
 AND gr_wide.studentid = comment_rc10.id
 AND comment_rc10.finalgradename = 'Q3'
/* ONLY USED ON RC
LEFT OUTER JOIN PS$comments#static comment_adv WITH (NOLOCK)
  ON roster.base_studentid = comment_adv.id
 AND comment_adv.finalgradename = 'Q3'
 AND comment_adv.course_number = 'HR'
--*/

--MERITS & DEMERITS
LEFT OUTER JOIN DISC$merits_demerits_count#NCA merits WITH (NOLOCK)
  ON roster.base_studentid = merits.studentid