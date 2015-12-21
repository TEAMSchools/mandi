USE KIPP_NJ
GO

ALTER VIEW FINANCE$enrollment_targets AS

WITH enr_targets AS (
  SELECT academic_year
        ,schoolid
        ,target_enrollment
  FROM KIPP_NJ..AUTOLOAD$GDOCS_FINANCE_enrollment_targets WITH(NOLOCK)
 )

,enr_actual AS (
  SELECT co.schoolid
        ,co.year
        ,COUNT(co.studentid) AS actual_enrollment
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE CONVERT(DATE,CONCAT(co.year,'-10-15')) BETWEEN co.entrydate AND co.exitdate
    AND (co.team NOT LIKE '%pathways%' OR co.team IS NULL)
  GROUP BY co.schoolid
          ,co.year
 )

SELECT a.year AS academic_year
      ,a.schoolid      
      ,a.actual_enrollment
      ,t.target_enrollment
      ,a.actual_enrollment - t.target_enrollment AS diff_from_target
FROM enr_actual a
LEFT OUTER JOIN enr_targets t
  ON a.schoolid = t.schoolid
 AND a.year = t.academic_year