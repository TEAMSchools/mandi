USE KIPP_NJ
GO

ALTER VIEW TABLEAU$trip_tracker#TEAM AS

WITH paycheck_avg AS (
  SELECT student_number        
        ,CASE 
          WHEN SUM(points_denom) = 0 THEN NULL          
          ELSE ((SUM(points_denom) + SUM(points_num)) / SUM(points_denom))
         END AS points_pct
  FROM
      (
       SELECT bhv.external_id AS student_number             
             ,CASE WHEN bhv.behavior != 'Deposit' THEN CONVERT(FLOAT,bhv.dollar_points) ELSE NULL END AS points_num
             ,CASE WHEN bhv.behavior = 'Deposit' THEN CONVERT(FLOAT,bhv.dollar_points) ELSE NULL END AS points_denom                 
       FROM KIPP_NJ..AUTOLOAD$KICKBOARD_behavior bhv WITH(NOLOCK)       
      ) sub
  GROUP BY student_number
 )

SELECT *
      ,ISNULL(gpa_pts,0)
         + ISNULL(hw_pts,0)
         + ISNULL(paycheck_pts,0)
         + ISNULL(independence_pts,0)
         + ISNULL(responds_pts,0) AS total_points
FROM
    (
     SELECT co.student_number
           ,co.lastfirst
           ,co.year AS academic_year
           ,co.schoolid
           ,co.grade_level      
           ,co.team
           ,co.advisor
           /* GPA = 12.5% */
           ,gpa.GPA_y1_all
           ,CASE
             WHEN gpa.GPA_y1_all >= 4.0 THEN 15
             WHEN gpa.GPA_y1_all BETWEEN 3.5 AND 3.99 THEN 12.5
             WHEN gpa.GPA_y1_all BETWEEN 3.0 AND 3.49 THEN 10
             WHEN gpa.GPA_y1_all BETWEEN 2.5 AND 2.99 THEN 8
             WHEN gpa.GPA_y1_all BETWEEN 2.0 AND 2.49 THEN 6
             WHEN gpa.GPA_y1_all BETWEEN 1.0 AND 1.99 THEN 4
             WHEN gpa.GPA_y1_all < 1.0 THEN 0        
            END AS gpa_pts
      
           /* HW = 12.5% */
           ,ele.simple_avg AS hw_y1_all
           ,ROUND(ele.simple_avg * .125, 1) AS hw_pts
      
           /* Paycheck = 50% */
           ,ROUND(kb.points_pct * 100, 1) AS paycheck_y1_avg
           ,CASE
             WHEN kb.points_pct < 0 THEN 0
             ELSE ROUND(kb.points_pct * 50, 1) 
            END AS paycheck_pts

           /* Trust Scores = 12.5% each*/
           ,NULL AS independence_avg
           ,NULL AS independence_pts
           ,NULL AS responds_avg
           ,NULL AS responds_pts
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..GPA$detail#MS gpa WITH(NOLOCK)
       ON co.student_number = gpa.STUDENT_NUMBER
     LEFT OUTER JOIN KIPP_NJ..GRADES$elements ele WITH(NOLOCK)
       ON co.studentid = ele.studentid
      AND ele.pgf_type = 'H'
      AND ele.course_number = 'all_courses'
     LEFT OUTER JOIN paycheck_avg kb
       ON co.student_number = kb.student_number
     WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND co.enroll_status = 0
       AND co.schoolid = 133570965
    ) sub