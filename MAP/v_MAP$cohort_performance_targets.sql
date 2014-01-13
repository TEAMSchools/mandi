USE KIPP_NJ
GO

CREATE VIEW MAP$cohort_performance_targets AS
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

SELECT sub.*
      ,CAST(zscore.percentile AS FLOAT) AS cohort_growth_percentile
      ,zscore.zscore
      ,CAST(ROUND((zscore.zscore * sub.sd) + (sub.avg_baseline_rit + sub.mean), 1) AS float) AS target_spr_rit
FROM
       --join to norms table, get diff
      (SELECT sub.*
             ,cohort_norms.rit AS comparison_start_rit
             ,cohort_norms.mean
             ,cohort_norms.sd
             ,ROW_NUMBER() OVER
                (PARTITION BY sub.school
                             ,sub.grade_level
                             ,sub.iep_status
                             ,sub.measurementscale
                 ORDER BY ABS(avg_baseline_rit - cohort_norms.rit)
                ) AS rn
       FROM
             (SELECT sub.school
                    ,sub.grade_level
                    ,CASE GROUPING(sub.iep_status)
                       WHEN 1 THEN 'All Students'
                       ELSE sub.iep_status
                     END AS iep_status
                    ,sub.measurementscale
                    ,CAST(ROUND(AVG(testritscore + 0.0),1) AS FLOAT) AS avg_baseline_rit
                    ,COUNT(*) AS N
              FROM
                     (SELECT cohort.*
                           ,map_baseline.year
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