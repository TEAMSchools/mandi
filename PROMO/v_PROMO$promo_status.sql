USE KIPP_NJ
GO

ALTER VIEW PROMO$promo_status AS

WITH attendance AS (
  SELECT studentid
        ,academic_year
        ,term
        ,MEM_counts_yr
        ,ABS_all_counts_yr
        ,TDY_all_counts_yr
        ,att_pts
        ,att_pts_pct
        ,ROUND((((sub.MEM_counts_yr * 0.105) - att_pts) / -0.105) + 0.5,0) AS days_to_90
        ,ROUND((((sub.MEM_counts_yr * 0.105) - ABS_all_counts_yr) / -0.105) + 0.5,0) AS days_to_90_abs_only
        ,CASE 
          --WHEN sub.att_pts_pct >= 98 THEN 'Honors'
          WHEN sub.att_pts_pct >= 92 THEN 'On Track'
          WHEN sub.att_pts_pct >= 90 THEN 'Warning'
          WHEN sub.att_pts_pct < 90 THEN 'Off Track'          
         END AS promo_status_attendance        
  FROM
      (
       SELECT att.studentid
             ,att.academic_year
             ,att.term
             ,att.MEM_counts_yr
             ,att.ABS_all_counts_yr
             ,att.TDY_all_counts_yr        
             ,ROUND(att.ABS_all_counts_yr + (att.TDY_all_counts_yr / 3), 1, 1) AS att_pts
             ,ROUND(((att.MEM_counts_yr - (att.ABS_all_counts_yr + FLOOR(att.TDY_all_counts_yr / 3))) / att.MEM_counts_yr) * 100, 0) AS att_pts_pct
       FROM KIPP_NJ..ATT_MEM$attendance_counts_long#static att WITH(NOLOCK)
       WHERE att.MEM_counts_yr > 0
      ) sub
 )

,lit AS (
  SELECT lit.student_number
        ,lit.academic_year
        ,CASE WHEN lit.test_round = 'DR' AND is_curterm = 1 THEN 'Q1' ELSE lit.test_round END AS term
        ,lit.read_lvl
        ,lit.goal_lvl      
        ,lit.goal_status        
        ,COUNT(lit.read_lvl) OVER(PARTITION BY lit.studentid, lit.academic_year) - 1 AS n_growth_rounds
        ,lit.met_goal
        ,CASE 
          WHEN lit.lvl_num >= lit.natl_goal_num THEN 1
          WHEN lit.lvl_num < lit.natl_goal_num THEN 0
         END AS met_natl_goal
        
        ,MAX(CASE WHEN lit.rn_round_asc = 1 THEN lit.read_lvl END) OVER(PARTITION BY lit.student_number, lit.academic_year) AS base_read_lvl
        ,lit.lvl_num - MAX(CASE WHEN lit.rn_round_asc = 1 THEN lit.lvl_num END) OVER(PARTITION BY lit.student_number, lit.academic_year) AS lvls_grown_yr        
        ,lit.lvl_num - LAG(lit.lvl_num, 1) OVER(PARTITION BY lit.student_number, lit.academic_year ORDER BY lit.rn_round_asc) AS lvls_grown_term        
  FROM KIPP_NJ..LIT$achieved_by_round#static lit WITH(NOLOCK)  
  --WHERE lit.start_date <= CONVERT(DATE,GETDATE())
 )

,final_grades AS (
  SELECT student_number
        ,academic_year
        ,term
        ,N_below_60
        ,N_below_65
        ,N_below_70
        ,CASE
          WHEN N_below_60 > 0 THEN 'Off Track'
          WHEN N_below_70 > 0 THEN 'Warning'
          ELSE 'On Track'
         END AS promo_status_grades        
  FROM
      (
       SELECT gr.student_number
             ,gr.academic_year
             ,gr.term
             ,SUM(CASE WHEN gr.y1_grade_percent_adjusted < 70 THEN 1 ELSE 0 END) AS N_below_70
             ,SUM(CASE WHEN gr.y1_grade_percent_adjusted < 65 THEN 1 ELSE 0 END) AS N_below_65
             ,SUM(CASE WHEN gr.y1_grade_percent_adjusted < 60 THEN 1 ELSE 0 END) AS N_below_60
       FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
       WHERE gr.excludefromgpa = 0
         AND gr.y1_grade_percent_adjusted IS NOT NULL
       GROUP BY gr.student_number
               ,gr.term
               ,gr.academic_year
      ) sub
 )

,credits AS (
  SELECT student_number
        ,academic_year
        ,term      
        ,ISNULL(SUM(credit_hours),0) AS total_credit_hours_enrolled
        ,ISNULL(SUM(CASE WHEN y1_grade_letter LIKE 'F%' THEN 0 ELSE credit_hours END),0) AS total_projected_credit_hours
  FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
  GROUP BY student_number
          ,academic_year
          ,term      
 )

SELECT *
      ,CASE 
        WHEN school_level = 'ES' AND (SPEDLEP = 'SPED' OR retention_flag >= 1) THEN 'See Teacher'
        WHEN CONCAT(promo_status_attendance, promo_status_credits, promo_status_grades, promo_status_lit) LIKE '%Off Track%' THEN 'Off Track'
        --WHEN CONCAT(promo_status_attendance, promo_status_credits, promo_status_grades, promo_status_lit) LIKE '%Honors%' THEN 'Honors'
        ELSE 'On Track'
       END AS promo_status_overall
FROM
    (
     SELECT co.studentid
           ,co.student_number
           ,co.year AS academic_year
           ,co.schoolid      
           ,co.school_level
           ,co.spedlep
           ,co.retained_ever_flag + co.retained_yr_flag AS retention_flag
           ,dt.alt_name AS term
           ,dt.time_per_name AS reporting_term
           ,CASE 
             WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 
             WHEN co.year < KIPP_NJ.dbo.fn_Global_Academic_Year() AND dt.alt_name = 'Q4' THEN 1 /* keeps things alive during summer */
             ELSE 0 
            END AS is_curterm

           /* attendance */
           ,att.promo_status_attendance
           ,att.att_pts_pct
           ,att.att_pts
           ,att.MEM_counts_yr
           ,att.ABS_all_counts_yr
           ,att.TDY_all_counts_yr
           ,att.days_to_90
           ,att.days_to_90_abs_only

           /* lit */
           ,CASE                     
             --WHEN lit.lvls_grown_term IS NULL OR lit.n_growth_rounds < 0 THEN NULL                
             /* Life Upper students have different promo criteria */
             WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.goal_status IN ('On Track','Off Track') THEN 'On Track' /* if On Track, then On Track*/
             WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.lvls_grown_yr >= lit.n_growth_rounds THEN 'On Track' /* if grew 1 lvl per round overall, then On Track */        
             WHEN (co.schoolid = 73257 AND (co.grade_level - (year - 2014)) > 0) AND lit.lvls_grown_term < lit.n_growth_rounds THEN 'Off Track'
             ELSE lit.goal_status
            END AS promo_status_lit
           ,lit.base_read_lvl
           ,lit.read_lvl AS cur_read_lvl
           ,lit.goal_lvl
           ,lit.met_goal
           ,lit.met_natl_goal
           ,lit.goal_status AS lit_goal_status
           ,lit.lvls_grown_yr
           ,lit.lvls_grown_term

           /* final grades */
           ,fg.promo_status_grades
           ,fg.N_below_60
           ,fg.N_below_65
           ,fg.N_below_70

           /* credits */
           ,CASE
             WHEN co.grade_level < 9 THEN NULL
             WHEN co.grade_level = 12 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(earned_credits_cum,0) >= 120 THEN 'On Track'
             WHEN co.grade_level = 11 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(earned_credits_cum,0) >= 85 THEN 'On Track'
             WHEN co.grade_level = 10 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(earned_credits_cum,0) >= 50 THEN 'On Track'
             WHEN co.grade_level = 9 AND ISNULL(cr.total_projected_credit_hours,0) + ISNULL(earned_credits_cum,0) >= 25 THEN 'On Track'
             ELSE 'Off Track'
            END AS promo_status_credits
           ,CASE
             WHEN co.grade_level < 9 THEN NULL
             WHEN co.grade_level = 12 THEN 120
             WHEN co.grade_level = 11 THEN 85
             WHEN co.grade_level = 10 THEN 50
             WHEN co.grade_level = 9 THEN 25
            END AS credits_needed
           ,CASE WHEN co.grade_level < 9 THEN NULL ELSE cr.total_credit_hours_enrolled END AS credits_enrolled_y1
           ,CASE WHEN co.grade_level < 9 THEN NULL ELSE cr.total_projected_credit_hours END AS projected_credits_earned_y1
           ,CASE WHEN co.grade_level < 9 THEN NULL ELSE ISNULL(cum.earned_credits_cum,0) END AS earned_credits_cum
           ,CASE WHEN co.grade_level < 9 THEN NULL ELSE cr.total_credit_hours_enrolled + ISNULL(cum.earned_credits_cum,0) END AS credits_enrolled_cum
           ,CASE WHEN co.grade_level < 9 THEN NULL ELSE cr.total_projected_credit_hours + ISNULL(cum.earned_credits_cum,0) END AS projected_credits_earned_cum
           
           /* HW grades */
           ,cat.H_Y1 AS HWC_Y1
           ,CASE WHEN co.year <= 2015 THEN cat.E_Y1 ELSE  cat.H_Y1 END AS HWQ_Y1

           /* GPA */
           ,gpa.GPA_Y1
           ,CASE 
             WHEN gpa.GPA_Y1 IS NULL THEN NULL
             WHEN gpa.GPA_Y1 >= 3.85 THEN 'Summa Cum Laude'
             WHEN gpa.GPA_Y1 >= 3.5 THEN 'Magna Cum Laude'
             WHEN gpa.GPA_Y1 >= 3.0  THEN 'Cum Laude'
            END AS GPA_Y1_status      
           ,gpa.GPA_term      
           ,CASE 
             WHEN gpa.GPA_term IS NULL THEN NULL
             WHEN gpa.GPA_term >= 3.85 THEN 'Summa Cum Laude'
             WHEN gpa.GPA_term >= 3.5 THEN 'Magna Cum Laude'
             WHEN gpa.GPA_term >= 3.0  THEN 'Cum Laude'
            END AS GPA_term_status      
           ,cum.cumulative_Y1_gpa AS GPA_cum
           ,CASE 
             WHEN cum.cumulative_Y1_gpa IS NULL THEN NULL
             WHEN cum.cumulative_Y1_gpa >= 3.85 THEN 'Summa Cum Laude'
             WHEN cum.cumulative_Y1_gpa >= 3.5 THEN 'Magna Cum Laude'
             WHEN cum.cumulative_Y1_gpa >= 3.0  THEN 'Cum Laude'
            END AS GPA_cum_status          
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
       ON co.schoolid = dt.schoolid
      AND co.year = dt.academic_year
      AND dt.identifier = 'RT'
      AND dt.alt_name != 'Summer School'
     LEFT OUTER JOIN attendance att
       ON co.studentid = att.studentid
      AND co.year = att.academic_year
      AND dt.alt_name = att.term
     LEFT OUTER JOIN lit
       ON co.student_number = lit.student_number
      AND co.year = lit.academic_year
      AND dt.alt_name = lit.term
     LEFT OUTER JOIN final_grades fg
       ON co.student_number = fg.student_number
      AND co.year = fg.academic_year
      AND dt.alt_name = fg.term
     LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static cat WITH(NOLOCK)
       ON co.student_number = cat.student_number
      AND co.year = cat.academic_year 
      AND dt.time_per_name = cat.reporting_term
      AND cat.CREDITTYPE = 'ALL'
     LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static gpa WITH(NOLOCK)
       ON co.student_number = gpa.student_number
      AND co.year = gpa.academic_year
      AND dt.alt_name = gpa.term
     LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_cumulative#static cum WITH(NOLOCK)
       ON co.studentid = cum.studentid
      AND co.schoolid = cum.schoolid
     LEFT OUTER JOIN credits cr
       ON co.student_number = cr.student_number
      AND co.year = cr.academic_year
      AND dt.alt_name = cr.term
     WHERE co.rn = 1
    ) sub