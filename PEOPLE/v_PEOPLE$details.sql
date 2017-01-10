USE KIPP_NJ
GO

ALTER VIEW PEOPLE$details AS

SELECT adp.associate_id
	  ,adp.position_id
      ,adp.rn_base
	  ,adp.rn_curr
	  ,CASE WHEN gdoc.timestamp IS NULL THEN 1 ELSE 0 END AS update_status

	  ,adp.position_status
	  ,adp.employee_type
	  ,adp.benefits_elig_class
	  ,gdoc.kipp_alumni_status

	  ,adp.last_name
	  ,adp.first_name
	  ,adp.preferred_name
	  ,adp.preferred_first
	  ,adp.preferred_last
	  ,gdoc.firstlast AS gdoc_firstlast
	  ,CASE WHEN gdoc.firstlast IS NULL THEN adp.preferred_first + ' ' + adp.preferred_last ELSE gdoc.firstlast END AS name_combined

	  ,adp.location
	  ,gdoc.reporting_location AS gdoc_reporting_location
	  ,CASE WHEN gdoc.reporting_location IS NULL THEN adp.location ELSE gdoc.reporting_location END AS location_combined
/*
	  ,CASE WHEN gdoc.reporting_location IS NULL AND adp.location = 'KIPP NJ' THEN 'Room 9'
		    WHEN adp.location = 'TEAM Schools' THEN 'Room 9'
			WHEN gdoc.reporting_location IS NULL THEN adp.location
			ELSE gdoc.reporting_location END AS location_combined
*/
	  ,gdoc.subject_primary
	  ,gdoc.subject_secondary
	  ,adp.subject_taught
	  ,adp.grade_taught
	  ,gdoc.grades_taught
	  --,CONCAT(CASE WHEN gdoc.grade_k_teacher IS NOT NULL THEN 'K,' END
			-- ,CASE WHEN gdoc.grade_1_teacher IS NOT NULL THEN '1,' END
			-- ,CASE WHEN gdoc.grade_2_teacher IS NOT NULL THEN '2,' END
			-- ,CASE WHEN gdoc.grade_3_teacher IS NOT NULL THEN '3,' END
			-- ,CASE WHEN gdoc.grade_4_teacher IS NOT NULL THEN '4,' END
			-- ,CASE WHEN gdoc.grade_5_teacher IS NOT NULL THEN '5,' END
			-- ,CASE WHEN gdoc.grade_6_teacher IS NOT NULL THEN '6,' END
			-- ,CASE WHEN gdoc.grade_7_teacher IS NOT NULL THEN '7,' END
			-- ,CASE WHEN gdoc.grade_8_teacher IS NOT NULL THEN '8,' END
			-- ,CASE WHEN gdoc.grade_9_teacher IS NOT NULL THEN '9,' END
			-- ,CASE WHEN gdoc.grade_10_teacher IS NOT NULL THEN '10,' END
			-- ,CASE WHEN gdoc.grade_11_teacher IS NOT NULL THEN '11,' END
			-- ,CASE WHEN gdoc.grade_12_teacher IS NOT NULL THEN '12,' END) AS grades_taught

  	  ,adp.department
	  ,CASE WHEN gdoc.department IS NULL THEN adp.department ELSE gdoc.department END AS department_combined
	  ,CASE WHEN gdoc.subject_primary IS NULL THEN adp.department ELSE gdoc.subject_primary END AS subject_combined

	  ,adp.job_title
	  ,CASE WHEN gdoc.job_title IS NULL THEN adp.job_title ELSE gdoc.job_title END AS job_title_combined
	  ,gdoc.primary_role AS gdoc_primary_role



	  ,adp.is_management
	  ,gdoc.manager_status AS gdoc_is_management
--	  ,CASE WHEN gdoc.manager_status IS NULL THEN adp.is_management ELSE gdoc.manager_status END AS is_management_combined

	  ,gdoc.manager_name AS gdoc_manager
	  ,adp.reports_to

	  ,adp.gender
	  ,gdoc.gender AS gdoc_gender
	  ,CASE WHEN gdoc.gender IS NULL THEN adp.gender ELSE gdoc.gender END AS gender_combined
	  ,adp.ethnicity
	  ,gdoc.ethnicity AS gdoc_ethnicity
	  ,CASE WHEN gdoc.ethnicity IS NULL THEN adp.ethnicity ELSE gdoc.ethnicity END AS ethnicity_combined

	  ,ad.mail AS kipp_nj_email
	  
	  ,adp.phone_mobile
	  ,gdoc.cell_phone AS gdoc_cell_phone
	  ,CASE WHEN gdoc.cell_phone IS NULL THEN adp.phone_mobile ELSE gdoc.cell_phone END AS cell_phone_combined

	  ,adp.date_of_birth
 	  ,DATEDIFF(DAY, adp.date_of_birth, CONVERT(DATE,GETDATE())) / 365 AS age
	  ,DATEDIFF(DAY, adp.hire_date, CONVERT(DATE,GETDATE())) / 365 AS years_employed

	  ,adp.hire_date
	  ,adp.rehire_date
	  ,adp.termination_date
	  ,adp.termination_code
	  ,adp.termination_reason

FROM PEOPLE$ADP_detail adp WITH(NOLOCK)

LEFT OUTER JOIN PEOPLE$AD_users#static AD WITH(NOLOCK)
  ON adp.associate_id = ad.associate_id

LEFT OUTER JOIN AUTOLOAD$GDOCS_PM_survey_roster gdoc WITH(NOLOCK)
  ON adp.associate_id = gdoc.associate_id

WHERE adp.rn_curr = 1
AND adp.position_status IN ('Active','Leave')



