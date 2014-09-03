USE KIPP_NJ
GO

ALTER VIEW MAP$cohort_growth_scores AS
WITH zscore AS
    (SELECT *
     FROM OPENQUERY(KIPP_NWK,
       'SELECT zscore
              ,percentile
        FROM ZSCORES'
       )
   )
   ,cohort_norms AS
   (SELECT *
     FROM OPENQUERY(KIPP_NWK,
       'SELECT *
        FROM map_rit_mean_sd norms
        WHERE (term = ''Spring-to-Spring'') OR (grade = 0 AND term = ''Fall-to-Spring'')
       '
       ) sub
   )
   ,cohort AS
     (SELECT c.studentid
            ,c.lastfirst
            ,c.grade_level
            ,c.year
            ,c.abbreviation AS year_abbreviation
            ,c.cohort
            ,CASE 
               WHEN cust.spedlep LIKE 'SPED%' THEN 'IEP'
               ELSE 'Gen Ed'
             END AS iep_status
            ,sch.abbreviation AS school
      FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
      JOIN KIPP_NJ..SCHOOLS sch
        ON c.schoolid = sch.school_number
      JOIN KIPP_NJ..CUSTOM_STUDENTS cust WITH (NOLOCK)
        ON c.studentid = cust.studentid
      WHERE c.rn = 1
        AND c.schoolid != 999999
        AND c.year < 2014
     )
    ,map_results AS
      (SELECT m.studentid
             ,m.year
             ,m.measurementscale
             ,m.period_string
             ,m.start_rit
             ,m.end_rit
             ,m.start_npr
             ,m.end_npr
             ,m.rit_change
             ,m.end_npr - m.start_npr AS npr_change
             ,m.met_typical_growth_target
             ,m.cgi
             ,m.growth_percentile
             ,ROW_NUMBER () OVER 
               (PARTITION BY m.studentid
                            ,m.year
                            ,m.measurementscale
                ORDER BY m.period_numeric ASC
               ) AS rn
       FROM KIPP_NJ..MAP$growth_measures_long#static m
       WHERE m.period_string IN ('Fall to Spring', 'Spring to Spring')
         AND m.valid_observation = 1
       )
SELECT sub.*
      ,CAST((rit_change - mean) / sd AS decimal(4,2)) AS z_score
      ,CASE 
         WHEN CAST((rit_change - mean) / sd AS decimal(4,2)) < -4 THEN 0.01
         WHEN CAST((rit_change - mean) / sd AS decimal(4,2)) > 6 THEN 99.999
         ELSE zscore.percentile
       END AS cohort_growth_percentile
FROM
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
                 ORDER BY ABS(sub.start_rit - cohort_norms.rit)
                ) AS rn
       FROM
             (SELECT TOP 1000000 cohort.school
                    ,cohort.year
                    ,cohort.year_abbreviation
                    ,cohort.grade_level
                    ,cohort.cohort
                    ,CASE GROUPING(cohort.iep_status)
                       WHEN 1 THEN 'All Students'
                       ELSE cohort.iep_status
                     END AS iep_status
                    ,m.measurementscale
                    ,COUNT(*) AS n
                    ,CAST(AVG(m.start_rit + 0.0) AS decimal(4,1)) AS start_rit
                    ,CAST(AVG(m.end_rit + 0.0) AS decimal(4,1))  AS end_rit
                    ,CAST(AVG(m.start_npr + 0.0) AS decimal(4,1)) AS start_npr
                    ,CAST(AVG(m.end_npr + 0.0) AS decimal(4,1)) AS end_npr
                    ,CAST(AVG(m.rit_change + 0.0) AS decimal(4,1)) AS rit_change
                    ,CAST(AVG(m.npr_change + 0.0) AS decimal(3,1)) AS npr_change
                    ,CAST(AVG(m.met_typical_growth_target + 0.0) * 100 AS decimal(4,1)) AS met_typ
                    ,CAST(AVG(m.cgi) AS decimal(4,2)) AS cgi
                    ,CAST(AVG(m.growth_percentile) AS decimal(4,1)) AS sgp 
              FROM cohort
              JOIN map_results m
                ON cohort.studentid = m.studentid
               AND cohort.year = m.year
               AND m.rn = 1
              GROUP BY cohort.school
                      ,cohort.year
                      ,cohort.year_abbreviation
                      ,cohort.grade_level
                      ,cohort.cohort
                      ,CUBE(cohort.iep_status)
                      ,m.measurementscale
              ORDER BY cohort.year DESC
                      ,cohort.school
                      ,m.measurementscale
                      ,cohort.grade_level
              ) sub
       LEFT OUTER JOIN cohort_norms
         ON sub.grade_level = cohort_norms.grade
        AND sub.measurementscale = cohort_norms.subject
       ) sub
LEFT OUTER JOIN zscore
  ON CAST((rit_change - mean) / sd AS decimal(4,2)) = zscore.zscore
WHERE rn = 1
