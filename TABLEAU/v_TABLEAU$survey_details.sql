USE KIPP_NJ
GO

ALTER VIEW TABLEAU$survey_details AS

SELECT survey_type
      ,survey_timestamp
      ,academic_year
      ,subject_name
      ,is_instructional
      ,question_code
      ,response
      ,CONVERT(FLOAT,response_value) AS response_value
      ,term
      ,subject_associate_id
      ,subject_reporting_location
      ,team
      ,subject_manager_name
      ,responder_name
      ,responder_reporting_location
      ,competency
      ,is_open_ended
      ,question_text
      ,exclude_from_agg
      ,exclude_location
      ,exclude_department
      ,exclude_role
      ,1 AS N
      ,CASE WHEN response_value >= 4 THEN 1 ELSE 0 END AS N_agree
	     ,people.associate_id
      ,people.position_id
      ,people.rn_base
      ,people.rn_curr
      ,people.update_status
      ,people.position_status
      ,people.employee_type
      ,people.benefits_elig_class
      ,people.kipp_alumni_status
      ,people.last_name
      ,people.first_name
      ,people.preferred_name
      ,people.preferred_first
      ,people.preferred_last
      ,people.gdoc_firstlast
      ,people.name_combined
      ,people.location
      ,people.gdoc_reporting_location
      ,people.location_combined
      ,people.subject_primary
      ,people.subject_secondary
      ,people.subject_taught
      ,people.grade_taught
      ,people.grades_taught
      ,people.department
      ,people.department_combined
      ,people.subject_combined
      ,people.job_title
      ,people.job_title_combined
      ,people.gdoc_primary_role
      ,people.is_management
      ,people.gdoc_is_management
      ,people.gdoc_manager
      ,people.reports_to
      ,people.gender
      ,people.gdoc_gender
      ,people.gender_combined
      ,people.ethnicity
      ,people.gdoc_ethnicity
      ,people.ethnicity_combined
      ,people.kipp_nj_email
      ,people.phone_mobile
      ,people.gdoc_cell_phone
      ,people.cell_phone_combined
      ,people.date_of_birth
      ,people.age
      ,people.years_employed
      ,people.hire_date
      ,people.rehire_date
      ,people.termination_date
      ,people.termination_code
      ,people.termination_reason
FROM PEOPLE$PM_survey_responses_long#static survey WITH(NOLOCK)
JOIN PEOPLE$details people WITH(NOLOCK)
  ON survey.subject_associate_id = people.associate_id

UNION ALL

SELECT 'R9' AS survey_type
      ,NULL AS survey_timestamp
      ,academic_year
      ,'Room 9' AS subject_name
      ,NULL AS is_instructional
      ,NULL AS question_code
      ,value response
      ,CONVERT(FLOAT,value) AS response_value
      ,term
      ,NULL AS subject_associate_id
      ,NULL AS subject_reporting_location
      ,NULL AS team
      ,NULL AS subject_manager_name
      ,school AS responder_name
      ,school AS responder_reporting_location
      ,domain AS competency
      ,NULL AS is_open_ended
      ,field AS question_text
      ,NULL AS exclude_from_agg
      ,NULL AS exclude_location
      ,NULL AS exclude_department
      ,NULL AS exclude_role
      ,MAX(CASE WHEN field = 'Survey Respondents' THEN value END) OVER(PARTITION BY academic_year, term, type, school) AS N
      ,ROUND(MAX(CASE WHEN field = 'Survey Respondents' THEN value END) OVER(PARTITION BY academic_year, term, type, school) * CONVERT(FLOAT,value),0) AS N_agree
      ,NULL AS associate_id
      ,NULL AS position_id
      ,NULL AS rn_base
      ,NULL AS rn_curr
      ,NULL AS update_status
      ,NULL AS position_status
      ,NULL AS employee_type
      ,NULL AS benefits_elig_class
      ,NULL AS kipp_alumni_status
      ,NULL AS last_name
      ,NULL AS first_name
      ,NULL AS preferred_name
      ,NULL AS preferred_first
      ,NULL AS preferred_last
      ,NULL AS gdoc_firstlast
      ,NULL AS name_combined
      ,NULL AS location
      ,NULL AS gdoc_reporting_location
      ,NULL AS location_combined
      ,NULL AS subject_primary
      ,NULL AS subject_secondary
      ,NULL AS subject_taught
      ,NULL AS grade_taught
      ,NULL AS grades_taught
      ,NULL AS department
      ,NULL AS department_combined
      ,NULL AS subject_combined
      ,NULL AS job_title
      ,NULL AS job_title_combined
      ,NULL AS gdoc_primary_role
      ,NULL AS is_management
      ,NULL AS gdoc_is_management
      ,NULL AS gdoc_manager
      ,NULL AS reports_to
      ,NULL AS gender
      ,NULL AS gdoc_gender
      ,NULL AS gender_combined
      ,NULL AS ethnicity
      ,NULL AS gdoc_ethnicity
      ,NULL AS ethnicity_combined
      ,NULL AS kipp_nj_email
      ,NULL AS phone_mobile
      ,NULL AS gdoc_cell_phone
      ,NULL AS cell_phone_combined
      ,NULL AS date_of_birth
      ,NULL AS age
      ,NULL AS years_employed
      ,NULL AS hire_date
      ,NULL AS rehire_date
      ,NULL AS termination_date
      ,NULL AS termination_code
      ,NULL AS termination_reason
FROM KIPP_NJ..AUTOLOAD$GDOCS_TNTP_insight_survey_data WITH(NOLOCK)
WHERE academic_year >= 2016
  AND school NOT IN ('KIPP Network Average','KIPP Top Quartile Schools*','KIPP New Jersey Average','KIPP Top Quartile Schools','KIPP New Jersey')
  AND ISNUMERIC(value) = 1
/*

--removing 2015-16 surve code to replace: need to rebuild all survey detail for 2016-17

WITH long_data AS (
  SELECT survey_type
	       ,academic_year
	       ,subject_name
	       ,is_instructional
	       ,question_code
	       ,response
	       ,response_value
	       ,term
	       ,subject_reporting_location
	       ,subject_team
	       ,subject_manager_name
	       ,responder_name
	       ,CASE WHEN responder_reporting_location LIKE '%Pathways%' THEN 'Life Academy'
		    ELSE responder_reporting_location
			END AS responder_reporting_location
	       ,competency
	       ,is_open_ended
	       ,question_text
	       ,exclude_from_agg
	       /* exclusions */
	       ,exclude_location
		   ,exclude_department
           ,exclude_role	     
  FROM KIPP_NJ..PEOPLE$PM_survey_responses_long WITH(NOLOCK)
  WHERE responder_reporting_location IS NOT NULL

  UNION ALL

  SELECT 'R9' AS survey_type
        ,s.academic_year
        ,NULL AS subject_name
        ,NULL AS is_instructional
        ,NULL question_code
        ,NULL AS response
        ,CASE WHEN s.response >= r.n THEN 5 ELSE 1 END AS response_value
        ,s.term      
        ,NULL AS subject_reporting_location
        ,NULL AS subject_team
        ,NULL AS subject_manager_name
        ,NULL AS responder_name      
        ,CASE        
          WHEN s.reporting_location IN ('Life','Life Upper','Life Lower','Pathways','Life Academy') THEN 'Life Academy'
          WHEN s.reporting_location IN ('Newark Collegiate Academy','NCA') THEN 'Newark Collegiate Academy'
          WHEN s.reporting_location IN ('LSP','Revolution','Lanning Square Primary') THEN 'Lanning Square Primary'
          WHEN s.reporting_location IN ('Rise Academy','Rise') THEN 'Rise Academy'
          WHEN s.reporting_location IN ('Seek Academy','Seek') THEN 'Seek Academy'
          WHEN s.reporting_location IN ('SPARK Academy','SPARK') THEN 'SPARK Academy'
          WHEN s.reporting_location IN ('TEAM Academy','TEAM') THEN 'TEAM Academy'
          WHEN s.reporting_location IN ('THRIVE Academy','THRIVE') THEN 'THRIVE Academy'
          WHEN s.reporting_location IN ('Room 9') THEN 'Room 9'
         END AS responder_reporting_location      
        ,s.competency
        ,0 AS is_open_ended
        ,NULL AS question_text
        ,'N' AS exclude_from_aff
        ,NULL AS exclude_location
        ,NULL AS exclude_department
        ,NULL AS exclude_role
  FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_historical_r9 s WITH(NOLOCK)
  JOIN KIPP_NJ..UTIL$row_generator r WITH(NOLOCK)
    ON r.n BETWEEN 1 AND 100

  UNION ALL

  SELECT 'R9' AS survey_type
        ,q12.academic_year
        ,NULL AS subject_name
        ,NULL AS is_instructional
        ,CONCAT('r9q12_', RIGHT(CONCAT('00',REPLACE(question_code,'Q','')),2)) AS question_code
        ,NULL AS response
        ,q12.response AS response_value
        ,q12.term      
        ,NULL AS subject_reporting_location
        ,NULL AS subject_team
        ,NULL AS subject_manager_name
        ,NULL AS responder_name      
        ,CASE        
          WHEN q12.school IN ('Life','Life Upper','Life Lower','Pathways','Life Academy') THEN 'Life Academy'
          WHEN q12.school IN ('Newark Collegiate Academy','NCA') THEN 'Newark Collegiate Academy'
          WHEN q12.school IN ('LSP','Revolution','Lanning Square Primary') THEN 'Lanning Square Primary'
          WHEN q12.school IN ('Rise Academy','Rise') THEN 'Rise Academy'
          WHEN q12.school IN ('Seek Academy','Seek') THEN 'Seek Academy'
          WHEN q12.school IN ('SPARK Academy','SPARK') THEN 'SPARK Academy'
          WHEN q12.school IN ('TEAM Academy','TEAM') THEN 'TEAM Academy'
          WHEN q12.school IN ('THRIVE Academy','THRIVE') THEN 'THRIVE Academy'
          WHEN q12.school IN ('Room 9') THEN 'Room 9'
         END AS responder_reporting_location      
        ,'Q12' AS competency
        ,0 AS is_open_ended
        ,NULL AS question_text
        ,'N' AS exclude_from_aff
        ,NULL AS exclude_location
        ,NULL AS exclude_department
        ,NULL AS exclude_role
  FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_historical_q12 q12 WITH(NOLOCK)
 )

SELECT *
	     ,CONCAT(exclude_location_status, exclude_department_status, exclude_role_status) AS exclude_audit
	     ,CASE 
			WHEN CONCAT(exclude_location_status, exclude_department_status, exclude_role_status) LIKE '%exclude%' THEN 'exclude' 
			ELSE 'include' 
		  END AS exclude
FROM 
    (
	    SELECT survey_type
	          ,academic_year
	          ,subject_name
	          ,is_instructional
	          ,question_code
	          ,response
	          ,response_value
	          ,term
			  ,CASE 
				WHEN term IN ('Q1','Q2') THEN 'Winter'
				WHEN term IN ('Q3','Q4') THEN 'Spring'
				ELSE term 
			   END AS term_season
			  ,CASE 
				WHEN term IN ('Winter','Q2') THEN CONVERT(VARCHAR,academic_year) + '-12-01'
				WHEN term IN ('Spring', 'Q4') THEN CONVERT(VARCHAR,academic_year +1 ) + '-06-01'
				ELSE NULL 
			   END AS dates
	          ,subject_reporting_location
	          ,subject_team
	          ,subject_manager_name
	          ,responder_name
	          ,LTRIM(RTRIM(responder_reporting_location)) AS responder_reporting_location
	          ,competency
	          ,is_open_ended
	          ,question_text
	          ,exclude_from_agg

	          /* exclusions */
	          ,exclude_location
			  ,exclude_department
		      ,exclude_role
	          ,CASE 
				WHEN exclude_location	LIKE '%Include%' AND CHARINDEX(responder_reporting_location, exclude_location) > 0 THEN 'include'
		           WHEN exclude_location	LIKE '%Include%' AND CHARINDEX(responder_reporting_location, exclude_location) = 0 THEN 'exclude'
		           WHEN exclude_location	NOT LIKE	'%Include%' AND CHARINDEX(responder_reporting_location, exclude_location) > 0 THEN 'exclude'
		           WHEN exclude_location	NOT LIKE	'%Include%' AND CHARINDEX(responder_reporting_location, exclude_location) = 0 THEN 'include'
		           ELSE 'include' 
	           END AS exclude_location_status
	          ,CASE 
				WHEN exclude_department	LIKE	'%Include%' AND CHARINDEX(adp_responder.department, exclude_department) > 0 THEN 'include'
		           WHEN exclude_department	LIKE '%Include%' AND CHARINDEX(adp_responder.department, exclude_department) = 0 THEN 'exclude'
		           WHEN exclude_department	NOT LIKE	'%Include%' AND CHARINDEX(adp_responder.department, exclude_department) > 0 THEN 'exclude'
		           WHEN exclude_department	NOT LIKE	'%Include%' AND CHARINDEX(adp_responder.department, exclude_department) = 0 THEN 'include'
		           ELSE 'include' 
	           END AS exclude_department_status
	          ,CASE 
				WHEN exclude_role		LIKE		'%Include%' AND CHARINDEX(adp_responder.job_title, exclude_role) > 0 THEN 'include'
		           WHEN exclude_role			LIKE		'%Include%' AND CHARINDEX(adp_responder.job_title, exclude_role) = 0 THEN 'exclude'
		           WHEN exclude_role			NOT LIKE	'%Include%' AND CHARINDEX(adp_responder.job_title, exclude_role) > 0 THEN 'exclude'
		           WHEN exclude_role			NOT LIKE	'%Include%' AND CHARINDEX(adp_responder.job_title, exclude_role) = 0 THEN 'include'
		           ELSE 'include' 
	           END AS exclude_role_status	 
	      
           /* responder/subject details */
	          ,responder.associate_id AS responder_associate_id
	          ,responder.gapps_email AS responder_gapps_email
	          ,subject.associate_id AS subject_associate_id
	          ,subject.gapps_email AS subject_gapps_email
	          ,adp_responder.location AS adp_responder_location
	          ,adp_responder.job_title AS adp_responder_job_title
	          ,adp_responder.department AS adp_responder_department
	          ,adp_responder.position_status AS adp_responder_position_status
	          ,adp_responder.benefits_elig_class AS adp_responder_benefits_elig_class
	          ,adp_responder.ethnicity_code AS adp_responder_ethnicity_code
	          ,adp_responder.is_management AS adp_responder_is_management
	          ,adp_responder.reports_to AS adp_responder_reports_to
	          ,adp_responder.hire_date AS adp_responder_hire_date
	          ,DATEDIFF(DAY, adp_responder.hire_date, CONVERT(DATE,GETDATE())) / 365 AS years_employed
     FROM long_data surveys WITH(NOLOCK)
     LEFT OUTER JOIN AUTOLOAD$GDOCS_PM_survey_roster responder WITH(NOLOCK)
       ON surveys.responder_name = responder.firstlast
     LEFT OUTER JOIN AUTOLOAD$GDOCS_PM_survey_roster subject WITH(NOLOCK)
       ON surveys.subject_name = subject.firstlast
     LEFT OUTER JOIN PEOPLE$ADP_detail adp_responder WITH(NOLOCK)
       ON responder.associate_id = adp_responder.associate_id
      AND adp_responder.rn_curr = 1
     LEFT OUTER JOIN PEOPLE$ADP_detail adp_subject WITH(NOLOCK)
       ON subject.associate_id = adp_subject.associate_id
      AND adp_subject.rn_curr = 1
	   ) sub

*/