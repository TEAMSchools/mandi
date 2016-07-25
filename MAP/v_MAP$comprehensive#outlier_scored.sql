USE KIPP_NJ
GO

ALTER VIEW MAP$comprehensive#outlier_scored AS

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
             ,m.lastfirst                
             ,m.schoolid
             ,m.SchoolName
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

SELECT *
      ,ISNULL(global_testdurationminutes_z,0) 
        + ISNULL(prev_npr_z, 0) 
        + 2 * ISNULL(student_testdurationminutes_z,0)        
        + 2 * ISNULL(CASE WHEN prev_npr_z < 0 AND next_npr_z < 0 THEN prev_npr_z + next_npr_z ELSE NULL END,0)
       AS total_z      
FROM
    (
     SELECT *      
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
          SELECT *
                ,AVG(prev_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, prev_term) AS mean_prev_npr_change
                ,STDEV(prev_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, prev_term) AS stdev_prev_npr_change
                ,AVG(next_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, next_term) AS mean_next_npr_change
                ,STDEV(next_npr_change) OVER(PARTITION BY grade_level, measurementscale, term, next_term) AS stdev_next_npr_change
          FROM
              (
               SELECT *
                     ,CASE 
                       WHEN global_prev_N < 100 THEN NULL 
                       WHEN academic_year - prev_academic_year < 1 THEN NULL /* previous NPR should be from at least 1 year ago -- this seems weird*/
                       WHEN term = prev_term THEN NULL
                       ELSE npr - prev_npr
                      END AS prev_npr_change
                     ,CASE 
                       WHEN global_next_N < 100 THEN NULL
                       WHEN next_academic_year - academic_year > 1 THEN NULL
                       WHEN term = next_term THEN NULL
                       ELSE next_npr - npr
                      END AS next_npr_change
               FROM map_long               
              ) sub    
         ) sub       
    ) sub