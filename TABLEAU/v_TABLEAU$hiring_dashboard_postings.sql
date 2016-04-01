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
      ,app.[Application_Review_Score__c]
      ,app.[Average_Teacher_Phone_Score__c]
      ,app.[Job_Posting__c]
      ,app.[Job_Position__c]
      ,app.[Job_Position_Name__c]
      ,app.[Stage__c]
      ,app.[Selection_Status__c]
      ,app.[Primary_Interest_Grade_Level_General__c]

      --,pos.id AS position_id
      --,pos.Position_Name__c
      --,pos.CreatedDate AS position_createddate      
      --,pos.Date_Position_Filled__c
      --,pos.Name AS position_name
      --,pos.School__c
      --,pos.Replacement_or_New_Position__c
      --,pos.Status__c
      --,pos.LastModifiedDate
FROM KIPP_NJ..AUTOLOAD$GDOCS_RECRUIT_jobpostingdrop post WITH(NOLOCK) 
LEFT OUTER JOIN KIPPCareersMirror..Job_Application__c app WITH(NOLOCK)
  ON post.job_posting_id = LEFT(app.Job_Posting__c, (LEN(app.Job_Posting__c) - 3)) 
--LEFT OUTER JOIN KIPPCareersMirror..Job_Position__c pos WITH(NOLOCK) 
--  ON LEFT(pos.Job_Posting__c, (LEN(pos.Job_Posting__c) - 3)) = post.job_posting_id