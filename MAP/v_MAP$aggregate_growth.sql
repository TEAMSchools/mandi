USE KIPP_NJ
GO

ALTER VIEW MAP$aggregate_growth AS
WITH map_base AS 
    (SELECT m.*
     FROM KIPP_NJ..MAP$growth_measures_long#static m
     WHERE m.year >= 2011 AND (
         (m.year_in_network=1 AND m.period_string = 'Fall to Spring') OR
         (m.year_in_network>1 AND m.period_string = 'Spring to Spring')
       ) 
     --AND m.measurementscale IN ('Mathematics', 'Reading')
     AND m.valid_observation = 1
    )
SELECT sub.year
      ,sub.grade_level
      ,sub.cohort
      ,sub.measurementscale
      ,CASE GROUPING(sub.schoolid) WHEN 1 THEN 0 ELSE sub.schoolid END AS schoolid
      ,CAST(ROUND(AVG(start_rit + 0.0),1) AS NUMERIC(4,1)) AS avg_start
      ,CAST(ROUND(AVG(end_rit + 0.0),1) AS NUMERIC(4,1)) AS avg_end
      ,CAST(ROUND(AVG(met_typical_growth_target + 0.0) * 100, 1) AS NUMERIC(4,1)) AS pct_keep_up
      ,CAST(ROUND(AVG(met_rr_dummy + 0.0) * 100, 1) AS NUMERIC(4,1)) AS pct_rr
      ,CAST(ROUND(AVG(CASE WHEN end_npr >= 75 THEN 1 WHEN end_npr < 75 THEN 0.0 END) * 100, 1) AS NUMERIC(4,1)) AS pct_above_75th_npr      
      ,CAST(ROUND(AVG(CASE WHEN end_proj_ACT >= 21 AND grade_level >= 3 THEN 1.0 WHEN end_proj_ACT < 21 AND grade_level >= 3 THEN 0.0 END) * 100, 1) AS NUMERIC(4,1)) AS pct_ontrack_act21
      ,CAST(ROUND(AVG(CASE WHEN end_proj_ACT >= 23 AND grade_level >= 3 THEN 1.0 WHEN end_proj_ACT < 23 AND grade_level >= 3 THEN 0.0 END) * 100, 1) AS NUMERIC(4,1)) AS pct_ontrack_act23
      ,CAST(AVG(growth_percentile) AS NUMERIC(4,1)) AS avg_sgp
FROM
      (SELECT map_base.*
             ,rr.rutgers_ready_goal
             ,rr.rutgers_ready_rit
             ,CASE WHEN map_base.end_rit >= rr.rutgers_ready_rit THEN 1 WHEN map_base.end_rit < rr.rutgers_ready_rit THEN 0 END AS met_rr_dummy
             ,CASE
                --MATH ACT model
                WHEN map_base.measurementscale = 'Mathematics'
                  THEN round(-28.193 --intercept
                    + (0.307 * CAST(map_base.end_rit AS FLOAT)) 
                    + ( (-4.256 * map_base.grade_level) + (0.183 * (map_base.grade_level * map_base.grade_level))  ) 
                    + CASE
                        WHEN map_base.end_term_string = 'Fall' THEN 0
                        WHEN map_base.end_term_string = 'Winter' THEN -1.173  --half of Spring
                        WHEN map_base.end_term_string = 'Spring' THEN -2.346 
                        ELSE NULL
                      END
                         ,0)
                --READING ACT model
                WHEN map_base.measurementscale = 'Reading'
                  THEN round(-52.748 --intercept
                    + (0.417 * map_base.end_rit )
                    + ( (-3.433 * map_base.grade_level) + (0.132 * (map_base.grade_level * map_base.grade_level))  )
                    + CASE
                        WHEN map_base.end_term_string = 'Fall' THEN 0
                        WHEN map_base.end_term_string = 'Winter' THEN -0.829  --half of Spring
                        WHEN map_base.end_term_string = 'Spring' THEN -1.655
                        ELSE NULL
                      END
                         ,0)
                ELSE NULL
              END AS end_proj_ACT
       FROM map_base
       LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals rr
         ON map_base.studentid = rr.studentid
        AND map_base.measurementscale = rr.measurementscale
        AND map_base.year = rr.year
       ) sub
GROUP BY sub.year
        ,sub.grade_level
        ,sub.cohort
        ,sub.measurementscale
        ,CUBE(sub.schoolid)