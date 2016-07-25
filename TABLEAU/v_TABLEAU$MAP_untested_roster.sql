USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_untested_roster AS

WITH roster AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,co.schoolid
        ,co.grade_level
        ,co.year AS academic_year
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.rn = 1
    AND co.grade_level < 99
    AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.enroll_status = 0
 )

,subjects AS (
  SELECT 'Reading' AS measurementscale
  UNION
  SELECT 'Mathematics'
  UNION
  SELECT 'Language Usage'
  UNION
  SELECT 'Science - General Science'
 )

,terms AS (
  SELECT 'Fall' AS term
  UNION
  SELECT 'Winter'
  UNION
  SELECT 'Spring'
 )

,scaffold AS (
  SELECT *
  FROM roster WITH(NOLOCK)
  CROSS JOIN subjects WITH(NOLOCK)    
  CROSS JOIN terms WITH(NOLOCK)    
 )

SELECT studentid
      ,STUDENT_NUMBER
      ,lastfirst
      ,schoolid
      ,grade_level
      ,academic_year
      ,measurementscale
      ,term
      ,map_studentid
      ,test_date
      ,RIT
      ,percentile
      ,lexile
      ,base_term
      ,base_RIT
      ,base_percentile
      ,base_lexile
      ,n_tests      
      ,COALESCE(test_date, base_term) AS tested_on
      ,COALESCE(rit, base_rit) AS current_rit
      ,COALESCE(percentile, base_percentile) AS current_percentile
      ,COALESCE(lexile, base_lexile) AS current_lexile
      ,CASE
        WHEN term = 'Fall' AND map_studentid IS NULL AND base_term IS NOT NULL THEN 'Missing test, has baseline'
        WHEN term = 'Fall' AND map_studentid IS NULL AND base_term IS NULL THEN 'Missing test, no baseline'
        WHEN term != 'Fall' AND n_tests > 1 THEN 'Multiple test events'
        WHEN term = 'Fall' AND map_studentid IS NOT NULL AND base_term IS NOT NULL THEN 'Tested, has baseline'
        WHEN term = 'Fall' AND map_studentid IS NOT NULL AND base_term IS NULL THEN 'Tested, no baseline'
        WHEN term IN ('Winter','Spring') AND map_studentid IS NULL THEN 'Missing test'
        ELSE NULL
       END AS test_audit      
FROM
    (
     SELECT r.studentid
           ,r.STUDENT_NUMBER
           ,r.lastfirst      
           ,r.schoolid
           ,r.grade_level
           ,r.academic_year
           ,r.measurementscale
           ,r.term
           ,map.studentid AS map_studentid
           ,CONVERT(VARCHAR,map.teststartdate,101) AS test_date
           ,map.testritscore AS RIT
           ,map.percentile_2015_norms AS percentile
           ,REPLACE(map.rittoreadingscore, 'BR', 0) AS lexile      
           ,base.termname AS base_term
           ,base.testritscore AS base_RIT
           ,base.testpercentile AS base_percentile
           ,REPLACE(base.lexile_score, 'BR', 0) AS base_lexile                
           ,COUNT(map.studentid) OVER(PARTITION BY map.studentid, map.academic_year, map.measurementscale, map.term) AS n_tests
     FROM scaffold r WITH(NOLOCK)
     LEFT OUTER JOIN MAP$CDF#identifiers#static map WITH(NOLOCK)
       ON r.student_number = map.student_number
      AND r.academic_year = map.academic_year
      AND r.measurementscale = map.measurementscale
      AND r.term = map.term
      --AND map.rn = 1
     LEFT OUTER JOIN MAP$best_baseline#static base WITH(NOLOCK)
       ON r.studentid = base.studentid
      AND r.academic_year = base.year
      AND r.measurementscale = base.measurementscale
    ) sub