USE KIPP_NJ
GO

ALTER VIEW PEOPLE$onboarding_roster AS 

SELECT jp.Name AS job_position_name        
      ,jp.Position_Name__c AS salesforce_position_name              
      ,CASE          
        WHEN CHARINDEX('_',jp.Position_Name__c) = 0 THEN jp.Position_Name__c          
        ELSE SUBSTRING(jp.Position_Name__c
                      ,CHARINDEX('_',jp.Position_Name__c) + 1
                      ,CHARINDEX('_',jp.Position_Name__c,CHARINDEX('_',jp.Position_Name__c) + 1) - CHARINDEX('_',jp.Position_Name__c) - 1) 
        END AS salesforce_location               
       
       ,ja.Contact_Name__c AS salesforce_contact_name        
       ,CASE WHEN ja.Selection_Status__c = 'Complete' THEN 'Accepted' ELSE ja.Selection_Status__c END AS Selection_Status__c
       --,ja.Stage__c
       ,CONVERT(DATE,ja.Hired_Status_Date__c) AS Hired_Status_Date__c                

       ,adp.first_name AS adp_first_name        
       ,adp.last_name AS adp_last_name    
       ,adp.preferred_name        
       ,adp.job_title AS adp_job_title        
       ,adp.job_title_custom AS adp_job_title_custom        
       ,adp.position_start_date        
       ,adp.associate_id        
       ,adp.hire_date
       ,CASE 
         WHEN adp.associate_id IS NOT NULL THEN 'Y' 
         ELSE 'N' 
        END AS in_ADP          
       
       ,CONVERT(DATE,ad.createTimeStamp) AS ad_createdate
       ,ad.mail AS email_address        
       ,ad.sAMAccountName AS username        
       ,CASE
         WHEN ad.is_active IS NULL THEN 'New Hire'
         WHEN ad.is_active = 1 AND ad.createTimeStamp >= '2017-06-01' THEN 'New Hire'
         WHEN ad.is_active = 1 AND ad.createTimeStamp < '2017-06-01' THEN 'Returning Staff - Current'
         WHEN ad.is_active = 0 THEN 'Returning Staff - Departed'
        END AS ad_account_status
       ,CASE 
         WHEN ad.associate_id IS NOT NULL THEN 'Y' 
         ELSE 'N' 
        END AS in_ActiveDirectory       

       ,ad.userPrincipalName
       ,ad.displayName
       ,ad.givenName
       ,ad.sn
       ,ad.physicalDeliveryOfficeName
       ,ad.title
       ,ad.idautostatus
FROM KIPPCareersMirror..Job_Position__c jp WITH(NOLOCK)  
LEFT OUTER JOIN KIPPCareersMirror..Job_Application__c ja WITH(NOLOCK)    
  ON jp.Id = ja.Job_Position__c               
 AND ja.Selection_Status__c IN ('Complete','Withdrew')
 AND ja.Stage__c = 'Hired'              
LEFT OUTER JOIN KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)    
  ON jp.Name = adp.salesforce_job_position_name_custom  
 AND adp.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static ad WITH(NOLOCK)    
  ON adp.associate_id = ad.associate_id  
WHERE jp.Region__c = 'New Jersey'