USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_status#MS AS

SELECT studentid
      ,student_number      
      ,attendance_points
      ,y1_att_pts_pct
      ,att_pts_string
      ,days_to_90      
      ,days_to_90_string
      ,promo_grades_team      
      ,promo_att_team      
      ,promo_hw AS promo_hw_team
      ,CASE 
        WHEN (promo_grades_team + promo_att_team LIKE '%Off Track%' OR
              promo_grades_team + promo_att_team LIKE '%Warning%' OR
              promo_grades_team + promo_att_team LIKE '%Promotion In Doubt%') THEN 'Promotion In Doubt'
        ELSE 'On Track'
       END AS promo_overall_team
      ,promo_grades_rise
      ,promo_grades_gpa_rise
      ,promo_att_rise
      ,hw_avg
      ,promo_hw AS promo_hw_rise
      ,GPA_y1_all
      ,CASE 
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw LIKE '%Off Track%' THEN 'Off Track'
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw LIKE '%Warning%' THEN 'Warning'
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw LIKE '%High Honors%' THEN 'High Honors'
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw LIKE '%Honors%' THEN 'Honors'        
        ELSE 'Satisfactory' 
       END AS promo_overall_rise
FROM
    (
     SELECT studentid
           ,student_number
           ,attendance_points
           ,y1_att_pts_pct
           ,CASE
             WHEN ROUND((((Y1_MEM * .105) - attendance_points) / -.105) + 0.5, 0) <= 0 THEN NULL
             ELSE ROUND((((Y1_MEM * .105) - attendance_points) / -.105) + 0.5, 0)
            END AS days_to_90
           ,'(' + CONVERT(VARCHAR,Y1_MEM) + ' * .105) - ' + CONVERT(VARCHAR,attendance_points) + ') / -.105 + 0.5' AS days_to_90_string
           ,att_pts_string
           ,promo_grades_team
           ,promo_grades_rise
           ,CASE 
             WHEN y1_att_pts_pct <= 90 THEN 'Off Track'           
             ELSE 'On Track' 
            END AS promo_att_team
           ,CASE 
             WHEN y1_att_pts_pct < 89.5 THEN 'Off Track'
             WHEN y1_att_pts_pct < 92 AND y1_att_pts_pct >= 89.5 THEN 'Warning'
             WHEN y1_att_pts_pct >= 98 THEN 'Honors'
             ELSE 'Satisfactory' 
            END AS promo_att_rise
           ,simple_avg AS hw_avg
           ,CASE 
             WHEN simple_avg < 65 THEN 'Off Track'
             WHEN simple_avg < 70 THEN 'Warning'
             WHEN simple_avg >= 90 THEN 'Honors'
             ELSE 'Satisfactory' 
            END AS promo_hw
           ,GPA_y1_all
           ,CASE 
             WHEN gpa_y1_all >= 3.5 AND promo_grades_rise NOT LIKE '%Warning%' THEN 'High Honors'
             WHEN gpa_y1_all >= 3.0 AND promo_grades_rise NOT LIKE '%Warning%' THEN 'Honors'        
             ELSE promo_grades_rise
            END AS promo_grades_gpa_rise
     FROM
         (
          SELECT co.studentid AS studentid
                ,co.student_number
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
                 END AS promo_grades_rise
                ,CASE
                  WHEN ((gr_wide.rc1_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc1_y1) < 65 AND gr_wide.rc1_credittype != 'COCUR') OR
                        (gr_wide.rc2_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc2_y1) < 65 AND gr_wide.rc2_credittype != 'COCUR') OR 
                        (gr_wide.rc3_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc3_y1) < 65 AND gr_wide.rc3_credittype != 'COCUR') OR
                        (gr_wide.rc4_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc4_y1) < 65 AND gr_wide.rc4_credittype != 'COCUR') OR
                        (gr_wide.rc5_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc5_y1) < 65 AND gr_wide.rc5_credittype != 'COCUR') OR
                        (gr_wide.rc6_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc6_y1) < 65 AND gr_wide.rc6_credittype != 'COCUR') OR
                        (gr_wide.rc7_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc7_y1) < 65 AND gr_wide.rc7_credittype != 'COCUR') OR
                        (gr_wide.rc8_y1 IS NOT NULL AND CONVERT(FLOAT,gr_wide.rc8_y1) < 65 AND gr_wide.rc8_credittype != 'COCUR'))
                        THEN 'Promotion In Doubt'
                  ELSE 'On Track'
                 END AS promo_grades_team
                ,gpa.GPA_y1_all
                ,gpa.GPA_y1_core
                ,CAST(mem.Y1_MEM AS VARCHAR) + ' - (' 
                  + CAST(ac.Y1_ABS_ALL AS VARCHAR) + ' + (' 
                  + CAST(ac.Y1_T_ALL AS VARCHAR) + ' / 3)) / ' 
                  + CAST(mem.y1_mem AS VARCHAR) AS att_pts_string
                ,ac.Y1_ABS_ALL + FLOOR(ac.Y1_T_ALL / 3) AS attendance_points
                ,ROUND(((mem.Y1_MEM - (ac.Y1_ABS_ALL + FLOOR(ac.Y1_T_ALL / 3))) / mem.Y1_MEM) * 100, 2) AS y1_att_pts_pct
                ,hw.simple_avg
                ,mem.Y1_MEM
          FROM COHORT$comprehensive_long#static co WITH (NOLOCK)
          LEFT OUTER JOIN GRADES$wide_all#MS#static gr_wide WITH (NOLOCK)
            ON co.studentid = gr_wide.studentid
          LEFT OUTER JOIN GPA$detail#MS gpa WITH (NOLOCK)
            ON co.studentid = gpa.studentid
          LEFT OUTER JOIN ATT_MEM$attendance_counts#static ac WITH (NOLOCK)
            ON co.studentid = ac.studentid
          LEFT OUTER JOIN ATT_MEM$membership_counts#static mem WITH (NOLOCK)
            ON co.studentid = mem.studentid
          LEFT OUTER JOIN GRADES$elements hw WITH (NOLOCK)
            ON co.studentid = hw.studentid
           AND hw.pgf_type = 'H'
           AND hw.course_number = 'all_courses'
           AND hw.yearid = LEFT(dbo.fn_Global_Term_ID(), 2)
          WHERE co.year = dbo.fn_Global_Academic_Year()
            AND co.schoolid IN (73252, 133570965)
            AND co.rn = 1
         ) sub
    ) sub2