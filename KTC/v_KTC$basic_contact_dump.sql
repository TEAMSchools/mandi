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

,contact_note AS (
  SELECT *
  FROM
      (
       SELECT Contact__c AS contact_id
             ,Subject__c AS contact_subject
             ,CONVERT(DATE,Date__c) AS contact_date
       FROM AlumniMirror..Contact_Note__c WITH(NOLOCK)
       WHERE (Subject__c LIKE 'AAS_' OR Subject__c = 'PSC' OR Subject__c = 'REM')
      ) sub
  PIVOT(
    MAX(contact_date)
    FOR contact_subject IN ([AAS1]
                           ,[AAS2]
                           ,[AAS3]
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
  SELECT Student__c
        ,Date__c
        ,Status__c
        ,Amount__c
        ,ROW_NUMBER() OVER(
           PARTITION BY Student__c
             ORDER BY Date__c DESC) AS rn
  FROM AlumniMirror..KIPP_Aid__c WITH(NOLOCK)
  WHERE Type__c = 'College Book Stipend Program'
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
      ,cn.REM

      ,gpa.GPA_MP0
      ,gpa.GPA_MP1
      ,gpa.GPA_MP2
      ,gpa.GPA_MP3
      ,gpa.GPA_MP4
      ,COALESCE(gpa.GPA_MP4, gpa.GPA_MP3, gpa.GPA_MP2, gpa.GPA_MP1, gpa.GPA_MP0) AS GPA_recent

      ,s.Date__c AS stipend_date
      ,s.Status__c AS stipend_status
      ,s.Amount__c AS stipend_amount
FROM AlumniMirror..Contact c WITH(NOLOCK)
JOIN AlumniMirror..User2 u WITH(NOLOCK)
  ON c.OwnerId = u.Id
LEFT OUTER JOIN enrollment e
  ON c.id = e.Student__c 
 --AND c.Currently_Enrolled_School__c = e.account_name
 AND e.rn = 1 
LEFT OUTER JOIN contact_note cn
  ON c.Id = cn.contact_id
LEFT OUTER JOIN gpa
  ON e.enrollment_id = gpa.Enrollment__c
LEFT OUTER JOIN stipends s
  ON c.Id = s.Student__c
 AND s.rn = 1
--ORDER BY c.Currently_Enrolled_School__c