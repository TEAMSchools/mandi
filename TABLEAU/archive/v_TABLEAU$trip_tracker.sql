USE KIPP_NJ
GO

ALTER VIEW TABLEAU$trip_tracker AS

WITH disc_count AS (
  SELECT studentid
        ,entry_date        
        ,SUM(CASE WHEN subtype = 'Detention' THEN 1 ELSE 0 END) detentions
        ,SUM(CASE 
              WHEN subtype = 'Silent Lunch' THEN 1
              WHEN subtype = 'Silent Lunch (5 Day)' THEN 5
              ELSE 0 
             END) AS silent_lunches
        ,SUM(CASE WHEN subtype LIKE '%Choices%' OR subtype LIKE 'Bench%' THEN 1 ELSE 0 END) AS bench_choices
        ,SUM(CASE WHEN subtype LIKE '%ISS%' THEN 1 ELSE 0 END) AS ISS
        ,SUM(CASE WHEN subtype = 'Class Removal' THEN 1 ELSE 0 END) AS class_removal
        ,SUM(CASE WHEN subtype LIKE '%OSS%' THEN 1 ELSE 0 END) AS OSS
        ,SUM(CASE WHEN subtype = 'Paycheck' AND discipline_details = 'Paycheck Below $90' THEN 1 ELSE 0 END) AS paycheck_below_90
        ,SUM(CASE WHEN subtype = 'Paycheck' AND discipline_details = 'Paycheck Below $80' THEN 1 ELSE 0 END) AS paycheck_below_80                
  FROM KIPP_NJ..DISC$log#static WITH(NOLOCK)
  WHERE schoolid IN (73252, 133570965, 179902, 73258)
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND logtypeid = -100000
  GROUP BY studentid
          ,entry_date          
 )

SELECT s.student_number      
      ,s.lastfirst      
      ,s.school_name
      ,s.grade_level
      ,s.team
      ,s.advisor      
      ,s.term
      ,s.date
      
      ,dt.time_per_name
      
      ,promo.promo_overall_rise AS promo_status_overall      
      ,promo.attendance_points
      ,CASE
        WHEN s.schoolid = 73252 THEN promo.promo_grades_gpa_rise
        WHEN s.schoolid = 133570965 THEN promo.promo_grades_team 
       END AS promo_status_grades
      ,CASE
        WHEN s.schoolid = 73252 THEN promo.promo_att_rise 
        WHEN s.schoolid = 133570965 THEN promo.promo_att_team
       END AS promo_status_att
      ,CASE
        WHEN s.schoolid = 73252 THEN promo.promo_hw_rise 
        WHEN s.schoolid = 133570965 THEN promo.promo_hw_team
       END AS promo_status_hw      
      
      ,rise_gpa.GPA_Y1 AS GPA_y1_all      
      ,rise_gpa.n_failing_y1 AS n_failing_all      
      
      ,cat.H_CUR AS hwc_term
      ,cat.E_CUR AS hwq_term
      
      --,ts.HY AS hwc_y1
      --,ts.H_term AS hwc_term
      --,ts.EY AS hwq_y1
      --,ts.E_term AS hwq_term
      
      ,ISNULL(disc_count.silent_lunches,0) AS silent_lunches
      ,ISNULL(disc_count.detentions,0) AS detentions
      ,ISNULL(disc_count.bench_choices,0) AS bench_choices
      ,ISNULL(disc_count.ISS,0) AS ISS
      ,ISNULL(disc_count.OSS,0) AS OSS
      ,ISNULL(disc_count.class_removal,0) AS class_removal
      ,ISNULL(disc_count.paycheck_below_80,0) AS paycheck_below_80
      ,ISNULL(disc_count.paycheck_below_90,0) AS paycheck_below_90
FROM KIPP_NJ..COHORT$identifiers_scaffold#static s WITH(NOLOCK)
--LEFT OUTER JOIN KIPP_NJ..GRADES$time_series_wide#static ts WITH(NOLOCK)
--  ON s.student_number = ts.student_number
-- AND s.date = ts.date
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON s.schoolid = dt.schoolid
 AND s.date BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..REPORTING$promo_status#MS promo WITH(NOLOCK)
  ON s.studentid = promo.studentid
 AND promo.is_curterm = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static rise_gpa WITH(NOLOCK)
  ON s.student_number = rise_gpa.student_number
 AND s.year = rise_gpa.academic_year
 AND rise_gpa.is_curterm = 1
LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static cat WITH(NOLOCK)
  ON s.student_number = cat.student_number
 AND s.year = cat.academic_year
 AND dt.time_per_name = cat.reporting_term
 AND cat.course_number = 'ALL'
LEFT OUTER JOIN disc_count WITH(NOLOCK)
  ON s.studentid = disc_count.studentid
 AND s.date = disc_count.entry_date
WHERE s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND s.enroll_status = 0
  AND s.schoolid IN (73252,133570965)
  AND s.date <= CONVERT(DATE,GETDATE())