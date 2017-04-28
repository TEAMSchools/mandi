USE KIPP_NJ
GO

ALTER VIEW FINANCE$staff_roster AS

SELECT associate_id
      ,first_name
      ,last_name
      ,location
      ,department
      ,job_title
      ,position_status
      ,termination_date
      ,NULL AS employee_type     
      ,benefits_elig_class
      ,FLSA_status
FROM KIPP_NJ..PEOPLE$ADP_detail WITH(NOLOCK)
WHERE (position_status = 'Active' OR termination_date >= '2015-07-01')
  AND rn_curr = 1