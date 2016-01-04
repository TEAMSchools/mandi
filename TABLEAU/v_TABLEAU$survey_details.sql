USE KIPP_NJ
GO

ALTER VIEW TABLEAU$survey_details AS

SELECT surveys.*
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
	  ,DATEDIFF(DD,adp_responder.hire_date,GETDATE()) / 365 AS years_employed

FROM PEOPLE$PM_survey_responses_long surveys WITH(NOLOCK)

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

