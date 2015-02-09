USE KIPP_NJ
GO

ALTER VIEW TABLEAU$trip_tracker AS

SELECT s.student_number      
      ,s.lastfirst      
      ,s.grade_level
      ,s.team
      ,s.advisor      
      ,promo.promo_overall_rise AS promo_status_overall
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
      ,promo.attendance_points
      ,rise_gpa.GPA_y1_all      
      ,rise_gpa.n_failing_all      
      ,rise_hw.simple_avg AS hwc_y1
      ,rise_hwq.simple_avg AS hwq_y1
      ,ISNULL(disc_count.silent_lunches,0) AS silent_lunches
      ,ISNULL(disc_count.detentions,0) AS detentions
      ,CASE WHEN s.grade_level <= 6 THEN ISNULL(disc_count.bench,0) ELSE ISNULL(disc_count.choices,0) END AS bench_choices_yr
      ,ISNULL(disc_count.ISS,0) AS ISS
      ,ISNULL(disc_count.OSS,0) AS OSS
FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..REPORTING$promo_status#MS promo WITH(NOLOCK)
  ON s.studentid = promo.studentid
LEFT OUTER JOIN KIPP_NJ..GPA$detail#MS rise_gpa WITH(NOLOCK)
  ON s.studentid = rise_gpa.studentid
LEFT OUTER JOIN KIPP_NJ..GRADES$elements rise_hw WITH(NOLOCK)
  ON s.studentid = rise_hw.studentid
AND s.schoolid = rise_hw.schoolid  
 AND rise_hw.pgf_type = 'H'
AND rise_hw.yearid >= REPLACE(KIPP_NJ.dbo.fn_Global_Term_Id(),'00','')
AND rise_hw.course_number = 'all_courses'
LEFT OUTER JOIN KIPP_NJ..GRADES$elements rise_hwq WITH(NOLOCK)
  ON s.studentid = rise_hwq.studentid
AND s.schoolid = rise_hwq.schoolid
AND rise_hwq.pgf_type = 'Q'
AND rise_hwq.yearid >= REPLACE(KIPP_NJ.dbo.fn_Global_Term_Id(),'00','')
AND rise_hwq.course_number = 'all_courses'
LEFT OUTER JOIN KIPP_NJ..DISC$counts_wide disc_count WITH(NOLOCK)
  ON s.studentid = disc_count.studentid
WHERE s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND s.enroll_status = 0
  AND s.schoolid IN (73252,133570965)