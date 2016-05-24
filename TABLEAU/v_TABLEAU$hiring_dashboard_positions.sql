USE KIPP_NJ
GO

ALTER VIEW TABLEAU$hiring_dashboard_positions AS

WITH goals AS (
  SELECT academic_year
        ,quarter AS term
        ,CONVERT(DATE,start_date) AS start_date
        ,CONVERT(DATE,ends_on) AS end_date
        --,type     
        ,multiplier
  FROM KIPP_NJ..AUTOLOAD$GDOCS_RECRUIT_jobpostinggoals WITH(NOLOCK)
  WHERE type != 'Actual'
 )

SELECT pos.id AS position_id
      ,pos.Position_Name__c
      ,pos.CreatedDate AS position_createddate
      ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,pos.CreatedDate)) AS academic_year
      ,pos.Date_Position_Filled__c
      ,pos.Name AS position_name
      ,pos.School__c
      ,pos.Replacement_or_New_Position__c
      ,pos.Status__c
      ,pos.LastModifiedDate
      
      ,post.name AS job_posting_job_posting_name
      ,CONVERT(DATE,post.createddate) AS job_posting_created_date
      
      ,post.primary_contact__c AS primary_contact
      ,post.id AS job_posting_id
      ,post.city__c AS city
      ,post.job_type__c AS job_type
      ,post.job_sub_type__c AS job_subtype
      ,post.grade_level__c AS grade_level
      ,post.job_posting_url__c AS job_posting_url

      ,app.[Name] AS app_name
      ,app.[Profile_Application__c]
      ,app.[Contact_Name__c]
      ,app.[CreatedDate] AS app_createddate
      ,app.[Application_Review_Score__c]
      ,app.[Average_Teacher_Phone_Score__c]
      ,app.[Job_Posting__c]
      ,app.[Job_Position__c]
      ,app.[Stage__c]
      ,app.[Selection_Status__c]
      ,app.[Primary_Interest_Grade_Level_General__c]
      
      ,goals.term
      ,goals.multiplier
      ,goals.start_date
      ,goals.end_date
FROM KIPPCareersMirror..Job_Position__c pos WITH(NOLOCK) 
LEFT OUTER JOIN KIPPCareersMirror..Job_Application__c app WITH(NOLOCK)
  ON pos.Id = app.Job_Position__c
LEFT OUTER JOIN KIPPCareersMirror..Job_Posting__c post WITH(NOLOCK)
  ON pos.Job_Posting__c = post.id
LEFT OUTER JOIN goals
  ON pos.CreatedDate BETWEEN goals.start_date AND goals.end_date
WHERE pos.Region__c = 'New Jersey'