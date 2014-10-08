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
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE co.rn = 1
    AND co.grade_level < 99
    AND co.year = dbo.fn_Global_Academic_Year()
    AND co.exitdate >= GETDATE()
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
  JOIN subjects WITH(NOLOCK)
    ON 1 = 1
  JOIN terms WITH(NOLOCK)
    ON 1 = 1
 )

SELECT *
      ,COALESCE(test_date, base_term) AS tested_on
      ,COALESCE(rit, base_rit) AS current_rit
      ,COALESCE(percentile, base_percentile) AS current_percentile
      ,COALESCE(lexile, base_lexile) AS current_lexile
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
           ,CONVERT(VARCHAR,map.teststartdate,101) AS test_date
           ,map.testritscore AS RIT
           ,map.percentile_2011_norms AS percentile
           ,REPLACE(map.rittoreadingscore, 'BR', 0) AS lexile      
           ,base.termname AS base_term
           ,base.testritscore AS base_RIT
           ,base.testpercentile AS base_percentile
           ,REPLACE(base.lexile_score, 'BR', 0) AS base_lexile      
           ,CASE
             WHEN r.term = 'Fall' AND map.ps_studentid IS NULL AND base.termname IS NOT NULL THEN 'Missing test, has baseline'
             WHEN r.term = 'Fall' AND map.ps_studentid IS NULL AND base.termname IS NULL THEN 'Missing test, no baseline'
             WHEN r.term = 'Fall' AND map.ps_studentid IS NOT NULL AND base.termname IS NOT NULL THEN 'Tested, has baseline'
             WHEN r.term = 'Fall' AND map.ps_studentid IS NOT NULL AND base.termname IS NULL THEN 'Tested, no baseline'
             WHEN r.term IN ('Winter','Spring') AND map.ps_studentid IS NULL THEN 'Missing Test'
             ELSE NULL
            END AS test_audit
     FROM scaffold r WITH(NOLOCK)
     LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH(NOLOCK)
       ON r.studentid = map.ps_studentid
      AND r.academic_year = map.map_year_academic
      AND r.measurementscale = map.measurementscale
      AND r.term = map.fallwinterspring
      AND map.rn = 1
     LEFT OUTER JOIN MAP$best_baseline#static base WITH(NOLOCK)
       ON r.studentid = base.studentid
      AND r.academic_year = base.year
      AND r.measurementscale = base.measurementscale
    ) sub