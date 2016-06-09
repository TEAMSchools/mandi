USE KIPP_NJ
GO

ALTER VIEW TABLEAU$ops_dashboard AS

SELECT co.STUDENTID
      ,co.student_number
      ,co.lastfirst
      ,co.YEAR AS academic_year
      ,CONVERT(DATE,CONCAT(co.year, '-10-15')) AS date
      ,co.entrydate
      ,co.exitdate
      ,co.school_level
      ,co.SCHOOLID
      ,co.GRADE_LEVEL
      ,co.ENROLL_STATUS
      ,co.spedlep AS iep_status
      ,co.sped_code
      ,co.LEP_STATUS
      ,co.lunchstatus
      ,co.lunch_app_status
      ,co.ethnicity
      ,co.gender
      ,CASE WHEN CONVERT(DATE,CONCAT(co.year, '-10-15')) BETWEEN CONVERT(DATE,co.entrydate) AND CONVERT(DATE,co.exitdate) THEN 1 ELSE 0 END AS is_oct15_enrolled
      ,LEAD(co.entrydate, 1) OVER(PARTITION BY co.student_number, co.rn ORDER BY co.year ASC) AS next_entrydate
      ,LEAD(co.exitdate, 1) OVER(PARTITION BY co.student_number, co.rn ORDER BY co.year ASC) AS next_exitdate

      ,t.target_enrollment
      ,t.sped_enrollment AS target_enrollment_sped
      ,t.fr_enrollment AS target_enrollment_fr
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)            
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_FINANCE_enrollment_targets t WITH(NOLOCK)
  ON co.year = t.academic_year
 AND co.schoolid = t.schoolid
WHERE co.schoolid != 999999
  --AND co.year >= 2013