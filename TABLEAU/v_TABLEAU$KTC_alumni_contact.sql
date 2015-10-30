USE [KIPP_NJ]
GO

ALTER VIEW [dbo].[TABLEAU$KTC_alumni] AS 

WITH roster_scaffold AS (
  SELECT r.counselor_id
        ,r.counselor_name
        ,r.student_number
        ,r.salesforce_id
        ,r.lastfirst
        ,r.cohort        
        ,year.academic_year
        ,year.month
  FROM KIPP_NJ..KTC$combined_roster_long r WITH(NOLOCK)
  JOIN (
        SELECT DISTINCT 
               KIPP_NJ.dbo.fn_DateToSy(date) AS academic_year
              ,month_part AS month
        FROM UTIL$reporting_days#static WITH(NOLOCK)
        WHERE KIPP_NJ.dbo.fn_DateToSy(date) = KIPP_NJ.dbo.fn_Global_Academic_Year()
          AND date <= CONVERT(DATE,GETDATE())        
       ) year    
    ON r.academic_year = year.academic_year  
 )

,contact_long AS (
  SELECT Contact__c AS salesforce_id        
        ,CreatedById AS counselor_id        
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,COALESCE(date__c, lastmodifieddate))) AS academic_year        
        ,DATEPART(MONTH,CONVERT(DATE,COALESCE(date__c, lastmodifieddate))) AS month                   
        ,CONVERT(DATE,COALESCE(date__c, lastmodifieddate)) AS contact_date
        ,status__c        
        ,Type__c
        ,Category__c        
        ,Subject__c
        ,Comments__c        
  FROM [AlumniMirror].[dbo].[Contact_Note__c] WITH(NOLOCK)
  WHERE isdeleted = 0
 )

SELECT scaff.academic_year
      ,scaff.month
      ,scaff.counselor_id
      ,scaff.counselor_name      
      ,scaff.student_number
      ,scaff.lastfirst      
      ,scaff.cohort
      ,NULL AS schoolid
      ,scaff.salesforce_id      
      ,con.salesforce_id AS contact_student_id      
      ,con.contact_date
      ,con.Status__c
      ,con.Type__c
      ,con.Category__c
      ,con.Subject__c
      ,con.Comments__c      
      ,ROW_NUMBER() OVER(
         PARTITION BY scaff.student_number, scaff.academic_year, scaff.month
           ORDER BY con.Status__c DESC) AS rn_month /* Successful > Outreach */
FROM roster_scaffold scaff WITH(NOLOCK)
LEFT OUTER JOIN contact_long con WITH(NOLOCK)
  ON scaff.counselor_id = con.counselor_id
 AND scaff.salesforce_id = con.salesforce_id
 AND scaff.academic_year = con.academic_year
 AND scaff.month = con.month
GO