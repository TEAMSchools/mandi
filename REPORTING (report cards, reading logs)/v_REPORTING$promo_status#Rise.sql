USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_status#Rise AS
SELECT studentid
      ,student_number
      ,attendance_points
      ,y1_att_pts_pct
      ,att_string
      ,GPA_Promo_Status_Grades
      ,promo_status_att
      ,promo_status_hw
      ,CASE 
        WHEN GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw LIKE 'HonorsHonorsHonors' THEN 'Honors'
        WHEN GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw LIKE 'High HonorsHonorsHonors' THEN 'Honors'
        WHEN GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw LIKE '%Off Track%' THEN 'Off Track'
        WHEN GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw LIKE '%Warning%' THEN 'Warning'
        ELSE 'Satisfactory' 
       END AS promo_status_overall
FROM 
     (SELECT studentid
            ,student_number
            ,attendance_points
            ,y1_att_pts_pct
            ,att_string
            ,promo_status_grades
            ,CASE 
               WHEN y1_att_pts_pct < 90 THEN 'Off Track'
               WHEN y1_att_pts_pct < 92 THEN 'Warning'
               WHEN y1_att_pts_pct >= 98 THEN 'Honors'
               ELSE 'Satisfactory' 
             END AS promo_status_att
            ,CASE 
               WHEN simple_avg < 65 THEN 'Off Track'
               WHEN simple_avg < 70 THEN 'Warning'
               WHEN simple_avg >= 90 THEN 'Honors'
               ELSE 'Satisfactory' 
             END AS promo_status_hw
            ,CASE 
               WHEN GPA >= 3   AND GPA <3.5 AND promo_status_grades NOT LIKE '%Warning%' THEN 'Honors' 
               WHEN GPA >= 3.5 AND promo_status_grades NOT LIKE '%Warning%' THEN 'High Honors' 
               ELSE promo_status_grades 
             END AS GPA_Promo_Status_Grades
     FROM
          (SELECT s.id AS studentid
                 ,s.student_number
                 ,CASE 
                   WHEN (gr_wide.rc1_y1 < 65 OR
                         gr_wide.rc2_y1 < 65 OR
                         gr_wide.rc3_y1 < 65 OR
                         gr_wide.rc4_y1 < 65 OR
                         gr_wide.rc5_y1 < 65 OR
                         gr_wide.rc6_y1 < 65 OR
                         gr_wide.rc7_y1 < 65 OR
                         gr_wide.rc8_y1 < 65) 
                         THEN 'Off Track'
                   WHEN (gr_wide.rc1_y1 < 70 OR
                         gr_wide.rc2_y1 < 70 OR
                         gr_wide.rc3_y1 < 70 OR
                         gr_wide.rc4_y1 < 70 OR
                         gr_wide.rc5_y1 < 70 OR
                         gr_wide.rc6_y1 < 70 OR
                         gr_wide.rc7_y1 < 70 OR
                         gr_wide.rc8_y1 < 70) 
                         THEN 'Warning'
/*
                   WHEN (NVL(gr_wide.rc1_y1,100) >= 85 AND
                         NVL(gr_wide.rc2_y1,100) >= 85 AND
                         NVL(gr_wide.rc3_y1,100) >= 85 AND
                         NVL(gr_wide.rc4_y1,100) >= 85 AND 
                         NVL(gr_wide.rc5_y1,100) >= 85 AND
                         NVL(gr_wide.rc6_y1,100) >= 85 AND
                         NVL(gr_wide.rc7_y1,100) >= 85 AND
                         NVL(gr_wide.rc8_y1,100) >= 85)
                         THEN 'Honors'
--*/
                   ELSE 'Satisfactory' 
                  END AS promo_status_grades
                 ,Rise_GPA.GPA_Y1 AS GPA
                 ,CAST(mem.mem AS VARCHAR) + '-(' + CAST(ac.absences_total AS VARCHAR) + '+(' + CAST(ac.tardies_total AS VARCHAR) + '/3))' + '/' + CAST(mem.mem AS VARCHAR) AS att_string
                 ,ac.absences_total + FLOOR(ac.tardies_total/3) AS attendance_points
                 ,ROUND(((mem.mem - (ac.absences_total + FLOOR(ac.tardies_total/3))) / mem.mem) * 100,2) AS y1_att_pts_pct
                 ,rise_hw.simple_avg
           FROM STUDENTS s
           LEFT OUTER JOIN GRADES$wide_all#MS gr_wide ON s.id = gr_wide.studentid
           LEFT OUTER JOIN GPA$detail#Rise Rise_GPA ON s.id = Rise_GPA.studentid
           LEFT OUTER JOIN ATT_MEM$attendance_counts ac ON s.id = ac.id
           LEFT OUTER JOIN ATT_MEM$membership_counts mem ON s.id = mem.id
           LEFT OUTER JOIN GRADES$elements rise_hw
                        ON s.id = rise_hw.studentid
                       AND rise_hw.pgf_type = 'H'
                       AND rise_hw.course_number = 'all_courses'
           WHERE s.schoolid = 73252 AND s.enroll_status = 0              
           )sub
     )sub1