USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_tool AS

WITH map_long AS (
  SELECT base.studentid        
        ,base.student_number
        ,base.year
        ,'Baseline' AS term                
        ,base.measurementscale
        ,base.testid
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct        
        ,CONVERT(INT,REPLACE(base.lexile_score,'BR',0)) AS base_lex
        ,rr.keep_up_goal
        ,rr.keep_up_rit
        ,rr.rutgers_ready_goal
        ,rr.rutgers_ready_rit      
        ,base.testpercentile AS pct
        ,base.testritscore AS rit      
        ,REPLACE(base.lexile_score, 'BR', 0) AS lex      
  FROM MAP$best_baseline#static base WITH(NOLOCK)
  LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
    ON base.year = rr.year
   AND REPLACE(base.measurementscale,' Usage','') = rr.measurementscale
   AND base.studentid = rr.studentid
  
  UNION ALL
  
  SELECT base.studentid                
        ,base.student_number
        ,base.year
        ,map.term
        ,base.measurementscale
        ,map.TestID
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,CONVERT(INT,REPLACE(base.lexile_score,'BR',0)) AS base_lex        
        ,rr.keep_up_goal
        ,rr.keep_up_rit
        ,rr.rutgers_ready_goal
        ,rr.rutgers_ready_rit              
        ,map.percentile_2011_norms AS pct
        ,map.testritscore AS rit      
        ,REPLACE(map.rittoreadingscore, 'BR', 0) AS lex      
  FROM MAP$best_baseline#static base WITH(NOLOCK)
  LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
    ON base.year = rr.year
   AND REPLACE(base.measurementscale,' Usage','') = rr.measurementscale
   AND base.studentid = rr.studentid
  LEFT OUTER JOIN MAP$CDF#identifiers#static map WITH(NOLOCK)
    ON base.studentid = map.studentid
   AND base.year = map.academic_year
   AND base.measurementscale = map.measurementscale   
   AND map.rn = 1
 )

,illuminate_groups AS (
  SELECT DISTINCT 
         student_number
        ,academic_year
        ,illuminate_group
  FROM KIPP_NJ..PS$enrollments_rollup#static WITH(NOLOCK)  
 )

SELECT r.year
      ,r.studentid
      ,r.student_number
      ,r.lastfirst
      ,CASE WHEN r.team LIKE '%Pathways%' THEN 732579 ELSE r.schoolid END AS schoolid
      ,r.school_level
      ,r.grade_level
      ,r.cohort
      ,r.team        
      ,r.SPEDLEP      
      ,r.enroll_status      
      
      ,terms.term      
      ,subjects.measurementscale      
      
      ,map_long.base_rit
      ,map_long.base_pct
      ,map_long.base_lex      
      ,map_long.keep_up_goal
      ,map_long.keep_up_rit
      ,map_long.rutgers_ready_goal
      ,map_long.rutgers_ready_rit      
      ,map_long.rit       
      ,map_long.pct       
      ,map_long.lex           

      ,domain.testname AS domain_testname
      ,domain.goal_number      
      ,domain.name AS domain_name
      ,domain.ritscore
      ,domain.range      
      ,domain.adjective
      
      /* Quartiles -- if 1st year, use base %ile, otherwise previous spring (unless NULL) */
      ,CASE 
        WHEN r.year_in_network = 1 AND map_long.base_pct BETWEEN 0 AND 24 THEN 1
        WHEN r.year_in_network = 1 AND map_long.base_pct BETWEEN 25 AND 49 THEN 2
        WHEN r.year_in_network = 1 AND map_long.base_pct BETWEEN 50 AND 74 THEN 3
        WHEN r.year_in_network = 1 AND map_long.base_pct >= 75 THEN 4            
       END AS base_quartile
      ,CASE 
        WHEN map_long.pct BETWEEN 0 AND 24 THEN 1
        WHEN map_long.pct BETWEEN 25 AND 49 THEN 2
        WHEN map_long.pct BETWEEN 50 AND 74 THEN 3
        WHEN map_long.pct >= 75 THEN 4                
       END AS term_quartile
      
      ,CASE WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL ELSE map_long.rit - map_long.base_rit END AS term_rit_growth
      ,CASE WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL ELSE map_long.pct - map_long.base_pct END AS term_pct_growth
      ,CASE WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL ELSE map_long.lex - map_long.base_lex END AS term_lex_growth
      
      ,ill.illuminate_group           
FROM COHORT$identifiers_long#static r WITH(NOLOCK)
CROSS JOIN (
            SELECT 'Baseline' UNION
            SELECT 'Fall' UNION
            SELECT 'Winter' UNION
            SELECT 'Spring' UNION
            SELECT 'Previous Spring'
           ) terms (term)
CROSS JOIN (
            SELECT 'Mathematics' UNION
            SELECT 'Language Usage' UNION
            SELECT 'Reading' UNION
            SELECT 'Science - General Science'
           ) subjects (measurementscale)
LEFT OUTER JOIN map_long
  ON r.studentid = map_long.studentid
 AND r.year = map_long.year 
 AND terms.term = map_long.term
 AND subjects.measurementscale = map_long.measurementscale
LEFT OUTER JOIN KIPP_NJ..MAP$domain_goals_long#static domain
  ON r.student_number = domain.student_number
 AND map_long.testid = domain.TestID
LEFT OUTER JOIN illuminate_groups ill WITH(NOLOCK)
  ON r.student_number = ill.student_number
 AND r.year = ill.academic_year 
WHERE r.year >= 2008 /* first year of MAP data */
  AND r.schoolid != 999999
  AND r.rn = 1