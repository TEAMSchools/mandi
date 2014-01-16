USE KIPP_NJ
GO

ALTER VIEW MAP$cohort_performance_targets AS
WITH zscore AS
    (SELECT *
     FROM OPENQUERY(KIPP_NWK,
       'SELECT z.zscore
              ,z.percentile
        FROM
             (SELECT zscore
                    ,percentile
                    ,row_number() OVER
                       (PARTITION BY percentile
                        ORDER BY zscore ASC
                        ) AS rn
              FROM ZSCORES
              WHERE (MOD(percentile, 1) = 0 OR percentile = 99.9 OR percentile = 99.99 OR percentile = 99.999)
              ) z
        WHERE rn = 1'
       )
   )

   ,cohort_norms AS
   (SELECT *
     FROM OPENQUERY(KIPP_NWK,
       'SELECT *
        FROM map_rit_mean_sd norms
        WHERE term = ''Spring-to-Spring''
       '
       )
   )

   ,cohort AS
     (SELECT c.studentid
            ,c.lastfirst
            ,c.grade_level
            ,c.year
            ,CASE 
               WHEN cust.spedlep LIKE 'SPED%' THEN 'IEP'
               ELSE 'Gen Ed'
             END AS iep_status
            ,sch.abbreviation AS school
      FROM KIPP_NJ..COHORT$comprehensive_long#static c
      JOIN KIPP_NJ..SCHOOLS sch
        ON c.schoolid = sch.school_number
      JOIN KIPP_NJ..CUSTOM_STUDENTS cust
        ON c.studentid = cust.studentid
      WHERE c.year = 2013
        AND c.rn = 1
        AND c.schoolid != 999999)

    ,map_baseline AS
    (SELECT map.*
           ,CASE
               WHEN map.measurementscale = 'Mathematics' THEN 'MATH'
               WHEN map.measurementscale = 'Reading' THEN 'ENG'
               WHEN map.measurementscale = 'Language Usage' THEN 'RHET'
               WHEN map.measurementscale = 'Science - General Science' THEN 'SCI'
            END AS join_credittype
     FROM KIPP_NJ..MAP$baseline_composite#static map
     WHERE map.year = 2013)

    --SWITCH THIS AS THE YEAR PROGRESSES eg winter, spring
    ,map_endpoint AS
    (SELECT map_end.*
           ,sch.abbreviation AS school
     FROM KIPP_NJ..MAP$comprehensive#identifiers map_end
     JOIN KIPP_NJ..SCHOOLS sch
       ON map_end.schoolid = sch.school_number
     WHERE map_end.map_year_academic = 2013
       AND map_end.rn = 1
       --SWITCH THIS AS THE YEAR PROGRESSES eg winter, spring
       AND map_end.fallwinterspring = 'Winter')

    ,cc AS
    (SELECT last_tch.*
           ,courses.credittype
     FROM KIPP_NJ..CC c
     JOIN PS$teacher_by_last_enrollment last_tch
       ON c.studentid = last_tch.studentid
      AND c.course_number = last_tch.course_number
     JOIN KIPP_NJ..COURSES
       ON c.course_number = courses.course_number
     WHERE c.dateenrolled <= CAST(GETDATE() AS date)
       AND c.dateleft >= CAST(GETDATE() AS date)
     ) 

--LOOSE method
SELECT sub.school
      ,sub.grade_level
      ,sub.year
      ,sub.iep_status
      ,sub.measurementscale
      ,sub.avg_baseline_rit
      ,sub.avg_baseline_percentile
      ,sub.N
      ,sub.comparison_start_rit
      ,sub.mean
      ,sub.sd
      ,'loose' AS roster_match_method
      ,CAST(zscore.percentile AS FLOAT) AS cohort_growth_percentile
      ,zscore.zscore
      ,CAST(ROUND((zscore.zscore * sub.sd) + (sub.mean), 1) AS float) AS target_rit_change
      ,CAST(ROUND((zscore.zscore * sub.sd) + (sub.avg_baseline_rit + sub.mean), 1) AS float) AS target_spr_rit
      ,loose_agg.avg_cur_endpoint_rit
      ,loose_agg.avg_cur_endpoint_percentile
FROM
       --join to norms table, get diff
      (SELECT sub.*
             ,cohort_norms.rit AS comparison_start_rit
             ,cohort_norms.mean
             ,cohort_norms.sd
             ,ROW_NUMBER() OVER
                (PARTITION BY sub.school
                             ,sub.grade_level
                             ,sub.year
                             ,sub.iep_status
                             ,sub.measurementscale
                 ORDER BY ABS(avg_baseline_rit - cohort_norms.rit)
                ) AS rn
       FROM
             (SELECT sub.school
                    ,sub.grade_level
                    ,sub.year
                    ,CASE GROUPING(sub.iep_status)
                       WHEN 1 THEN 'All Students'
                       ELSE sub.iep_status
                     END AS iep_status
                    ,sub.measurementscale
                    ,CAST(ROUND(AVG(testritscore + 0.0),2) AS FLOAT) AS avg_baseline_rit
                    ,CAST(ROUND(AVG(testpercentile + 0.0),1) AS FLOAT) AS avg_baseline_percentile
                    ,COUNT(*) AS N
              FROM
                    (SELECT cohort.*
                           ,map_baseline.measurementscale
                           ,map_baseline.termname
                           ,map_baseline.testritscore
                           ,map_baseline.testpercentile
                     FROM cohort
                     JOIN map_baseline
                       ON cohort.studentid = map_baseline.studentid
                     ) sub
              GROUP BY sub.school
                      ,sub.grade_level
                      ,sub.year
                      ,CUBE(sub.iep_status)
                      ,sub.measurementscale
              ) sub
       JOIN cohort_norms
         ON sub.grade_level = cohort_norms.grade
        AND sub.measurementscale = cohort_norms.subject
       ) sub
LEFT OUTER JOIN 
  (SELECT sub.year
         ,sub.school
         ,sub.measurementscale
         ,sub.grade_level
         ,CASE GROUPING(sub.iep_status)
            WHEN 1 THEN 'All Students'
            ELSE sub.iep_status
          END AS iep_status
         ,CAST(ROUND(AVG(sub.testritscore + 0.0),2) AS FLOAT) AS avg_cur_endpoint_rit
         ,ROUND(AVG(CAST(sub.testpercentile AS FLOAT) + 0.0),1) AS avg_cur_endpoint_percentile
   FROM
         (SELECT map_endpoint.map_year_academic AS year
                ,map_endpoint.school
                ,map_endpoint.measurementscale
                ,map_endpoint.grade_level
                ,CASE 
                   WHEN cust.spedlep LIKE 'SPED%' THEN 'IEP'
                   ELSE 'Gen Ed'
                 END AS iep_status
                ,map_endpoint.testritscore
                ,map_endpoint.testpercentile
          FROM map_endpoint
          JOIN KIPP_NJ..CUSTOM_STUDENTS cust
            ON map_endpoint.ps_studentid = cust.studentid
         ) sub
   GROUP BY sub.year
           ,sub.school
           ,sub.measurementscale
           ,sub.grade_level
           ,CUBE(sub.iep_status)
  ) loose_agg
  ON sub.year = loose_agg.year
 AND sub.school = loose_agg.school
 AND sub.measurementscale = loose_agg.measurementscale
 AND sub.grade_level = loose_agg.grade_level
 AND sub.iep_status = loose_agg.iep_status
JOIN zscore
  ON 1=1
WHERE rn = 1

UNION ALL

--STRICT method
SELECT sub.school
      ,sub.grade_level
      ,sub.year
      ,sub.iep_status
      ,sub.measurementscale
      ,sub.avg_baseline_rit
      ,sub.avg_baseline_percentile
      ,sub.N
      ,sub.comparison_start_rit
      ,sub.mean
      ,sub.sd
      ,'strict' AS roster_match_method
      ,CAST(zscore.percentile AS FLOAT) AS cohort_growth_percentile
      ,zscore.zscore
      ,CAST(ROUND((zscore.zscore * sub.sd) + (sub.mean), 1) AS float) AS target_rit_change
      ,CAST(ROUND((zscore.zscore * sub.sd) + (sub.avg_baseline_rit + sub.mean), 1) AS float) AS target_spr_rit
      ,sub.avg_cur_endpoint_rit
      ,sub.avg_cur_endpoint_percentile
FROM
       --join to norms table, get diff
      (SELECT sub.*
             ,cohort_norms.rit AS comparison_start_rit
             ,cohort_norms.mean
             ,cohort_norms.sd
             ,ROW_NUMBER() OVER
                (PARTITION BY sub.school
                             ,sub.grade_level
                             ,sub.year
                             ,sub.iep_status
                             ,sub.measurementscale
                 ORDER BY ABS(avg_baseline_rit - cohort_norms.rit)
                ) AS rn
       FROM
             (SELECT sub.school
                    ,sub.grade_level
                    ,sub.year
                    ,CASE GROUPING(sub.iep_status)
                       WHEN 1 THEN 'All Students'
                       ELSE sub.iep_status
                     END AS iep_status
                    ,sub.measurementscale
                    ,CAST(ROUND(AVG(testritscore + 0.0),2) AS FLOAT) AS avg_baseline_rit
                    ,CAST(ROUND(AVG(testpercentile + 0.0),1) AS FLOAT) AS avg_baseline_percentile
                    ,CAST(ROUND(AVG(cur_endpoint_rit + 0.0),2) AS FLOAT) AS avg_cur_endpoint_rit
                    ,ROUND(AVG(CAST(cur_endpoint_percentile AS FLOAT) + 0.0),1) AS avg_cur_endpoint_percentile
                    ,COUNT(*) AS N
              FROM
                    (SELECT cohort.*
                           ,map_baseline.measurementscale
                           ,map_baseline.termname
                           ,map_baseline.testritscore
                           ,map_baseline.testpercentile
                           ,map_endpoint.testritscore AS cur_endpoint_rit
                           ,map_endpoint.testpercentile AS cur_endpoint_percentile
                     FROM cohort
                     JOIN map_baseline
                       ON cohort.studentid = map_baseline.studentid
                     --STRICT only returns students with test events in both terms
                     JOIN map_endpoint
                       ON cohort.STUDENTID = map_endpoint.ps_studentid
                      AND map_baseline.measurementscale = map_endpoint.measurementscale
                      AND map_baseline.testritscore IS NOT NULL
                     ) sub
              GROUP BY sub.school
                      ,sub.grade_level
                      ,sub.year
                      ,CUBE(sub.iep_status)
                      ,sub.measurementscale
              ) sub
       JOIN cohort_norms
         ON sub.grade_level = cohort_norms.grade
        AND sub.measurementscale = cohort_norms.subject
       ) sub
JOIN zscore
  ON 1=1
WHERE rn = 1
