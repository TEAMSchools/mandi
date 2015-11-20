USE KIPP_NJ
GO

ALTER VIEW MAP$wide_all AS

WITH terms AS (
  SELECT 'Fall' AS term
  UNION
  SELECT 'Winter'
  UNION
  SELECT 'Spring'
 )

SELECT *
FROM       
    (
     SELECT studentid
           ,CONCAT(pivot_field, '_', field) AS pivot_field
           ,value
     FROM
         (
          SELECT co.studentid                
                ,CONCAT('Y', (KIPP_NJ.dbo.fn_Global_Academic_Year() - co.year), '_' /* years ago */
                       ,terms.term, '_'
                       ,CASE
                         WHEN base.measurementscale = 'Reading' THEN 'READ'
                         WHEN base.measurementscale = 'Mathematics' THEN 'MATH'
                         WHEN base.measurementscale = 'Language Usage' THEN 'LANG'
                         WHEN base.measurementscale = 'Science - General Science' THEN 'GEN'
                         WHEN base.measurementscale = 'Science - Concepts and Processes' THEN 'CP'
                         ELSE NULL
                        END) AS pivot_field           
                ,CONVERT(INT,
                  CASE 
                    WHEN terms.term = 'Fall' THEN COALESCE(base.testritscore, map.testritscore) 
                    ELSE map.testritscore 
                   END) AS RIT
                ,CONVERT(INT,
                   CASE 
                    WHEN terms.term = 'Fall' THEN COALESCE(base.testpercentile, map.percentile_2011_norms) 
                    ELSE map.percentile_2011_norms 
                   END) AS percentile
          FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
          CROSS JOIN terms       
          JOIN MAP$best_baseline#static base WITH(NOLOCK)
            ON co.studentid = base.studentid
           AND co.year = base.year 
          LEFT OUTER JOIN MAP$CDF#identifiers#static map WITH(NOLOCK)
            ON co.student_number = map.student_number
           AND base.measurementscale = map.measurementscale 
           AND base.year = map.academic_year
           AND terms.term = map.term
           AND map.rn = 1
           AND map.testname NOT LIKE '%Algebra%'                      
          WHERE co.rn = 1                         
         ) sub
     UNPIVOT(
       value
       FOR field IN (RIT, percentile)
      ) u
    ) sub
PIVOT (
  MAX(value)
  FOR pivot_field IN ([Y0_Fall_GEN_percentile]
                    ,[Y0_Fall_GEN_RIT]
                    ,[Y0_Fall_LANG_percentile]
                    ,[Y0_Fall_LANG_RIT]
                    ,[Y0_Fall_MATH_percentile]
                    ,[Y0_Fall_MATH_RIT]
                    ,[Y0_Fall_READ_percentile]
                    ,[Y0_Fall_READ_RIT]
                    ,[Y0_Spring_GEN_percentile]
                    ,[Y0_Spring_GEN_RIT]
                    ,[Y0_Spring_LANG_percentile]
                    ,[Y0_Spring_LANG_RIT]
                    ,[Y0_Spring_MATH_percentile]
                    ,[Y0_Spring_MATH_RIT]
                    ,[Y0_Spring_READ_percentile]
                    ,[Y0_Spring_READ_RIT]
                    ,[Y0_Winter_GEN_percentile]
                    ,[Y0_Winter_GEN_RIT]
                    ,[Y0_Winter_LANG_percentile]
                    ,[Y0_Winter_LANG_RIT]
                    ,[Y0_Winter_MATH_percentile]
                    ,[Y0_Winter_MATH_RIT]
                    ,[Y0_Winter_READ_percentile]
                    ,[Y0_Winter_READ_RIT]
                    ,[Y1_Fall_GEN_percentile]
                    ,[Y1_Fall_GEN_RIT]
                    ,[Y1_Fall_LANG_percentile]
                    ,[Y1_Fall_LANG_RIT]
                    ,[Y1_Fall_MATH_percentile]
                    ,[Y1_Fall_MATH_RIT]
                    ,[Y1_Fall_READ_percentile]
                    ,[Y1_Fall_READ_RIT]
                    ,[Y1_Spring_GEN_percentile]
                    ,[Y1_Spring_GEN_RIT]
                    ,[Y1_Spring_LANG_percentile]
                    ,[Y1_Spring_LANG_RIT]
                    ,[Y1_Spring_MATH_percentile]
                    ,[Y1_Spring_MATH_RIT]
                    ,[Y1_Spring_READ_percentile]
                    ,[Y1_Spring_READ_RIT]
                    ,[Y1_Winter_GEN_percentile]
                    ,[Y1_Winter_GEN_RIT]
                    ,[Y1_Winter_LANG_percentile]
                    ,[Y1_Winter_LANG_RIT]
                    ,[Y1_Winter_MATH_percentile]
                    ,[Y1_Winter_MATH_RIT]
                    ,[Y1_Winter_READ_percentile]
                    ,[Y1_Winter_READ_RIT]
                    ,[Y2_Fall_GEN_percentile]
                    ,[Y2_Fall_GEN_RIT]
                    ,[Y2_Fall_LANG_percentile]
                    ,[Y2_Fall_LANG_RIT]
                    ,[Y2_Fall_MATH_percentile]
                    ,[Y2_Fall_MATH_RIT]
                    ,[Y2_Fall_READ_percentile]
                    ,[Y2_Fall_READ_RIT]
                    ,[Y2_Spring_GEN_percentile]
                    ,[Y2_Spring_GEN_RIT]
                    ,[Y2_Spring_LANG_percentile]
                    ,[Y2_Spring_LANG_RIT]
                    ,[Y2_Spring_MATH_percentile]
                    ,[Y2_Spring_MATH_RIT]
                    ,[Y2_Spring_READ_percentile]
                    ,[Y2_Spring_READ_RIT]
                    ,[Y2_Winter_GEN_percentile]
                    ,[Y2_Winter_GEN_RIT]
                    ,[Y2_Winter_LANG_percentile]
                    ,[Y2_Winter_LANG_RIT]
                    ,[Y2_Winter_MATH_percentile]
                    ,[Y2_Winter_MATH_RIT]
                    ,[Y2_Winter_READ_percentile]
                    ,[Y2_Winter_READ_RIT]
                    ,[Y3_Fall_GEN_percentile]
                    ,[Y3_Fall_GEN_RIT]
                    ,[Y3_Fall_MATH_percentile]
                    ,[Y3_Fall_MATH_RIT]
                    ,[Y3_Fall_READ_percentile]
                    ,[Y3_Fall_READ_RIT]
                    ,[Y3_Spring_GEN_percentile]
                    ,[Y3_Spring_GEN_RIT]
                    ,[Y3_Spring_LANG_percentile]
                    ,[Y3_Spring_LANG_RIT]
                    ,[Y3_Spring_MATH_percentile]
                    ,[Y3_Spring_MATH_RIT]
                    ,[Y3_Spring_READ_percentile]
                    ,[Y3_Spring_READ_RIT]
                    ,[Y3_Winter_GEN_percentile]
                    ,[Y3_Winter_GEN_RIT]
                    ,[Y3_Winter_LANG_percentile]
                    ,[Y3_Winter_LANG_RIT]
                    ,[Y3_Winter_MATH_percentile]
                    ,[Y3_Winter_MATH_RIT]
                    ,[Y3_Winter_READ_percentile]
                    ,[Y3_Winter_READ_RIT])
 ) p