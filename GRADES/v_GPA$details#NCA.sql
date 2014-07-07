/*
PURPOSE:
  GPA detail for all terms
  
MAINTENANCE:
  None
  Dependent on grades_extended, GRADES$detail#NCA
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Ported to SQL Server yo - CB

CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
LAST MODIFIED: Fall 2013 (CB)
  
*/

ALTER VIEW GPA$detail#NCA AS

SELECT studentid
      ,student_number
      ,schoolid
      ,lastfirst
      ,grade_level
      ,dbo.GROUP_CONCAT(course_y1) AS elements
      ,ROUND(SUM(weighted_points_Q1)/SUM(credit_hours_Q1),2) AS GPA_Q1
      ,ROUND(SUM(weighted_points_Q2)/SUM(credit_hours_Q2),2) AS GPA_Q2
      ,ROUND(SUM(weighted_points_Q3)/SUM(credit_hours_Q3),2) AS GPA_Q3
      ,ROUND(SUM(weighted_points_Q4)/SUM(credit_hours_Q4),2) AS GPA_Q4
      ,ROUND(SUM(weighted_points_E1)/SUM(credit_hours_E1),2) AS GPA_E1
      ,ROUND(SUM(weighted_points_E2)/SUM(credit_hours_E2),2) AS GPA_E2
      --if you need to override Y1 GPA for a RC window here is an example for theoretical Q2 RC
      --      ,ROUND( (SUM(weighted_points_Q1) + SUM(weighted_points_Q2))
      --        /(SUM(credit_hours_Q1) + SUM(credit_hours_Q2)),2) AS GPA_Y1
      ,ROUND(SUM(weighted_points_Y1)/SUM(credit_hours_Y1),2) AS GPA_Y1
      ,ROUND(SUM(weighted_points_Q1 + weighted_points_Q2 + weighted_points_E1)/SUM(credit_hours_Q1 + credit_hours_Q2 + credit_hours_E1),2) AS GPA_S1
      ,ROUND(SUM(weighted_points_Q3 + weighted_points_Q4 + weighted_points_E2)/SUM(credit_hours_Q3 + credit_hours_Q4 + credit_hours_E2),2) AS GPA_S2
      ,SUM(Promo_Test) AS num_failing
      ,dbo.GROUP_CONCAT(failing_y1) AS failing
FROM KIPP_NJ..GRADES$detail#NCA WITH (NOLOCK)
GROUP BY studentid, student_number, schoolid, lastfirst, grade_level