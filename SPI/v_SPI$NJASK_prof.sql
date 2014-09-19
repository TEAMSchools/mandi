USE KIPP_NJ
GO

ALTER VIEW SPI$njask_prof AS

SELECT sch.abbreviation AS school
      ,co.schoolid
      ,nj.academic_year + 1 AS test_year -- SPI uses year of test date, not academic
      ,nj.subject
      ,nj.test_grade_level
      ,ROUND(SUM(nj.is_prof)
         /
       CONVERT(FLOAT,COUNT(njask_proficiency))
         * 100,0) AS perc_prof
      ,sch.abbreviation + '@' + CONVERT(VARCHAR,nj.academic_year + 1) + '@' + nj.subject + '@' + CONVERT(VARCHAR,nj.test_grade_level) AS hash
FROM NJASK$detail nj WITH(NOLOCK)
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON nj.studentid = co.studentid
 AND nj.academic_year = co.year
 AND co.rn = 1
JOIN SCHOOLS sch WITH(NOLOCK)
  ON co.schoolid = sch.school_number
GROUP BY sch.abbreviation
        ,co.schoolid
        ,nj.academic_year
        ,nj.subject
        ,nj.test_grade_level