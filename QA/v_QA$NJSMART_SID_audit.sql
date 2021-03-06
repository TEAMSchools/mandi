USE KIPP_NJ
GO

ALTER VIEW QA$NJSMART_SID_audit AS

WITH all_data AS (
  SELECT *
        ,CASE WHEN PS_lunchstatus != NJSMART_lunchstatus THEN 1 ELSE 0 END AS lunch_flag
        ,CASE WHEN mcs_description = 'No Application' OR mcs_description IS NULL THEN 1 ELSE 0 END AS app_flag
        ,CASE WHEN PS_SPEDCODE != NJSMART_SPEDCODE THEN 1 ELSE 0 END AS sped_flag
        ,CASE WHEN BINI_ID IS NULL THEN 1 ELSE 0 END AS enroll_flag
  FROM
      (
       SELECT s.STUDENT_NUMBER
             ,s.STATE_STUDENTNUMBER
             ,s.LASTFIRST
             ,s.SCHOOLID
             ,s.GRADE_LEVEL
             ,s.ENROLL_STATUS
             ,CONVERT(DATE,s.ENTRYDATE) AS ENTRYDATE           
             ,CASE WHEN mcs.MealBenefitStatus = 'P' THEN 'N' ELSE mcs.MealBenefitStatus END AS PS_lunchstatus
             ,mcs.description AS mcs_description

             ,nj.freeandreducedratelunchstatus AS NJSMART_lunchstatus           
             ,CASE
               WHEN iep.SPECIAL_EDUCATION IS NULL THEN NULL
               WHEN iep.SPECIAL_EDUCATION = 'AI' THEN '01'
               WHEN iep.SPECIAL_EDUCATION = 'AUT' THEN '02'
               WHEN iep.SPECIAL_EDUCATION = 'CMI' THEN '03'
               WHEN iep.SPECIAL_EDUCATION = 'CMO' THEN '04'
               WHEN iep.SPECIAL_EDUCATION = 'CSE' THEN '05'
               WHEN iep.SPECIAL_EDUCATION = 'CI' THEN '06'
               WHEN iep.SPECIAL_EDUCATION = 'ED' THEN '07'
               WHEN iep.SPECIAL_EDUCATION = 'MD' THEN '08'
               WHEN iep.SPECIAL_EDUCATION = 'DB' THEN '09'
               WHEN iep.SPECIAL_EDUCATION = 'OI' THEN '10'
               WHEN iep.SPECIAL_EDUCATION = 'OHI' THEN '11'
               WHEN iep.SPECIAL_EDUCATION = 'PSD' THEN '12'
               WHEN iep.SPECIAL_EDUCATION = 'SM' THEN '13' /* no longer valid */
               WHEN iep.SPECIAL_EDUCATION = 'SLD' THEN '14'
               WHEN iep.SPECIAL_EDUCATION = 'TBI' THEN '15'
               WHEN iep.SPECIAL_EDUCATION = 'VI' THEN '16'
               WHEN iep.SPECIAL_EDUCATION = 'ESLS' THEN '17'
               ELSE RIGHT(CONCAT('0',iep.SPECIAL_EDUCATION),2)
              END AS PS_SPEDCODE
             ,CASE 
               WHEN nj.specialeducationclassification IS NULL THEN NULL
               ELSE RIGHT(CONCAT('0', nj.specialeducationclassification),2) 
              END AS NJSMART_SPEDCODE
             ,nj.BINI_ID
       FROM KIPP_NJ..PS$STUDENTS#static s
       LEFT OUTER JOIN KIPP_NJ..PS$IEP_details#static iep
         ON s.ID = iep.STUDENTID
       LEFT OUTER JOIN KIPP_NJ..MCS$lunch_info mcs
         ON s.STUDENT_NUMBER = mcs.StudentNumber
       JOIN KIPP_NJ..AUTOLOAD$GDOCS_NJSMART_sid_export nj
         ON s.STUDENT_NUMBER = nj.localidentificationnumber

       UNION ALL

       SELECT s.STUDENT_NUMBER
             ,s.STATE_STUDENTNUMBER
             ,s.LASTFIRST
             ,s.SCHOOLID
             ,s.GRADE_LEVEL
             ,s.ENROLL_STATUS
             ,CONVERT(DATE,s.ENTRYDATE) AS ENTRYDATE
             ,CASE WHEN mcs.MealBenefitStatus = 'P' THEN 'N' ELSE mcs.MealBenefitStatus END AS PS_lunchstatus
             ,mcs.description AS mcs_description
             ,nj.freeandreducedratelunchstatus AS NJSMART_lunchstatus
             ,CASE
               WHEN iep.SPECIAL_EDUCATION IS NULL THEN NULL
               WHEN iep.SPECIAL_EDUCATION = 'AI' THEN '01'
               WHEN iep.SPECIAL_EDUCATION = 'AUT' THEN '02'
               WHEN iep.SPECIAL_EDUCATION = 'CMI' THEN '03'
               WHEN iep.SPECIAL_EDUCATION = 'CMO' THEN '04'
               WHEN iep.SPECIAL_EDUCATION = 'CSE' THEN '05'
               WHEN iep.SPECIAL_EDUCATION = 'CI' THEN '06'
               WHEN iep.SPECIAL_EDUCATION = 'ED' THEN '07'
               WHEN iep.SPECIAL_EDUCATION = 'MD' THEN '08'
               WHEN iep.SPECIAL_EDUCATION = 'DB' THEN '09'
               WHEN iep.SPECIAL_EDUCATION = 'OI' THEN '10'
               WHEN iep.SPECIAL_EDUCATION = 'OHI' THEN '11'
               WHEN iep.SPECIAL_EDUCATION = 'PSD' THEN '12'
               WHEN iep.SPECIAL_EDUCATION = 'SM' THEN '13' /* no longer valid */
               WHEN iep.SPECIAL_EDUCATION = 'SLD' THEN '14'
               WHEN iep.SPECIAL_EDUCATION = 'TBI' THEN '15'
               WHEN iep.SPECIAL_EDUCATION = 'VI' THEN '16'
               WHEN iep.SPECIAL_EDUCATION = 'ESLS' THEN '17'
               ELSE RIGHT(CONCAT('0',iep.SPECIAL_EDUCATION),2)
              END AS PS_SPEDCODE
             ,CASE 
               WHEN nj.specialeducationclassification IS NULL THEN NULL
               ELSE RIGHT(CONCAT('0', nj.specialeducationclassification),2) 
              END AS NJSMART_SPEDCODE
             ,nj.BINI_ID
       FROM KIPP_NJ..PS$STUDENTS#static s
       LEFT OUTER JOIN KIPP_NJ..PS$IEP_details#static iep
         ON s.ID = iep.STUDENTID
       LEFT OUTER JOIN KIPP_NJ..MCS$lunch_info mcs
         ON s.STUDENT_NUMBER = mcs.StudentNumber
       LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_NJSMART_sid_export nj
         ON s.STUDENT_NUMBER = nj.localidentificationnumber
       WHERE s.ENROLL_STATUS = 0
         AND nj.BINI_ID IS NULL
      ) sub
 )

SELECT *
FROM all_data
WHERE lunch_flag = 1
   OR app_flag = 1
   OR sped_flag = 1
   OR enroll_flag = 1