USE KIPP_NJ
GO

ALTER VIEW TABLEAU$hiring_dashboard_progress AS

SELECT Position_Name__c
      ,KIPP_NJ.dbo.fn_DateToSY(CreatedDate) AS academic_year
      ,CreatedDate AS position_createddate
      ,Date_Position_Filled__c
      ,CreatedDate AS timeline_date
      ,Name AS position_name
      ,School__c
      ,Replacement_or_New_Position__c
      ,CASE WHEN Status__c = 'Filled' THEN 'Open' ELSE Status__c END AS Status__c
      ,LastModifiedDate
FROM KIPPCAREERSMIRROR..JOB_POSITION__C WITH(NOLOCK)
WHERE Region__c = 'New Jersey'

UNION ALL

SELECT Position_Name__c
      ,KIPP_NJ.dbo.fn_DateToSY(CreatedDate) AS academic_year
      ,CreatedDate AS position_createddate
      ,Date_Position_Filled__c
      ,Date_Position_Filled__c AS timeline_date
      ,Name AS position_name
      ,School__c
      ,Replacement_or_New_Position__c
      ,Status__c
      ,LastModifiedDate
FROM KIPPCAREERSMIRROR..JOB_POSITION__C WITH(NOLOCK)
WHERE Region__c = 'New Jersey'
  AND Status__c = 'Filled'