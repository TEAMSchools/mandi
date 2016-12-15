USE KIPP_NJ
GO

ALTER VIEW TABLEAU$survey_details AS

WITH survey AS (
	SELECT *
	FROM PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
	WHERE academic_year = 2016
	  AND survey_type = 'Manager'
	)

SELECT survey.survey_type
	  ,survey.term
	  ,survey.survey_timestamp
	  ,survey.academic_year
	  ,survey.question_code
	  ,survey.question_text
	  ,survey.response
	  ,survey.response_value
	  ,survey.competency
	  ,survey.is_open_ended
	  ,survey.exclude_department
	  ,survey.exclude_from_agg
	  ,survey.exclude_location
	  ,survey.exclude_role
	  ,survey.responder_name
	  ,people.*

FROM PEOPLE$details people WITH(NOLOCK)

JOIN survey
  ON people.associate_id = survey.subject_associate_id


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