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
        ,SUM(CASE WHEN subtype = 'ISS' THEN 1 ELSE 0 END) AS ISS
        ,SUM(CASE WHEN subtype = 'Class Removal' THEN 1 ELSE 0 END) AS class_removal
        ,SUM(CASE WHEN subtype = 'OSS' THEN 1 ELSE 0 END) AS OSS
  FROM KIPP_NJ..DISC$log#static WITH(NOLOCK)
  WHERE schoolid IN (73252,133570965)
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY studentid
          ,entry_date
 )

SELECT s.student_number      
      ,s.lastfirst      
      ,s.school_name
      ,s.grade_level
      ,s.team
      ,s.advisor      
      ,s.date
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
      ,ISNULL(disc_count.bench_choices,0) AS bench_choices
      ,ISNULL(disc_count.ISS,0) AS ISS
      ,ISNULL(disc_count.OSS,0) AS OSS
      ,ISNULL(disc_count.class_removal,0) AS class_removal
FROM KIPP_NJ..COHORT$identifiers_scaffold#static s WITH(NOLOCK)
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
LEFT OUTER JOIN disc_count WITH(NOLOCK)
  ON s.studentid = disc_count.studentid
 AND s.date = disc_count.entry_date
WHERE s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND s.enroll_status = 0
  AND s.schoolid IN (73252,133570965)