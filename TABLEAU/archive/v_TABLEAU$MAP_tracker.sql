USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_tracker AS

WITH map_long AS (
  SELECT base.studentid        
        ,base.year
        ,'Baseline' AS term
        ,base.measurementscale
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,REPLACE(base.lexile_score,'BR',0) AS base_lex
        ,prevspr.testritscore AS prevspr_rit
        ,prevspr.testpercentile AS prevspr_pct
        ,CASE WHEN prevspr.rittoreadingscore = 'BR' THEN 0 ELSE prevspr.rittoreadingscore END AS prevspr_lex
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
  LEFT OUTER JOIN MAP$CDF#identifiers#static prevspr WITH(NOLOCK)
    ON base.studentid = prevspr.studentid
   AND base.year = (prevspr.academic_year + 1)
   AND base.measurementscale = prevspr.measurementscale
   AND prevspr.term = 'Spring'
   AND prevspr.rn = 1
  
  UNION ALL
  
  SELECT base.studentid                
        ,base.year
        ,map.term
        ,base.measurementscale
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,REPLACE(base.lexile_score,'BR',0) AS base_lex
        ,prevspr.testritscore AS prevspr_rit
        ,prevspr.testpercentile AS prevspr_pct
        ,CASE WHEN prevspr.rittoreadingscore = 'BR' THEN 0 ELSE prevspr.rittoreadingscore END AS prevspr_lex
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
   --AND terms.term = map.term
   AND map.rn = 1
  LEFT OUTER JOIN MAP$CDF#identifiers#static prevspr WITH(NOLOCK)
    ON base.studentid = prevspr.studentid
   AND base.year = (prevspr.academic_year + 1)
   AND base.measurementscale = prevspr.measurementscale
   AND prevspr.term = 'Spring'
   AND prevspr.rn = 1

  UNION ALL

  SELECT base.studentid                
        ,base.year
        ,'Previous Spring' AS term
        ,base.measurementscale
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,REPLACE(base.lexile_score,'BR',0) AS base_lex
        ,prevspr.testritscore AS prevspr_rit
        ,prevspr.testpercentile AS prevspr_pct
        ,CASE WHEN prevspr.rittoreadingscore = 'BR' THEN 0 ELSE prevspr.rittoreadingscore END AS prevspr_lex
        ,rr.keep_up_goal
        ,rr.keep_up_rit
        ,rr.rutgers_ready_goal
        ,rr.rutgers_ready_rit      
        ,prevspr.percentile_2011_norms AS pct
        ,prevspr.testritscore AS rit      
        ,CONVERT(INT,REPLACE(prevspr.rittoreadingscore, 'BR', 0)) AS lex      
  FROM MAP$best_baseline#static base WITH(NOLOCK)
  LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
    ON base.year = rr.year
   AND REPLACE(base.measurementscale,' Usage','') = rr.measurementscale
   AND base.studentid = rr.studentid  
  LEFT OUTER JOIN MAP$CDF#identifiers#static prevspr WITH(NOLOCK)
    ON base.studentid = prevspr.studentid
   AND base.year = (prevspr.academic_year + 1)
   AND base.measurementscale = prevspr.measurementscale
   AND prevspr.term = 'Spring'
   AND prevspr.rn = 1 
 )

,illuminate_groups AS (
  SELECT DISTINCT 
         student_number
        ,academic_year
        ,illuminate_group
  FROM KIPP_NJ..PS$enrollments_rollup#static WITH(NOLOCK)
  WHERE academic_year >= 2013
 )

SELECT r.year
      ,r.studentid
      ,r.student_number
      ,r.lastfirst
      ,CASE WHEN r.team LIKE '%Pathways%' THEN 732579 ELSE r.schoolid END AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team        
      ,r.SPEDLEP
      ,r.GENDER
      ,r.enroll_status
      ,r.retained_ever_flag
      ,r.retained_yr_flag
      ,CASE WHEN r.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN 1 ELSE 0 END AS is_current_year
      ,terms.term AS fallwinterspring      
      ,subjects.measurementscale
      ,map_long.base_rit
      ,map_long.base_pct
      ,map_long.base_lex
      ,map_long.prevspr_rit
      ,map_long.prevspr_pct
      ,map_long.prevspr_lex
      ,map_long.keep_up_goal
      ,map_long.keep_up_rit
      ,map_long.rutgers_ready_goal
      ,map_long.rutgers_ready_rit      
      ,map_long.rit       
      ,map_long.pct       
      ,map_long.lex       
      /* Quartiles -- if 1st year, use base %ile, otherwise previous spring (unless NULL) */
      ,CASE 
        WHEN r.year_in_network = 1 AND map_long.base_pct BETWEEN 0 AND 24 THEN 1
        WHEN r.year_in_network = 1 AND map_long.base_pct BETWEEN 25 AND 49 THEN 2
        WHEN r.year_in_network = 1 AND map_long.base_pct BETWEEN 50 AND 74 THEN 3
        WHEN r.year_in_network = 1 AND map_long.base_pct >= 75 THEN 4
        WHEN r.year_in_network > 1 AND COALESCE(map_long.prevspr_pct,map_long.base_pct) BETWEEN 0 AND 24 THEN 1
        WHEN r.year_in_network > 1 AND COALESCE(map_long.prevspr_pct,map_long.base_pct) BETWEEN 25 AND 49 THEN 2
        WHEN r.year_in_network > 1 AND COALESCE(map_long.prevspr_pct,map_long.base_pct) BETWEEN 50 AND 74 THEN 3
        WHEN r.year_in_network > 1 AND COALESCE(map_long.prevspr_pct,map_long.base_pct) >= 75 THEN 4                
       END AS base_quartile
      ,CASE 
        WHEN map_long.pct BETWEEN 0 AND 24 THEN 1
        WHEN map_long.pct BETWEEN 25 AND 49 THEN 2
        WHEN map_long.pct BETWEEN 50 AND 74 THEN 3
        WHEN map_long.pct >= 75 THEN 4                
       END AS term_quartile
      ,CONVERT(INT,map_curr.testritscore) AS cur_rit       
      ,CONVERT(INT,map_curr.percentile_2011_norms) AS cur_pct       
      ,CONVERT(INT,REPLACE(map_curr.rittoreadingscore, 'BR', 0)) AS cur_lex
      ,CASE WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL ELSE map_long.rit - map_long.base_rit END AS term_rit_growth
      ,CASE WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL ELSE map_long.pct - map_long.base_pct END AS term_pct_growth
      ,CASE WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL ELSE map_long.lex - map_long.base_lex END AS term_lex_growth
      ,CASE 
        WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL
        WHEN r.year_in_network = 1 THEN map_long.rit - map_long.base_rit
        ELSE map_long.rit - map_long.prevspr_rit         
       END AS term_rit_growth_prevspr
      ,CASE 
        WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL         
        WHEN r.year_in_network = 1 THEN map_long.pct - map_long.base_pct
        ELSE map_long.pct - map_long.prevspr_pct         
       END AS term_pct_growth_prevspr
      ,CASE 
        WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL 
        WHEN r.year_in_network = 1 THEN map_long.lex - map_long.base_lex        
        ELSE map_long.lex - map_long.prevspr_lex
       END AS term_lex_growth_prevspr
      ,CONVERT(INT,map_curr.testritscore) - map_long.base_rit AS ytd_rit_growth
      ,CONVERT(INT,map_curr.percentile_2011_norms) - map_long.base_pct AS ytd_pct_growth
      ,CONVERT(INT,REPLACE(map_curr.rittoreadingscore, 'BR', 0)) - map_long.base_lex AS ytd_lex_growth
      ,CASE 
        WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL
        WHEN r.year_in_network = 1 THEN CONVERT(INT,map_curr.testritscore) - map_long.base_rit
        ELSE CONVERT(INT,map_curr.testritscore) - map_long.prevspr_rit         
       END AS ytd_rit_growth_prevspr
      ,CASE 
        WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL         
        WHEN r.year_in_network = 1 THEN CONVERT(INT,map_curr.percentile_2011_norms) - map_long.base_pct
        ELSE CONVERT(INT,map_curr.percentile_2011_norms) - map_long.prevspr_pct         
       END AS ytd_pct_growth_prevspr
      ,CASE 
        WHEN map_long.term IN ('Fall','Baseline','Previous Spring') THEN NULL 
        WHEN r.year_in_network = 1 THEN CONVERT(INT,REPLACE(map_curr.rittoreadingscore, 'BR', 0)) - map_long.base_lex        
        ELSE CONVERT(INT,REPLACE(map_curr.rittoreadingscore, 'BR', 0)) - map_long.prevspr_lex
       END AS ytd_lex_growth_prevspr
      ,CONVERT(INT,map_curr.percentile_2011_norms) - 75 AS dist_from_75
      ,CASE WHEN map_long.year = map_curr.academic_year AND map_long.term = map_curr.term THEN 1 ELSE 0 END AS is_current
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.teacher_name AS teacher
      ,enr.teacher_coach
      ,enr.period      
      ,NULL AS read_lvl 
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
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr WITH(NOLOCK)
  ON r.studentid = enr.STUDENTID
 AND r.year = enr.academic_year
 AND subjects.measurementscale = enr.measurementscale 
LEFT OUTER JOIN illuminate_groups ill WITH(NOLOCK)
  ON r.student_number = ill.student_number
 AND r.year = ill.academic_year 
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_curr WITH(NOLOCK)          
  ON r.studentid = map_curr.studentid
 AND r.year = map_curr.academic_year
 AND subjects.measurementscale = map_curr.measurementscale
 AND map_curr.rn_curr_yr = 1
WHERE r.year >= 2008 /* first year of MAP data */
  AND r.schoolid != 999999
  AND r.rn = 1