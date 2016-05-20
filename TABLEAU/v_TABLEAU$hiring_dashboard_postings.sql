USE KIPP_NJ
GO

ALTER VIEW TABLEAU$hiring_dashboard_postings AS

SELECT post.job_posting_job_posting_name
      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,post.job_posting_created_date)) AS academic_year
      ,CONVERT(DATE,post.job_posting_created_date) AS job_posting_created_date      
      ,post.primary_contact
      ,post.job_posting_id
      ,post.city
      ,post.job_type
      ,post.job_subtype
      ,post.grade_level
      ,post.job_posting_url

      ,app.[Name] AS app_name
      ,app.[Profile_Application__c]
      ,app.[Contact_Name__c]
      ,app.[CreatedDate] AS app_createddate
      ,app.LastActivityDate      
      ,app.[Application_Review_Score__c]
      ,app.[Average_Teacher_Phone_Score__c]
      ,app.[Job_Posting__c]
      ,app.[Job_Position__c]
      ,app.[Job_Position_Name__c]
      ,app.[Stage__c]
      ,app.[Selection_Status__c]
      ,app.[Primary_Interest_Grade_Level_General__c]     
      ,app.Applicant_Source__c
      ,app.Cultivation_Regional_Source__c

      ,con.Ethnicity__c      
      ,con.Gender__c

      ,con.Current_Employer__c
      ,con.Educational_Institution_Undergraduate__c
      ,con.Educational_Institution_Graduate__c
      ,con.Years_of_Teaching_Experience__c
      ,con.Years_in_FRPL_Schools__c
      ,con.Years_of_Leadership_Experience__c
      
      ,con.KIPP_Regions_of_Interest__c
      ,con.Regions_Applied_To__c
      ,con.Source__c
FROM KIPP_NJ..AUTOLOAD$GDOCS_RECRUIT_jobpostingdrop post WITH(NOLOCK) 
LEFT OUTER JOIN KIPPCareersMirror..Job_Application__c app WITH(NOLOCK)
  ON post.job_posting_id = LEFT(app.Job_Posting__c, (LEN(app.Job_Posting__c) - 3)) 
LEFT OUTER JOIN KIPPCareersMirror..Contact con WITH(NOLOCK)
  ON app.contact_id__c = LEFT(con.id, (LEN(con.id) - 3))