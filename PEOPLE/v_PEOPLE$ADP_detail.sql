USE KIPP_NJ
GO
 
ALTER VIEW PEOPLE$ADP_detail AS

SELECT [associate_id]      
      ,[first_name]      
      ,[last_name]
      ,[preferred_name]
      ,[maiden_name]
      ,CONVERT(DATE,[birth_date]) AS date_of_birth            
      ,ethnicity_code      
      ,ethnicity
      ,LEFT([gender],1) AS gender
      ,[primary_address_city] AS city
      ,[primary_address_state__territory_code] AS state
      ,RIGHT('0' + [primary_address_zip__postal_code], 5) AS ZIP      
      ,[personal_contact_personal_mobile] AS phone_mobile      
      ,[education_level_code] AS edu_level_code
      ,[education_level_description] AS edu_level      
      ,CONVERT(DATE,hire_date) AS hire_date
      ,CONVERT(DATE,rehire_date) AS rehire_date      
      ,[subject_dept_custom] AS subject_taught
      ,[manager_secondary_custom] AS secondary_manager
      ,[grades_taught_custom] AS grade_taught

      ,[position_id]
      ,[salesforce_job_position_name_custom]
      ,[job_title_description] AS job_title
      ,[job_title_custom]
      ,[position_status]
      ,[location_code]
      ,[location_description] AS location      
      ,[Location_Custom]
      ,[home_department_code] AS department_code
      ,[home_department_description] AS department      
      ,[reports_to_position_id]
      ,[reports_to_name] AS reports_to      
      ,CONVERT(DATE,position_start_date) AS position_start_date      
      ,CONVERT(DATE,termination_date) AS termination_date                  
      ,[years_of_service]            
      ,[termination_reason_code] AS termination_code
      ,[termination_reason_description] AS termination_reason      
      ,[spunoffmerged_employee]
      ,CONVERT(DATE,[spinoffmerge_date]) AS merged_on
      ,[worker_category_code]
      ,[worker_category_description]
      ,[benefits_eligibility_class_description] AS benefits_elig_class
      ,[payroll_company_code] AS payroll_company_code
      ,[flsa_code]
      ,[flsa_description] AS FLSA_status
      ,[this_is_a_management_position]      
      ,manager_custom_associd

      ,CASE 
        WHEN this_is_a_management_position = 'Yes' THEN 1
        WHEN this_is_a_management_position = 'No' THEN 0
       END AS is_management
      ,CASE 
        WHEN spunoffmerged_employee = 'Yes' THEN 1 
        WHEN spunoffmerged_employee = 'No' THEN 0
       END AS is_merged      
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) = 0 THEN SUBSTRING(preferred_name, 1, LEN(preferred_name))
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) > 0 THEN SUBSTRING(preferred_name, 1, CHARINDEX(' ',preferred_name))
                      WHEN CHARINDEX(',',preferred_name) > 0 THEN SUBSTRING(preferred_name, CHARINDEX(',',preferred_name) + 1, LEN(preferred_name))
                     END)) 
        ,first_name) AS preferred_first
      ,COALESCE(
         LTRIM(RTRIM(CASE
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) = 0 THEN NULL
                      WHEN CHARINDEX(',',preferred_name) = 0 AND CHARINDEX(' ',preferred_name) > 0 THEN SUBSTRING(preferred_name, CHARINDEX(' ',preferred_name) + 1, LEN(preferred_name))
                      WHEN CHARINDEX(',',preferred_name) > 0 THEN SUBSTRING(preferred_name, 1, CHARINDEX(',',preferred_name) - 1)
                     END))
        ,last_name) AS preferred_last
      ,ROW_NUMBER() OVER(
         PARTITION BY associate_id
           ORDER BY position_status ASC
                   ,CONVERT(DATE,position_start_date) DESC
                   ,CONVERT(DATE,termination_date) DESC) AS rn_curr
      ,ROW_NUMBER() OVER(
         PARTITION BY associate_id
           ORDER BY position_status DESC
                   ,CONVERT(DATE,position_start_date) ASC
                   ,CONVERT(DATE,termination_date) ASC) AS rn_base
FROM [KIPP_NJ].[dbo].[AUTOLOAD$ADP_Export_People_Details] WITH(NOLOCK)