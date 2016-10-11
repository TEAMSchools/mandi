USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$SMID_roster_submission AS

SELECT adp.associate_id AS localstaffidentifier
      ,u.SIF_STATEPRID AS staffmemberidentifier
      ,NULL AS socialsecuritynumber
      ,NULL AS nameprefix
      ,adp.first_name AS firstname
      ,NULL AS middlename
      ,adp.last_name AS lastname
      ,NULL AS generationcodesuffix
      ,adp.maiden_name AS formername
      ,adp.gender AS sex
      ,REPLACE(adp.date_of_birth,'-','') AS dateofbirth
      ,CASE WHEN adp.ethnicity = 'Hispanic or Latino' THEN 'Y' ELSE 'N' END AS ethnicity
      ,CASE WHEN adp.ethnicity = 'American Indian or Alaska Native' THEN 'Y' ELSE 'N' END AS raceamericanindian
      ,CASE WHEN adp.ethnicity = 'Asian' THEN 'Y' ELSE 'N' END AS raceasian
      ,CASE WHEN adp.ethnicity = 'Black or African American' THEN 'Y' ELSE 'N' END AS raceblack
      ,CASE WHEN adp.ethnicity = 'Native Hawaiian or Other Pacific Islander' THEN 'Y' ELSE 'N' END AS racepacific
      ,CASE WHEN adp.ethnicity = 'White' THEN 'Y' ELSE 'N' END AS racewhite
      ,r.certification_level AS certificationstatus
      ,CASE WHEN adp.position_status != 'Terminated' THEN 'A' ELSE 'I' END AS status
      ,REPLACE(adp.hire_date,'-','') AS districtemploymentbegindate
      ,CASE WHEN adp.hire_date >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(),'-07-01')) THEN '!' END AS districtentrycode /* anyone w/o SMID */
      ,REPLACE(adp.termination_date,'-','') AS employmentexitdate      
      ,CASE WHEN adp.termination_code IS NOT NULL THEN '!' END AS districtemploymentexitreason

      /* reference fields */
      ,adp.termination_reason AS ADP_termination_reason
      ,COALESCE(r.reporting_location, adp.location) AS reporting_location
FROM KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PEOPLE_teachernumber_associateid_link link WITH(NOLOCK)
  ON adp.associate_id = link.associate_id
 AND link.is_master = 1
LEFT OUTER JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
  ON COALESCE(link.teachernumber, adp.associate_id) = u.TEACHERNUMBER
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PM_survey_roster r WITH(NOLOCK)
  ON adp.associate_id = r.associate_id
WHERE rn_curr = 1
  AND NOT (adp.termination_code IS NOT NULL AND u.SIF_STATEPRID IS NULL) /* exclude anyone not yet in NJSMART and already terminated */
  AND (adp.termination_code IS NULL OR (adp.position_start_date < CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(),'-07-01')) /* include current staff and */
                                        AND adp.termination_date >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(),'-07-01'))))