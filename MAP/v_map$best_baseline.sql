USE KIPP_NJ
GO

ALTER VIEW MAP$best_baseline AS

WITH roster AS (
  SELECT studentid
        ,student_number
        ,grade_level
        ,schoolid
        ,cohort.school_name AS school
        ,cohort.year
        ,cohort.lastfirst
  FROM KIPP_NJ..COHORT$identifiers_long#static cohort WITH(NOLOCK)  
  WHERE schoolid != 999999
    AND rn = 1    
 )
 
,subj AS (
  SELECT 'Mathematics' AS measurementscale
  UNION
  SELECT 'Reading'
  UNION
  SELECT 'Language Usage'
  UNION
  SELECT 'Science - General Science'
 )

,roster_subj_scaffold AS ( 
  SELECT roster.*
        ,subj.*
  FROM roster
  CROSS JOIN subj       
 )
  
SELECT sub.*
      ,CASE
        WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.TestID
        WHEN map_spr.testritscore IS NULL THEN map_fall.TestID
        ELSE map_spr.TestID
       END AS testid
      ,CASE
        WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.termname
        WHEN map_spr.testritscore IS NULL THEN map_fall.termname
        ELSE map_spr.termname
       END AS termname
      ,CASE
        WHEN map_fall.testritscore > map_spr.testritscore THEN CAST(map_fall.testritscore AS INT)
        WHEN map_spr.testritscore IS NULL THEN CAST(map_fall.testritscore AS INT)
        ELSE CAST(map_spr.testritscore AS INT)
       END AS testritscore
      ,CASE 
        WHEN map_fall.testritscore > map_spr.testritscore THEN CAST(map_fall.percentile_2011_norms AS INT)
        WHEN map_spr.testritscore IS NULL THEN CAST(map_fall.percentile_2011_norms AS INT)
        ELSE CAST(map_spr.percentile_2011_norms AS INT)
       END AS testpercentile
      ,CASE 
        WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.FallToSpringProjectedGrowth
        WHEN map_spr.testritscore IS NULL THEN map_fall.FallToSpringProjectedGrowth
        ELSE map_spr.springtospringprojectedgrowth
       END AS typical_growth_fallorspring_to_spring
      ,CASE 
        WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.rittoreadingscore
        WHEN map_spr.testritscore IS NULL THEN map_fall.rittoreadingscore
        ELSE map_spr.rittoreadingscore
       END AS lexile_score
FROM roster_subj_scaffold sub
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_fall WITH(NOLOCK) /* THIS YEAR FALL */
  ON sub.studentid = map_fall.studentid
 AND sub.measurementscale = map_fall.MeasurementScale
 AND map_fall.rn = 1
 AND map_fall.academic_year = sub.year
 AND map_fall.term = 'Fall'
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_spr WITH(NOLOCK) /* PREVIOUS YEAR SPRING */
  ON sub.studentid = map_spr.studentid
 AND sub.measurementscale = map_spr.MeasurementScale
 AND map_spr.rn = 1 
 AND map_spr.test_year = sub.year
 AND map_spr.term = 'Spring'