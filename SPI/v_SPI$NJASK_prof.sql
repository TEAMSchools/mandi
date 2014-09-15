USE KIPP_NJ
GO

ALTER VIEW SPI$njask_prof AS

WITH njask AS(
  SELECT *
  FROM
      (
       SELECT njask.*
             ,sch.ABBREVIATION AS school_name
             ,ROW_NUMBER() OVER(
                 PARTITION BY studentid, test_year, subject
                     ORDER BY subject) AS rn
       FROM NJASK$detail#static njask WITH(NOLOCK)
       JOIN SCHOOLS sch WITH(NOLOCK)
         ON njask.test_schoolid = sch.SCHOOL_NUMBER
      ) sub
  WHERE rn = 1
 )

SELECT school_name AS school
      ,test_schoolid AS schoolid
      ,test_year
      ,subject
      ,test_grade_level
      ,ROUND(SUM(CASE WHEN njask_proficiency IN ('Proficient','Advanced Proficient') THEN 1.0 ELSE 0.0 END)
         /
       CONVERT(FLOAT,COUNT(njask_proficiency))
         * 100,0) AS perc_prof
      ,school_name + '@' + CONVERT(VARCHAR,test_year) + '@' + subject + '@' + CONVERT(VARCHAR,test_grade_level) AS hash
FROM njask
GROUP BY school_name
        ,test_schoolid
        ,test_year
        ,subject
        ,test_grade_level