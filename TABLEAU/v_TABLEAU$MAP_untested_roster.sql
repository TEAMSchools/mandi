USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_untested_roster AS

WITH roster AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,co.lastfirst
        ,co.reporting_schoolid AS schoolid
        ,co.grade_level
        ,co.team
        ,co.year AS academic_year
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE co.rn = 1
    AND co.grade_level < 99
    --AND co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
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
  SELECT academic_year
        ,start_date AS term_start_date
        ,time_per_name AS term
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'MAP'
    AND start_date <= CONVERT(DATE,GETDATE())
 )

,scaffold AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER        
        ,co.lastfirst
        ,co.academic_year
        ,co.schoolid
        ,co.grade_level
        ,co.team                        
        ,terms.term
        ,terms.term_start_date
        ,subjects.measurementscale
  FROM roster co WITH(NOLOCK)  
  JOIN terms WITH(NOLOCK)    
    ON co.academic_year = terms.academic_year
  CROSS JOIN subjects WITH(NOLOCK)    
 )

SELECT studentid
      ,STUDENT_NUMBER
      ,lastfirst
      ,schoolid
      ,grade_level
      ,team
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
      ,COALESCE(test_date, term_start_date) AS tested_on
      ,COALESCE(rit, base_rit) AS current_rit
      ,COALESCE(percentile, base_percentile) AS current_percentile
      ,COALESCE(lexile, base_lexile) AS current_lexile
      ,CASE
        WHEN n_tests > 1 THEN 'Multiple test events'
        WHEN term IN ('Winter','Spring') AND map_studentid IS NULL THEN 'Missing test'        
        WHEN term = 'Fall' AND map_studentid IS NULL AND base_term IS NULL THEN 'Missing test, No baseline'
        WHEN term = 'Fall' AND map_studentid IS NULL AND base_term IS NOT NULL THEN 'Missing test, Has baseline'
        WHEN term = 'Fall' AND map_studentid IS NOT NULL AND base_term IS NOT NULL THEN 'Tested, Has baseline'             
       END AS test_audit      
FROM
    (
     SELECT r.studentid
           ,r.STUDENT_NUMBER
           ,r.lastfirst      
           ,r.schoolid
           ,r.grade_level
           ,r.team
           ,r.academic_year
           ,r.measurementscale
           ,r.term
           ,r.term_start_date
           ,map.studentid AS map_studentid
           ,map.teststartdate AS test_date
           ,map.testritscore AS RIT
           ,map.percentile_2015_norms AS percentile
           ,REPLACE(map.rittoreadingscore, 'BR', 0) AS lexile      
           ,base.termname AS base_term           
           ,base.testritscore AS base_RIT
           ,base.testpercentile AS base_percentile
           ,REPLACE(base.lexile_score, 'BR', 0) AS base_lexile                
           ,COUNT(map.studentid) OVER(PARTITION BY map.studentid, map.academic_year, map.term, map.measurementscale) AS n_tests
     FROM scaffold r WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
       ON r.student_number = map.student_number
      AND r.academic_year = map.academic_year
      AND r.measurementscale = map.measurementscale
      AND r.term = map.term
      --AND map.rn = 1
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
       ON r.studentid = base.studentid
      AND r.academic_year = base.year
      AND r.measurementscale = base.measurementscale
    ) sub