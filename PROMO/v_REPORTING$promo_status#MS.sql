USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_status#MS AS

WITH final_grades AS (
  SELECT *
        ,CASE
          WHEN N_below_65 > 0 THEN 'Off Track'
          WHEN N_below_70 > 0 THEN 'Warning'
          ELSE 'Satisfactory'
         END AS promo_grades_rise
        ,CASE WHEN N_below_65 > 0 THEN 'Promotion In Doubt' ELSE 'On Track' END AS promo_grades_team
  FROM
      (
       SELECT gr.student_number
             ,gr.term
             ,SUM(CASE WHEN gr.y1_grade_percent_adjusted < 70 THEN 1 ELSE 0 END) AS N_below_70
             ,SUM(CASE WHEN gr.y1_grade_percent_adjusted < 65 THEN 1 ELSE 0 END) AS N_below_65
       FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
       WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND gr.credittype != 'COCUR'  
         AND gr.y1_grade_percent_adjusted IS NOT NULL
       GROUP BY gr.student_number
               ,gr.term
      ) sub
 )

,attendance AS (
  SELECT *
        ,CASE WHEN sub.att_pts_pct <= 90 THEN 'Off Track' ELSE 'On Track' END AS promo_att_team
        ,CASE 
          WHEN sub.att_pts_pct >= 98 THEN 'Honors'
          WHEN sub.att_pts_pct BETWEEN 89.5 AND 92 THEN 'Warning'
          WHEN sub.att_pts_pct < 89.5 THEN 'Off Track'
          ELSE 'Satisfactory' 
         END AS promo_att_rise
        ,ROUND((((sub.MEM_counts_yr * 0.105) - att_pts) / -0.105) + 0.5,0) AS days_to_90
        ,ROUND((((sub.MEM_counts_yr * 0.105) - ABS_all_counts_yr) / -0.105) + 0.5,0) AS days_to_90_abs_only
  FROM
      (
       SELECT att.studentid
             ,att.term
             ,att.MEM_counts_yr
             ,att.ABS_all_counts_yr
             ,att.TDY_all_counts_yr        
             ,ROUND(att.ABS_all_counts_yr + (att.TDY_all_counts_yr / 3), 1, 1) AS att_pts
             ,ROUND(((att.MEM_counts_yr - (att.ABS_all_counts_yr + FLOOR(att.TDY_all_counts_yr / 3))) / att.MEM_counts_yr) * 100, 1) AS att_pts_pct
       FROM KIPP_NJ..ATT_MEM$attendance_counts_long#static att WITH(NOLOCK)
       WHERE att.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND att.MEM_counts_yr > 0
      ) sub
 )

SELECT studentid
      ,student_number      
      
      ,term
      ,is_curterm
      
      ,att_pts AS attendance_points
      ,att_pts_pct AS y1_att_pts_pct      
      ,days_to_90      
      ,days_to_90_abs_only
      ,promo_att_team            
      ,promo_att_rise

      ,N_below_65
      ,N_below_70
      ,promo_grades_team      
      ,promo_grades_rise
      ,promo_grades_gpa_rise      
      
      ,H_Y1 AS hw_avg
      ,promo_hw_rise
      ,promo_hw_rise AS promo_hw_team
      
      ,GPA_Y1 AS GPA_y1_all
      
      ,CASE 
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw_rise LIKE '%Off Track%' THEN 'Off Track'
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw_rise LIKE '%Warning%' THEN 'Warning'
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw_rise LIKE '%High Honors%' THEN 'High Honors'
        WHEN promo_grades_gpa_rise + promo_att_rise + promo_hw_rise LIKE '%Honors%' THEN 'Honors'        
        ELSE 'Satisfactory' 
       END AS promo_overall_rise
      ,CASE 
        WHEN (promo_grades_team + promo_att_team LIKE '%Off Track%' OR
              promo_grades_team + promo_att_team LIKE '%Warning%' OR
              promo_grades_team + promo_att_team LIKE '%Promotion In Doubt%') THEN 'Promotion In Doubt'
        ELSE 'On Track'
       END AS promo_overall_team

      ,ROW_NUMBER() OVER(
         PARTITION BY studentid
           ORDER BY term DESC) AS rn_curterm
FROM
    (
     SELECT co.studentid
           ,co.student_number
           ,co.schoolid
      
           ,dt.alt_name AS term
           ,dt.time_per_name AS reporting_term
           ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dt.start_date AND dt.end_date THEN 1 ELSE 0 END AS is_curterm
      
           ,fg.N_below_70
           ,fg.N_below_65
           ,fg.promo_grades_rise
           ,fg.promo_grades_team

           ,gpa.GPA_Y1
           ,CASE 
             WHEN gpa.GPA_Y1 >= 3.5 AND promo_grades_rise NOT LIKE '%Warning%' THEN 'High Honors'
             WHEN gpa.GPA_Y1 >= 3.0 AND promo_grades_rise NOT LIKE '%Warning%' THEN 'Honors'        
             ELSE promo_grades_rise
            END AS promo_grades_gpa_rise

           ,cat.H_Y1
           ,CASE 
             WHEN cat.H_Y1 >= 90 THEN 'Honors'
             WHEN cat.H_Y1 < 65 THEN 'Off Track'
             WHEN cat.H_Y1 < 70 THEN 'Warning'        
             ELSE 'Satisfactory'
            END AS promo_hw_rise

           ,att.MEM_counts_yr
           ,att.ABS_all_counts_yr
           ,att.TDY_all_counts_yr
           ,att.att_pts
           ,att.att_pts_pct
           ,att.promo_att_rise
           ,att.promo_att_team
           ,att.days_to_90
           ,att.days_to_90_abs_only
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
       ON co.schoolid = dt.schoolid
      AND co.year = dt.academic_year
      AND dt.identifier = 'RT'
      AND dt.alt_name != 'Summer School'
     LEFT OUTER JOIN final_grades fg
       ON co.student_number = fg.student_number
      AND dt.alt_name = fg.term
     LEFT OUTER JOIN attendance att
       ON co.studentid = att.studentid
      AND dt.alt_name = att.term
     LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static gpa WITH(NOLOCK)
       ON co.student_number = gpa.student_number
      AND co.year = gpa.academic_year
      AND dt.alt_name = gpa.term
     LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static cat WITH(NOLOCK)
       ON co.student_number = cat.student_number
      AND co.year = cat.academic_year 
      AND dt.time_per_name = cat.reporting_term
      AND cat.CREDITTYPE = 'ALL' 
     WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND ((co.grade_level BETWEEN 5 AND 8) OR (co.grade_level = 4 AND co.schoolid = 73252))
       AND co.rn = 1 
    ) sub