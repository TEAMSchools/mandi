USE KIPP_NJ
GO

ALTER PROCEDURE sp_PEOPLE$ADP_detail#MERGE AS

BEGIN

  WITH clean_export AS (
    SELECT [Associate ID] AS associate_id
          ,[First Name] AS first_name
          ,[Last Name] AS last_name      
          ,[Preferred Name] AS preferred_name
          ,[Maiden Name] AS maiden_name
          ,CONVERT(DATE,[Birth Date]) AS date_of_birth      
          ,[Primary Address: City] AS city
          ,[Primary Address: State / Territory Code] AS state
          ,RIGHT('0' + [Primary Address: Zip / Postal Code],5) AS ZIP
          ,[Personal Contact: Personal Mobile] AS phone_mobile
          ,CONVERT(INT,CONVERT(FLOAT,[Location Code])) AS location_code
          ,[Location Description] AS location
          ,[Home Department Code] AS department_code
          ,[Home Department Description] AS department      
          ,[ï»¿"Position ID"] AS position_id
          ,[Job Title Description] AS job_title      
          ,[Reports To Position ID] AS reports_to_position_id
          ,[Reports To Name] AS reports_to      
          ,[Second Manager] AS secondary_manager      
          ,[Subject Taught] AS subject_taught
          ,[Grade Taught] AS grade_taught          
          ,CASE 
            WHEN [This is a Management position] = 'Yes' THEN 1
            WHEN [This is a Management position] = 'No' THEN 0
            ELSE NULL
           END AS is_management
          ,[Position Status] AS position_status
          ,CONVERT(DATE,[Position Start Date]) AS position_start_date
          ,CONVERT(DATE,[Hire Date]) AS hire_date
          ,CONVERT(DATE,[Termination Date]) AS termination_date            
          ,CONVERT(DATE,[Rehire Date]) AS rehire_date      
          ,[Years of Service] AS years_of_service
          ,[Termination Reason Code] AS termination_code
          ,[Termination Reason Description] AS termination_reason      
          ,CONVERT(INT,CONVERT(FLOAT,[EEO Ethnic Code])) AS ethnicity_code
          ,[EEO Ethnic Description] AS ethnicity
          ,LEFT([Gender],1) AS gender
          ,[Education Level Code] AS edu_level_code
          ,[Education Level Description] AS edu_level            
          ,[Employee Type Code] AS employee_type_code
          ,[Employee Type Description] AS employee_type
          ,[Benefits Eligibility Class Description] AS benefits_elig_class
          ,[Payroll Company Code] AS payroll_company_code
          ,[FLSA Code] AS FLSA_code
          ,[FLSA Description] AS FLSA_status              
          ,CASE 
            WHEN [Spun-Off/Merged Employee] = 'Yes' THEN 1 
            WHEN [Spun-Off/Merged Employee] = 'No' THEN 0
            ELSE NULL
           END AS is_merged
          ,CONVERT(DATE,[Spin-off/Merge Date]) AS merged_on
          ,ROW_NUMBER() OVER(
            PARTITION BY [Associate ID]
              ORDER BY [Position Status] ASC, CONVERT(DATE,[Position Start Date]) DESC, CONVERT(DATE,[Termination Date]) ASC) AS rn_curr
          ,ROW_NUMBER() OVER(
            PARTITION BY [Associate ID]
              ORDER BY [Position Status] DESC, CONVERT(DATE,[Position Start Date]) ASC, CONVERT(DATE,[Termination Date]) ASC) AS rn_base
          ,COALESCE(
              LTRIM(RTRIM(CASE
                           WHEN CHARINDEX(',',[Preferred Name]) = 0 AND CHARINDEX(' ',[Preferred Name]) = 0 THEN SUBSTRING([Preferred Name], 1, LEN([Preferred Name]))
                           WHEN CHARINDEX(',',[Preferred Name]) = 0 AND CHARINDEX(' ',[Preferred Name]) > 0 THEN SUBSTRING([Preferred Name], 1, CHARINDEX(' ',[Preferred Name]))
                           WHEN CHARINDEX(',',[Preferred Name]) > 0 THEN SUBSTRING([Preferred Name], CHARINDEX(',',[Preferred Name]) + 1, LEN([Preferred Name]))
                          END)) 
             ,[First Name]) AS preferred_first
          ,COALESCE(
              LTRIM(RTRIM(CASE
                           WHEN CHARINDEX(',',[Preferred Name]) = 0 AND CHARINDEX(' ',[Preferred Name]) = 0 THEN NULL
                           WHEN CHARINDEX(',',[Preferred Name]) = 0 AND CHARINDEX(' ',[Preferred Name]) > 0 THEN SUBSTRING([Preferred Name], CHARINDEX(' ',[Preferred Name]) + 1, LEN([Preferred Name]))
                           WHEN CHARINDEX(',',[Preferred Name]) > 0 THEN SUBSTRING([Preferred Name], 1, CHARINDEX(',',[Preferred Name]) - 1)
                          END))
             ,[Last Name]) AS preferred_last
     FROM [KIPP_NJ].[dbo].[AUTOLOAD$ADP_Export_People_Details]
   )

  MERGE KIPP_NJ..PEOPLE$ADP_detail AS TARGET
    USING clean_export AS SOURCE
       ON TARGET.associate_id = SOURCE.associate_id
      AND TARGET.position_id = SOURCE.position_id    
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.first_name = SOURCE.first_name
         ,TARGET.last_name = SOURCE.last_name
         ,TARGET.preferred_name = SOURCE.preferred_name
         ,TARGET.maiden_name = SOURCE.maiden_name
         ,TARGET.date_of_birth = SOURCE.date_of_birth
         ,TARGET.city = SOURCE.city
         ,TARGET.state = SOURCE.state
         ,TARGET.ZIP = SOURCE.ZIP
         ,TARGET.phone_mobile = SOURCE.phone_mobile
         ,TARGET.location_code = SOURCE.location_code
         ,TARGET.location = SOURCE.location
         ,TARGET.department_code = SOURCE.department_code
         ,TARGET.department = SOURCE.department       
         ,TARGET.job_title = SOURCE.job_title
         ,TARGET.reports_to_position_id = SOURCE.reports_to_position_id
         ,TARGET.reports_to = SOURCE.reports_to
         ,TARGET.secondary_manager = SOURCE.secondary_manager
         ,TARGET.subject_taught = SOURCE.subject_taught
         ,TARGET.grade_taught = SOURCE.grade_taught
         ,TARGET.is_management = SOURCE.is_management
         ,TARGET.position_status = SOURCE.position_status
         ,TARGET.position_start_date = SOURCE.position_start_date
         ,TARGET.hire_date = SOURCE.hire_date
         ,TARGET.termination_date = SOURCE.termination_date
         ,TARGET.rehire_date = SOURCE.rehire_date
         ,TARGET.years_of_service = SOURCE.years_of_service
         ,TARGET.termination_code = SOURCE.termination_code
         ,TARGET.termination_reason = SOURCE.termination_reason
         ,TARGET.ethnicity_code = SOURCE.ethnicity_code
         ,TARGET.ethnicity = SOURCE.ethnicity
         ,TARGET.gender = SOURCE.gender
         ,TARGET.edu_level_code = SOURCE.edu_level_code
         ,TARGET.edu_level = SOURCE.edu_level
         ,TARGET.employee_type_code = SOURCE.employee_type_code
         ,TARGET.employee_type = SOURCE.employee_type
         ,TARGET.benefits_elig_class = SOURCE.benefits_elig_class
         ,TARGET.payroll_company_code = SOURCE.payroll_company_code
         ,TARGET.FLSA_code = SOURCE.FLSA_code
         ,TARGET.FLSA_status = SOURCE.FLSA_status
         ,TARGET.is_merged = SOURCE.is_merged
         ,TARGET.merged_on = SOURCE.merged_on
         ,TARGET.rn_curr = SOURCE.rn_curr
         ,TARGET.rn_base = SOURCE.rn_base
         ,TARGET.preferred_first = SOURCE.preferred_first
         ,TARGET.preferred_last = SOURCE.preferred_last
    WHEN NOT MATCHED AND SOURCE.position_id IS NOT NULL THEN
     INSERT
      (associate_id
      ,first_name
      ,last_name
      ,preferred_name
      ,maiden_name
      ,date_of_birth
      ,city
      ,state
      ,ZIP
      ,phone_mobile
      ,location_code
      ,location
      ,department_code
      ,department
      ,position_id
      ,job_title
      ,reports_to_position_id
      ,reports_to
      ,secondary_manager
      ,subject_taught
      ,grade_taught
      ,is_management
      ,position_status
      ,position_start_date
      ,hire_date
      ,termination_date
      ,rehire_date
      ,years_of_service
      ,termination_code
      ,termination_reason
      ,ethnicity_code
      ,ethnicity
      ,gender
      ,edu_level_code
      ,edu_level
      ,employee_type_code
      ,employee_type
      ,benefits_elig_class
      ,payroll_company_code
      ,FLSA_code
      ,FLSA_status
      ,is_merged
      ,merged_on
      ,rn_curr
      ,rn_base
      ,preferred_first
      ,preferred_last)
     VALUES
      (SOURCE.associate_id
      ,SOURCE.first_name
      ,SOURCE.last_name
      ,SOURCE.preferred_name
      ,SOURCE.maiden_name
      ,SOURCE.date_of_birth
      ,SOURCE.city
      ,SOURCE.state
      ,SOURCE.ZIP
      ,SOURCE.phone_mobile
      ,SOURCE.location_code
      ,SOURCE.location
      ,SOURCE.department_code
      ,SOURCE.department
      ,SOURCE.position_id
      ,SOURCE.job_title
      ,SOURCE.reports_to_position_id
      ,SOURCE.reports_to
      ,SOURCE.secondary_manager
      ,SOURCE.subject_taught
      ,SOURCE.grade_taught
      ,SOURCE.is_management
      ,SOURCE.position_status
      ,SOURCE.position_start_date
      ,SOURCE.hire_date
      ,SOURCE.termination_date
      ,SOURCE.rehire_date
      ,SOURCE.years_of_service
      ,SOURCE.termination_code
      ,SOURCE.termination_reason
      ,SOURCE.ethnicity_code
      ,SOURCE.ethnicity
      ,SOURCE.gender
      ,SOURCE.edu_level_code
      ,SOURCE.edu_level
      ,SOURCE.employee_type_code
      ,SOURCE.employee_type
      ,SOURCE.benefits_elig_class
      ,SOURCE.payroll_company_code
      ,SOURCE.FLSA_code
      ,SOURCE.FLSA_status
      ,SOURCE.is_merged
      ,SOURCE.merged_on
      ,SOURCE.rn_curr
      ,SOURCE.rn_base
      ,SOURCE.preferred_first
      ,SOURCE.preferred_last)
     --OUTPUT $ACTION, DELETED.*
     ;

END

GO