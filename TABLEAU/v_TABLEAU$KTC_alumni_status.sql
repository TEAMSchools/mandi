USE [KIPP_NJ]
GO

ALTER VIEW TABLEAU$KTC_alumni_status AS

WITH sf_students AS (
  SELECT s.Id AS student_sf_id        
        ,s.School_Specific_ID__c AS student_number
        ,s.Name AS student_name
        ,u.Name AS counselor_name
  FROM AlumniMirror.dbo.Contact s WITH(NOLOCK)  
  JOIN AlumniMirror.dbo.User2 u WITH(NOLOCK)
    ON s.OwnerId = u.Id
 )

,enrollments AS (
  SELECT Student__c
        ,Name      
        ,Status__c
        ,Pursuing_Degree_Type__c
        ,CASE
          WHEN Pursuing_Degree_Type__c = 'Bachelor''s (4-year)' THEN 4
          WHEN Pursuing_Degree_Type__c = 'Associate''s (2 year)' THEN 2
         END AS degree_length
        ,Start_Date__c
        ,DATEDIFF(YEAR,Start_Date__c,GETDATE()) + 1 AS yrs_enrolled
        ,Actual_End_Date__c      
        ,Anticipated_Graduation__c
        ,Date_Last_Verified__c
        ,Type__c
        ,ROW_NUMBER() OVER(
           PARTITION BY student__c
             ORDER BY start_date__c DESC) AS rn
  FROM [AlumniMirror].[dbo].[Enrollment__c] WITH(NOLOCK)  
 )

SELECT sub.student_number
      ,sub.lastfirst      
      ,sub.cohort
      ,sf.counselor_name 
      ,enr.Status__c
      ,enr.Pursuing_Degree_Type__c
      ,enr.degree_length
      ,enr.Type__c
      ,enr.Start_Date__c
      ,enr.Actual_End_Date__c      
      ,CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(),'-08-01')) AS curr_academic_year_start
FROM
    (
     SELECT co.student_number           
           ,co.lastfirst
           ,co.cohort
           ,ROW_NUMBER() OVER(
              PARTITION BY co.student_number
                ORDER BY co.exitdate DESC) AS rn
     FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
     WHERE co.rn = 1
       AND co.exitcode = 'G1'       
       AND co.student_number NOT IN (2026,3049,3012)
    ) sub
LEFT OUTER JOIN sf_students sf
  ON sub.student_number = sf.student_number
LEFT OUTER JOIN enrollments enr
  ON sf.student_sf_id = enr.Student__c
 AND enr.rn = 1
WHERE sub.rn = 1