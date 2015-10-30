USE [KIPP_NJ]
GO

ALTER VIEW [dbo].[TABLEAU$KTC_alumni] AS 

--/*
WITH graduates AS (
  SELECT co.year AS academic_year        
        ,co.STUDENT_NUMBER
        ,co.lastfirst        
        ,sub.grade_level + (co.year - sub.cohort) AS grade_level        
        ,sub.cohort
        ,sub.schoolid        
        ,r.Id AS salesforce_id                
        ,u.id AS counselor_id
        ,u.Name AS counselor_name
        ,0 AS is_tf
  FROM
      (
       SELECT co.year AS academic_year
             ,co.student_number
             ,co.lastfirst
             ,co.grade_level
             ,co.cohort        
             ,co.schoolid                        
             ,ROW_NUMBER() OVER(
               PARTITION BY co.student_number
                 ORDER BY co.year DESC) AS rn
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       WHERE co.rn = 1
         AND co.exitcode = 'G1'       
         AND co.student_number NOT IN (2026,3049,3012)
      ) sub
  JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
    ON sub.student_number = co.student_number   
   AND co.schoolid = 999999
   AND co.rn = 1
  LEFT OUTER JOIN AlumniMirror.dbo.Contact r WITH(NOLOCK)
    ON co.student_number = r.School_Specific_ID__c  
  LEFT OUTER JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
    ON r.OwnerId = u.Id
  WHERE sub.rn = 1    
 )  

,team_and_fam AS (
  SELECT KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
        ,tf.student_number
        ,tf.lastfirst
        ,tf.approx_grade_level AS grade_level
        ,tf.cohort
        ,tf.schoolid         
        ,r.Id AS salesforce_id                
        ,u.id AS counselor_id
        ,u.Name AS counselor_name
        ,1 is_tf             
  FROM KIPP_NJ..KTC$team_and_family_roster tf WITH(NOLOCK)     
  LEFT OUTER JOIN AlumniMirror.dbo.Contact r WITH(NOLOCK)
    ON tf.student_number = r.School_Specific_ID__c  
  LEFT OUTER JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
    ON r.OwnerId = u.Id
  WHERE tf.student_number NOT IN (SELECT student_number FROM graduates)
 )
--*/

,combined_roster AS (
  --/* temp fix */
  --SELECT KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
  --      ,r.School_Specific_ID__c AS student_number
  --      ,r.Name AS lastfirst                
  --      ,r.Id AS salesforce_id                
  --      ,u.id AS counselor_id
  --      ,u.Name AS counselor_name    
  --FROM AlumniMirror.dbo.Contact r WITH(NOLOCK)  
  --LEFT OUTER JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
  --  ON r.OwnerId = u.Id  

  --/*
  SELECT *
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
             ORDER BY academic_year) AS rn
  FROM
      (
       SELECT *
       FROM graduates
       UNION ALL
       SELECT *
       FROM team_and_fam
      ) sub
  --*/
 )

,roster_scaffold AS (
  SELECT r.counselor_id
        ,r.counselor_name
        ,r.student_number
        ,r.salesforce_id
        ,r.lastfirst
        ,r.cohort        
        ,year.academic_year
        ,year.month
  FROM combined_roster r WITH(NOLOCK)
  JOIN (
        SELECT DISTINCT 
               KIPP_NJ.dbo.fn_DateToSy(date) AS academic_year
              ,month_part AS month
        FROM UTIL$reporting_days#static WITH(NOLOCK)
        WHERE KIPP_NJ.dbo.fn_DateToSy(date) = KIPP_NJ.dbo.fn_Global_Academic_Year()
          AND date <= CONVERT(DATE,GETDATE())
        --WHERE KIPP_NJ.dbo.fn_DateToSy(date) BETWEEN 2010 AND KIPP_NJ.dbo.fn_Global_Academic_Year()
        --  AND date <= CONVERT(DATE,GETDATE())
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