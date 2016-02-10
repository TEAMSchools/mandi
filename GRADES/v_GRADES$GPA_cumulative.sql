USE KIPP_NJ
GO

ALTER VIEW GRADES$GPA_cumulative AS

SELECT studentid
      ,CONVERT(FLOAT,ROUND(CONVERT(DECIMAL(4,3),(weighted_points / credit_hours)), 2)) AS cumulative_Y1_gpa
      ,earned_credits_cum      
      ,schoolid
FROM
    (
     SELECT studentid AS studentid
           ,schoolid AS schoolid
           ,ROUND(SUM(CONVERT(FLOAT,weighted_points)),3) AS weighted_points
           ,CASE
             WHEN SUM(CONVERT(FLOAT,potentialcrhrs)) = 0 THEN NULL
             ELSE SUM(CONVERT(FLOAT,potentialcrhrs))
            END AS credit_hours
           ,SUM(earnedcrhrs) AS earned_credits_cum            
     FROM 
         (
          SELECT studentid
                ,potentialcrhrs                   
                ,schoolid                   
                ,potentialcrhrs * gpa_points AS weighted_points
                ,earnedcrhrs                   
          FROM KIPP_NJ..GRADES$STOREDGRADES#static WITH(NOLOCK)
          WHERE storecode = 'Y1'
            AND schoolid IN (73252, 73253, 133570965, 179902)
            AND excludefromgpa = 0
         ) sub
     GROUP BY studentid, schoolid
    ) sub