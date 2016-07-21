USE KIPP_NJ
GO

ALTER VIEW DEVFIN$MAP_results AS

SELECT map.map_year_academic
      ,map.ps_studentid
      ,map.measurementscale 
      ,map.fallwinterspring
      ,map.testritscore
      ,map.percentile_2011_norms AS testpercentile
      ,co.SCHOOLID
      ,co.GRADE_LEVEL
      ,co.COHORT
      ,co.YEAR_IN_NETWORK
      ,rr.baseline_rit
      ,rr.baseline_percentile
      ,rr.keep_up_goal
      ,rr.keep_up_rit
      ,rr.rutgers_ready_goal
      ,rr.rutgers_ready_rit
      ,map.testritscore - rr.baseline_rit AS RIT_growth_baseline
      ,map.percentile_2011_norms - rr.baseline_percentile AS pctle_growth_baseline
      ,CASE 
        WHEN rr.keep_up_goal IS NOT NULL AND map.testritscore >= rr.keep_up_goal THEN 1.0
        WHEN rr.keep_up_goal IS NOT NULL AND map.testritscore < rr.keep_up_goal THEN 0.0
        ELSE NULL 
       END AS made_keepup_goal
      ,CASE 
        WHEN rr.rutgers_ready_goal IS NOT NULL AND map.testritscore >= rr.rutgers_ready_goal THEN 1.0 
        WHEN rr.rutgers_ready_goal IS NOT NULL AND map.testritscore < rr.rutgers_ready_goal THEN 0.0
        ELSE NULL
       END AS made_rr_goal
FROM MAP$comprehensive#identifiers map WITH(NOLOCK)
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON map.ps_studentid = co.STUDENTID
 AND map.map_year_academic = co.YEAR
 AND co.RN = 1
LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
  ON map.ps_studentid = rr.studentid
 AND map.map_year_academic = rr.year
 AND REPLACE(map.measurementscale, 'Usage', '') = rr.measurementscale