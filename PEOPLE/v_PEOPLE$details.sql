USE KIPP_NJ
GO

ALTER VIEW PEOPLE$details AS

SELECT adp.associate_id
	  ,adp.position_id
      ,adp.rn_base
	  ,adp.rn_curr
	  ,adp.position_status
	  ,adp.employee_type
	  ,adp.benefits_elig_class
	  ,adp.last_name
	  ,adp.first_name
	  ,adp.preferred_name
	  ,adp.preferred_first
	  ,adp.preferred_last
	  ,adp.location
	  ,gdoc.reporting_location AS gdoc_reporting_location
	  ,CASE WHEN gdoc.reporting_location IS NULL AND adp.location = 'KIPP NJ' THEN 'Room 9'
		    WHEN adp.location = 'TEAM Schools' THEN 'Room 9'
			WHEN gdoc.reporting_location IS NULL THEN adp.location
	   ELSE gdoc.reporting_location END AS location_combined
	  ,adp.department
	  ,adp.job_title
	  ,gdoc.team AS gdoc_team
	  ,adp.subject_taught
	  ,adp.grade_taught
	  ,adp.is_management
	  ,gdoc.manager_name AS gdoc_manager
	  ,adp.gender
	  ,adp.ethnicity
	  ,gdoc.kipp_nj_email
	  ,gdoc.gapps_email
	  ,adp.phone_mobile
	  ,adp.date_of_birth
 	  ,DATEDIFF(DAY, adp.date_of_birth, CONVERT(DATE,GETDATE())) / 365 AS age
	  ,DATEDIFF(DAY, adp.hire_date, CONVERT(DATE,GETDATE())) / 365 AS years_employed
	  ,adp.hire_date
	  ,adp.rehire_date
	  ,adp.termination_date
	  ,adp.termination_code
	  ,adp.termination_reason

FROM PEOPLE$ADP_detail adp WITH(NOLOCK)

LEFT OUTER JOIN AUTOLOAD$GDOCS_PM_survey_roster gdoc WITH(NOLOCK)
  ON adp.associate_id = gdoc.associate_id



