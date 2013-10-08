--this is hack as of 9/14
--only shows 5 core credit types
--dependent on grades$wide_credittype#MS (which is dependent on grades$detail_placeholder#MS)


USE KIPP_NJ
GO

--ALTER VIEW REPORTING$progress_tracker#Rise AS

WITH roster AS
       (SELECT --add "Count" to Excel quesry, ORDER BY grade_level, lastfirst
               s.id
              ,s.student_number
              ,s.schoolid
              ,s.lastfirst
              ,s.grade_level
              ,s.team
              ,cs.advisor       
              ,cs.SPEDLEP
              ,s.gender
              ,s.mother
              ,s.father       
              ,s.home_phone
              ,cs.mother_cell
              ,cs.mother_home
              ,cs.father_cell
              ,cs.father_home
              ,cs.guardianemail AS contactemail
        FROM STUDENTS s
        LEFT OUTER JOIN CUSTOM_STUDENTS cs
          ON s.id = cs.studentid
        WHERE s.schoolid = 73252
          AND s.enroll_status = 0
          AND s.id = 4686
       )
       
SELECT roster.*
       
--ATTENDANCE
      --yr
      ,att_counts.absences_total           AS Y1_absences_total
      ,att_counts.absences_undoc           AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
      ,att_counts.tardies_total            AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total
      --cur   
      ,att_counts.cur_absences_total           AS curterm_absences_total
      ,att_counts.cur_absences_undoc           AS curterm_absences_undoc
      ,ROUND(att_pct.cur_att_pct_total,0)      AS curterm_att_pct_total
      ,ROUND(att_pct.cur_att_pct_undoc,0)      AS curterm_att_pct_undoc      
      ,att_counts.cur_tardies_total            AS curterm_tardies_total
      ,ROUND(att_pct.cur_tardy_pct_total,0)    AS curterm_tardy_pct_total

--PROMOTIONAL STATUS
      ,promo.attendance_points
      ,ROUND(promo.y1_att_pts_pct,1) AS ATT_POINTS_PCT
      ,promo.att_string
      ,promo.promo_status_overall      
      ,promo.GPA_Promo_Status_Grades
      ,promo.promo_status_att
      ,promo.promo_status_hw
      ,CASE
        WHEN (ROUND((((membership_counts.mem *.105)-promo.attendance_points)/-.105)+.5,0)) <='0'
        THEN NULL
        ELSE(ROUND((((membership_counts.mem *.105)-promo.attendance_points)/-.105)+.5,0))
       END AS days_to_perfect

--GPA
      ,CONVERT(FLOAT,gpa.gpa_t1) AS gpa_t1
      ,gpa.GPA_T1_Rank_G AS GPA_T1_RANK
      ,CONVERT(FLOAT,gpa.gpa_t2) AS gpa_t2
      ,gpa.GPA_T2_Rank_G AS GPA_T2_RANK
      ,CONVERT(FLOAT,gpa.GPA_t3) AS gpa_t3
      ,gpa.GPA_T3_Rank_G AS GPA_T3_RANK
      ,CONVERT(FLOAT,gpa.gpa_y1) AS gpa_y1       
      ,gpa.GPA_Y1_Rank_G AS GPA_Y1_RANK

--COURSE GRADES
      ,grades.rc1_course_number
      ,grades.rc1_credittype
      ,grades.rc1_course_name
      ,grades.rc1_teacher_last
      ,grades.rc1_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc1_t1) AS rc1_t1
      ,CONVERT(FLOAT,grades.rc1_t2) AS rc1_t2
      ,CONVERT(FLOAT,grades.rc1_t3) AS rc1_t3
      ,CONVERT(FLOAT,grades.rc1_y1) AS rc1_y1
      ,grades.rc1_t1_ltr
      ,grades.rc1_t2_ltr
      ,grades.rc1_t3_ltr
      ,grades.rc1_y1_ltr
      ,CONVERT(FLOAT,grades.rc1_H1) AS rc1_H1
      ,CONVERT(FLOAT,grades.rc1_H2) AS rc1_H2
      ,CONVERT(FLOAT,grades.rc1_H3) AS rc1_H3
      ,CONVERT(FLOAT,grades.rc1_A1) AS rc1_A1
      ,CONVERT(FLOAT,grades.rc1_A2) AS rc1_A2
      ,CONVERT(FLOAT,grades.rc1_A3) AS rc1_A3
      ,CONVERT(FLOAT,grades.rc1_Q1) AS rc1_Q1
      ,CONVERT(FLOAT,grades.rc1_Q2) AS rc1_Q2
      ,CONVERT(FLOAT,grades.rc1_Q3) AS rc1_Q3
      ,grades.rc2_course_number
      ,grades.rc2_credittype
      ,grades.rc2_course_name
      ,grades.rc2_teacher_last
      ,grades.rc2_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc2_t1) AS rc2_t1
      ,CONVERT(FLOAT,grades.rc2_t2) AS rc2_t2
      ,CONVERT(FLOAT,grades.rc2_t3) AS rc2_t3
      ,CONVERT(FLOAT,grades.rc2_y1) AS rc2_y1
      ,grades.rc2_t1_ltr
      ,grades.rc2_t2_ltr
      ,grades.rc2_t3_ltr
      ,grades.rc2_y1_ltr
      ,CONVERT(FLOAT,grades.rc2_H1) AS rc2_H1
      ,CONVERT(FLOAT,grades.rc2_H2) AS rc2_H2
      ,CONVERT(FLOAT,grades.rc2_H3) AS rc2_H3
      ,CONVERT(FLOAT,grades.rc2_A1) AS rc2_A1
      ,CONVERT(FLOAT,grades.rc2_A2) AS rc2_A2
      ,CONVERT(FLOAT,grades.rc2_A3) AS rc2_A3
      ,CONVERT(FLOAT,grades.rc2_Q1) AS rc2_Q1
      ,CONVERT(FLOAT,grades.rc2_Q2) AS rc2_Q2
      ,CONVERT(FLOAT,grades.rc2_Q3) AS rc2_Q3
      ,grades.rc3_course_number
      ,grades.rc3_credittype
      ,grades.rc3_course_name
      ,grades.rc3_teacher_last
      ,grades.rc3_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc3_t1) AS rc3_t1
      ,CONVERT(FLOAT,grades.rc3_t2) AS rc3_t2
      ,CONVERT(FLOAT,grades.rc3_t3) AS rc3_t3
      ,CONVERT(FLOAT,grades.rc3_y1) AS rc3_y1
      ,grades.rc3_t1_ltr
      ,grades.rc3_t2_ltr
      ,grades.rc3_t3_ltr
      ,grades.rc3_y1_ltr
      ,CONVERT(FLOAT,grades.rc3_H1) AS rc3_H1
      ,CONVERT(FLOAT,grades.rc3_H2) AS rc3_H2
      ,CONVERT(FLOAT,grades.rc3_H3) AS rc3_H3
      ,CONVERT(FLOAT,grades.rc3_A1) AS rc3_A1
      ,CONVERT(FLOAT,grades.rc3_A2) AS rc3_A2
      ,CONVERT(FLOAT,grades.rc3_A3) AS rc3_A3
      ,CONVERT(FLOAT,grades.rc3_Q1) AS rc3_Q1
      ,CONVERT(FLOAT,grades.rc3_Q2) AS rc3_Q2
      ,CONVERT(FLOAT,grades.rc3_Q3) AS rc3_Q3
      ,grades.rc4_course_number
      ,grades.rc4_credittype
      ,grades.rc4_course_name
      ,grades.rc4_teacher_last
      ,grades.rc4_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc4_t1) AS rc4_t1
      ,CONVERT(FLOAT,grades.rc4_t2) AS rc4_t2
      ,CONVERT(FLOAT,grades.rc4_t3) AS rc4_t3
      ,CONVERT(FLOAT,grades.rc4_y1) AS rc4_y1
      ,grades.rc4_t1_ltr
      ,grades.rc4_t2_ltr
      ,grades.rc4_t3_ltr
      ,grades.rc4_y1_ltr
      ,CONVERT(FLOAT,grades.rc4_H1) AS rc4_H1
      ,CONVERT(FLOAT,grades.rc4_H2) AS rc4_H2
      ,CONVERT(FLOAT,grades.rc4_H3) AS rc4_H3
      ,CONVERT(FLOAT,grades.rc4_A1) AS rc4_A1
      ,CONVERT(FLOAT,grades.rc4_A2) AS rc4_A2
      ,CONVERT(FLOAT,grades.rc4_A3) AS rc4_A3
      ,CONVERT(FLOAT,grades.rc4_Q1) AS rc4_Q1
      ,CONVERT(FLOAT,grades.rc4_Q2) AS rc4_Q2
      ,CONVERT(FLOAT,grades.rc4_Q3) AS rc4_Q3
      ,grades.rc5_course_number
      ,grades.rc5_credittype
      ,grades.rc5_course_name
      ,grades.rc5_teacher_last
      ,grades.rc5_teacher_lastfirst
      ,CONVERT(FLOAT,grades.rc5_t1) AS rc5_t1
      ,CONVERT(FLOAT,grades.rc5_t2) AS rc5_t2
      ,CONVERT(FLOAT,grades.rc5_t3) AS rc5_t3
      ,CONVERT(FLOAT,grades.rc5_y1) AS rc5_y1
      ,grades.rc5_t1_ltr
      ,grades.rc5_t2_ltr
      ,grades.rc5_t3_ltr
      ,grades.rc5_y1_ltr
      ,CONVERT(FLOAT,grades.rc5_H1) AS rc5_H1
      ,CONVERT(FLOAT,grades.rc5_H2) AS rc5_H2
      ,CONVERT(FLOAT,grades.rc5_H3) AS rc5_H3
      ,CONVERT(FLOAT,grades.rc5_A1) AS rc5_A1
      ,CONVERT(FLOAT,grades.rc5_A2) AS rc5_A2
      ,CONVERT(FLOAT,grades.rc5_A3) AS rc5_A3
      ,CONVERT(FLOAT,grades.rc5_Q1) AS rc5_Q1
      ,CONVERT(FLOAT,grades.rc5_Q2) AS rc5_Q2
      ,CONVERT(FLOAT,grades.rc5_Q3) AS rc5_Q3
      
     --Accelerated Reader
     --update terms in JOIN
     --AR year
     ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
     ,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr      
     ,ar_yr.rank_words_grade_in_school AS words_rank_yr_in_grade
     ,ar_yr.mastery AS mastery_yr
     
     --AR current
     ,replace(convert(varchar,convert(Money, ar_curr.words),1),'.00','') AS words_read_cur_term
     ,replace(convert(varchar,convert(Money, ar_curr.words_goal),1),'.00','') AS words_goal_cur_term
     ,ar_curr.rank_words_grade_in_school AS words_rank_cur_term_in_grade
     ,ar_curr.mastery AS mastery_curr
      
      --AR progress
        --to year goal      
     ,CASE
       WHEN ar_yr.stu_status_words = 'On Track' THEN 'Yes!'
       WHEN ar_yr.stu_status_words = 'Off Track' THEN 'No'
       ELSE ar_yr.stu_status_words
      END AS stu_status_words_yr   
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, CAST(ROUND(
         CASE
          WHEN ((ar_curr.words_goal * 6) - ar_yr.words) <= 0 THEN NULL 
          ELSE (ar_curr.words_goal * 6) - ar_yr.words
         END
            ,0) AS INT)),1),'.00','') AS words_needed_yr
      --to term goal       
     ,CASE
       WHEN ar_curr.stu_status_words = 'On Track' THEN 'Yes!'
       WHEN ar_curr.stu_status_words = 'Off Track' THEN 'No'
       ELSE ar_curr.stu_status_words
      END AS stu_status_words_cur_term      
     ,REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, CAST(ROUND(
         CASE
          WHEN (ar_curr.words_goal - ar_curr.words) <= 0 THEN NULL 
          ELSE ar_curr.words_goal - ar_curr.words
         END
            ,0) AS INT)),1),'.00','') AS words_needed_cur_term
     ,gpa.Y1_Dem AS IN_GRADE_DENOM
      
FROM roster

LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts
  ON roster.id = att_counts.id
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct
  ON roster.id = att_pct.id
LEFT OUTER JOIN ATT_MEM$membership_counts membership_counts
  ON roster.id = membership_counts.id



LEFT OUTER JOIN GRADES$wide_credit_core#MS grades
  ON roster.ID = grades.studentid

LEFT OUTER JOIN GPA$detail#Rise gpa
  ON roster.id = gpa.studentid

LEFT OUTER JOIN REPORTING$promo_status#Rise promo
  ON roster.id = promo.studentid
  
--ED TECH
  --ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr
  ON roster.id = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr
  ON roster.id = ar_curr.studentid 
 AND ar_curr.time_period_name = 'RT1'
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()