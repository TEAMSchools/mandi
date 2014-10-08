USE KIPP_NJ
GO

ALTER VIEW TABLEAU$KTC_alumni AS 

WITH max_grade AS (
  SELECT co.year AS academic_year
        ,co.studentid
        ,co.lastfirst
        ,co.grade_level
        ,co.cohort
        ,co.schoolid        
        ,ROW_NUMBER() OVER(
           PARTITION BY co.studentid
             ORDER BY co.year DESC) AS rn
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE co.schoolid != 999999         
    AND co.rn = 1
 )

,roster AS (
  SELECT co.year AS academic_year
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,max_grade.grade_level + (dbo.fn_Global_Academic_Year() - co.year) AS grade_level
        ,max_grade.cohort
        ,max_grade.schoolid        
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN max_grade WITH(NOLOCK)
    ON co.studentid = max_grade.studentid
   AND co.year >= max_grade.cohort
   AND max_grade.rn = 1
  WHERE co.rn = 1
    AND co.schoolid = 999999
)

,alumni_roster AS (
  SELECT contact_id AS salesforce_id
        ,sis_id AS student_number        
        ,cohort
        ,composite_status
        ,User2.id AS counselor_id
        ,ktc_contact AS counselor_name
        ,last_advisor_activity
        ,last_successful_contact
        ,school_name
        ,school_type
        ,school_id      
  FROM [AlumniMirror].[dbo].[vwRoster_Basic] r WITH(NOLOCK)
  LEFT OUTER JOIN AlumniMirror.dbo.User2 WITH(NOLOCK)
    ON r.ktc_contact = user2.name
 )

,combined_roster AS (
  SELECT r.academic_year
        ,r.STUDENT_NUMBER
        ,r.lastfirst
        ,r.grade_level
        ,r.cohort
        ,alum.salesforce_id
        ,alum.composite_status        
        ,alum.counselor_id
        ,ISNULL(alum.counselor_name,'Unassigned') AS counselor_name
        ,alum.last_advisor_activity
        ,alum.last_successful_contact
        ,alum.school_name
        ,alum.school_type
        ,alum.school_id
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN alumni_roster alum WITH(NOLOCK)
    ON r.STUDENT_NUMBER = alum.student_number  
 )

,counselors AS (
  SELECT DISTINCT 
         r.counselor_id
        ,r.counselor_name
        ,year.year_part AS academic_year
  FROM combined_roster r WITH(NOLOCK)
  JOIN (
        SELECT DISTINCT year_part
        FROM UTIL$reporting_days WITH(NOLOCK)
        WHERE year_part >= 2010
          AND year_part <= dbo.fn_Global_Academic_Year()
       ) year
    ON 1 = 1
 )

,advisor_scaffold AS (
  SELECT c.*
        ,gen.n AS month
  FROM counselors c WITH(NOLOCK)  
  JOIN UTIL$row_generator gen WITH(NOLOCK)
    ON gen.n BETWEEN 1 AND 12
 )

,supported AS (
  SELECT academic_year
        ,counselor_id
        --,counselor_name        
        ,cohort
        ,COUNT(*) AS n_supported
        ,CONVERT(FLOAT,ROUND(AVG(is_persisting) * 100,0)) AS pct_persisting
  FROM 
      (
       SELECT *
             ,CASE 
               WHEN r.school_type = 'High School' THEN NULL
               WHEN r.composite_status IN ('College Persisting', 'College Grad - BA') THEN 1.0 
               ELSE 0.0
              END AS is_persisting           
       FROM combined_roster r WITH(NOLOCK)     
      ) sub
  GROUP BY academic_year, counselor_id, cohort
 )

,contact_long AS (
  SELECT Contact__c AS salesforce_id
        ,LastModifiedById AS counselor_id
        ,KIPP_NJ.dbo.fn_DateToSY(COALESCE(date__c, lastmodifieddate)) AS academic_year        
        ,DATEPART(MONTH,COALESCE(date__c, lastmodifieddate)) AS month           
        ,comments__c
        ,status__c
        ,Subject__c
        ,Type__c
        ,Category__c
        ,CASE WHEN Type__c = 'School Visit' THEN 1.0 ELSE 0.0 END AS is_school_visit
  FROM [AlumniMirror].[dbo].[Contact_Note__c] WITH(NOLOCK)
  WHERE isdeleted = 0
 )

,pct_contacted AS (
  --SELECT counselor_id
  --      --,counselor_name
  --      ,academic_year
  --      ,cohort
  --      ,[7] AS pct_contacted_Jul
  --      ,[8] AS pct_contacted_Aug
  --      ,[9] AS pct_contacted_Sep
  --      ,[10] AS pct_contacted_Oct
  --      ,[11] AS pct_contacted_Nov
  --      ,[12] AS pct_contacted_Dec
  --      ,[1] AS pct_contacted_Jan
  --      ,[2] AS pct_contacted_Feb
  --      ,[3] AS pct_contacted_Mar
  --      ,[4] AS pct_contacted_Apr
  --      ,[5] AS pct_contacted_May
  --      ,[6] AS pct_contacted_Jun
  --FROM
  --    (
       SELECT counselor_id
             ,counselor_name
             ,academic_year
             ,cohort
             ,month
             ,CONVERT(FLOAT,ROUND(AVG(is_contacted) * 100,0)) AS pct_contacted
       FROM
           (
            SELECT counselor_id
                  ,counselor_name
                  ,academic_year
                  ,month
                  ,cohort
                  ,salesforce_id
                  ,MAX(is_contacted) AS is_contacted
            FROM
                (
                 SELECT scaff.counselor_id
                       ,scaff.counselor_name      
                       ,scaff.month
                       ,scaff.academic_year
                       ,r.cohort
                       ,r.salesforce_id      
                       ,CASE WHEN con.salesforce_id IS NOT NULL THEN 1.0 ELSE 0.0 END AS is_contacted
                 FROM advisor_scaffold scaff WITH(NOLOCK)
                 LEFT OUTER JOIN combined_roster r WITH(NOLOCK)
                   ON scaff.counselor_id = r.counselor_id
                 LEFT OUTER JOIN contact_long con WITH(NOLOCK)
                   ON scaff.counselor_id = con.counselor_id
                  AND r.salesforce_id = con.salesforce_id
                  AND scaff.academic_year = con.academic_year
                  AND scaff.month = con.month
                ) sub
            GROUP BY counselor_id
                    ,counselor_name
                    ,academic_year
                    ,cohort
                    ,month
                    ,salesforce_id
           ) sub
       GROUP BY counselor_id
               ,counselor_name
               ,academic_year
               ,month
               ,cohort
  --    ) sub

  --PIVOT(
  --  MAX(pct_contacted)
  --  FOR month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
  -- ) p
 )

,visited AS (
  SELECT counselor_id
        --,counselor_name
        ,academic_year
        ,cohort
        ,CONVERT(FLOAT,ROUND(AVG(is_visited) * 100,0)) AS pct_visited
  FROM
      (
       SELECT counselor_id
             ,counselor_name
             ,academic_year      
             ,cohort
             ,salesforce_id
             ,MAX(is_school_visit) AS is_visited
       FROM
           (
            SELECT DISTINCT
                   scaff.counselor_id
                  ,scaff.counselor_name                 
                  ,scaff.academic_year
                  ,r.cohort
                  ,r.salesforce_id      
                  ,ISNULL(con.is_school_visit, 0.0) AS is_school_visit
            FROM advisor_scaffold scaff WITH(NOLOCK)
            LEFT OUTER JOIN combined_roster r WITH(NOLOCK)
              ON scaff.counselor_id = r.counselor_id
            LEFT OUTER JOIN contact_long con WITH(NOLOCK)
              ON scaff.counselor_id = con.counselor_id
             AND r.salesforce_id = con.salesforce_id
             AND scaff.academic_year = con.academic_year     
           ) sub
       GROUP BY counselor_id
               ,counselor_name
               ,academic_year
               ,cohort        
               ,salesforce_id
      ) sub
  GROUP BY counselor_id
          ,counselor_name
          ,academic_year
          ,cohort      
 )

SELECT c.counselor_id
      ,c.counselor_name
      ,c.academic_year
      ,sup.cohort
      ,sup.n_supported
      ,sup.pct_persisting
      ,v.pct_visited
      ,con.month
      ,con.pct_contacted
      --,con.pct_contacted_Jul
      --,con.pct_contacted_Aug
      --,con.pct_contacted_Sep
      --,con.pct_contacted_Oct
      --,con.pct_contacted_Nov
      --,con.pct_contacted_Dec
      --,con.pct_contacted_Jan
      --,con.pct_contacted_Feb
      --,con.pct_contacted_Mar
      --,con.pct_contacted_Apr
      --,con.pct_contacted_May
      --,con.pct_contacted_Jun
FROM counselors c WITH(NOLOCK)
JOIN supported sup WITH(NOLOCK)
  ON (c.counselor_id = sup.counselor_id OR (c.counselor_id IS NULL AND sup.counselor_id IS NULL))
 AND c.academic_year = sup.academic_year
LEFT OUTER JOIN visited v WITH(NOLOCK)
  ON c.counselor_id = v.counselor_id
 AND c.academic_year = v.academic_year
 AND sup.cohort = v.cohort
LEFT OUTER JOIN pct_contacted con WITH(NOLOCK)
  ON c.counselor_id = con.counselor_id
 AND c.academic_year = con.academic_year
 AND sup.cohort = con.cohort