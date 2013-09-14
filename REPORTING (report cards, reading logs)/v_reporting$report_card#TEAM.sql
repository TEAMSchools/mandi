USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card#TEAM AS
WITH roster AS
     (SELECT s.student_number AS base_student_number
            ,s.id AS base_studentid
            ,s.lastfirst AS stu_lastfirst
            ,s.first_name AS stu_firstname
            ,s.last_name AS stu_lastname
            ,c.grade_level AS stu_grade_level
            ,s.team AS travel_group            
      FROM KIPP_NJ..COHORT$comprehensive_long#static c      
      JOIN KIPP_NJ..STUDENTS s
        ON c.studentid = s.id
       AND s.enroll_status = 0
       --AND s.ID = 2360
       --AND s.ID BETWEEN 2360 AND 3000    
      WHERE year = 2013
        AND c.rn = 1        
        AND c.schoolid = 133570965
     )

    ,info AS
    (SELECT s.id
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
     FROM KIPP_NJ..PS$CUSTOM_STUDENTS cs
     JOIN KIPP_NJ..STUDENTS s
       ON cs.studentid = s.id
      AND s.enroll_status = 0
     JOIN KIPP_NJ..PS$local_emails local
       ON cs.studentid = local.studentid
    )       
  
SELECT roster.*
      ,info.*
      
--GRADES$wide_all, course grades
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last            
      ,gr_wide.rc1_t1_ltr AS rc1_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc1_T1,0) AS rc1_cur_term_pct --change field name for current term
      ,gr_wide.rc1_T1_ltr AS rc1_T1_term_ltr
      ,gr_wide.rc1_T2_ltr AS rc1_T2_term_ltr
      ,gr_wide.rc1_T3_ltr AS rc1_T3_term_ltr
      ,ROUND(gr_wide.rc1_T1,0) AS rc1_T1_term_pct
      ,ROUND(gr_wide.rc1_T2,0) AS rc1_T2_term_pct
      ,ROUND(gr_wide.rc1_T3,0) AS rc1_T3_term_pct
      ,ROUND(gr_wide.rc1_y1,0) AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      
      ,gr_wide.rc2_course_name
      ,gr_wide.rc2_teacher_last            
      ,gr_wide.rc2_t1_ltr AS rc2_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc2_T1,0) AS rc2_cur_term_pct --change field name for current term
      ,gr_wide.rc2_T1_ltr AS rc2_T1_term_ltr
      ,gr_wide.rc2_T2_ltr AS rc2_T2_term_ltr
      ,gr_wide.rc2_T3_ltr AS rc2_T3_term_ltr
      ,ROUND(gr_wide.rc2_T1,0) AS rc2_T1_term_pct
      ,ROUND(gr_wide.rc2_T2,0) AS rc2_T2_term_pct
      ,ROUND(gr_wide.rc2_T3,0) AS rc2_T3_term_pct
      ,ROUND(gr_wide.rc2_y1,0) AS rc2_y1_pct
      ,gr_wide.rc2_y1_ltr
      
      ,gr_wide.rc3_course_name
      ,gr_wide.rc3_teacher_last            
      ,gr_wide.rc3_t1_ltr AS rc3_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc3_T1,0) AS rc3_cur_term_pct --change field name for current term
      ,gr_wide.rc3_T1_ltr AS rc3_T1_term_ltr
      ,gr_wide.rc3_T2_ltr AS rc3_T2_term_ltr
      ,gr_wide.rc3_T3_ltr AS rc3_T3_term_ltr
      ,ROUND(gr_wide.rc3_T1,0) AS rc3_T1_term_pct
      ,ROUND(gr_wide.rc3_T2,0) AS rc3_T2_term_pct
      ,ROUND(gr_wide.rc3_T3,0) AS rc3_T3_term_pct
      ,ROUND(gr_wide.rc3_y1,0) AS rc3_y1_pct
      ,gr_wide.rc3_y1_ltr
      
      ,gr_wide.rc4_course_name
      ,gr_wide.rc4_teacher_last            
      ,gr_wide.rc4_t1_ltr AS rc4_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc4_T1,0) AS rc4_cur_term_pct --change field name for current term
      ,gr_wide.rc4_T1_ltr AS rc4_T1_term_ltr
      ,gr_wide.rc4_T2_ltr AS rc4_T2_term_ltr
      ,gr_wide.rc4_T3_ltr AS rc4_T3_term_ltr
      ,ROUND(gr_wide.rc4_T1,0) AS rc4_T1_term_pct
      ,ROUND(gr_wide.rc4_T2,0) AS rc4_T2_term_pct
      ,ROUND(gr_wide.rc4_T3,0) AS rc4_T3_term_pct
      ,ROUND(gr_wide.rc4_y1,0) AS rc4_y1_pct
      ,gr_wide.rc4_y1_ltr
      
      ,gr_wide.rc5_course_name
      ,gr_wide.rc5_teacher_last            
      ,gr_wide.rc5_t1_ltr AS rc5_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc5_T1,0) AS rc5_cur_term_pct --change field name for current term
      ,gr_wide.rc5_T1_ltr AS rc5_T1_term_ltr
      ,gr_wide.rc5_T2_ltr AS rc5_T2_term_ltr
      ,gr_wide.rc5_T3_ltr AS rc5_T3_term_ltr
      ,ROUND(gr_wide.rc5_T1,0) AS rc5_T1_term_pct
      ,ROUND(gr_wide.rc5_T2,0) AS rc5_T2_term_pct
      ,ROUND(gr_wide.rc5_T3,0) AS rc5_T3_term_pct
      ,ROUND(gr_wide.rc5_y1,0) AS rc5_y1_pct
      ,gr_wide.rc5_y1_ltr
      
      ,gr_wide.rc6_course_name
      ,gr_wide.rc6_teacher_last            
      ,gr_wide.rc6_t1_ltr AS rc6_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc6_T1,0) AS rc6_cur_term_pct --change field name for current term
      ,gr_wide.rc6_T1_ltr AS rc6_T1_term_ltr
      ,gr_wide.rc6_T2_ltr AS rc6_T2_term_ltr
      ,gr_wide.rc6_T3_ltr AS rc6_T3_term_ltr
      ,ROUND(gr_wide.rc6_T1,0) AS rc6_T1_term_pct
      ,ROUND(gr_wide.rc6_T2,0) AS rc6_T2_term_pct
      ,ROUND(gr_wide.rc6_T3,0) AS rc6_T3_term_pct
      ,ROUND(gr_wide.rc6_y1,0) AS rc6_y1_pct
      ,gr_wide.rc6_y1_ltr
      
      ,gr_wide.rc7_course_name
      ,gr_wide.rc7_teacher_last            
      ,gr_wide.rc7_t1_ltr AS rc7_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc7_T1,0) AS rc7_cur_term_pct --change field name for current term
      ,gr_wide.rc7_T1_ltr AS rc7_T1_term_ltr
      ,gr_wide.rc7_T2_ltr AS rc7_T2_term_ltr
      ,gr_wide.rc7_T3_ltr AS rc7_T3_term_ltr
      ,ROUND(gr_wide.rc7_T1,0) AS rc7_T1_term_pct
      ,ROUND(gr_wide.rc7_T2,0) AS rc7_T2_term_pct
      ,ROUND(gr_wide.rc7_T3,0) AS rc7_T3_term_pct
      ,ROUND(gr_wide.rc7_y1,0) AS rc7_y1_pct
      ,gr_wide.rc7_y1_ltr
      
      ,gr_wide.rc8_course_name
      ,gr_wide.rc8_teacher_last            
      ,gr_wide.rc8_t1_ltr AS rc8_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc8_T1,0) AS rc8_cur_term_pct --change field name for current term
      ,gr_wide.rc8_T1_ltr AS rc8_T1_term_ltr
      ,gr_wide.rc8_T2_ltr AS rc8_T2_term_ltr
      ,gr_wide.rc8_T3_ltr AS rc8_T3_term_ltr
      ,ROUND(gr_wide.rc8_T1,0) AS rc8_T1_term_pct
      ,ROUND(gr_wide.rc8_T2,0) AS rc8_T2_term_pct
      ,ROUND(gr_wide.rc8_T3,0) AS rc8_T3_term_pct
      ,ROUND(gr_wide.rc8_y1,0) AS rc8_y1_pct
      ,gr_wide.rc8_y1_ltr
      
      ,gr_wide.rc9_course_name
      ,gr_wide.rc9_teacher_last            
      ,gr_wide.rc9_t1_ltr AS rc9_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc9_T1,0) AS rc9_cur_term_pct --change field name for current term
      ,gr_wide.rc9_T1_ltr AS rc9_T1_term_ltr
      ,gr_wide.rc9_T2_ltr AS rc9_T2_term_ltr
      ,gr_wide.rc9_T3_ltr AS rc9_T3_term_ltr
      ,ROUND(gr_wide.rc9_T1,0) AS rc9_T1_term_pct
      ,ROUND(gr_wide.rc9_T2,0) AS rc9_T2_term_pct
      ,ROUND(gr_wide.rc9_T3,0) AS rc9_T3_term_pct
      ,ROUND(gr_wide.rc9_y1,0) AS rc9_y1_pct
      ,gr_wide.rc9_y1_ltr
      
      ,gr_wide.rc10_course_name
      ,gr_wide.rc10_teacher_last            
      ,gr_wide.rc10_t1_ltr AS rc10_cur_term_ltr      --change field name for current term
      ,ROUND(gr_wide.rc10_T1,0) AS rc10_cur_term_pct --change field name for current term
      ,gr_wide.rc10_T1_ltr AS rc10_T1_term_ltr
      ,gr_wide.rc10_T2_ltr AS rc10_T2_term_ltr
      ,gr_wide.rc10_T3_ltr AS rc10_T3_term_ltr
      ,ROUND(gr_wide.rc10_T1,0) AS rc10_T1_term_pct
      ,ROUND(gr_wide.rc10_T2,0) AS rc10_T2_term_pct
      ,ROUND(gr_wide.rc10_T3,0) AS rc10_T3_term_pct
      ,ROUND(gr_wide.rc10_y1,0) AS rc10_y1_pct
      ,gr_wide.rc10_y1_ltr

      --current term component averages -- change term number (e.g. H1) on component fields for current term
      --H
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_H1  END AS rc1_cur_hw_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_H1  END AS rc2_cur_hw_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_H1  END AS rc3_cur_hw_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_H1  END AS rc4_cur_hw_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_H1  END AS rc5_cur_hw_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_H1  END AS rc6_cur_hw_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_H1  END AS rc7_cur_hw_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_H1  END AS rc8_cur_hw_pct
      ,CASE WHEN gr_wide.rc9_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc9_H1  END AS rc9_cur_hw_pct
      ,CASE WHEN gr_wide.rc10_credittype = 'COCUR' THEN NULL ELSE gr_wide.rc10_H1 END AS rc10_cur_hw_pct
      --A
      ,CASE WHEN gr_wide.rc1_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc1_A1  END AS rc1_cur_assess_pct
      ,CASE WHEN gr_wide.rc2_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc2_A1  END AS rc2_cur_assess_pct
      ,CASE WHEN gr_wide.rc3_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc3_A1  END AS rc3_cur_assess_pct
      ,CASE WHEN gr_wide.rc4_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc4_A1  END AS rc4_cur_assess_pct
      ,CASE WHEN gr_wide.rc5_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc5_A1  END AS rc5_cur_assess_pct
      ,CASE WHEN gr_wide.rc6_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc6_A1  END AS rc6_cur_assess_pct
      ,CASE WHEN gr_wide.rc7_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc7_A1  END AS rc7_cur_assess_pct
      ,CASE WHEN gr_wide.rc8_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc8_A1  END AS rc8_cur_assess_pct
      ,CASE WHEN gr_wide.rc9_credittype  = 'COCUR' THEN NULL ELSE gr_wide.rc9_A1  END AS rc9_cur_assess_pct
      ,CASE WHEN gr_wide.rc10_credittype = 'COCUR' THEN NULL ELSE gr_wide.rc10_A1 END AS rc10_cur_assess_pct      

--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts
      ,att_counts.absences_total           AS Y1_absences_total
      ,att_counts.absences_undoc           AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
      ,att_counts.tardies_total            AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total
      
      --change field name for current term
      ,att_counts.RT1_absences_total        AS curterm_absences_total
      ,att_counts.RT1_absences_undoc        AS curterm_absences_undoc
      ,ROUND(att_pct.RT1_att_pct_total,0)   AS curterm_att_pct_total
      ,ROUND(att_pct.RT1_att_pct_undoc,0)   AS curterm_att_pct_undoc      
      ,att_counts.RT1_tardies_total         AS curterm_tardies_total
      ,ROUND(att_pct.RT1_tardy_pct_total,0) AS curterm_tardy_pct_total

--GPA$detail#TEAM
      --change field name for current term
      ,team_gpa.gpa_T1_weighted_all  as gpa_curterm_all
      ,team_gpa.gpa_T1_weighted_core as gpa_curterm_core
      
      ,team_gpa.gpa_Y1_weighted_all  as gpa_y1_all
      ,team_gpa.gpa_Y1_weighted_core as gpa_y1_core
      
--REPORTING$promo_status#TEAM
      ,promo.promo_status_overall
      ,promo.promo_status_att
      ,promo.promo_status_grades
      ,promo.attendance_points 

FROM roster
--INFO
LEFT OUTER JOIN info
  ON roster.base_studentid = info.id

--GRADES
LEFT OUTER JOIN GRADES$wide_all#MS gr_wide
  ON roster.base_studentid = gr_wide.studentid

--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts
  ON roster.base_studentid = att_counts.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct
  ON roster.base_studentid = att_pct.id

--GPA
LEFT OUTER JOIN GPA$detail#TEAM team_gpa
  ON roster.base_studentid = team_gpa.studentid

--PROMO STATUS  
LEFT OUTER JOIN REPORTING$promo_status#TEAM promo
  ON roster.base_studentid = promo.studentid
--ORDER BY stu_grade_level, travel_group, stu_lastfirst