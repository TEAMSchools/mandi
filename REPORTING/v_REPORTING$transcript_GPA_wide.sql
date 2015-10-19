USE KIPP_NJ
GO

ALTER VIEW REPORTING$transcript_GPA_wide AS 

WITH grades_long AS (
  SELECT co.student_number
        ,co.schoolid
        ,CONCAT(co.year, ' - ', (co.year + 1)) AS academic_year           
        ,sg.GPA_POINTS
        ,sg.EARNEDCRHRS
        ,sc.grade_points        
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..GRADES$STOREDGRADES#static sg WITH(NOLOCK)
    ON co.studentid = sg.STUDENTID
   AND co.year = sg.academic_year
   AND sg.EXCLUDEFROMGPA = 0
   AND sg.STORECODE = 'Y1'
  LEFT OUTER JOIN KIPP_NJ..GRADES$grade_scales#static sc WITH(NOLOCK)
    ON sg.PCT >= sc.low_cut
   AND sg.PCT < sc.high_cut
   AND sc.scale_id = 662
  WHERE co.rn = 1
    AND co.grade_level BETWEEN 5 AND 12  
)

SELECT student_number
      ,schoolid
      ,CONCAT('GPA', CHAR(9), CHAR(9), 'Wt', CHAR(9), 'Unwt', CHAR(9), 'Cr') AS GPA_header
      ,KIPP_NJ.dbo.GROUP_CONCAT_DS(
         CONCAT(academic_year, CHAR(9)
               ,weighted_GPA_pts, CHAR(9)
               ,unweighted_GPA_pts, CHAR(9)
               ,EARNEDCRHRS)
        ,CHAR(10), 2) AS GPA_grouped
FROM
    (
     SELECT student_number
           ,schoolid
           ,ISNULL(academic_year,'Cumulative') AS academic_year
           ,STUFF(REPLACE(LEFT(CONCAT(ROUND(SUM((GPA_POINTS * EARNEDCRHRS)) / CASE 
                                                                               WHEN SUM(EARNEDCRHRS) = 0 THEN NULL 
                                                                               ELSE SUM(EARNEDCRHRS) 
                                                                              END, 2),'00'),4),'.',''), 2, 0, '.') AS weighted_GPA_pts
           ,STUFF(REPLACE(LEFT(CONCAT(ROUND(SUM((grade_points * EARNEDCRHRS)) / CASE 
                                                                                 WHEN SUM(EARNEDCRHRS) = 0 THEN NULL 
                                                                                 ELSE SUM(EARNEDCRHRS) 
                                                                                END, 2),'00'),4),'.',''), 2, 0, '.') AS unweighted_GPA_pts      
           ,ISNULL(SUM(EARNEDCRHRS),0) AS EARNEDCRHRS
     FROM grades_long
     GROUP BY student_number
             ,schoolid
             ,CUBE(academic_year)
    ) sub
GROUP BY student_number, schoolid