USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_status#Rise AS

SELECT studentid
      ,student_number
      ,attendance_points
      ,y1_att_pts_pct
      ,days_to_perfect
      ,att_string
      ,GPA_Promo_Status_Grades
      ,promo_status_att
      ,promo_status_hw
      ,CASE 
        WHEN GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw LIKE '%Off Track%' THEN 'Off Track'
        WHEN GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw LIKE '%Warning%' THEN 'Warning'
        WHEN GPA_Promo_Status_Grades  + promo_status_att + promo_status_hw LIKE '%Honors%' THEN 'Honors'        
        ELSE 'Satisfactory' 
       END AS promo_status_overall
FROM 
    (
     SELECT studentid
           ,student_number
           ,attendance_points
           ,y1_att_pts_pct
           ,CASE
             WHEN (ROUND((((Y1_MEM * .105) - attendance_points) / -.105) + .5,0)) <= 0 THEN 'n/a'
             ELSE CONVERT(VARCHAR,(ROUND((((Y1_MEM * .105) - attendance_points) / -.105) + .5,0)))
            END AS days_to_perfect
           ,att_string
           ,promo_status_grades
           ,CASE 
              WHEN y1_att_pts_pct < 89.5 THEN 'Off Track'
              WHEN y1_att_pts_pct < 92 AND y1_att_pts_pct >= 89.5 THEN 'Warning'
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
              WHEN GPA >= 3.0 AND GPA < 3.5 AND promo_status_grades NOT LIKE '%Warning%' THEN 'Honors' 
              WHEN GPA >= 3.5 AND promo_status_grades NOT LIKE '%Warning%' THEN 'High Honors' 
              ELSE promo_status_grades 
            END AS GPA_Promo_Status_Grades
     FROM
         (
          SELECT s.id AS studentid
                ,s.student_number
                ,CASE 
                  WHEN (CONVERT(FLOAT,gr_wide.rc1_y1) < 65.0 OR
                        CONVERT(FLOAT,gr_wide.rc2_y1) < 65.0 OR
                        CONVERT(FLOAT,gr_wide.rc3_y1) < 65.0 OR
                        CONVERT(FLOAT,gr_wide.rc4_y1) < 65.0 OR
                        CONVERT(FLOAT,gr_wide.rc5_y1) < 65.0 OR
                        CONVERT(FLOAT,gr_wide.rc6_y1) < 65.0 OR
                        CONVERT(FLOAT,gr_wide.rc7_y1) < 65.0 OR
                        CONVERT(FLOAT,gr_wide.rc8_y1) < 65.0) 
                        THEN 'Off Track'
                  WHEN (CONVERT(FLOAT,gr_wide.rc1_y1) < 70.0 OR
                        CONVERT(FLOAT,gr_wide.rc2_y1) < 70.0 OR
                        CONVERT(FLOAT,gr_wide.rc3_y1) < 70.0 OR
                        CONVERT(FLOAT,gr_wide.rc4_y1) < 70.0 OR
                        CONVERT(FLOAT,gr_wide.rc5_y1) < 70.0 OR
                        CONVERT(FLOAT,gr_wide.rc6_y1) < 70.0 OR
                        CONVERT(FLOAT,gr_wide.rc7_y1) < 70.0 OR
                        CONVERT(FLOAT,gr_wide.rc8_y1) < 70.0) 
                        THEN 'Warning'                  
                  ELSE 'Satisfactory' 
                 END AS promo_status_grades
                ,Rise_GPA.GPA_Y1 AS GPA
                ,CAST(mem.Y1_MEM AS VARCHAR) + '-(' + CAST(ac.Y1_ABS_ALL AS VARCHAR) + '+(' + CAST(ac.Y1_T_ALL AS VARCHAR) + '/3))' + '/' + CAST(mem.y1_mem AS VARCHAR) AS att_string
                ,ac.Y1_ABS_ALL + FLOOR(ac.Y1_T_ALL / 3) AS attendance_points
                ,ROUND(((mem.Y1_MEM - (ac.Y1_ABS_ALL + FLOOR(ac.Y1_T_ALL / 3))) / mem.Y1_MEM) * 100,2) AS y1_att_pts_pct
                ,rise_hw.simple_avg
                ,mem.Y1_MEM
          FROM STUDENTS s WITH (NOLOCK)
          LEFT OUTER JOIN GRADES$wide_all#MS gr_wide WITH (NOLOCK)
            ON s.id = gr_wide.studentid
          LEFT OUTER JOIN GPA$detail#Rise Rise_GPA WITH (NOLOCK)
            ON s.id = Rise_GPA.studentid
          LEFT OUTER JOIN ATT_MEM$attendance_counts ac WITH (NOLOCK)
            ON s.id = ac.studentid
          LEFT OUTER JOIN ATT_MEM$membership_counts mem WITH (NOLOCK)
            ON s.id = mem.studentid
          LEFT OUTER JOIN GRADES$elements rise_hw WITH (NOLOCK)
            ON s.id = rise_hw.studentid
           AND rise_hw.pgf_type = 'H'
           AND rise_hw.course_number = 'all_courses'
          WHERE s.schoolid = 73252
            AND s.enroll_status = 0
         )sub
    )sub1