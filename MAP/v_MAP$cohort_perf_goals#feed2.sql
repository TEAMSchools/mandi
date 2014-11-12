USE KIPP_NJ
GO

ALTER VIEW MAP$cohort_performance_goals#feed2 AS
SELECT *
FROM     
      (SELECT cpt.school
             ,cpt.grade_level
             ,cpt.iep_status
             ,cpt.measurementscale AS subject
             ,'RIT' AS measured_in
             ,cpt.avg_baseline_rit AS avg_baseline
             ,cpt.mean AS avg_cohort_change
             ,cpt.sd AS cohort_sd
             ,cpt.school + '@' + cpt.grade_level + '@' + cpt.iep_status + '@' + cpt.measurementscale AS hash
             ,'p' + CAST(cpt.cohort_growth_percentile AS varchar) AS cohort_growth_percentile
             ,CAST(cpt.target_rit_change AS NUMERIC(3,1)) AS target_rit_change
             --,CAST(cpt.avg_baseline_rit + cpt.target_rit_change AS NUMERIC(4,1)) AS target_end_rit
       FROM KIPP_NJ..MAP$cohort_performance_targets#static cpt
       WHERE cpt.year = 2014
         AND cpt.roster_match_method = 'loose'
         AND cpt.measurementscale IN ('Reading', 'Mathematics', 'Language Usage')
         AND cpt.grade_level NOT LIKE '%_NPR'
         AND cpt.avg_baseline_rit IS NOT NULL
         AND cpt.cohort_growth_percentile IN
           (1, 5, 10, 20, 25, 30, 40, 50, 60, 66, 70, 75, 80, 90, 95, 99)
       ) rit_data
PIVOT (
  --MAX(target_end_rit)
  MAX(target_rit_change) 
  FOR cohort_growth_percentile 
  IN (p1,p5,p10,p20,p30,p40,p50,p60,p66,p70,p75,p80,p90,p95,p99) 
) AS target_cgp

--npr
UNION ALL

SELECT TOP 10000000 *
FROM     
      (SELECT cpt.school
             ,cpt.grade_level
             ,cpt.iep_status
             ,cpt.measurementscale AS subject
             ,'NPR' AS measured_in
             ,cpt.avg_baseline_percentile AS avg_baseline
             ,cpt.mean AS avg_cohort_change
             ,cpt.sd AS cohort_sd
             ,cpt.school + '@' + cpt.grade_level + '@' + cpt.iep_status + '@' + cpt.measurementscale AS hash
             ,'p' + CAST(cpt.cohort_growth_percentile AS varchar) AS cohort_growth_percentile
             ,CAST(cpt.target_npr_change AS NUMERIC (3,1)) AS target_npr_change
             --,CAST(cpt.avg_baseline_percentile + cpt.target_npr_change AS NUMERIC(4,1)) AS target_end_npr
       FROM KIPP_NJ..MAP$cohort_performance_targets#static cpt
       WHERE cpt.year = 2014
         AND cpt.roster_match_method = 'loose'
         AND (
           cpt.measurementscale = 'Science - General Science' OR cpt.grade_level IN ('Math 8 Algebra I Honors_NPR') OR cpt.grade_level = '1_NPR'
         )
         AND cpt.avg_baseline_rit IS NOT NULL
         AND cpt.cohort_growth_percentile IN
           (1, 5, 10, 20, 25, 30, 40, 50, 60, 66, 70, 75, 80, 90, 95, 99)
       ) rit_data
PIVOT (
  --MAX(target_end_npr)
  MAX(target_npr_change) 
  FOR cohort_growth_percentile 
  IN (p1,p5,p10,p20,p30,p40,p50,p60,p66,p70,p75,p80,p90,p95,p99) 
) AS target_cgp
ORDER BY subject, school, grade_level, iep_status