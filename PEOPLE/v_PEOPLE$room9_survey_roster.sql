USE KIPP_NJ
GO

ALTER VIEW PEOPLE$room9_survey_roster AS

SELECT COALESCE(ad.displayName, CONCAT(adp.first_name, ' ', adp.last_name)) AS name
      ,first_name
      ,ad.mail AS email_addr      
      ,adp.location
      ,adp.department
      ,adp.job_title
      ,adp.grade_taught
      ,adp.position_status
FROM KIPP_NJ..PEOPLE$ADP_detail adp
LEFT OUTER JOIN KIPP_NJ..PEOPLE$AD_users#static ad
  ON adp.position_id = ad.employeenumber
 AND ad.is_student = 0
 AND ad.is_active = 1
WHERE adp.position_status = 'Active'