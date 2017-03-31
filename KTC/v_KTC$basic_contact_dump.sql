USE KIPP_NJ
GO

ALTER VIEW KTC$basic_contact_dump AS

WITH enrollment AS (
  SELECT e.Id AS enrollment_id
        ,e.Student__c
        ,e.School__c
        ,e.Status__c
        ,e.Start_Date__c
        ,e.Actual_End_Date__c
        ,e.Major__c              
        ,e.Pursuing_Degree_Type__c        

        ,a.NCESid__c
        ,a.Name AS account_name
        ,a.Type AS account_type    

        ,ROW_NUMBER() OVER(
           PARTITION BY e.Student__c
             ORDER BY e.Start_Date__c DESC) AS rn  
  FROM AlumniMirror..Enrollment__c e WITH(NOLOCK)
  LEFT OUTER JOIN AlumniMirror..Account a WITH(NOLOCK)
    ON e.School__c = a.Id
  WHERE e.Status__c IN ('Attending')
 )

,checkins AS (
  SELECT contact_id
        ,term
        ,AAS1
        ,AAS2
        ,AAS3
        ,AAS4
        ,PSC
        ,REM
  FROM
      (
       SELECT c.Contact__c AS contact_id
             ,c.Subject__c AS contact_subject
             ,CONVERT(DATE,c.Date__c) AS contact_date
             ,dts.alt_name AS term
       FROM AlumniMirror..Contact_Note__c c WITH(NOLOCK)
       JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
         ON c.Date__c BETWEEN dts.start_date AND dts.end_date
        AND dts.identifier = 'KTC'
       WHERE (c.Subject__c LIKE 'AAS_' OR c.Subject__c = 'PSC' OR c.Subject__c = 'REM')
      ) sub
  PIVOT(
    MAX(contact_date)
    FOR contact_subject IN ([AAS1]
                           ,[AAS2]
                           ,[AAS3]
                           ,[AAS4]
                           ,[PSC]
                           ,[REM])
   ) p
 )

,gpa AS (
  SELECT Enrollment__c
        ,School_Year__c
        ,[0] AS GPA_MP0
        ,[1] AS GPA_MP1
        ,[2] AS GPA_MP2
        ,[3] AS GPA_MP3
        ,[4] AS GPA_MP4
  FROM
      (
       SELECT Enrollment__c
             ,School_Year__c
             ,Number__c
             ,GPA__c
       FROM AlumniMirror..Marking_Period__c WITH(NOLOCK)     
      ) sub
  PIVOT(
    MAX(GPA__c)
    FOR Number__c IN ([0],[1],[2],[3],[4])
   ) p
  WHERE School_Year__c = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,stipends AS (
  SELECT a.Student__c
        ,a.Date__c
        ,a.Status__c
        ,a.Amount__c
        ,dts.alt_name AS term
        ,ROW_NUMBER() OVER(
           PARTITION BY a.Student__c, dts.alt_name
             ORDER BY a.Date__c DESC) AS rn
  FROM AlumniMirror..KIPP_Aid__c a WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
    ON a.Date__c BETWEEN dts.start_date AND dts.end_date
   AND dts.identifier = 'KTC'
  WHERE Type__c = 'College Book Stipend Program'
 )

,oot_roster AS (
  SELECT *
        ,KIPP_NJ.dbo.fn_DateToSY(missing_start_date) AS missing_academic_year
        ,KIPP_NJ.dbo.fn_DateToSY(found_date) AS found_academic_year
  FROM
      (
       SELECT Contact__c AS contact_id
             ,Date__c AS last_successful_contact_date
             ,DATEADD(MONTH, 12, Date__c) AS missing_start_date
             ,COALESCE(LEAD(Date__c, 1) OVER(PARTITION BY Contact__c ORDER BY Date__c ASC), GETDATE()) AS found_date
             ,CASE WHEN LEAD(Date__c, 1) OVER(PARTITION BY Contact__c ORDER BY Date__c ASC) IS NULL THEN 1 END AS is_still_missing
             ,DATEDIFF(MONTH
                      ,Date__c
                      ,COALESCE(LEAD(Date__c, 1) OVER(PARTITION BY Contact__c ORDER BY Date__c), GETDATE())) AS n_months_elapsed
       FROM AlumniMirror..Contact_Note__c c WITH(NOLOCK)
       WHERE Status__c = 'Successful'
      ) sub
  WHERE n_months_elapsed >= 12
 ) 

SELECT c.id AS contact_id
      ,c.School_Specific_ID__c AS student_number
      ,c.Full_Name__c
      ,c.FirstName
      ,c.LastName      
      ,c.KIPP_HS_Class__c
      ,(KIPP_NJ.dbo.fn_Global_Academic_Year() + 1) - c.KIPP_HS_Class__c AS years_out_of_HS
      ,c.Currently_Enrolled_School__c
      ,c.KIPP_MS_Graduate__c
      ,c.Middle_School_Attended__c
      ,c.KIPP_HS_Graduate__c
      ,c.High_School_Graduated_From__c
      ,c.College_Graduated_From__c
      ,c.Post_HS_Simple_Admin__c
      ,c.Gender__c
      ,c.Ethnicity__c
      ,c.Last_Outreach__c
      ,c.Last_Successful_Contact__c
      ,c.Actual_College_Graduation_Date__c
      ,c.Cumulative_GPA__c
      ,c.College_Credits_Attempted__c
      ,c.Accumulated_Credits_College__c      
      ,c.Actual_HS_Graduation_Date__c
      ,c.Transcript_Release__c
      ,c.Latest_FAFSA_Date__c
      ,c.Latest_Resume__c
      
      ,CASE 
        WHEN c.Post_HS_Simple_Admin__c IN ('College Grad - BA') THEN 0 /* exclude grads */
        WHEN oot.contact_id IS NOT NULL THEN 1
        ELSE 0 
       END AS is_oot_baseline
      ,CASE 
        WHEN c.Post_HS_Simple_Admin__c IN ('College Grad - BA') THEN 0 /* exclude grads */
        WHEN oot.is_still_missing = 1 THEN 1
        ELSE 0 
       END AS is_out_of_touch      
      ,CASE WHEN oot.found_date BETWEEN dts.start_date AND dts.end_date THEN 1 ELSE 0 END AS is_found_this_term
      
      ,dts.alt_name AS term
      
      ,u.Name AS ktc_manager

      ,e.Major__c
      ,e.Pursuing_Degree_Type__c
      ,e.Start_Date__c
      ,e.Status__c AS enrollment_status
      ,e.account_name
      ,e.account_type  
      ,e.NCESid__c

      ,cn.PSC
      ,cn.AAS1
      ,cn.AAS2
      ,cn.AAS3      
      ,cn.AAS4
      ,cn.REM

      ,gpa.GPA_MP0
      ,gpa.GPA_MP1
      ,gpa.GPA_MP2      
      ,CASE
        WHEN dts.alt_name IN ('Q1','Q2') THEN gpa.GPA_MP2
        WHEN dts.alt_name IN ('Q3','Q4') THEN gpa.GPA_MP1
       END AS GPA_recent

      ,s.Date__c AS stipend_date
      ,s.Status__c AS stipend_status
      ,s.Amount__c AS stipend_amount

      ,oot.n_months_elapsed
FROM AlumniMirror..Contact c WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
  ON dts.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 AND dts.identifier = 'KTC'
JOIN AlumniMirror..User2 u WITH(NOLOCK)
  ON c.OwnerId = u.Id
LEFT OUTER JOIN enrollment e
  ON c.id = e.Student__c 
 AND e.rn = 1 
LEFT OUTER JOIN checkins cn
  ON c.Id = cn.contact_id
 AND dts.alt_name = cn.term
LEFT OUTER JOIN gpa
  ON e.enrollment_id = gpa.Enrollment__c
LEFT OUTER JOIN stipends s
  ON c.Id = s.Student__c
 AND dts.alt_name = s.term
 AND s.rn = 1
LEFT OUTER JOIN oot_roster oot
  ON c.Id = oot.contact_id
 AND KIPP_NJ.dbo.fn_Global_Academic_Year() BETWEEN oot.missing_academic_year AND oot.found_academic_year