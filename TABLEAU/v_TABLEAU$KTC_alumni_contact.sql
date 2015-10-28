USE KIPP_NJ
GO

ALTER VIEW TABLEAU$KTC_alumni AS 

WITH max_grade AS (
  SELECT co.year AS academic_year
        ,co.student_number
        ,co.lastfirst
        ,co.grade_level
        ,co.cohort
        ,co.schoolid        
        ,ROW_NUMBER() OVER(
           PARTITION BY co.studentid
             ORDER BY co.year DESC) AS rn
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.student_number NOT IN (2026,3049,3012)
    AND co.rn = 1
 )

,combined_roster AS (
  SELECT co.year AS academic_year
        ,co.STUDENT_NUMBER
        ,co.lastfirst        
        ,max_grade.grade_level + (co.year - max_grade.cohort) AS grade_level        
        ,max_grade.cohort
        ,max_grade.schoolid        
        ,r.Id AS salesforce_id                
        ,u.id AS counselor_id
        ,u.Name AS counselor_name
  FROM max_grade WITH(NOLOCK)
  JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
    ON max_grade.student_number = co.student_number   
   AND co.rn = 1
  LEFT OUTER JOIN AlumniMirror.dbo.Contact r WITH(NOLOCK)
    ON co.student_number = r.School_Specific_ID__c  
  LEFT OUTER JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
    ON r.OwnerId = u.Id
  WHERE max_grade.rn = 1    
 )

,roster_scaffold AS (
  SELECT DISTINCT 
         r.counselor_id
        ,r.counselor_name
        ,r.salesforce_id
        ,r.lastfirst
        ,year.year_part AS academic_year
        ,gen.n AS month
  FROM combined_roster r WITH(NOLOCK)
  CROSS JOIN (
              SELECT DISTINCT year_part
              FROM UTIL$reporting_days#static WITH(NOLOCK)
              WHERE year_part >= 2010
                AND year_part <= dbo.fn_Global_Academic_Year()
             ) year    
  JOIN UTIL$row_generator gen WITH(NOLOCK)
    ON gen.n BETWEEN 1 AND 12  
  WHERE r.counselor_id IS NOT NULL
    AND r.salesforce_id IS NOT NULL
 )

,contact_long AS (
  SELECT Contact__c AS salesforce_id        
        ,LastModifiedById AS counselor_id        
        ,KIPP_NJ.dbo.fn_DateToSY(COALESCE(date__c, lastmodifieddate)) AS academic_year        
        ,DATEPART(MONTH,COALESCE(date__c, lastmodifieddate)) AS month                   
        ,COALESCE(date__c, lastmodifieddate) AS contact_date
        ,status__c        
        ,Type__c
        ,Category__c        
        ,Subject__c
        ,Comments__c
        --,id AS contact_record_id
        --,CASE WHEN Type__c = 'School Visit' THEN 1.0 ELSE 0.0 END AS is_school_visit
  FROM [AlumniMirror].[dbo].[Contact_Note__c] WITH(NOLOCK)
  WHERE isdeleted = 0
 )

SELECT scaff.academic_year
      ,scaff.month
      ,scaff.counselor_id
      ,scaff.counselor_name      
      ,r.student_number
      ,r.lastfirst      
      ,r.cohort
      ,r.schoolid
      ,r.salesforce_id      
      ,con.salesforce_id AS contact_student_id      
      ,con.contact_date
      ,con.Status__c
      ,con.Type__c
      ,con.Category__c
      ,con.Subject__c
      ,con.Comments__c      
      ,ROW_NUMBER() OVER(
         PARTITION BY r.student_number, r.academic_year, scaff.month
           ORDER BY con.Status__c DESC) AS rn_month
FROM roster_scaffold scaff WITH(NOLOCK)
LEFT OUTER JOIN combined_roster r WITH(NOLOCK)
  ON scaff.counselor_id = r.counselor_id
 AND scaff.salesforce_id = r.salesforce_id
 AND scaff.academic_year = r.academic_year
LEFT OUTER JOIN contact_long con WITH(NOLOCK)
  ON scaff.counselor_id = con.counselor_id
 AND scaff.salesforce_id = con.salesforce_id
 AND scaff.academic_year = con.academic_year
 AND scaff.month = con.month