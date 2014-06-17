USE KIPP_NJ
GO

ALTER VIEW REPORTING$promo_status#NCA AS

WITH cum_credits AS (
  SELECT studentid
        ,earned_credits_cum
  FROM GPA$cumulative WITH(NOLOCK)
  WHERE schoolid = 73253
 )
 
,proj_credits AS (  
  SELECT studentid
        ,SUM(credit_hours) AS proj_credits
        ,dbo.GROUP_CONCAT_D(course_name + ': ' + CONVERT(VARCHAR,y1) + '% [' + CONVERT(VARCHAR,credit_hours) + ']', '; ') AS audit_string
  FROM
      (
       SELECT studentid
             ,credit_hours
             ,course_name
             ,y1             
       FROM GRADES$DETAIL#NCA WITH(NOLOCK)
       WHERE Promo_Test = 0  
      
       UNION ALL
       
       SELECT studentid
             ,0 AS credit_hours
             ,course_name
             ,y1             
       FROM GRADES$DETAIL#NCA WITH(NOLOCK)
       WHERE Promo_Test = 1  
      ) sub
  GROUP BY studentid
 )
 
SELECT STUDENT_NUMBER
      ,LASTFIRST
      ,GRADE_LEVEL
      ,ADVISOR
      ,SPEDLEP
      ,earned_credits_cum
      ,proj_credits
      ,eoy_proj_credits
      ,proj_gr
      ,CASE 
        WHEN proj_gr - GRADE_LEVEL > 0 THEN 'Promoted' 
        WHEN proj_gr - GRADE_LEVEL = 0 THEN 'Retained' 
        WHEN proj_gr - GRADE_LEVEL < 0 THEN 'Demoted'
       END AS promo_status
      ,audit_string
FROM
    (
     SELECT s.STUDENT_NUMBER
           ,s.LASTFIRST
           ,s.GRADE_LEVEL
           ,cs.ADVISOR
           ,cs.SPEDLEP
           ,cum.earned_credits_cum
           ,proj.proj_credits
           ,ISNULL(cum.earned_credits_cum,0) + proj.proj_credits AS eoy_proj_credits
           ,CASE
             WHEN ISNULL(cum.earned_credits_cum,0) + proj.proj_credits >= 120 THEN 99
             WHEN ISNULL(cum.earned_credits_cum,0) + proj.proj_credits >= 85 THEN 12
             WHEN ISNULL(cum.earned_credits_cum,0) + proj.proj_credits >= 50 THEN 11
             WHEN ISNULL(cum.earned_credits_cum,0) + proj.proj_credits >= 25 THEN 10
             WHEN ISNULL(cum.earned_credits_cum,0) + proj.proj_credits < 25 THEN 9
            END AS proj_gr
           ,proj.audit_string
     FROM STUDENTS s WITH(NOLOCK)
     LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
       ON s.ID = cs.STUDENTID
     LEFT OUTER JOIN cum_credits cum WITH(NOLOCK)
       ON s.ID = cum.studentid  
     LEFT OUTER JOIN proj_credits proj WITH(NOLOCK)
       ON s.ID = proj.studentid  
     WHERE s.ENROLL_STATUS = 0
       AND s.SCHOOLID = 73253     
    ) sub2