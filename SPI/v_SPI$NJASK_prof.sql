USE KIPP_NJ
GO

ALTER VIEW SPI$NJASK_prof AS

SELECT co.school_name AS school
      ,co.schoolid
      ,nj.academic_year + 1 AS test_year -- SPI uses year of test date, not academic
      ,nj.subject
      ,nj.test_grade_level
      ,ROUND(SUM(nj.is_prof)
         /
       CONVERT(FLOAT,COUNT(njask_proficiency))
         * 100,0) AS perc_prof
      ,co.school_name + '@' + CONVERT(VARCHAR,nj.academic_year + 1) + '@' + nj.subject + '@' + CONVERT(VARCHAR,nj.test_grade_level) AS hash
FROM NJASK$detail nj WITH(NOLOCK)
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON nj.studentid = co.studentid
 AND nj.academic_year = co.year
 AND co.rn = 1
GROUP BY co.school_name
        ,co.schoolid
        ,nj.academic_year
        ,nj.subject
        ,nj.test_grade_level