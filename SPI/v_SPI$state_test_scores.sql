USE KIPP_NJ
GO

ALTER VIEW SPI$state_test_scores AS

WITH long_data AS (
  SELECT schoolid
        ,academic_year
        ,test_name
        ,subject
        ,median_SGP
        ,(AVG(is_prof_terminal_grades) * 100) AS pct_prof_terminal_grades      
  FROM
      (
       SELECT co.schoolid
             ,co.grade_level
             ,co.year AS academic_year
             ,nj.test_name
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

       UNION ALL

       SELECT co.schoolid
             ,co.grade_level
             ,LEFT(parcc.assessmentYear, 4) AS academic_year
             ,'PARCC' AS test_name      
             ,CASE 
               WHEN testcode LIKE 'ELA%' THEN 'ELA'
               ELSE 'Math'
              END AS subject      
             ,CASE                
               WHEN co.grade_level IN (4,8,11) AND parcc.summativeperformancelevel >= 4 THEN 1.0 
               WHEN co.grade_level IN (4,8,11) AND parcc.summativeperformancelevel < 4 THEN 0.0 
               ELSE NULL
              END AS is_prof_terminal_grades
             ,NULL AS median_SGP
       FROM KIPP_NJ..AUTOLOAD$GDOCS_PARCC_district_summative_record_file parcc WITH(NOLOCK)
       JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
         ON parcc.statestudentidentifier = co.SID
        AND LEFT(parcc.assessmentYear, 4) = co.year
        AND co.rn = 1
       WHERE parcc.recordtype = 1
         AND parcc.multiplerecordflag IS NULL
         AND parcc.reportedsummativescoreflag = 'Y'
         AND parcc.reportsuppressioncode IS NULL
      ) sub
  GROUP BY schoolid
          ,academic_year
          ,test_name
          ,subject
          ,median_SGP
 )

SELECT *
FROM
    (
     SELECT schoolid
           ,academic_year
           ,test_name
           ,CONCAT(subject,'_',field) AS pivot_field
           ,value
     FROM long_data
     UNPIVOT(
       value
       FOR field in (median_SGP
                    ,pct_prof_terminal_grades)
      ) u
     ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([ELA_median_SGP]
                     ,[ELA_pct_prof_terminal_grades]
                     ,[Math_median_SGP]
                     ,[Math_pct_prof_terminal_grades])
 ) p