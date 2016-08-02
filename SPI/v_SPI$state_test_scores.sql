USE KIPP_NJ
GO

ALTER VIEW SPI$state_test_scores AS

WITH parcc_prof AS (
  SELECT sub.schoolid      
        ,sub.grade_level
        ,sub.academic_year        
        ,sub.subject
        ,sub.testcode              
        ,sub.median_SGP
        ,CONVERT(FLOAT,COUNT(sub.student_number)) AS N_tested
        ,SUM(sub.is_prof_terminal_grades) AS N_prof
        ,ROUND((AVG(sub.is_prof_terminal_grades) * 100),0) AS pct_proficient      
  FROM
      (
       SELECT co.schoolid           
             ,co.grade_level
             ,co.student_number
             ,LEFT(parcc.assessmentYear, 4) AS academic_year
             ,'PARCC' AS test_name      
             ,parcc.testcode
             ,CASE 
               WHEN parcc.testcode LIKE 'ELA%' THEN 'ELA'
               ELSE 'Math'
              END AS subject      
             ,CASE                
               WHEN parcc.summativeperformancelevel >= 4 THEN 1.0 
               WHEN parcc.summativeperformancelevel < 4 THEN 0.0 
               ELSE NULL
              END AS is_prof_terminal_grades
             ,NULL AS median_SGP      
       FROM KIPP_NJ..AUTOLOAD$GDOCS_PARCC_district_summative_record_file parcc WITH(NOLOCK)
       JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
         ON parcc.statestudentidentifier = co.SID
        AND LEFT(parcc.assessmentYear, 4) = co.year
        AND co.grade_level IN (4,8,11)
        AND co.rn = 1
       WHERE parcc.recordtype = 1
         AND parcc.multiplerecordflag IS NULL
         AND parcc.reportedsummativescoreflag = 'Y'
         AND parcc.reportsuppressioncode IS NULL
       
       UNION ALL

       /* TEMP FIX FOR 2015 PARCC */
       SELECT co.schoolid
             ,co.grade_level
             ,pre.local_student_identifier AS student_number
             ,pre.academic_year
             ,'PARCC' AS test_name
             ,CASE
               WHEN test_name = 'Algebra I' THEN 'ALG01'
               WHEN test_name = 'Algebra II' THEN 'ALG02'
               WHEN test_name = 'Geometry' THEN 'GEO01'
               WHEN test_name = 'Grade 10 ELA/Literacy' THEN 'ELA10'
               WHEN test_name = 'Grade 11 ELA/Literacy' THEN 'ELA11'
               WHEN test_name = 'Grade 3 ELA/Literacy' THEN 'ELA03'
               WHEN test_name = 'Grade 3 Mathematics' THEN 'MAT03'
               WHEN test_name = 'Grade 4 ELA/Literacy' THEN 'ELA04'
               WHEN test_name = 'Grade 4 Mathematics' THEN 'MAT04'
               WHEN test_name = 'Grade 5 ELA/Literacy' THEN 'ELA05'
               WHEN test_name = 'Grade 5 Mathematics' THEN 'MAT05'
               WHEN test_name = 'Grade 6 ELA/Literacy' THEN 'ELA06'
               WHEN test_name = 'Grade 6 Mathematics' THEN 'MAT06'
               WHEN test_name = 'Grade 7 ELA/Literacy' THEN 'ELA07'
               WHEN test_name = 'Grade 7 Mathematics' THEN 'MAT07'
               WHEN test_name = 'Grade 8 ELA/Literacy' THEN 'ELA08'
               WHEN test_name = 'Grade 8 Mathematics' THEN 'MAT08'
               WHEN test_name = 'Grade 9 ELA/Literacy' THEN 'ELA09'
              END AS testcode
             ,CASE 
               WHEN pre.test_name LIKE '%ELA%' THEN 'ELA'
               ELSE 'Math'
              END AS subject            
             ,CASE                
              WHEN pre.performance_level IN ('Met Expectations','Exceeded Expectations') THEN 1.0 
              WHEN pre.performance_level NOT IN ('Met Expectations','Exceeded Expectations') THEN 0.0 
              ELSE NULL
             END AS is_prof_terminal_grades
            ,NULL AS median_SGP      
       FROM KIPP_NJ..AUTOLOAD$GDOCS_PARCC_preliminary_data pre WITH(NOLOCK)       
       JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
         ON pre.local_student_identifier = co.STUDENT_NUMBER
        AND pre.academic_year = co.year
        AND co.rn = 1
        AND co.grade_level IN (4,8,11)
       /* TEMP FIX FOR 2015 PARCC */
       
       UNION ALL

       SELECT co.schoolid
             ,co.grade_level
             ,co.STUDENT_NUMBER
             ,co.year AS academic_year             
             ,nj.test_name
             ,nj.subject AS test_code
             ,nj.subject
             ,CASE WHEN co.grade_level IN (4,8,11) THEN CONVERT(FLOAT,nj.is_prof) ELSE NULL END AS is_prof_terminal_grades
             ,PERCENTILE_DISC(0.5)
                  WITHIN GROUP (ORDER BY nj.growth_score) 
                    OVER (PARTITION BY co.year, co.schoolid, nj.subject) AS median_SGP
       FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
       JOIN KIPP_NJ..AUTOLOAD$GDOCS_STATE_NJASK_HSPA_scores nj WITH(NOLOCK)
         ON co.STUDENT_NUMBER = nj.student_number
        AND co.year = nj.academic_year
        AND nj.subject IN ('ELA','Math')
       WHERE co.rn = 1
      ) sub
  GROUP BY sub.schoolid
          ,sub.grade_level
          ,sub.academic_year
          ,sub.subject
          ,sub.testcode
          ,sub.median_SGP
 )

,long_data AS (
  SELECT schoolid
        ,grade_level
        ,academic_year
        ,subject  
        ,median_SGP    
        ,SUM(diff_pct_proficient * pct_tested_gr) AS diff_pct_proficient_weighted
  FROM
      (
       SELECT sub.schoolid
             ,sub.grade_level
             ,sub.academic_year
             ,sub.subject
             ,sub.testcode
             ,sub.N_tested           
             ,sub.pct_proficient           
             ,sub.median_sgp
             ,SUM(sub.N_tested) OVER(PARTITION BY sub.academic_year, sub.schoolid, sub.grade_level, sub.subject) AS N_total_gr
             ,sub.N_tested / SUM(sub.N_tested) OVER(PARTITION BY sub.academic_year, sub.schoolid, sub.grade_level, sub.subject) AS pct_tested_gr           
             ,nj.pct_proficient AS state_pct_proficient           
             ,sub.pct_proficient - nj.pct_proficient AS diff_pct_proficient           
       FROM parcc_prof sub
       LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_PARCC_external_proficiency_rates nj WITH(NOLOCK)
         ON sub.academic_year = nj.academic_year
        AND sub.testcode = nj.testcode
        AND sub.grade_level = nj.grade_level
        AND nj.entity = 'NJ'            
      ) sub
  GROUP BY schoolid
          ,grade_level
          ,academic_year
          ,subject
          ,median_SGP
 )

SELECT *
FROM
    (
     SELECT schoolid
           ,academic_year           
           ,CONCAT(subject,'_',field) AS pivot_field
           ,value
     FROM long_data
     UNPIVOT(
       value
       FOR field in (median_SGP
                    ,diff_pct_proficient_weighted)
      ) u
     ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([ELA_median_SGP]
                     ,[ELA_diff_pct_proficient_weighted]
                     ,[Math_median_SGP]
                     ,[Math_diff_pct_proficient_weighted])
 ) p