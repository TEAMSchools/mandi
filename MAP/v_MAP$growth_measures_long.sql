USE KIPP_NJ 
GO

ALTER VIEW MAP$growth_measures_long AS
WITH cohort AS
     (SELECT cohort.studentid
            ,cohort.grade_level
            ,cohort.schoolid
            ,cohort.year
            ,cohort.cohort
            ,cohort.year_in_network
      FROM KIPP_NJ..COHORT$comprehensive_long#static cohort
      WHERE cohort.grade_level <= 12
        AND cohort.rn = 1
      )

    ,periods AS
     (SELECT 4 AS start_term_numeric
            ,2 AS end_term_numeric
            ,42 AS period_numeric
            ,0 AS lookback_modifier
            ,'Fall' AS start_term_string
            ,'Spring' AS end_term_string
            ,'Fall to Spring' AS period_string
            ,1 AS goal_prorater
      UNION ALL
      SELECT 2
            ,2
            ,22
            ,-1
            ,'Spring'
            ,'Spring'
            ,'Spring to Spring'
            ,1
      UNION ALL
      SELECT 4
            ,4
            ,44
            ,-1
            ,'Fall'
            ,'Fall'
            ,'Fall to Fall'
            ,1
      UNION ALL
      SELECT 4
            ,1
            ,41
            ,0
            ,'Fall'
            ,'Winter'
            ,'Fall to Winter'
            ,1
      UNION ALL
      SELECT 1
            ,2
            ,12
            ,0
            ,'Winter'
            ,'Spring'
            ,'Winter to Spring'
            ,1
      UNION ALL
      SELECT 2
            ,1
            ,22
            ,-1
            ,'Spring'
            ,'Winter'
            ,'Spring to half-of-Spring'
            ,0.5
      /*
      UNION ALL
      SELECT 2
            ,1
            ,22
            ,-1
            ,'Spring'
            ,'Winter'
            ,'Spring to psuedo-Spring (Spring goal, Winter actual)'
      UNION ALL
      SELECT 4
            ,1
            ,42
            ,0
            ,'Fall'
            ,'Winter'
            ,'Fall to psuedo-Spring (Spring goal, Winter actual)'
      */
      )

    ,scales AS
     (SELECT 'Mathematics' AS measurementscale
      UNION ALL
      SELECT 'Reading'
      UNION ALL
      SELECT 'Language Usage'
      UNION ALL
      SELECT 'Concepts and Processes'
      UNION ALL
      SELECT 'Science - General Science'
     )

SELECT growth_index.*
      ,CASE
         WHEN cgi < -3.99 THEN 0.001
         WHEN cgi > 6 THEN 99.999
         ELSE zscores.percentile 
       END AS growth_percentile
FROM
      (SELECT with_map.*
             ,CASE
                WHEN rit_change IS NOT NULL THEN 1
                ELSE 0
              END AS valid_observation
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
             ,ROUND((rit_change - true_growth_projection) / std_dev_of_growth_projection, 2) AS cgi
       FROM
             (SELECT base.*
                    ,map_start.testritscore AS start_rit
                    ,map_end.testritscore AS end_rit
                    ,map_start.percentile_2011_norms AS start_npr
                    ,map_end.percentile_2011_norms AS end_npr
                    ,map_end.testritscore - map_start.testritscore AS rit_change
                    ,map_start.grade_level AS start_grade_verif
                    ,map_end.grade_level AS end_grade_verif
                    ,map_start.termname AS start_term_verif
                    ,map_end.termname AS end_term_verif
                    --norm study data
                    ,CASE
                       WHEN base.period_numeric = 42 THEN norms.r42 * base.goal_prorater
                       WHEN base.period_numeric = 22 THEN norms.r22 * base.goal_prorater
                       WHEN base.period_numeric = 44 THEN norms.r44 * base.goal_prorater
                       WHEN base.period_numeric = 41 THEN norms.r41 * base.goal_prorater
                       WHEN base.period_numeric = 12 THEN norms.r12 * base.goal_prorater
                     END AS reported_growth_projection
                   ,CASE
                       WHEN base.period_numeric = 42 THEN norms.t42 * base.goal_prorater
                       WHEN base.period_numeric = 22 THEN norms.t22 * base.goal_prorater
                       WHEN base.period_numeric = 44 THEN norms.t44 * base.goal_prorater
                       WHEN base.period_numeric = 41 THEN norms.t41 * base.goal_prorater
                       WHEN base.period_numeric = 12 THEN norms.t12 * base.goal_prorater
                     END AS true_growth_projection
                    ,CASE
                       WHEN base.period_numeric = 42 THEN norms.s42
                       WHEN base.period_numeric = 22 THEN norms.s22
                       WHEN base.period_numeric = 44 THEN norms.s44
                       WHEN base.period_numeric = 41 THEN norms.s41
                       WHEN base.period_numeric = 12 THEN norms.s12
                     END AS std_dev_of_growth_projection
              FROM
                     --assembles scaffold of enrollments, goal periods, subjects
                    (SELECT cohort.*
                           ,periods.*
                           ,scales.*
                     FROM cohort
                     JOIN periods
                       ON 1=1
                     JOIN scales
                       ON 1=1
                     ) base
              --data for START of target period
              LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_start
                ON base.studentid = map_start.ps_studentid
               AND base.measurementscale = map_start.measurementscale
               AND (base.year + base.lookback_modifier) = map_start.map_year_academic
               AND base.start_term_string = map_start.fallwinterspring
               AND map_start.rn = 1
              --data for END of target period
              LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_end
                ON base.studentid = map_end.ps_studentid
               AND base.measurementscale = map_end.measurementscale
               AND base.year = map_end.map_year_academic
               AND base.end_term_string = map_end.fallwinterspring
               AND map_end.rn = 1
              --norms data
              LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data#2011 norms
                ON base.measurementscale = norms.subject
               AND map_start.testritscore = norms.startrit
               AND map_start.grade_level = norms.startgrade
              ) with_map
       ) growth_index
LEFT OUTER JOIN KIPP_NJ..UTIL$zscores zscores
  ON growth_index.cgi = zscores.zscore