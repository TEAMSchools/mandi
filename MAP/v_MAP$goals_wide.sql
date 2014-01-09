USE KIPP_NJ
GO

ALTER VIEW MAP$goals_wide AS
SELECT grade_level
      ,measurementscale AS subject
      ,iep_status
      ,course
      ,avg_baseline_rit
      ,avg_cohort_change
      ,cohort_sd
      /*
      ,rit_change_winter
      ,pctile_change_winter
      ,ontrack_keepup_pct
      ,ontrack_rr_pct
      --*/
      ,CONVERT(FLOAT,ROUND((p01_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p01_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p05_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p05_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p10_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p10_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p20_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p20_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p25_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p25_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p30_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p30_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p40_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p40_goal_spr_2013
      ,CONVERT(FLOAT,ROUND(avg_baseline_rit + avg_cohort_change,1)) AS p50_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p60_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p60_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p70_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p70_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p75_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p75_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p80_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p80_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p90_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p90_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p95_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p95_goal_spr_2013
      ,CONVERT(FLOAT,ROUND((p99_zscore * cohort_sd) + (avg_baseline_rit + avg_cohort_change),1)) AS p99_goal_spr_2013
FROM
     (
      SELECT sub_3.*
            ,norms.mean AS avg_cohort_change
            ,norms.sd AS cohort_sd
            ,ROW_NUMBER() OVER
               (PARTITION BY sub_3.grade_level, sub_3.measurementscale, sub_3.iep_status, sub_3.course
                    ORDER BY ABS(avg_baseline_rit - norms.rit) ASC) AS closest_match
      FROM
           (
            SELECT grade_level
                  ,measurementscale
                  ,CASE
                    WHEN GROUPING(iep_status) = 0 THEN iep_status
                    ELSE 'All Students'
                   END AS iep_status
                  ,CASE
                    WHEN GROUPING(match_course) = 0 THEN match_course
                    ELSE 'Whole Grade'
                   END AS course
                  ,ROUND(AVG(testritscore),1) AS avg_baseline_RIT
                  /*
                  ,AVG(rit_change_winter) AS rit_change_winter
                  ,AVG(pctile_change_winter) AS pctile_change_winter
                  ,CONVERT(FLOAT,ROUND(((SUM(ontrack_keepup) / COUNT(*)) * 100),1)) AS ontrack_keepup_pct
                  ,CONVERT(FLOAT,ROUND(((SUM(ontrack_rr) / COUNT(*)) * 100),1)) AS ontrack_rr_pct
                  --*/
            FROM
                 (
                  SELECT sub_1.measurementscale
                        ,sub_1.grade_level
                        ,enrollments.course_name AS match_course
                        ,enrollments.enr_hash AS match_section
                        ,CASE
                          WHEN sub_1.spedlep LIKE '%SPED%' THEN 'IEP'
                          ELSE 'No IEP'
                         END AS iep_status
                        ,sub_1.testritscore
                        ,sub_1.typical_growth_goal
                        ,sub_1.typical_growth_target                        
                        /*
                        ,rit_change_winter
                        ,pctile_change_winter
                        ,ontrack_keepup
                        ,ontrack_rr                        
                        --*/
                  FROM
                       (
                        SELECT s.ID AS studentid                              
                              ,baseline.measurementscale
                              ,baseline.grade_level
                              ,cs.SPEDLEP
                              ,CASE
                                WHEN baseline.measurementscale = 'Mathematics' THEN 'MATH'
                                WHEN baseline.measurementscale = 'Reading' THEN 'ENG'
                                WHEN baseline.measurementscale = 'Language Usage' THEN 'RHET'
                                WHEN baseline.measurementscale IN ('Science - Concepts and Processes', 'Science - General Science') THEN 'SCI'
                               END AS credit_join
                              ,baseline.testritscore
                              ,norms.r22 AS typical_growth_goal
                              ,baseline.testritscore + norms.r22 AS typical_growth_target                              
                              /*
                              ,(map_winter.testritscore - rr.baseline_rit) AS rit_change_winter
                              ,(map_winter.testpercentile - rr.baseline_percentile) AS pctile_change_winter
                              ,CASE
                                WHEN rr.baseline_rit IS NULL THEN NULL        
                                WHEN rr.baseline_rit IS NOT NULL AND (map_winter.testritscore - rr.baseline_rit) >= rr.keep_up_goal THEN 1.0
                                WHEN rr.baseline_rit IS NOT NULL AND (map_winter.testritscore - rr.baseline_rit) > 0 THEN 1.0
                                ELSE 0.0
                               END AS ontrack_keepup
                              ,CASE
                                WHEN rr.baseline_rit IS NULL THEN NULL
                                WHEN rr.baseline_rit IS NOT NULL AND (map_winter.testritscore - rr.baseline_rit) >= rutgers_ready_goal THEN 1.0
                                WHEN rr.baseline_rit IS NOT NULL AND (map_winter.testritscore - rr.baseline_rit) > 0 THEN 1.0
                                ELSE 0.0
                               END AS ontrack_rr
                              --*/
                        FROM STUDENTS s WITH(NOLOCK)
                        LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
                          ON s.id = cs.studentid  
                        JOIN MAP$best_baseline#static baseline WITH(NOLOCK)
                          ON s.id = baseline.studentid
                         AND s.GRADE_LEVEL = baseline.grade_level
                        /*
                        LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
                          ON s.id = rr.studentid
                         AND s.grade_level = rr.grade_level
                         AND REPLACE(baseline.measurementscale, ' Usage', '') = rr.measurementscale
                        LEFT OUTER JOIN MAP$comprehensive#identifiers map_winter WITH(NOLOCK)
                          ON rr.studentid = map_winter.ps_studentid
                         AND rr.grade_level = map_winter.grade_level
                         AND rr.measurementscale = REPLACE(map_winter.measurementscale, ' Usage', '')
                         AND map_winter.fallwinterspring = 'Winter'
                         AND rr.year = map_winter.map_year_academic
                        --*/
                        LEFT OUTER JOIN MAP$growth_norms_data#2011 norms WITH(NOLOCK)
                          ON baseline.measurementscale = norms.subject
                         AND (baseline.grade_level - 1) = norms.startgrade
                         AND (baseline.testritscore) = norms.startrit                        
                        WHERE s.schoolid = 133570965
                          AND s.enroll_status = 0
                       ) sub_1
                  LEFT OUTER JOIN
                                 (
                                  SELECT cc.studentid
                                        ,courses.course_name
                                        ,courses.credittype
                                        ,courses.course_number
                                        ,courses.course_name + ': ' + sections.section_number AS enr_hash
                                  FROM CC WITH(NOLOCK)
                                  JOIN COURSES WITH(NOLOCK)
                                    ON cc.course_number = courses.course_number
                                   AND courses.credittype != 'COCUR'
                                   AND courses.credittype != 'WLANG'
                                  JOIN SECTIONS WITH(NOLOCK)
                                    ON cc.sectionid = sections.id
                                  WHERE cc.schoolid = 133570965
                                    AND cc.termid >= 2300
                                 ) enrollments
                    ON sub_1.studentid = enrollments.studentid
                   AND sub_1.credit_join = enrollments.credittype
                 ) sub_2
            WHERE testritscore IS NOT NULL
              AND sub_2.match_course IS NOT NULL
              AND sub_2.measurementscale NOT IN ('Science - General Science', 'Science - Concepts and Processes')
            GROUP BY sub_2.grade_level, sub_2.measurementscale, CUBE(sub_2.iep_status,sub_2.match_course)      
           ) sub_3 
      LEFT OUTER JOIN MAP$rit_scale_school_norms norms WITH(NOLOCK)
        ON norms.subject = sub_3.measurementscale
       AND norms.grade = sub_3.grade_level
       AND norms.term = 'Spring-to-Spring'
      WHERE (sub_3.iep_status = 'IEP' AND sub_3.course = 'Whole Grade')
         OR sub_3.iep_status = 'All Students'
     ) sub_4
LEFT OUTER JOIN (
                 SELECT *
                 FROM
                      (
                       SELECT zscore
                             ,CASE 
                               WHEN percentile = 1 THEN 'p01_zscore'
                               WHEN percentile = 5 THEN 'p05_zscore'
                               WHEN percentile = 10 THEN 'p10_zscore'
                               WHEN percentile = 20 THEN 'p20_zscore'
                               WHEN percentile = 25 THEN 'p25_zscore'
                               WHEN percentile = 30 THEN 'p30_zscore'
                               WHEN percentile = 40 THEN 'p40_zscore'
                               WHEN percentile = 50 THEN 'p50_zscore'
                               WHEN percentile = 60 THEN 'p60_zscore'
                               WHEN percentile = 70 THEN 'p70_zscore'
                               WHEN percentile = 75 THEN 'p75_zscore'
                               WHEN percentile = 80 THEN 'p80_zscore'
                               WHEN percentile = 90 THEN 'p90_zscore'
                               WHEN percentile = 95 THEN 'p95_zscore'
                               WHEN percentile = 99 THEN 'p99_zscore'
                              END AS percentile            
                       FROM
                           (
                            SELECT zscore
                                  ,percentile
                                  ,ROW_NUMBER() OVER
                                     (PARTITION BY percentile
                                          ORDER BY zscore ASC) AS rn           
                            FROM UTIL$zscores WITH(NOLOCK)
                            WHERE percentile IN (1,5,10,20,25,30,40,50,60,70,75,80,90,95,99)
                           ) z
                      WHERE z.rn = 1
                     ) z2

                 PIVOT (
                        MAX(zscore) 
                        FOR percentile IN 
                            ([p01_zscore]
                            ,[p05_zscore]
                            ,[p10_zscore]
                            ,[p20_zscore]
                            ,[p25_zscore]
                            ,[p30_zscore]
                            ,[p40_zscore]
                            ,[p50_zscore]
                            ,[p60_zscore]
                            ,[p70_zscore]
                            ,[p75_zscore]
                            ,[p80_zscore]
                            ,[p90_zscore]
                            ,[p95_zscore]
                            ,[p99_zscore]
                            )
                        ) p
                ) norm_dist
  ON 1=1
WHERE closest_match = 1