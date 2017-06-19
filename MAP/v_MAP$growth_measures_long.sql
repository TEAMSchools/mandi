USE KIPP_NJ 
GO

ALTER VIEW MAP$growth_measures_long AS

WITH base AS (
  SELECT cohort.studentid
        ,cohort.grade_level
        ,cohort.schoolid
        ,cohort.year
        ,cohort.cohort
        ,cohort.year_in_network
        ,periods.start_term_numeric
        ,periods.end_term_numeric
        ,periods.period_numeric
        ,periods.lookback_modifier
        ,periods.start_term_string
        ,periods.end_term_string
        ,periods.period_string
        ,periods.goal_prorater
        ,periods.measurementscale  
        ,cohort.year AS period_start_year
        ,cohort.year + periods.lookback_modifier AS period_end_year
  FROM KIPP_NJ..COHORT$comprehensive_long#static cohort WITH(NOLOCK)    
  CROSS JOIN KIPP_NJ..AUTOLOAD$GDOCS_MAP_growth_terms periods WITH(NOLOCK)       
  WHERE cohort.grade_level <= 12
    AND cohort.rn = 1
 )

SELECT growth_index.studentid
      ,growth_index.grade_level
      ,growth_index.schoolid
      ,growth_index.year
      ,growth_index.cohort
      ,growth_index.year_in_network
      ,growth_index.start_term_numeric
      ,growth_index.end_term_numeric
      ,growth_index.period_numeric
      ,growth_index.lookback_modifier
      ,growth_index.start_term_string
      ,growth_index.end_term_string
      ,growth_index.period_string
      ,growth_index.goal_prorater
      ,growth_index.measurementscale
      ,growth_index.start_rit
      ,growth_index.end_rit
      ,growth_index.start_npr
      ,growth_index.end_npr
      ,growth_index.start_lex
      ,growth_index.end_lex
      ,growth_index.rit_change
      ,growth_index.lexile_change
      ,growth_index.start_grade_verif
      ,growth_index.end_grade_verif
      ,growth_index.start_term_verif
      ,growth_index.end_term_verif
      ,growth_index.reported_growth_projection
      ,growth_index.true_growth_projection
      ,growth_index.std_dev_of_growth_projection
      ,growth_index.valid_observation
      ,growth_index.met_typical_growth_target
      ,growth_index.met_typical_growth_target_str
      ,growth_index.growth_index
      ,growth_index.cgi      
      ,CASE
        WHEN cgi < -3.99 THEN 0.001
        WHEN cgi > 6 THEN 99.999
        ELSE zscores.percentile 
       END AS growth_percentile
FROM
    (
     SELECT with_map.studentid
           ,with_map.grade_level
           ,with_map.schoolid
           ,with_map.year
           ,with_map.cohort
           ,with_map.year_in_network
           ,with_map.start_term_numeric
           ,with_map.end_term_numeric
           ,with_map.period_numeric
           ,with_map.lookback_modifier
           ,with_map.start_term_string
           ,with_map.end_term_string
           ,with_map.period_string
           ,with_map.goal_prorater
           ,with_map.measurementscale
           ,with_map.start_rit
           ,with_map.end_rit
           ,with_map.start_npr
           ,with_map.end_npr
           ,with_map.start_lex
           ,with_map.end_lex
           ,with_map.rit_change
           ,with_map.lexile_change
           ,with_map.start_grade_verif
           ,with_map.end_grade_verif
           ,with_map.start_term_verif
           ,with_map.end_term_verif
           ,with_map.reported_growth_projection
           ,with_map.true_growth_projection
           ,with_map.std_dev_of_growth_projection
           ,CASE WHEN rit_change IS NOT NULL THEN 1 ELSE 0 END AS valid_observation
           ,CASE
             WHEN rit_change IS NULL THEN NULL
             WHEN rit_change >= reported_growth_projection THEN 1
             WHEN rit_change < reported_growth_projection THEN 0
            END AS met_typical_growth_target
           ,CASE
             WHEN rit_change IS NULL THEN NULL
             WHEN rit_change >= reported_growth_projection THEN 'Yes'
             WHEN rit_change < reported_growth_projection THEN 'No'
            END AS met_typical_growth_target_str
           ,rit_change - reported_growth_projection AS growth_index
           ,ROUND((CASE WHEN period_string = 'Spring to half-of-Spring' THEN rit_change * 2 ELSE rit_change END - true_growth_projection) / std_dev_of_growth_projection,2) AS cgi
     FROM
         (
          SELECT base.studentid
                ,base.grade_level
                ,base.schoolid
                ,base.year
                ,base.cohort
                ,base.year_in_network
                ,base.start_term_numeric
                ,base.end_term_numeric
                ,base.period_numeric
                ,base.lookback_modifier
                ,base.start_term_string
                ,base.end_term_string
                ,base.period_string
                ,base.goal_prorater
                ,base.measurementscale
                ,map_start.testritscore AS start_rit
                ,map_end.testritscore AS end_rit
                ,map_start.percentile_2015_norms AS start_npr
                ,map_end.percentile_2015_norms AS end_npr
                ,map_start.rittoreadingscore AS start_lex
                ,map_end.rittoreadingscore AS end_lex
                ,map_end.testritscore - map_start.testritscore AS rit_change
                ,CASE 
                   WHEN map_end.rittoreadingscore IN ('BR', '<100') THEN 0 
                   ELSE CONVERT(INT,map_end.rittoreadingscore) 
                 END - 
                 CASE 
                   WHEN map_start.rittoreadingscore IN ('BR','<100') THEN 0 
                   ELSE CONVERT(INT,map_start.rittoreadingscore) 
                 END AS lexile_change
                ,map_start.grade_level AS start_grade_verif
                ,map_end.grade_level AS end_grade_verif
                ,map_start.termname AS start_term_verif
                ,map_end.termname AS end_term_verif
                /* norm study data */
                ,norms.reported_student_growth AS reported_growth_projection
                ,norms.typical_student_growth AS true_growth_projection
                ,norms.sd_of_expectation AS std_dev_of_growth_projection
          FROM base
          /* data for START of target period */
          LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_start WITH(NOLOCK)
            ON base.studentid = map_start.studentid
           AND base.measurementscale = map_start.measurementscale
           AND base.period_start_year = map_start.academic_year
           AND base.start_term_string = map_start.term
           AND map_start.rn = 1
          /* data for END of target period */
          LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map_end WITH(NOLOCK)
            ON base.studentid = map_end.studentid
           AND base.measurementscale = map_end.measurementscale
           AND base.period_end_year = map_end.academic_year
           AND base.end_term_string = map_end.term
           AND map_end.rn = 1
          /* norms data */
          LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_MAP_student_growth_norms norms WITH(NOLOCK)
            ON base.measurementscale = norms.measurementscale           
           AND base.start_term_string = norms.start_term
           AND base.end_term_string = norms.end_term
           AND map_start.testritscore = norms.start_rit
           AND map_start.grade_level = norms.start_grade
         ) with_map
    ) growth_index
LEFT OUTER JOIN KIPP_NJ..UTIL$zscores zscores WITH(NOLOCK)
  ON ROUND(CONVERT(DECIMAL(4,2),growth_index.cgi), 2) = ROUND(CONVERT(DECIMAL(4,2),zscores.zscore), 2)