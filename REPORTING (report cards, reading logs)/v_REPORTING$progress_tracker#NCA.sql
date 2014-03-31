--NCA Blue

USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_tracker#NCA AS
WITH roster AS
     (
      SELECT s.student_number
            ,s.id AS studentid
            ,s.lastfirst
            ,s.first_name
            ,s.last_name                        
            ,s.gender
            ,CONVERT(DATE,s.dob) AS dob
            ,s.student_web_id
            ,s.student_web_password
            ,s.home_phone
            ,cs.mother_cell
            ,cs.father_cell
            ,c.grade_level AS grade_level
            ,s.classof
            ,cs.guardianemail
            ,cs.advisor
            ,cs.SPEDLEP AS SPED
            ,cs.SID
            ,ROW_NUMBER() OVER(
                PARTITION BY s.grade_level
                    ORDER BY s.id) AS peer_count
      FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
      JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
        ON c.studentid = s.id
       AND s.enroll_status = 0
      LEFT OUTER JOIN KIPP_NJ..CUSTOM_STUDENTS cs WITH (NOLOCK)
        ON cs.studentid = s.id
      WHERE year = 2013
        AND c.rn = 1        
        AND c.schoolid = 73253
     )

SELECT ROW_NUMBER() OVER(          
           ORDER BY lastfirst) AS rn
      ,student_number
      ,studentid
      ,lastfirst
      ,first_name
      ,last_name                        
      ,gender
      ,dob
      ,student_web_id
      ,student_web_password
      ,home_phone
      ,mother_cell
      ,father_cell
      ,grade_level
      ,classof
      ,guardianemail
      ,advisor
      ,SPED
      ,att_pct_counts_yr
      ,att_pct_yr
      ,att_counts_yr
      ,on_time_pct      
      ,inv_tardy_pct_yr
      ,tardy_count_yr
      ,suspensions
      ,ISS
      ,OSS
      ,gpa_ytd      
      ,gpa_cum
      ,earned_credits_cum
      ,AY_all           
      ,HY_all     
      ,PY_all
      --,CY_all
      ,E1_all
      ,E2_all
      ,num_failing
      ,courses AS courses_failing
      ,points_cur
      ,points_goal_cur
      ,status_cur
      ,points_yr
      ,points_goal_yr
      ,status_yr
      ,map_sci_pct      
      ,map_math_pct
      ,map_read_pct
      ,map_sci_rit      
      ,map_math_rit
      ,map_read_rit
      ,lexile_cur
      ,lexile_min
      ,lexile_max
      ,merits_yr      
      ,merits_curr
      ,demerits_yr
      ,demerits_curr
      ,subtype AS recent_merit
      ,entry_date AS merit_date
      ,disc_ISS
      ,disc_OSS
      ,detentions
      ,class_removal
      ,in_grade_denom
      ,CASE
        WHEN gpa_ytd IS NOT NULL THEN
         ROW_NUMBER() OVER(
         PARTITION BY grade_level
             ORDER BY gpa_ytd DESC) 
        ELSE NULL
       END AS gpa_rank_ytd
      ,CASE
        WHEN gpa_cum IS NOT NULL THEN
         ROW_NUMBER() OVER(
         PARTITION BY grade_level
             ORDER BY gpa_cum DESC) 
        ELSE NULL
       END AS gpa_rank_cum
      ,rc1_course_name
      ,rc1_Y1
      ,rc1_Q1
      ,rc1_Q2
      ,rc1_Q3
      ,rc1_Q4           
      ,rc2_course_name
      ,rc2_Y1
      ,rc2_Q1
      ,rc2_Q2
      ,rc2_Q3
      ,rc2_Q4
      ,rc3_course_name
      ,rc3_Y1
      ,rc3_Q1
      ,rc3_Q2
      ,rc3_Q3
      ,rc3_Q4
      ,rc4_course_name
      ,rc4_Y1
      ,rc4_Q1
      ,rc4_Q2
      ,rc4_Q3
      ,rc4_Q4
      ,rc5_course_name
      ,rc5_Y1
      ,rc5_Q1
      ,rc5_Q2
      ,rc5_Q3
      ,rc5_Q4
      ,rc6_course_name
      ,rc6_Y1
      ,rc6_Q1
      ,rc6_Q2
      ,rc6_Q3
      ,rc6_Q4
      ,rc7_course_name
      ,rc7_Y1
      ,rc7_Q1
      ,rc7_Q2
      ,rc7_Q3
      ,rc7_Q4
      ,rc8_course_name
      ,rc8_Y1
      ,rc8_Q1
      ,rc8_Q2
      ,rc8_Q3
      ,rc8_Q4
      ,rc9_course_name
      ,rc9_Y1
      ,rc9_Q1
      ,rc9_Q2
      ,rc9_Q3
      ,rc9_Q4
      ,rc10_course_name
      ,rc10_Y1
      ,rc10_Q1
      ,rc10_Q2
      ,rc10_Q3
      ,rc10_Q4
      ,a1
      ,a2
      ,a3
      ,a4      
      ,h1
      ,h2
      ,h3
      ,h4
      ,p1
      ,p2
      ,p3
      ,p4
      ,PSAT_highest_math
      ,PSAT_highest_verbal
      ,PSAT_highest_writing
      ,PSAT_highest_combined
      ,SAT_highest_math
      ,SAT_highest_verbal
      ,SAT_highest_writing
      ,SAT_highest_math_verbal
      ,SAT_highest_combined
      ,ACT_highest_math
      ,ACT_highest_english
      ,ACT_highest_reading
      ,ACT_highest_science
      ,ACT_highest_composite
      ,HSPA_LAL_scale
      ,HSPA_LAL_prof
      ,HSPA_math_scale
      ,HSPA_math_prof
     
--PROFICIENCY METRICS      
      ,CASE
        WHEN att_pct_yr >= 95.0 THEN 4
        WHEN att_pct_yr >= 93.0 AND att_pct_yr < 95.0 THEN 3
        WHEN att_pct_yr >= 90.0 AND att_pct_yr < 93.0 THEN 2
        WHEN att_pct_yr < 90.0 THEN 1
       END AS att_pct_counts_yr_prof
      ,CASE
        WHEN inv_tardy_pct_yr >= 98.0 THEN 4
        WHEN inv_tardy_pct_yr >= 95.0 AND inv_tardy_pct_yr < 98.0 THEN 3
        WHEN inv_tardy_pct_yr >= 90.0 AND inv_tardy_pct_yr < 95.0 THEN 2
        WHEN inv_tardy_pct_yr <  90.0 THEN 1
       END AS on_time_pct_prof      
      ,CASE
        WHEN suspensions =  0 THEN 3
        WHEN suspensions >= 1 THEN 1
       END AS suspensions_prof      
      ,CASE
        WHEN gpa_ytd >= 3.0 THEN 4
        WHEN gpa_ytd >= 2.5 AND gpa_ytd < 3.0 THEN 3
        WHEN gpa_ytd >= 2.0 AND gpa_ytd < 2.5 THEN 2
        WHEN gpa_ytd <  2.0 THEN 1
       END AS gpa_ytd_prof
      ,CASE
        WHEN gpa_cum >= 3.0 THEN 4
        WHEN gpa_cum >= 2.5 AND gpa_cum < 3.0 THEN 3
        WHEN gpa_cum >= 2.0 AND gpa_cum < 2.5 THEN 2
        WHEN gpa_cum <  2.0 THEN 1
       END AS gpa_cum_prof
      ,CASE        
        WHEN grade_level = 10 AND earned_credits_cum >  30 THEN 4
        WHEN grade_level = 10 AND earned_credits_cum =  30 THEN 3
        WHEN grade_level = 10 AND earned_credits_cum >= 25 AND earned_credits_cum < 30 THEN 2
        WHEN grade_level = 10 AND earned_credits_cum <  25 THEN 1
        WHEN grade_level = 11 AND earned_credits_cum >  60 THEN 4
        WHEN grade_level = 11 AND earned_credits_cum =  60 THEN 3
        WHEN grade_level = 11 AND earned_credits_cum >= 55 AND earned_credits_cum < 60 THEN 2
        WHEN grade_level = 11 AND earned_credits_cum <  55 THEN 1
        WHEN grade_level = 12 AND earned_credits_cum >  90 THEN 4
        WHEN grade_level = 12 AND earned_credits_cum =  90 THEN 3
        WHEN grade_level = 12 AND earned_credits_cum >= 85 AND earned_credits_cum < 90 THEN 2
        WHEN grade_level = 12 AND earned_credits_cum <  85 THEN 1
       END AS earned_credits_cum_prof
      ,CASE
        WHEN CONVERT(FLOAT,AY_all) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,AY_all) <  87.0 AND CONVERT(FLOAT,AY_all) >= 80.0  THEN 3
        WHEN CONVERT(FLOAT,AY_all) <  80.0 AND CONVERT(FLOAT,AY_all) >= 70.0  THEN 2
        WHEN CONVERT(FLOAT,AY_all) <  70.0  THEN 1
       END AS AY_all_prof
      ,CASE
        WHEN CONVERT(FLOAT,HY_all) >= 90.0 THEN 4
        WHEN CONVERT(FLOAT,HY_all) <  90.0 AND CONVERT(FLOAT,HY_all) >= 83.0  THEN 3
        WHEN CONVERT(FLOAT,HY_all) <  83.0 AND CONVERT(FLOAT,HY_all) >= 75.0  THEN 2
        WHEN CONVERT(FLOAT,HY_all) <  75.0 THEN 1
       END AS HY_all_prof
      ,CASE
        WHEN CONVERT(FLOAT,PY_all) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,PY_all) <  87.0 AND CONVERT(FLOAT,PY_all) >= 83.0  THEN 3
        WHEN CONVERT(FLOAT,PY_all) <  83.0 AND CONVERT(FLOAT,PY_all) >= 75.0  THEN 2
        WHEN CONVERT(FLOAT,PY_all) <  75.0  THEN 1
       END AS PY_all_prof
      ,CASE
        WHEN CONVERT(FLOAT,E1_all) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,E1_all) <  87.0 AND CONVERT(FLOAT,E1_all) >= 80.0  THEN 3
        WHEN CONVERT(FLOAT,E1_all) <  80.0 AND CONVERT(FLOAT,E1_all) >= 70.0  THEN 2
        WHEN CONVERT(FLOAT,E1_all) <  70.0  THEN 1
       END AS E1_all_prof            
      ,CASE
        WHEN CONVERT(FLOAT,E2_all) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,E2_all) <  87.0 AND CONVERT(FLOAT,E2_all) >= 80.0  THEN 3
        WHEN CONVERT(FLOAT,E2_all) <  80.0 AND CONVERT(FLOAT,E2_all) >= 70.0  THEN 2
        WHEN CONVERT(FLOAT,E2_all) <  70.0  THEN 1
       END AS E2_all_prof
      ,CASE
        WHEN CONVERT(FLOAT,A1) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,A1) < 87.0 AND CONVERT(FLOAT,A1) >= 80.0 THEN 3
        WHEN CONVERT(FLOAT,A1) < 80.0 AND CONVERT(FLOAT,A1) >= 70.0 THEN 2
        WHEN CONVERT(FLOAT,A1) < 70.0 THEN 1
        END AS A1_prof
        ,CASE
        WHEN CONVERT(FLOAT,H1) >= 90.0 THEN 4
        WHEN CONVERT(FLOAT,H1) < 90.0 AND CONVERT(FLOAT,H1) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,H1) < 83.0 AND CONVERT(FLOAT,H1) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,H1) < 75.0 THEN 1
        END AS H1_prof
        ,CASE
        WHEN CONVERT(FLOAT,P1) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,P1) < 87.0 AND CONVERT(FLOAT,P1) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,P1) < 83.0 AND CONVERT(FLOAT,P1) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,P1) < 75.0 THEN 1
        END AS P1_prof
        ,CASE
        WHEN CONVERT(FLOAT,A2) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,A2) < 87.0 AND CONVERT(FLOAT,A2) >= 80.0 THEN 3
        WHEN CONVERT(FLOAT,A2) < 80.0 AND CONVERT(FLOAT,A2) >= 70.0 THEN 2
        WHEN CONVERT(FLOAT,A2) < 70.0 THEN 1
        END AS A2_prof
        ,CASE
        WHEN CONVERT(FLOAT,H2) >= 90.0 THEN 4
        WHEN CONVERT(FLOAT,H2) < 90.0 AND CONVERT(FLOAT,H2) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,H2) < 83.0 AND CONVERT(FLOAT,H2) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,H2) < 75.0 THEN 1
        END AS H2_prof
        ,CASE
        WHEN CONVERT(FLOAT,P2) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,P2) < 87.0 AND CONVERT(FLOAT,P2) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,P2) < 83.0 AND CONVERT(FLOAT,P2) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,P2) < 75.0 THEN 1
        END AS P2_prof
        ,CASE
        WHEN CONVERT(FLOAT,A3) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,A3) < 87.0 AND CONVERT(FLOAT,A3) >= 80.0 THEN 3
        WHEN CONVERT(FLOAT,A3) < 80.0 AND CONVERT(FLOAT,A3) >= 70.0 THEN 2
        WHEN CONVERT(FLOAT,A3) < 70.0 THEN 1
        END AS A3_prof
        ,CASE
        WHEN CONVERT(FLOAT,H3) >= 90.0 THEN 4
        WHEN CONVERT(FLOAT,H3) < 90.0 AND CONVERT(FLOAT,H3) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,H3) < 83.0 AND CONVERT(FLOAT,H3) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,H3) < 75.0 THEN 1
        END AS H3_prof
        ,CASE
        WHEN CONVERT(FLOAT,P3) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,P3) < 87.0 AND CONVERT(FLOAT,P3) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,P3) < 83.0 AND CONVERT(FLOAT,P3) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,P3) < 75.0 THEN 1
        END AS P3_prof
        ,CASE
        WHEN CONVERT(FLOAT,A4) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,A4) < 87.0 AND CONVERT(FLOAT,A4) >= 80.0 THEN 3
        WHEN CONVERT(FLOAT,A4) < 80.0 AND CONVERT(FLOAT,A4) >= 70.0 THEN 2
        WHEN CONVERT(FLOAT,A4) < 70.0 THEN 1
        END AS A4_prof
        ,CASE
        WHEN CONVERT(FLOAT,H4) >= 90.0 THEN 4
        WHEN CONVERT(FLOAT,H4) < 90.0 AND CONVERT(FLOAT,H4) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,H4) < 83.0 AND CONVERT(FLOAT,H4) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,H4) < 75.0 THEN 1
        END AS H4_prof
        ,CASE
        WHEN CONVERT(FLOAT,P4) >= 87.0 THEN 4
        WHEN CONVERT(FLOAT,P4) < 87.0 AND CONVERT(FLOAT,P4) >= 83.0 THEN 3
        WHEN CONVERT(FLOAT,P4) < 83.0 AND CONVERT(FLOAT,P4) >= 75.0 THEN 2
        WHEN CONVERT(FLOAT,P4) < 75.0 THEN 1
        END AS P4_prof
      ,CASE
        WHEN num_failing = 0 THEN 3
        WHEN num_failing = 1 THEN 2
        WHEN num_failing > 1 THEN 1
       END AS num_failing_prof
      --,points_goal_yr,points_yr -- prof is relative to goal
      ,CASE
        WHEN map_sci_pct >= 75.0 THEN 4
        WHEN map_sci_pct <  75.0 AND map_sci_pct >= 62.0 THEN 3
        WHEN map_sci_pct <  62.0 AND map_sci_pct >= 50.0 THEN 2
        WHEN map_sci_pct <  50.0 THEN 1
       END AS map_sci_pct_prof
      ,CASE
        WHEN map_math_pct >= 75.0 THEN 4
        WHEN map_math_pct <  75.0 AND map_math_pct >= 62.0 THEN 3
        WHEN map_math_pct <  62.0 AND map_math_pct >= 50.0 THEN 2
        WHEN map_math_pct <  50.0 THEN 1
       END AS map_math_pct_prof
      ,CASE
        WHEN map_read_pct >= 75.0 THEN 4
        WHEN map_read_pct <  75.0 AND map_read_pct >= 62.0 THEN 3
        WHEN map_read_pct <  62.0 AND map_read_pct >= 50.0 THEN 2
        WHEN map_read_pct <  50.0 THEN 1
       END AS map_read_pct_prof                        
      ,CASE
        WHEN merits_curr >= 25 THEN 4
        WHEN merits_curr <  25 AND merits_curr >= 15 THEN 3
        WHEN merits_curr <  15 AND merits_curr >= 10 THEN 2
        WHEN merits_curr <  10 THEN 1
       END AS merits_curr_prof      
      ,CASE
        WHEN demerits_curr >  12 THEN 1
        WHEN demerits_curr <= 12 AND demerits_curr >= 7 THEN 2
        WHEN demerits_curr <=  6 AND demerits_curr >= 4 THEN 3
        WHEN demerits_curr <=  3 THEN 4
       END AS demerits_curr_prof
      ,CASE
        WHEN lexile_cur = 'BR' THEN NULL
        WHEN grade_level = 9 AND lexile_cur <  900  THEN 1
        WHEN grade_level = 9 AND lexile_cur >= 900  AND lexile_cur < 1000 THEN 2
        WHEN grade_level = 9 AND lexile_cur >= 1000 AND lexile_cur < 1050 THEN 3
        WHEN grade_level = 9 AND lexile_cur >= 1050 THEN 4
        --
        WHEN grade_level = 10 AND lexile_cur <  1000 THEN 1
        WHEN grade_level = 10 AND lexile_cur >= 1000 AND lexile_cur < 1100 THEN 2
        WHEN grade_level = 10 AND lexile_cur >= 1100 AND lexile_cur < 1150 THEN 3
        WHEN grade_level = 10 AND lexile_cur >= 1150 THEN 4
        --
        WHEN grade_level = 11 AND lexile_cur <  1100 THEN 1
        WHEN grade_level = 11 AND lexile_cur >= 1100 AND lexile_cur < 1200 THEN 2
        WHEN grade_level = 11 AND lexile_cur >= 1200 AND lexile_cur < 1250 THEN 3
        WHEN grade_level = 11 AND lexile_cur >= 1250 THEN 4
        --
        WHEN grade_level = 12 AND lexile_cur <  1200 THEN 1
        WHEN grade_level = 12 AND lexile_cur >= 1200 AND lexile_cur < 1300 THEN 2
        WHEN grade_level = 12 AND lexile_cur >= 1300 AND lexile_cur < 1350 THEN 3
        WHEN grade_level = 12 AND lexile_cur >= 1350 THEN 4
        ELSE NULL
       END AS lexile_cur_prof
      ,CASE
        WHEN status_cur = 'Off Track' AND status_yr = 'Off Track' THEN 1
        WHEN status_cur = 'Missed Goal' THEN 1
        WHEN status_cur = 'Missed Goal' AND status_yr = 'On Track' THEN 2
        WHEN status_cur = 'On Track' THEN 3
        WHEN status_cur = 'On Track' AND points_cur > points_goal_cur THEN 4
        WHEN status_cur = 'Met Goal' THEN 4
       END AS points_cur_prof
      ,CASE
        WHEN status_yr = 'Off Track' THEN 1
        WHEN status_yr = 'Missed Goal' THEN 1
        WHEN status_yr = 'Missed Goal' AND status_cur = 'On Track' THEN 2
        WHEN status_yr = 'On Track' THEN 3
        WHEN status_yr = 'On Track' AND points_yr > points_goal_yr THEN 4
        WHEN status_yr = 'Met Goal' THEN 4
       END AS points_yr_prof
FROM
     (SELECT roster.*                 
            ,dem.in_grade_denom
     --Attendance
     --ATT_MEM$attendance_percentages
     --ATT_MEM$attendance_counts
           --year
           ,ROUND(att_pct.Y1_att_pct_total,0) AS att_pct_yr
           ,ROUND(att_counts.absences_total,0) AS att_counts_yr
           ,CONVERT(VARCHAR,ROUND(att_pct.Y1_att_pct_total,0))
              + '% ('
              + CONVERT(VARCHAR,CONVERT(FLOAT,att_counts.absences_total))
              + ')'                                     
               AS att_pct_counts_yr
           ,CONVERT(VARCHAR,(100 - ROUND(att_pct.Y1_tardy_pct_total,0)))
              + '% ('
              + CONVERT(VARCHAR,CONVERT(FLOAT,att_counts.tardies_total))
              + ')'                                     
               AS on_time_pct
           ,(100 - ROUND(att_pct.Y1_tardy_pct_total,0)) AS inv_tardy_pct_yr
           ,ROUND(att_counts.tardies_total,0)           AS tardy_count_yr
           ,ROUND(att_counts.OSS,0) AS suspensions
           ,ROUND(att_counts.iss,0) AS ISS
           ,ROUND(att_counts.oss,0) AS OSS
           
     --GPA
     --GPA$detail#nca
     --GPA$cumulative#NCA
           --current SY
           ,nca_gpa.gpa_Y1 AS gpa_ytd      
           --cumulative (all years)
           ,gpa_cumulative.cumulative_Y1_gpa AS gpa_cum
           ,earned_credits_cum
           
     --Course Grades
     --GRADES$wide_all     
           ,gr_wide.AY_all                
           ,gr_wide.HY_all     
           ,gr_wide.PY_all
           --,gr_wide.CY_all
           ,gr_wide.E1_all
           ,gr_wide.E2_all
           ,gr_wide.rc1_course_name
           ,gr_wide.rc1_Y1
           ,gr_wide.rc1_Q1
           ,gr_wide.rc1_Q2
           ,gr_wide.rc1_Q3
           ,gr_wide.rc1_Q4           
           ,gr_wide.rc2_course_name
           ,gr_wide.rc2_Y1
           ,gr_wide.rc2_Q1
           ,gr_wide.rc2_Q2
           ,gr_wide.rc2_Q3
           ,gr_wide.rc2_Q4
           ,gr_wide.rc3_course_name
           ,gr_wide.rc3_Y1
           ,gr_wide.rc3_Q1
           ,gr_wide.rc3_Q2
           ,gr_wide.rc3_Q3
           ,gr_wide.rc3_Q4
           ,gr_wide.rc4_course_name
           ,gr_wide.rc4_Y1
           ,gr_wide.rc4_Q1
           ,gr_wide.rc4_Q2
           ,gr_wide.rc4_Q3
           ,gr_wide.rc4_Q4
           ,gr_wide.rc5_course_name
           ,gr_wide.rc5_Y1
           ,gr_wide.rc5_Q1
           ,gr_wide.rc5_Q2
           ,gr_wide.rc5_Q3
           ,gr_wide.rc5_Q4
           ,gr_wide.rc6_course_name
           ,gr_wide.rc6_Y1
           ,gr_wide.rc6_Q1
           ,gr_wide.rc6_Q2
           ,gr_wide.rc6_Q3
           ,gr_wide.rc6_Q4
           ,gr_wide.rc7_course_name
           ,gr_wide.rc7_Y1
           ,gr_wide.rc7_Q1
           ,gr_wide.rc7_Q2
           ,gr_wide.rc7_Q3
           ,gr_wide.rc7_Q4
           ,gr_wide.rc8_course_name
           ,gr_wide.rc8_Y1
           ,gr_wide.rc8_Q1
           ,gr_wide.rc8_Q2
           ,gr_wide.rc8_Q3
           ,gr_wide.rc8_Q4
           ,gr_wide.rc9_course_name
           ,gr_wide.rc9_Y1
           ,gr_wide.rc9_Q1
           ,gr_wide.rc9_Q2
           ,gr_wide.rc9_Q3
           ,gr_wide.rc9_Q4
           ,gr_wide.rc10_course_name
           ,gr_wide.rc10_Y1
           ,gr_wide.rc10_Q1
           ,gr_wide.rc10_Q2
           ,gr_wide.rc10_Q3
           ,gr_wide.rc10_Q4
           ,ele_a.grade_1 AS a1
           ,ele_a.grade_2 AS a2
           ,ele_a.grade_3 AS a3
           ,ele_a.grade_4 AS a4
           ,ele_c.grade_1 AS c1
           ,ele_c.grade_2 AS c2
           ,ele_c.grade_3 AS c3
           ,ele_c.grade_4 AS c4
           ,ele_e.grade_1 AS e1
           ,ele_e.grade_2 AS e2
           ,ele_e.grade_3 AS e3
           ,ele_e.grade_4 AS e4
           ,ele_h.grade_1 AS h1
           ,ele_h.grade_2 AS h2
           ,ele_h.grade_3 AS h3
           ,ele_h.grade_4 AS h4
           ,ele_p.grade_1 AS p1
           ,ele_p.grade_2 AS p2
           ,ele_p.grade_3 AS p3
           ,ele_p.grade_4 AS p4
           
           --On-track?
           ,fail.courses
           ,CASE
             WHEN fail.num_failing IS NULL THEN 0
             ELSE fail.num_failing
            END AS num_failing
           
     --Ed Tech
     --AR$progress_to_goals_long#static

           --Accelerated Reader      
           --AR year
           ,CONVERT(FLOAT,ar_cur.points) AS points_cur
           ,ar_cur.points_goal AS points_goal_cur
           ,ar_cur.stu_status_points AS status_cur
           ,CONVERT(FLOAT,ar_yr.points) AS points_yr
           ,ar_yr.points_goal AS points_goal_yr
           ,ar_yr.stu_status_points AS status_yr

     --MAP & Lexile scores -- update academic year in JOIN
     --MAP$comprehensive#identifiers
           ,map_sci_cur.percentile_2011_norms AS map_sci_pct
           ,map_sci_cur.testritscore AS map_sci_rit
           ,map_math_cur.percentile_2011_norms AS map_math_pct
           ,map_math_cur.testritscore AS map_math_rit
           ,map_read_cur.percentile_2011_norms AS map_read_pct
           ,map_read_cur.testritscore AS map_read_rit
           ,map_read_cur.rittoreadingscore AS lexile_cur
           ,map_read_cur.rittoreadingmin AS lexile_min
           ,map_read_cur.rittoreadingmax AS lexile_max
         
     --Discipline
     --DISC$merits_demerits_count#NCA
           --Merits
             --year      
           ,merits.total_merits_rt1 
             + merits.total_merits_rt2 
             + merits.total_merits_rt3 
             + merits.total_merits_rt4 AS merits_yr      
             --current            
           ,merits.total_merits_rt3    AS merits_curr   -- update field name for current term
           
           --Demerits
             --year
           ,merits.total_demerits_rt1
             + merits.total_demerits_rt2
             + merits.total_demerits_rt3
             + merits.total_demerits_rt4 AS demerits_yr
             --current
           ,merits.total_demerits_rt3    AS demerits_curr -- update field name for current term
           ,disc.subtype
           ,disc.entry_date
           ,dcounts.ISS AS disc_ISS
           ,dcounts.OSS AS disc_OSS
           ,dcounts.detentions
           ,dcounts.class_removal
           
     --College test scores
     --KTC$highest_scores_wide
           ,ktc.PSAT_highest_math
           ,ktc.PSAT_highest_verbal
           ,ktc.PSAT_highest_writing
           ,ktc.PSAT_highest_combined
           ,ktc.SAT_highest_math
           ,ktc.SAT_highest_verbal
           ,ktc.SAT_highest_writing
           ,ktc.SAT_highest_math_verbal
           ,ktc.SAT_highest_combined
           ,ktc.ACT_highest_math
           ,ktc.ACT_highest_english
           ,ktc.ACT_highest_reading
           ,ktc.ACT_highest_science
           ,ktc.ACT_highest_composite
     --HSPA
           ,hspa.LAL_scale_score AS HSPA_LAL_scale
           ,hspa.LAL_proficiency AS HSPA_LAL_prof
           ,hspa.Math_scale_score AS HSPA_math_scale
           ,hspa.Math_proficiency AS HSPA_math_prof

     FROM roster WITH (NOLOCK)
      
     --ATTENDANCE
     LEFT OUTER JOIN ATT_MEM$attendance_counts att_counts WITH (NOLOCK)
       ON roster.studentid = att_counts.id
     LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
       ON roster.studentid = att_pct.id
       
     --GPA
     LEFT OUTER JOIN GPA$detail#NCA nca_gpa WITH (NOLOCK)
       ON roster.studentid = nca_gpa.studentid      
     LEFT OUTER JOIN GPA$cumulative gpa_cumulative WITH (NOLOCK)
       ON roster.studentid = gpa_cumulative.studentid
      AND gpa_cumulative.schoolid = 73253
       
     --GRADES
     LEFT OUTER JOIN GRADES$wide_all#NCA gr_wide WITH (NOLOCK)
       ON roster.studentid = gr_wide.studentid
     LEFT OUTER JOIN (SELECT studentid
                            ,COUNT(fail.y1) AS num_failing
                            ,dbo.GROUP_CONCAT_DS(fail.course_name, CHAR(10), 1) AS courses
                      FROM GRADES$DETAIL#NCA fail WITH (NOLOCK)
                      WHERE fail.y1 < 70
                      GROUP BY studentid) fail
       ON roster.studentid = fail.studentid
     LEFT OUTER JOIN GRADES$elements ele_a WITH (NOLOCK)
       ON roster.studentid = ele_a.studentid
      AND ele_a.schoolid = 73253
      AND ele_a.yearid = LEFT(dbo.fn_Global_Term_Id(),2)
      AND ele_a.course_number = 'all_courses'
      AND ele_a.pgf_type = 'A'
     LEFT OUTER JOIN GRADES$elements ele_c WITH (NOLOCK)
       ON roster.studentid = ele_c.studentid
      AND ele_c.schoolid = 73253
      AND ele_c.yearid = LEFT(dbo.fn_Global_Term_Id(),2)
      AND ele_c.course_number = 'all_courses'
      AND ele_c.pgf_type = 'C'
     LEFT OUTER JOIN GRADES$elements ele_e WITH (NOLOCK)
       ON roster.studentid = ele_e.studentid
      AND ele_e.schoolid = 73253
      AND ele_e.yearid = LEFT(dbo.fn_Global_Term_Id(),2)
      AND ele_e.course_number = 'all_courses'
      AND ele_e.pgf_type = 'E'
     LEFT OUTER JOIN GRADES$elements ele_h WITH (NOLOCK)
       ON roster.studentid = ele_h.studentid
      AND ele_h.schoolid = 73253
      AND ele_h.yearid = LEFT(dbo.fn_Global_Term_Id(),2)
      AND ele_h.course_number = 'all_courses'
      AND ele_h.pgf_type = 'H'
     LEFT OUTER JOIN GRADES$elements ele_p WITH (NOLOCK)
       ON roster.studentid = ele_p.studentid
      AND ele_p.schoolid = 73253
      AND ele_p.yearid = LEFT(dbo.fn_Global_Term_Id(),2)
      AND ele_p.course_number = 'all_courses'
      AND ele_p.pgf_type = 'P'
       
     --ED TECH
       --ACCELERATED READER -- update for current term
     LEFT OUTER JOIN AR$progress_to_goals_long#static ar_cur WITH (NOLOCK)
       ON roster .studentid = ar_cur.studentid      
      AND ar_cur.yearid = dbo.fn_Global_Term_Id()
      --AND GETDATE() >= ar_cur.start_date
      --AND GETDATE() <= ar_cur.end_date
      AND ar_cur.time_period_name = 'RT3'
      AND ar_cur.time_hierarchy = 2
     LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
       ON roster .studentid = ar_yr.studentid      
      AND ar_yr.yearid = dbo.fn_Global_Term_Id()
      AND GETDATE() >= ar_yr.start_date
      AND GETDATE() <= ar_yr.end_date
      AND ar_yr.time_hierarchy = 1 
      
     --MAP (LEXILE)
     LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_read_cur WITH (NOLOCK)
       ON roster.studentid = map_read_cur.ps_studentid
      AND map_read_cur.measurementscale  = 'Reading'
      AND map_read_cur.map_year_academic = 2013 --update yearly
      AND map_read_cur.rn_curr = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_math_cur WITH (NOLOCK)
       ON roster.studentid = map_math_cur.ps_studentid
      AND map_math_cur.measurementscale = 'Mathematics'
      AND map_math_cur.map_year_academic = 2013 --update yearly
      AND map_math_cur.rn_curr = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_sci_cur WITH (NOLOCK)
       ON roster.studentid = map_sci_cur.ps_studentid
      AND map_sci_cur.measurementscale = 'Science - General Science'
      AND map_sci_cur.map_year_academic = 2013 --update yearly
      AND map_sci_cur.rn_curr = 1

     --MERITS & DEMERITS
     LEFT OUTER JOIN DISC$merits_demerits_count#NCA merits WITH (NOLOCK)
       ON roster.studentid = merits.studentid
     LEFT OUTER JOIN DISC$log#static disc WITH (NOLOCK)
       ON roster.studentid = disc.studentid
      AND disc.rn = 1
      AND disc.logtypeid = 3023      
     LEFT OUTER JOIN DISC$counts_wide dcounts WITH (NOLOCK)
       ON roster.studentid = dcounts.base_studentid       
     LEFT OUTER JOIN (SELECT grade_level
                            ,MAX(peer_count) AS in_grade_denom
                      FROM roster WITH (NOLOCK)
                      GROUP BY grade_level) dem
       ON roster.grade_level = dem.grade_level       
     
     --Test scores
     LEFT OUTER JOIN KTC$highest_scores_wide ktc WITH(NOLOCK)
       ON roster.student_number = ktc.student_number
     LEFT OUTER JOIN HSPA$scaled_scores_roster hspa WITH(NOLOCK)
       ON roster.SID = hspa.SID
    ) sub_1