--this is hack as of 9/14
--only shows 5 core credit types
--dependent on grades$wide_credittype#MS (which is dependent on grades$detail_placeholder#MS)


USE KIPP_NJ
GO

--ALTER VIEW REPORTING$progress_tracker#TEAM AS

SELECT TOP 100 PERCENT sub.*
FROM
(
SELECT  s.id
       ,s.student_number
       ,s.schoolid
       ,s.lastfirst
       ,s.grade_level
       
       ,custom.advisor
       ,custom.SPEDLEP
       
       ,promo.promo_status_overall
       ,promo.promo_status_att
       ,promo.promo_status_grades
       ,promo.attendance_points 

       ,att_counts.absences_total           AS Y1_absences_total
       ,att_counts.absences_undoc           AS Y1_absences_undoc
       ,ROUND(att_pct.Y1_att_pct_total,0)   AS Y1_att_pct_total
       ,ROUND(att_pct.Y1_att_pct_undoc,0)   AS Y1_att_pct_undoc      
       ,att_counts.tardies_total            AS Y1_tardies_total
       ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total
              
       ,gpa.gpa_Y1_weighted_all
       ,gpa.gpa_Y1_weighted_core
       ,gpa.gpa_T1_weighted_all
       ,gpa.gpa_T2_weighted_all
       ,gpa.gpa_T3_weighted_all

       
       ,grades.rc1_course_number
       ,grades.rc1_credittype
       ,grades.rc1_course_name
       ,grades.rc1_teacher_last
       ,grades.rc1_teacher_lastfirst
       ,grades.rc1_t1
       ,grades.rc1_t2
       ,grades.rc1_t3
       ,grades.rc1_y1
       ,grades.rc1_t1_ltr
       ,grades.rc1_t2_ltr
       ,grades.rc1_t3_ltr
       ,grades.rc1_y1_ltr
       ,grades.rc1_H1
       ,grades.rc1_H2
       ,grades.rc1_H3
       ,grades.rc1_A1
       ,grades.rc1_A2
       ,grades.rc1_A3
       ,grades.rc2_course_number
       ,grades.rc2_credittype
       ,grades.rc2_course_name
       ,grades.rc2_teacher_last
       ,grades.rc2_teacher_lastfirst
       ,grades.rc2_t1
       ,grades.rc2_t2
       ,grades.rc2_t3
       ,grades.rc2_y1
       ,grades.rc2_t1_ltr
       ,grades.rc2_t2_ltr
       ,grades.rc2_t3_ltr
       ,grades.rc2_y1_ltr
       ,grades.rc2_H1
       ,grades.rc2_H2
       ,grades.rc2_H3
       ,grades.rc2_A1
       ,grades.rc2_A2
       ,grades.rc2_A3
       ,grades.rc3_course_number
       ,grades.rc3_credittype
       ,grades.rc3_course_name
       ,grades.rc3_teacher_last
       ,grades.rc3_teacher_lastfirst
       ,grades.rc3_t1
       ,grades.rc3_t2
       ,grades.rc3_t3
       ,grades.rc3_y1
       ,grades.rc3_t1_ltr
       ,grades.rc3_t2_ltr
       ,grades.rc3_t3_ltr
       ,grades.rc3_y1_ltr
       ,grades.rc3_H1
       ,grades.rc3_H2
       ,grades.rc3_H3
       ,grades.rc3_A1
       ,grades.rc3_A2
       ,grades.rc3_A3
       ,grades.rc4_course_number
       ,grades.rc4_credittype
       ,grades.rc4_course_name
       ,grades.rc4_teacher_last
       ,grades.rc4_teacher_lastfirst
       ,grades.rc4_t1
       ,grades.rc4_t2
       ,grades.rc4_t3
       ,grades.rc4_y1
       ,grades.rc4_t1_ltr
       ,grades.rc4_t2_ltr
       ,grades.rc4_t3_ltr
       ,grades.rc4_y1_ltr
       ,grades.rc4_H1
       ,grades.rc4_H2
       ,grades.rc4_H3
       ,grades.rc4_A1
       ,grades.rc4_A2
       ,grades.rc4_A3
       ,grades.rc5_course_number
       ,grades.rc5_credittype
       ,grades.rc5_course_name
       ,grades.rc5_teacher_last
       ,grades.rc5_teacher_lastfirst
       ,grades.rc5_t1
       ,grades.rc5_t2
       ,grades.rc5_t3
       ,grades.rc5_y1
       ,grades.rc5_t1_ltr
       ,grades.rc5_t2_ltr
       ,grades.rc5_t3_ltr
       ,grades.rc5_y1_ltr
       ,grades.rc5_H1
       ,grades.rc5_H2
       ,grades.rc5_H3
       ,grades.rc5_A1
       ,grades.rc5_A2
       ,grades.rc5_A3


       
FROM STUDENTS s

LEFT OUTER JOIN GRADES$wide_credit_core#MS grades
  ON s.ID = grades.studentid

LEFT OUTER JOIN GPA$detail#TEAM gpa
  ON s.id = gpa.studentid

LEFT OUTER JOIN CUSTOM_STUDENTS custom
  ON s.id = custom.studentid

LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts
  ON s.id = att_counts.id

LEFT OUTER JOIN ATT_MEM$att_percentages att_pct
  ON s.id = att_pct.id

LEFT OUTER JOIN REPORTING$promo_status#TEAM promo
  ON s.id = promo.studentid

WHERE s.schoolid = 133570965
  AND s.enroll_status = 0
)sub
ORDER BY grade_level, lastfirst
