USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_status#TEAM AS

SELECT studentid
      ,student_number      
      ,attendance_points
      ,y1_att_pts_pct
      ,days_to_perfect
      ,att_string
      ,promo_status_grades
      ,promo_status_att      
      ,promo_status_hw
      ,CASE 
        WHEN promo_status_grades  + promo_status_att  LIKE 'On TrackOn Track' THEN 'On Track'
        WHEN promo_status_grades  + promo_status_att  LIKE '%Promotion In Doubt%' THEN 'Promotion In Doubt'
        WHEN promo_status_grades  + promo_status_att  LIKE '%Off Track%' THEN 'Promotion In Doubt'
        WHEN promo_status_grades  + promo_status_att  LIKE '%Warning%' THEN 'Promotion In Doubt'
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
             WHEN y1_att_pts_pct <= 90 THEN 'Off Track'           
             ELSE 'On Track' 
            END AS promo_status_att   
           ,CASE 
              WHEN simple_avg < 65 THEN 'Off Track'
              WHEN simple_avg < 70 THEN 'Warning'
              WHEN simple_avg >= 90 THEN 'Honors'
              ELSE 'Satisfactory' 
            END AS promo_status_hw
     FROM             
         (
          SELECT s.id AS studentid
                ,s.student_number                           
                ,CASE
                  WHEN ((gr_wide.rc1_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc1_y1) < 70 AND gr_wide.rc1_credittype != 'COCUR') OR
                        (gr_wide.rc2_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc2_y1) < 70 AND gr_wide.rc2_credittype != 'COCUR') OR 
                        (gr_wide.rc3_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc3_y1) < 70 AND gr_wide.rc3_credittype != 'COCUR') OR
                        (gr_wide.rc4_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc4_y1) < 70 AND gr_wide.rc4_credittype != 'COCUR') OR
                        (gr_wide.rc5_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc5_y1) < 70 AND gr_wide.rc5_credittype != 'COCUR') OR
                        (gr_wide.rc6_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc6_y1) < 70 AND gr_wide.rc6_credittype != 'COCUR') OR
                        (gr_wide.rc7_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc7_y1) < 70 AND gr_wide.rc7_credittype != 'COCUR') OR
                        (gr_wide.rc8_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc8_y1) < 70 AND gr_wide.rc8_credittype != 'COCUR'))
                        THEN 'Promotion In Doubt'
                  ELSE 'On Track'
                 END AS promo_status_grades                                          
                ,CAST(mem.y1_mem AS VARCHAR) + ' - (' 
                  + CAST(ac.Y1_ABS_ALL AS VARCHAR) + ' + (' 
                  + CAST(ac.Y1_T_ALL AS VARCHAR) + ' / 3)) / '
                  + CAST(mem.y1_mem AS VARCHAR) AS att_string
                ,ac.Y1_ABS_ALL + FLOOR(ac.Y1_T_ALL / 3) AS attendance_points
                ,ROUND(((mem.y1_mem - (ac.Y1_ABS_ALL + FLOOR(ac.Y1_T_ALL / 3))) / mem.y1_mem) * 100,2) AS y1_att_pts_pct
                ,team_hw.simple_avg
                ,mem.Y1_MEM
          FROM STUDENTS s WITH (NOLOCK)
          LEFT OUTER JOIN GRADES$wide_all#MS gr_wide WITH (NOLOCK)
            ON s.id = gr_wide.studentid
          LEFT OUTER JOIN GPA$detail#TEAM team_GPA WITH (NOLOCK)
            ON s.id = TEAM_GPA.studentid
          LEFT OUTER JOIN ATT_MEM$attendance_counts ac WITH (NOLOCK)
            ON s.id = ac.studentid
          LEFT OUTER JOIN ATT_MEM$membership_counts mem WITH (NOLOCK)
            ON s.id = mem.STUDENTID      
          LEFT OUTER JOIN GRADES$elements team_hw WITH (NOLOCK)
            ON s.id = team_hw.studentid 
           AND team_hw.pgf_type = 'H'
           AND team_hw.course_number = 'all_courses'
          WHERE s.schoolid = 133570965 
            AND s.enroll_status = 0
         )sub
    )sub1