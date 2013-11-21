/*
PURPOSE:
  GPA detail for all terms
  
MAINTENANCE:
  None
  Dependent on GRADES$detail#MS, grades_extended
  
MAJOR STRUCTURAL REVISIONS OR CHANGES:
  Ported to SQL Server like a bau5 - CB

CREATED BY: AM2
  
ORIGIN DATE: Fall 2011
LAST MODIFIED: Fall 2013 (CB)
  
*/
USE KIPP_NJ
GO

ALTER VIEW GPA$detail#Rise AS
SELECT TOP (100) PERCENT *
FROM
       (SELECT studentid
             ,student_number
             ,schoolid
             ,lastfirst 
             ,grade_level
             ,GPA_T1
             ,GPA_T2
             ,GPA_T3
             ,GPA_Y1
             ,GPA_Y1_Rank
             ,GPA_Y1_Rank_G
             ,MAX(GPA_Y1_Rank_G) OVER (PARTITION BY grade_level) AS Y1_Dem
             ,MAX(GPA_T1_Rank_G) OVER (PARTITION BY grade_level) AS T1_Dem
             ,MAX(GPA_T2_Rank_G) OVER (PARTITION BY grade_level) AS T2_Dem
             ,MAX(GPA_T3_Rank_G) OVER (PARTITION BY grade_level) AS T3_Dem
             ,GPA_T1_Rank
             ,GPA_T1_Rank_G
             ,GPA_T2_Rank
             ,GPA_T2_Rank_G
             ,GPA_T3_Rank
             ,GPA_T3_Rank_G
             ,elements
             ,num_failing
             ,failing    
       FROM
             (SELECT studentid
                    ,student_number
                    ,schoolid
                    ,lastfirst 
                    ,grade_level
                    ,GPA_T1
                    ,GPA_T2
                    ,GPA_T3
                    ,GPA_Y1
                    ,RANK() OVER (PARTITION BY schoolid  ORDER BY GPA_Y1 DESC) GPA_Y1_Rank
                    ,RANK() OVER (PARTITION BY schoolid,grade_level ORDER BY GPA_Y1 DESC) GPA_Y1_Rank_G
                    ,RANK() OVER (PARTITION BY schoolid ORDER BY GPA_T1 DESC) GPA_T1_Rank
                    ,RANK() OVER (PARTITION BY schoolid,grade_level ORDER BY GPA_T1 DESC) GPA_T1_Rank_G
                    ,RANK() OVER (PARTITION BY schoolid ORDER BY GPA_T2 DESC) GPA_T2_Rank
                    ,RANK() OVER (PARTITION BY schoolid,grade_level ORDER BY GPA_T2 DESC) GPA_T2_Rank_G
                    ,RANK() OVER (PARTITION BY schoolid ORDER BY GPA_T3 DESC) GPA_T3_Rank
                    ,RANK() OVER (PARTITION BY schoolid,grade_level ORDER BY GPA_T3 DESC) GPA_T3_Rank_G
                    ,elements
                    ,num_failing
                    ,failing
             FROM
                    (SELECT studentid
                           ,student_number
                           ,schoolid
                           ,lastfirst 
                           ,grade_level
                           ,dbo.GROUP_CONCAT(course_y1) AS elements
                           ,ROUND(SUM(weighted_points_T1)/SUM(credit_hours_T1),2) AS GPA_T1
                           ,ROUND(SUM(weighted_points_T2)/SUM(credit_hours_T2),2) AS GPA_T2
                           ,ROUND(SUM(weighted_points_T3)/SUM(credit_hours_T3),2) AS GPA_T3
                           ,ROUND(SUM(weighted_points_Y1)/SUM(credit_hours_Y1),2) AS GPA_Y1
                           ,SUM(Promo_Test) AS num_failing
                           ,dbo.GROUP_CONCAT(failing_y1) AS failing
                     FROM KIPP_NJ..GRADES$detail#MS WITH (NOLOCK)
                     WHERE SCHOOLID = 73252
                     GROUP BY studentid, student_number, schoolid, lastfirst, grade_level
                    ) sub
             ) sub2
       ) sub3
ORDER BY GPA_Y1_Rank