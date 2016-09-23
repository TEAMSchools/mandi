USE KIPP_NJ
GO

ALTER VIEW MAP$retest_roster AS

WITH map_long AS (
  SELECT sub.*      
        ,AVG(CONVERT(FLOAT,testdurationminutes)) OVER(PARTITION BY grade_level, measurementscale) AS global_mean_testdurationminutes
        ,STDEV(CONVERT(FLOAT,testdurationminutes)) OVER(PARTITION BY grade_level, measurementscale) AS global_stdev_testdurationminutes             
        ,AVG(CONVERT(FLOAT,student_TestDurationMinutes)) OVER(PARTITION BY student_number, measurementscale) AS student_mean_testdurationminutes
        ,STDEV(CONVERT(FLOAT,student_TestDurationMinutes)) OVER(PARTITION BY student_number, measurementscale) AS student_stdev_testdurationminutes
        
        ,SUM(student_N) OVER(PARTITION BY sub.measurementscale, sub.grade_level, sub.term, sub.prev_term) AS global_prev_N
        ,SUM(student_N) OVER(PARTITION BY sub.measurementscale, sub.grade_level, sub.term, sub.next_term) AS global_next_N
  FROM
      (
       SELECT m.student_number
             --,m.lastfirst                
             --,m.schoolid
             --,m.SchoolName
             ,m.grade_level
             ,m.academic_year                
             ,m.term                
             ,m.MeasurementScale
             ,m.TestRITScore
             ,CONVERT(FLOAT,m.percentile_2015_norms) AS npr
             ,m.TestStartDate
             ,m.TestDurationMinutes
             ,CASE WHEN COUNT(m.student_number) OVER(PARTITION BY m.student_number, m.measurementscale) < 4 THEN NULL ELSE m.TestDurationMinutes END AS student_TestDurationMinutes
                
             ,LAG(m.academic_year, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS prev_academic_year
             ,LAG(m.term, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS prev_term
             ,LAG(m.TestRITScore, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS prev_rit
             ,LAG(m.percentile_2015_norms, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS prev_npr

             ,LEAD(m.academic_year, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS next_academic_year
             ,LEAD(m.term, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS next_term
             ,LEAD(m.TestRITScore, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS next_rit
             ,LEAD(m.percentile_2015_norms, 1) OVER(PARTITION BY m.student_number, m.measurementscale ORDER BY m.teststartdate ASC) AS next_npr                
                
             ,COUNT(m.student_number) OVER(PARTITION BY m.student_number, m.measurementscale) AS student_N                                
       FROM KIPP_NJ..MAP$CDF#identifiers#static m WITH(NOLOCK)          
       WHERE m.rn = 1       
      ) sub
 )

SELECT sub.student_number
      ,sub.lastfirst
      ,sub.schoolid
      ,sub.school_name
      ,sub.grade_level
      ,sub.academic_year
      ,sub.term
      ,sub.MeasurementScale
      ,sub.TestRITScore
      ,sub.npr
      ,sub.TestStartDate
      ,sub.TestDurationMinutes
      ,sub.student_TestDurationMinutes
      ,sub.prev_academic_year
      ,sub.prev_term
      ,sub.prev_rit
      ,sub.prev_npr
      ,sub.next_academic_year
      ,sub.next_term
      ,sub.next_rit
      ,sub.next_npr
      ,sub.student_N
      ,sub.global_mean_testdurationminutes
      ,sub.global_stdev_testdurationminutes
      ,sub.student_mean_testdurationminutes
      ,sub.student_stdev_testdurationminutes
      ,sub.global_prev_N
      ,sub.global_next_N
      ,sub.prev_npr_change
      ,sub.next_npr_change
      ,sub.mean_prev_npr_change
      ,sub.mean_next_npr_change
      ,sub.stdev_prev_npr_change
      ,sub.stdev_next_npr_change
      ,sub.global_testdurationminutes_z
      ,sub.student_testdurationminutes_z
      ,sub.prev_npr_z
      ,sub.next_npr_z
      ,ISNULL(global_testdurationminutes_z,0) 
        + ISNULL(prev_npr_z, 0) 
        + 2 * ISNULL(student_testdurationminutes_z,0)        
        + 2 * ISNULL(CASE WHEN prev_npr_z < 0 AND next_npr_z < 0 THEN prev_npr_z + next_npr_z ELSE NULL END,0)
       AS total_z      
FROM
    (
     SELECT sub.student_number
           ,sub.lastfirst
           ,sub.schoolid
           ,sub.school_name
           ,sub.grade_level
           ,sub.academic_year
           ,sub.term
           ,sub.MeasurementScale
           ,sub.TestRITScore
           ,sub.npr
           ,sub.TestStartDate
           ,sub.TestDurationMinutes
           ,sub.student_TestDurationMinutes
           ,sub.prev_academic_year
           ,sub.prev_term
           ,sub.prev_rit
           ,sub.prev_npr
           ,sub.next_academic_year
           ,sub.next_term
           ,sub.next_rit
           ,sub.next_npr
           ,sub.student_N
           ,sub.global_mean_testdurationminutes
           ,sub.global_stdev_testdurationminutes
           ,sub.student_mean_testdurationminutes
           ,sub.student_stdev_testdurationminutes
           ,sub.global_prev_N
           ,sub.global_next_N
           ,sub.prev_npr_change
           ,sub.next_npr_change
           ,sub.mean_prev_npr_change
           ,sub.mean_next_npr_change
           ,sub.stdev_prev_npr_change
           ,sub.stdev_next_npr_change
           ,(student_testdurationminutes - global_mean_testdurationminutes) 
              / CASE WHEN global_stdev_testdurationminutes = 0 THEN NULL ELSE global_stdev_testdurationminutes END AS global_testdurationminutes_z
           ,(student_testdurationminutes - student_mean_testdurationminutes) 
              / CASE WHEN student_stdev_testdurationminutes = 0 THEN NULL ELSE student_stdev_testdurationminutes END AS student_testdurationminutes_z
           ,(prev_npr_change - mean_prev_npr_change)
              / CASE WHEN stdev_prev_npr_change = 0 THEN NULL ELSE stdev_prev_npr_change END AS prev_npr_z
           ,-1 * (next_npr_change - mean_next_npr_change) 
              / CASE WHEN stdev_next_npr_change = 0 THEN NULL ELSE stdev_next_npr_change END AS next_npr_z
     FROM
         (
          SELECT sub.student_number
                ,sub.lastfirst
                ,sub.schoolid
                ,sub.school_name
                ,sub.grade_level
                ,sub.academic_year
                ,sub.term
                ,sub.MeasurementScale
                ,sub.TestRITScore
                ,sub.npr
                ,sub.TestStartDate
                ,sub.TestDurationMinutes
                ,sub.student_TestDurationMinutes
                ,sub.prev_academic_year
                ,sub.prev_term
                ,sub.prev_rit
                ,sub.prev_npr
                ,sub.next_academic_year
                ,sub.next_term
                ,sub.next_rit
                ,sub.next_npr
                ,sub.student_N
                ,sub.global_mean_testdurationminutes
                ,sub.global_stdev_testdurationminutes
                ,sub.student_mean_testdurationminutes
                ,sub.student_stdev_testdurationminutes
                ,sub.global_prev_N
                ,sub.global_next_N
                ,sub.prev_npr_change
                ,sub.next_npr_change
                ,AVG(prev_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, prev_term) AS mean_prev_npr_change
                ,STDEV(prev_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, prev_term) AS stdev_prev_npr_change
                ,AVG(next_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, next_term) AS mean_next_npr_change
                ,STDEV(next_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, next_term) AS stdev_next_npr_change
          FROM
              (
               SELECT co.student_number
                     ,co.lastfirst
                     ,co.reporting_schoolid AS schoolid
                     ,co.school_name
                     ,co.grade_level
                     ,map_long.academic_year
                     ,map_long.term
                     ,map_long.MeasurementScale
                     ,map_long.TestRITScore
                     ,map_long.npr
                     ,map_long.TestStartDate
                     ,map_long.TestDurationMinutes
                     ,map_long.student_TestDurationMinutes
                     ,map_long.prev_academic_year
                     ,map_long.prev_term
                     ,map_long.prev_rit
                     ,map_long.prev_npr
                     ,map_long.next_academic_year
                     ,map_long.next_term
                     ,map_long.next_rit
                     ,map_long.next_npr
                     ,map_long.student_N
                     ,map_long.global_mean_testdurationminutes
                     ,map_long.global_stdev_testdurationminutes
                     ,map_long.student_mean_testdurationminutes
                     ,map_long.student_stdev_testdurationminutes
                     ,map_long.global_prev_N
                     ,map_long.global_next_N                     
                     ,CASE 
                       WHEN map_long.global_prev_N < 100 THEN NULL 
                       WHEN map_long.academic_year - map_long.prev_academic_year < 1 THEN NULL /* previous NPR should be from at least 1 year ago -- this seems weird*/
                       WHEN map_long.term = map_long.prev_term THEN NULL
                       ELSE map_long.npr - map_long.prev_npr
                      END AS prev_npr_change
                     ,CASE 
                       WHEN map_long.global_next_N < 100 THEN NULL
                       WHEN map_long.next_academic_year - map_long.academic_year > 1 THEN NULL
                       WHEN map_long.term = map_long.next_term THEN NULL
                       ELSE map_long.next_npr - map_long.npr
                      END AS next_npr_change
               FROM map_long
               JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
                 ON map_long.student_number = co.student_number
                AND map_long.academic_year = co.year
                AND co.rn = 1
              ) sub    
         ) sub       
    ) sub