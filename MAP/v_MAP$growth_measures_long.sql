USE KIPP_NJ 
GO

ALTER VIEW MAP$growth_measures_long AS

WITH scales AS (
  SELECT 'Mathematics' AS measurementscale
  UNION ALL
  SELECT 'Reading'
  UNION ALL
  SELECT 'Language Usage'
  UNION ALL
  SELECT 'Concepts and Processes'
  UNION ALL
  SELECT 'Science - General Science'
 )

-- assembles scaffold
,base AS (
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
        ,scales.measurementscale  
        ,cohort.year + periods.lookback_modifier AS period_start_year
  FROM KIPP_NJ..COHORT$comprehensive_long#static cohort WITH(NOLOCK)    
  CROSS JOIN KIPP_NJ..MAP$growth_terms#lookup periods WITH(NOLOCK)    
  CROSS JOIN scales    
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
           ,ROUND(
             (CASE WHEN period_string = 'Spring to half-of-Spring' THEN rit_change * 2 ELSE rit_change END - true_growth_projection) / std_dev_of_growth_projection
             ,2) AS cgi
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
                ,map_start.percentile_2011_norms AS start_npr
                ,map_end.percentile_2011_norms AS end_npr
                ,map_start.rittoreadingscore AS start_lex
                ,map_end.rittoreadingscore AS end_lex
                ,map_end.testritscore - map_start.testritscore AS rit_change
                ,CASE 
                   WHEN map_end.rittoreadingscore = 'BR' THEN 0 
                   ELSE CONVERT(INT,map_end.rittoreadingscore) 
                 END - 
                 CASE 
                   WHEN map_start.rittoreadingscore = 'BR' THEN 0 
                   ELSE CONVERT(INT,map_start.rittoreadingscore) 
                 END AS lexile_change
                ,map_start.grade_level AS start_grade_verif
                ,map_end.grade_level AS end_grade_verif
                ,map_start.termname AS start_term_verif
                ,map_end.termname AS end_term_verif
                --norm study data
                ,CASE
                  WHEN base.period_numeric = 42 THEN norms.r42
                  WHEN base.period_numeric = 22 THEN norms.r22
                  WHEN base.period_numeric = 44 THEN norms.r44
                  WHEN base.period_numeric = 41 THEN norms.r41
                  WHEN base.period_numeric = 12 THEN norms.r12
                 END AS reported_growth_projection
                ,CASE
                  WHEN base.period_numeric = 42 THEN norms.t42
                  WHEN base.period_numeric = 22 THEN norms.t22
                  WHEN base.period_numeric = 44 THEN norms.t44
                  WHEN base.period_numeric = 41 THEN norms.t41
                  WHEN base.period_numeric = 12 THEN norms.t12
                 END AS true_growth_projection
                ,CASE
                  WHEN base.period_numeric = 42 THEN norms.s42
                  WHEN base.period_numeric = 22 THEN norms.s22
                  WHEN base.period_numeric = 44 THEN norms.s44
                  WHEN base.period_numeric = 41 THEN norms.s41
                  WHEN base.period_numeric = 12 THEN norms.s12
                 END AS std_dev_of_growth_projection
          FROM base
          --data for START of target period
          LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_start WITH(NOLOCK)
            ON base.studentid = map_start.ps_studentid
           AND base.measurementscale = map_start.measurementscale
           AND base.period_start_year = map_start.map_year_academic
           AND base.start_term_string = map_start.fallwinterspring
           AND map_start.rn = 1
          --data for END of target period
          LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_end WITH(NOLOCK)
            ON base.studentid = map_end.ps_studentid
           AND base.measurementscale = map_end.measurementscale
           AND base.year = map_end.map_year_academic
           AND base.end_term_string = map_end.fallwinterspring
           AND map_end.rn = 1
          --norms data
          LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data_extended#2011 norms WITH(NOLOCK)
            ON base.measurementscale = CASE WHEN norms.subject IN ('General Science', 'Concepts and Processes') THEN 'Science - ' + norms.subject ELSE norms.SUBJECT END 
           AND map_start.testritscore = norms.startrit
           AND map_start.grade_level = norms.startgrade              
         ) with_map
    ) growth_index
LEFT OUTER JOIN KIPP_NJ..UTIL$zscores zscores WITH(NOLOCK)
  ON CAST(ROUND(growth_index.cgi, 2) AS decimal(4,2)) = CAST(ROUND(zscores.zscore, 2) AS decimal(4,2))