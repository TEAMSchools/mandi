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

,trust_scores AS (
  SELECT student_number
        ,term
        ,responds
        ,independence
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number
             ORDER BY term DESC) AS rn
  FROM
      (
       SELECT student_number
             ,term
             ,domain
             ,AVG(score) AS avg_score
       FROM KIPP_NJ..DISC$trust_scores WITH(NOLOCK)
       GROUP BY student_number
               ,term
               ,domain
      ) sub
  PIVOT(
    MAX(avg_score)
    FOR domain IN ([responds],[independence])
   ) p  
 )

,y1_grades AS (
  SELECT STUDENT_NUMBER
        ,ROUND(AVG(y1_grade_percent_adjusted),0) AS avg_y1
  FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND SCHOOLID = 133570965
    AND is_curterm = 1
  GROUP BY STUDENT_NUMBER
 )

SELECT *
      ,ISNULL(y1_pts,0)
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
           ,gpa.GPA_y1 AS GPA_y1_all
           ,CASE
             WHEN gpa.GPA_y1 >= 4.0 THEN 15
             WHEN gpa.GPA_y1 BETWEEN 3.5 AND 3.99 THEN 12.5
             WHEN gpa.GPA_y1 BETWEEN 3.0 AND 3.49 THEN 10
             WHEN gpa.GPA_y1 BETWEEN 2.5 AND 2.99 THEN 8
             WHEN gpa.GPA_y1 BETWEEN 2.0 AND 2.49 THEN 6
             WHEN gpa.GPA_y1 BETWEEN 1.0 AND 1.99 THEN 4
             WHEN gpa.GPA_y1 < 1.0 THEN 0        
            END AS gpa_pts
           ,y1.avg_y1
           ,ROUND(y1.avg_y1 * .125,1) AS y1_pts
      
           /* HW = 12.5% */
           ,ele.H_Y1 AS hw_y1_all
           ,ROUND(ele.H_Y1 * .125, 1) AS hw_pts
      
           /* Paycheck = 50% */
           ,ROUND(kb.points_pct * 100, 1) AS paycheck_y1_avg
           ,CASE
             WHEN kb.points_pct < 0 THEN 0
             ELSE ROUND(kb.points_pct * 50, 1) 
            END AS paycheck_pts

           /* Trust Scores = 12.5% each*/
           ,t.independence AS independence_avg
           ,((t.independence / 4) * 12.5) AS independence_pts
           ,t.responds AS responds_avg
           ,((t.responds / 4) * 12.5) AS responds_pts
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..GRADES$GPA_detail_long#static gpa WITH(NOLOCK)
       ON co.student_number = gpa.STUDENT_NUMBER
      AND co.year = gpa.academic_year
      AND gpa.is_curterm = 1
     LEFT OUTER JOIN KIPP_NJ..GRADES$category_grades_wide#static ele WITH(NOLOCK)
       ON co.student_number = ele.student_number
      AND co.year = ele.academic_year
      AND ele.is_curterm = 1      
      AND ele.course_number = 'ALL'
     LEFT OUTER JOIN paycheck_avg kb
       ON co.student_number = kb.student_number
     LEFT OUTER JOIN trust_scores t
       ON co.student_number = t.student_number
      AND t.rn = 1
     LEFT OUTER JOIN y1_grades y1
       ON co.student_number = y1.STUDENT_NUMBER
     WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND co.enroll_status = 0
       AND co.schoolid = 133570965
    ) sub