USE KIPP_NJ
GO

ALTER VIEW REPORTING$progress_tracker#NCA AS

WITH exams AS (
  SELECT student_number
        ,ROUND(AVG(CONVERT(FLOAT,e1_grade_percent)),0) AS e1_all
        ,ROUND(AVG(CONVERT(FLOAT,e2_grade_percent)),0) AS e2_all
  FROM KIPP_NJ..GRADES$final_grades_wide#static
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY student_number
 )

,failing AS (
  SELECT student_number
        ,COUNT(sectionid) AS n_failing
        ,KIPP_NJ.dbo.GROUP_CONCAT_DS(course_name, CHAR(10), 1) AS failing_courses
  FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND is_curterm = 1
    AND y1_grade_percent_adjusted < 70
  GROUP BY student_number
 )

,disc_counts AS (
  SELECT studentid
        ,[Class Removal] AS n_removals_yr
        ,[ISS] AS n_iss_yr
        ,[OSS] AS n_oss_yr
  FROM
      (
       SELECT studentid
             ,subtype
             ,COUNT(DCID) AS n_logs_yr
       FROM KIPP_NJ..DISC$log#static WITH(NOLOCK)
       WHERE academic_Year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND subtype IN ('Class Removal','ISS','OSS')
       GROUP BY studentid, subtype
      ) sub
  PIVOT(
    MAX(n_logs_yr)
    FOR subtype IN ([Class Removal],[ISS],[OSS])
   ) p
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
      ,rc1_cur
      ,rc2_cur
      ,rc3_cur
      ,rc4_cur
      ,rc5_cur
      ,rc6_cur
      ,rc7_cur
      ,rc8_cur
      ,rc9_cur
      ,rc10_cur
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
        WHEN map_sci_pct >= 80.0 THEN 4
        WHEN map_sci_pct <  80.0 AND map_sci_pct >= 70.0 THEN 3
        WHEN map_sci_pct <  70.0 AND map_sci_pct >= 50.0 THEN 2
        WHEN map_sci_pct <  50.0 THEN 1
       END AS map_sci_pct_prof
      ,CASE
        WHEN map_math_pct >= 80.0 THEN 4
        WHEN map_math_pct <  80.0 AND map_math_pct >= 70.0 THEN 3
        WHEN map_math_pct <  70.0 AND map_math_pct >= 50.0 THEN 2
        WHEN map_math_pct <  50.0 THEN 1
       END AS map_math_pct_prof
      ,CASE
        WHEN map_read_pct >= 80.0 THEN 4
        WHEN map_read_pct <  80.0 AND map_read_pct >= 70.0 THEN 3
        WHEN map_read_pct <  70.0 AND map_read_pct >= 50.0 THEN 2
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
    (
     SELECT roster.year
           ,roster.student_number
           ,roster.studentid
           ,roster.lastfirst
           ,roster.first_name
           ,roster.last_name                        
           ,roster.gender
           ,CONVERT(VARCHAR,roster.DOB,101) AS dob
           ,roster.student_web_id
           ,roster.student_web_password
           ,roster.home_phone
           ,roster.mother_cell
           ,roster.father_cell
           ,roster.grade_level AS grade_level
           ,roster.cohort AS classof
           ,roster.guardianemail
           ,roster.advisor
           ,roster.SPEDLEP AS SPED
           ,roster.SID
           ,COUNT(roster.student_number) OVER(PARTITION BY roster.grade_level) AS in_grade_denom
      
           /* ATTENDANCE */            
           ,ROUND((att_counts.ABS_ALL_counts_yr / att_counts.MEM_counts_yr) * 100,0) AS att_pct_yr
           ,ROUND(att_counts.ABS_ALL_counts_yr,0) AS att_counts_yr
           ,CONVERT(VARCHAR,ROUND((att_counts.ABS_ALL_counts_yr / att_counts.MEM_counts_yr) * 100,0)) + '% ('
              + CONVERT(VARCHAR,CONVERT(FLOAT,att_counts.ABS_ALL_counts_yr)) + ')' AS att_pct_counts_yr
           ,CONVERT(VARCHAR,ROUND((100 - (att_counts.TDY_all_counts_yr / att_counts.MEM_counts_yr)) * 100,0)) + '% ('
              + CONVERT(VARCHAR,CONVERT(FLOAT,att_counts.TDY_ALL_counts_yr)) + ')' AS on_time_pct
           ,ROUND((100 - (att_counts.TDY_all_counts_yr / att_counts.MEM_counts_yr)) * 100,0) AS inv_tardy_pct_yr
           ,att_counts.TDY_ALL_counts_yr AS tardy_count_yr
           ,att_counts.OSS_counts_yr + ISS_counts_yr AS suspensions
           ,att_counts.ISS_counts_yr AS ISS
           ,att_counts.OSS_counts_yr AS OSS
           
           /* GPA */
           ,nca_gpa.GPA_Y1 AS gpa_ytd                  
           ,gpa_cumulative.cumulative_Y1_gpa AS gpa_cum
           ,gpa_cumulative.earned_credits_cum
            
           /* COURSE GRADES */
           ,gr_wide.rc01_course_name AS rc1_course_name
           ,gr_wide.rc01_y1_grade_percent AS rc1_Y1
           ,gr_wide.rc01_RT1_term_grade_percent AS rc1_Q1
           ,gr_wide.rc01_RT2_term_grade_percent AS rc1_Q2
           ,gr_wide.rc01_RT3_term_grade_percent AS rc1_Q3
           ,gr_wide.rc01_RT4_term_grade_percent AS rc1_Q4
           ,gr_wide.rc01_CUR_term_grade_percent AS rc1_cur
            
           ,gr_wide.rc02_course_name AS rc2_course_name
           ,gr_wide.rc02_y1_grade_percent AS rc2_Y1
           ,gr_wide.rc02_RT1_term_grade_percent AS rc2_Q1
           ,gr_wide.rc02_RT2_term_grade_percent AS rc2_Q2
           ,gr_wide.rc02_RT3_term_grade_percent AS rc2_Q3
           ,gr_wide.rc02_RT4_term_grade_percent AS rc2_Q4
           ,gr_wide.rc02_CUR_term_grade_percent AS rc2_cur
            
           ,gr_wide.rc03_course_name AS rc3_course_name
           ,gr_wide.rc03_y1_grade_percent AS rc3_Y1
           ,gr_wide.rc03_RT1_term_grade_percent AS rc3_Q1
           ,gr_wide.rc03_RT2_term_grade_percent AS rc3_Q2
           ,gr_wide.rc03_RT3_term_grade_percent AS rc3_Q3
           ,gr_wide.rc03_RT4_term_grade_percent AS rc3_Q4
           ,gr_wide.rc03_CUR_term_grade_percent AS rc3_cur
            
           ,gr_wide.rc04_course_name AS rc4_course_name
           ,gr_wide.rc04_y1_grade_percent AS rc4_Y1
           ,gr_wide.rc04_RT1_term_grade_percent AS rc4_Q1
           ,gr_wide.rc04_RT2_term_grade_percent AS rc4_Q2
           ,gr_wide.rc04_RT3_term_grade_percent AS rc4_Q3
           ,gr_wide.rc04_RT4_term_grade_percent AS rc4_Q4
           ,gr_wide.rc04_CUR_term_grade_percent AS rc4_cur
            
           ,gr_wide.rc05_course_name AS rc5_course_name
           ,gr_wide.rc05_y1_grade_percent AS rc5_Y1
           ,gr_wide.rc05_RT1_term_grade_percent AS rc5_Q1
           ,gr_wide.rc05_RT2_term_grade_percent AS rc5_Q2
           ,gr_wide.rc05_RT3_term_grade_percent AS rc5_Q3
           ,gr_wide.rc05_RT4_term_grade_percent AS rc5_Q4
           ,gr_wide.rc05_CUR_term_grade_percent AS rc5_cur
            
           ,gr_wide.rc06_course_name AS rc6_course_name
           ,gr_wide.rc06_y1_grade_percent AS rc6_Y1
           ,gr_wide.rc06_RT1_term_grade_percent AS rc6_Q1
           ,gr_wide.rc06_RT2_term_grade_percent AS rc6_Q2
           ,gr_wide.rc06_RT3_term_grade_percent AS rc6_Q3
           ,gr_wide.rc06_RT4_term_grade_percent AS rc6_Q4
           ,gr_wide.rc06_CUR_term_grade_percent AS rc6_cur
            
           ,gr_wide.rc07_course_name AS rc7_course_name
           ,gr_wide.rc07_y1_grade_percent AS rc7_Y1
           ,gr_wide.rc07_RT1_term_grade_percent AS rc7_Q1
           ,gr_wide.rc07_RT2_term_grade_percent AS rc7_Q2
           ,gr_wide.rc07_RT3_term_grade_percent AS rc7_Q3
           ,gr_wide.rc07_RT4_term_grade_percent AS rc7_Q4
           ,gr_wide.rc07_CUR_term_grade_percent AS rc7_cur
            
           ,gr_wide.rc08_course_name AS rc8_course_name
           ,gr_wide.rc08_y1_grade_percent AS rc8_Y1
           ,gr_wide.rc08_RT1_term_grade_percent AS rc8_Q1
           ,gr_wide.rc08_RT2_term_grade_percent AS rc8_Q2
           ,gr_wide.rc08_RT3_term_grade_percent AS rc8_Q3
           ,gr_wide.rc08_RT4_term_grade_percent AS rc8_Q4
           ,gr_wide.rc08_CUR_term_grade_percent AS rc8_cur
            
           ,gr_wide.rc09_course_name AS rc9_course_name
           ,gr_wide.rc09_y1_grade_percent AS rc9_Y1
           ,gr_wide.rc09_RT1_term_grade_percent AS rc9_Q1
           ,gr_wide.rc09_RT2_term_grade_percent AS rc9_Q2
           ,gr_wide.rc09_RT3_term_grade_percent AS rc9_Q3
           ,gr_wide.rc09_RT4_term_grade_percent AS rc9_Q4
           ,gr_wide.rc09_CUR_term_grade_percent AS rc9_cur
            
           ,gr_wide.rc10_course_name AS rc10_course_name
           ,gr_wide.rc10_y1_grade_percent AS rc10_Y1
           ,gr_wide.rc10_RT1_term_grade_percent AS rc10_Q1
           ,gr_wide.rc10_RT2_term_grade_percent AS rc10_Q2
           ,gr_wide.rc10_RT3_term_grade_percent AS rc10_Q3
           ,gr_wide.rc10_RT4_term_grade_percent AS rc10_Q4
           ,gr_wide.rc10_CUR_term_grade_percent AS rc10_cur

           ,exams.E1_all
           ,exams.E2_all
            
           ,cat.A_Y1 AS AY_all                
           ,cat.H_Y1 AS HY_all     
           ,cat.P_Y1 AS PY_all
           ,cat.C_Y1 AS CY_all            
           ,cat.A_RT1 AS a1
           ,cat.A_RT2 AS a2
           ,cat.A_RT3 AS a3
           ,cat.A_RT4 AS a4
           ,cat.C_RT1 AS c1
           ,cat.C_RT2 AS c2
           ,cat.C_RT3 AS c3
           ,cat.C_RT4 AS c4            
           ,cat.H_RT1 AS h1
           ,cat.H_RT2 AS h2
           ,cat.H_RT3 AS h3
           ,cat.H_RT4 AS h4
           ,cat.P_RT1 AS p1
           ,cat.P_RT2 AS p2
           ,cat.P_RT3 AS p3
           ,cat.P_RT4 AS p4            
            
           /* PROMO */
           ,failing.failing_courses AS courses
           ,CASE WHEN failing.n_failing IS NULL THEN 0 ELSE failing.n_failing END AS num_failing            
      
           /* AR */
           ,CONVERT(FLOAT,ar_cur.points) AS points_cur
           ,ar_cur.points_goal AS points_goal_cur
           ,ar_cur.stu_status_points AS status_cur
           ,CONVERT(FLOAT,ar_yr.points) AS points_yr
           ,ar_yr.points_goal AS points_goal_yr
           ,ar_yr.stu_status_points AS status_yr
      
           /* MAP */
           ,COALESCE(map_sci_cur.percentile_2011_norms, map_sci_base.testpercentile) AS map_sci_pct
           ,COALESCE(map_sci_cur.testritscore, map_sci_base.testritscore) AS map_sci_rit
           ,COALESCE(map_math_cur.percentile_2011_norms, map_math_base.testpercentile) AS map_math_pct
           ,COALESCE(map_math_cur.testritscore, map_math_base.testritscore) AS map_math_rit
           ,COALESCE(map_read_cur.percentile_2011_norms, map_read_base.testpercentile) AS map_read_pct
           ,COALESCE(map_read_cur.testritscore, map_read_base.testritscore) AS map_read_rit
           ,COALESCE(map_read_cur.rittoreadingscore, map_read_base.lexile_score) AS lexile_cur
           ,map_read_cur.rittoreadingmin AS lexile_min
           ,map_read_cur.rittoreadingmax AS lexile_max          
      
           /* DISC */
           ,merits.n_logs_yr AS merits_yr                  
           ,merits.n_logs_term AS merits_curr
           ,demerits.n_logs_yr AS demerits_yr                  
           ,demerits.n_logs_term AS demerits_curr
           ,detentions.n_logs_yr AS detentions
            
           ,disc.subtype
           ,disc.entry_date
            
           ,ISNULL(disc_counts.n_removals_yr,0) AS class_removal
           ,ISNULL(disc_counts.n_iss_yr,0) AS disc_ISS
           ,ISNULL(disc_counts.n_oss_yr,0) AS disc_OSS
            
           /* STANDARDIZED TESTS */
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
                        
           ,hspa.LAL_scale_score AS HSPA_LAL_scale
           ,hspa.LAL_proficiency AS HSPA_LAL_prof
           ,hspa.Math_scale_score AS HSPA_math_scale
           ,hspa.Math_proficiency AS HSPA_math_prof

     FROM KIPP_NJ..COHORT$identifiers_long#static roster WITH(NOLOCK) 
     JOIN KIPP_NJ..REPORTING$dates curterm WITH(NOLOCK)
       ON roster.schoolid = curterm.schoolid
      AND CONVERT(DATE,GETDATE()) BETWEEN curterm.start_date AND curterm.end_date 
      AND curterm.identifier = 'RT'    

     /* ATTENDANCE */
     LEFT OUTER JOIN KIPP_NJ..ATT_MEM$attendance_counts_long#static att_counts WITH(NOLOCK)
       ON roster.studentid = att_counts.studentid     
      AND roster.year = att_counts.academic_year
      AND curterm.alt_name = att_counts.term
        
     /* GPA */
     LEFT OUTER JOIN GRADES$GPA_detail_long#static nca_gpa WITH(NOLOCK)
       ON roster.student_number = nca_gpa.student_number      
      AND roster.year = nca_gpa.academic_year
      AND nca_gpa.is_curterm = 1
     LEFT OUTER JOIN GRADES$GPA_cumulative#static gpa_cumulative WITH(NOLOCK)
       ON roster.studentid = gpa_cumulative.studentid
      AND roster.schoolid = gpa_cumulative.schoolid
        
     /* GRADES */
     LEFT OUTER JOIN KIPP_NJ..GRADES$final_grades_wide_course#static gr_wide WITH(NOLOCK)
       ON roster.student_number = gr_wide.student_number
      AND roster.year = gr_wide.academic_year
      AND curterm.alt_name = gr_wide.term
     LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static cat WITH(NOLOCK)
       ON roster.student_number = cat.student_number
      AND roster.year = cat.academic_year
      AND curterm.time_per_name = cat.reporting_term
      AND cat.COURSE_NUMBER = 'ALL'
     LEFT OUTER JOIN exams
       ON roster.student_number = exams.student_number        
     LEFT OUTER JOIN failing
       ON roster.student_number = failing.student_number
      
     /* ACCELERATED READER */
     LEFT OUTER JOIN AR$progress_to_goals_long#static ar_cur WITH (NOLOCK)
       ON roster.studentid = ar_cur.studentid             
      AND roster.year = ar_cur.academic_year       
      AND GETDATE() BETWEEN ar_cur.start_date AND ar_cur.end_date       
      AND ar_cur.time_hierarchy = 2
     LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
       ON roster.studentid = ar_yr.studentid      
      AND roster.year = ar_yr.academic_year       
      AND ar_yr.time_hierarchy = 1 
       
     /* MAP */
     LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_read_cur WITH (NOLOCK)
       ON roster.student_number = map_read_cur.student_number       
      AND roster.year = map_read_cur.academic_year
      AND map_read_cur.measurementscale  = 'Reading'
      AND map_read_cur.rn_curr = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_read_base WITH (NOLOCK)
       ON roster.studentid = map_read_base.studentid
      AND roster.year = map_read_base.year
      AND map_read_base.measurementscale  = 'Reading'             
     LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_math_cur WITH (NOLOCK)
       ON roster.student_number = map_math_cur.student_number
      AND roster.year = map_math_cur.academic_year
      AND map_math_cur.measurementscale = 'Mathematics'       
      AND map_math_cur.rn_curr = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_math_base WITH (NOLOCK)
       ON roster.studentid = map_math_base.studentid
      AND roster.year = map_math_base.year
      AND map_math_base.measurementscale  = 'Mathematics'             
     LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_sci_cur WITH (NOLOCK)
       ON roster.student_number = map_sci_cur.student_number
      AND roster.year = map_sci_cur.academic_Year
      AND map_sci_cur.measurementscale = 'Science - General Science'       
      AND map_sci_cur.rn_curr = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_sci_base WITH (NOLOCK)
       ON roster.studentid = map_sci_base.studentid
      AND roster.year = map_sci_base.year
      AND map_sci_base.measurementscale  = 'Science - General Science'       

     --MERITS & DEMERITS
     LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_long#static merits WITH(NOLOCK)
       ON roster.student_number = merits.student_number
      AND roster.year = merits.academic_year
      AND curterm.alt_name = merits.term
      AND merits.logtypeid = 3023
     LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_long#static demerits WITH(NOLOCK)
       ON roster.student_number = demerits.student_number
      AND roster.year = demerits.academic_year
      AND curterm.alt_name = demerits.term
      AND demerits.logtypeid = 3223
     LEFT OUTER JOIN KIPP_NJ..DISC$log_counts_long#static detentions WITH(NOLOCK)
       ON roster.student_number = detentions.student_number
      AND roster.year = detentions.academic_year
      AND curterm.alt_name = detentions.term
      AND detentions.logtypeid = -100000
     LEFT OUTER JOIN DISC$log#static disc WITH(NOLOCK)
       ON roster.studentid = disc.studentid       
      AND roster.year = disc.academic_year
      AND disc.logtypeid = 3023      
      AND disc.rn = 1
     LEFT OUTER JOIN disc_counts
       ON roster.studentid = disc_counts.studentid             
      
     /* STANDARDIZED TESTS */
     LEFT OUTER JOIN KIPP_NJ..KTC$highest_scores_wide ktc WITH(NOLOCK)
       ON roster.student_number = ktc.student_number
     LEFT OUTER JOIN KIPP_NJ..HSPA$best_score hspa WITH(NOLOCK)
       ON roster.SID = hspa.SID       

     WHERE roster.year = dbo.fn_Global_Academic_Year()
       AND roster.rn = 1        
       AND roster.schoolid = 73253
       AND roster.enroll_status = 0
    ) sub_1