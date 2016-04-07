USE KIPP_NJ
GO

ALTER VIEW COHORT$retention_flags AS 

SELECT sub.studentid
      ,sub.year
      ,retained_yr_flag
      ,MAX(retained_yr_flag) OVER(PARTITION BY sub.studentid) AS retained_ever_flag
FROM
    (
     SELECT co.studentid      
           ,co.year           
           ,CASE 
             WHEN co.grade_level != 99 AND co.grade_level <= LAG(co.grade_level, 1) OVER(PARTITION BY co.studentid ORDER BY co.year ASC) THEN 1 
             ELSE 0 
            END AS retained_yr_flag
     FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
     WHERE co.rn = 1       
    ) sub