USE KIPP_NJ
GO

ALTER VIEW REPORTING$MAP_goal_sheets AS

WITH map AS (
  SELECT *
  FROM
      (
       SELECT student_number
             ,academic_year
             ,CONCAT(term, '_', measurementscale, '_', field) AS pivot_field
             ,value
       FROM
           (
            SELECT student_number
                  ,academic_year
                  ,term           
                  ,CASE
                    WHEN CHARINDEX(' ', MeasurementScale) = 0 THEN MeasurementScale 
                    ELSE LEFT(measurementscale, CHARINDEX(' ', MeasurementScale) - 1) 
                   END AS measurementscale
                  ,TestRITScore
                  ,TestPercentile
                  ,ROW_NUMBER() OVER(
                     PARTITION BY student_number, academic_year, term, measurementscale
                       ORDER BY testritscore DESC) AS rn_high
            FROM MAP$CDF#identifiers#static WITH(NOLOCK)
            WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

            UNION ALL

            SELECT co.student_number
                  ,co.year
                  ,'Baseline' AS term
                  ,CASE
                    WHEN CHARINDEX(' ', base.measurementscale) = 0 THEN base.MeasurementScale 
                    ELSE LEFT(base.measurementscale, CHARINDEX(' ', base.MeasurementScale) - 1) 
                   END AS measurementscale
                  ,base.testritscore
                  ,base.testpercentile
                  ,1 AS rn_high
            FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
            LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
              ON co.studentid = base.studentid
             AND co.year = base.year
            WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() - 1
              AND co.grade_level <= 8
              AND co.rn = 1
              AND co.enroll_status = 0
           ) sub
       UNPIVOT(
         value
         FOR field IN (testritscore, testpercentile)
        ) u
       WHERE rn_high = 1
      ) sub
  PIVOT(
    MAX(value)
    FOR pivot_field IN ([Fall_Language_TestPercentile]
                       ,[Fall_Language_TestRITScore]
                       ,[Fall_Mathematics_TestPercentile]
                       ,[Fall_Mathematics_TestRITScore]
                       ,[Fall_Reading_TestPercentile]
                       ,[Fall_Reading_TestRITScore]
                       ,[Fall_Science_TestPercentile]
                       ,[Fall_Science_TestRITScore]
                       ,[Spring_Language_TestPercentile]
                       ,[Spring_Language_TestRITScore]
                       ,[Spring_Mathematics_TestPercentile]
                       ,[Spring_Mathematics_TestRITScore]
                       ,[Spring_Reading_TestPercentile]
                       ,[Spring_Reading_TestRITScore]
                       ,[Spring_Science_TestPercentile]
                       ,[Spring_Science_TestRITScore]
                       ,[Winter_Language_TestPercentile]
                       ,[Winter_Language_TestRITScore]
                       ,[Winter_Mathematics_TestPercentile]
                       ,[Winter_Mathematics_TestRITScore]
                       ,[Winter_Reading_TestPercentile]
                       ,[Winter_Reading_TestRITScore]
                       ,[Winter_Science_TestPercentile]
                       ,[Winter_Science_TestRITScore]
                       ,[Baseline_Mathematics_TestRITScore]
                       ,[Baseline_Mathematics_TestPercentile]
                       ,[Baseline_Science_TestRITScore]
                       ,[Baseline_Science_TestPercentile]
                       ,[Baseline_Language_TestRITScore]
                       ,[Baseline_Language_TestPercentile]
                       ,[Baseline_Reading_TestRITScore]
                       ,[Baseline_Reading_TestPercentile])
   ) p
 )

SELECT co.schoolid
      ,co.school_name
      ,co.student_number
      ,co.lastfirst
      ,co.grade_level
      ,co.team
      ,co.advisor
      ,base.measurementscale
      ,base.testritscore AS base_RIT
      ,base.testpercentile AS base_pctile
      ,goals.keep_up_goal
      ,goals.keep_up_rit
      ,goals.rutgers_ready_goal
      ,goals.rutgers_ready_rit
      ,map.[Baseline_Mathematics_TestRITScore]
      ,map.[Baseline_Mathematics_TestPercentile]
      ,map.[Baseline_Science_TestRITScore]
      ,map.[Baseline_Science_TestPercentile]
      ,map.[Baseline_Language_TestRITScore]
      ,map.[Baseline_Language_TestPercentile]
      ,map.[Baseline_Reading_TestRITScore]
      ,map.[Baseline_Reading_TestPercentile]
      ,map.[Fall_Language_TestPercentile]
      ,map.[Fall_Language_TestRITScore]
      ,map.[Fall_Mathematics_TestPercentile]
      ,map.[Fall_Mathematics_TestRITScore]
      ,map.[Fall_Reading_TestPercentile]
      ,map.[Fall_Reading_TestRITScore]
      ,map.[Fall_Science_TestPercentile]
      ,map.[Fall_Science_TestRITScore]
      ,map.[Spring_Language_TestPercentile]
      ,map.[Spring_Language_TestRITScore]
      ,map.[Spring_Mathematics_TestPercentile]
      ,map.[Spring_Mathematics_TestRITScore]
      ,map.[Spring_Reading_TestPercentile]
      ,map.[Spring_Reading_TestRITScore]
      ,map.[Spring_Science_TestPercentile]
      ,map.[Spring_Science_TestRITScore]
      ,map.[Winter_Language_TestPercentile]
      ,map.[Winter_Language_TestRITScore]
      ,map.[Winter_Mathematics_TestPercentile]
      ,map.[Winter_Mathematics_TestRITScore]
      ,map.[Winter_Reading_TestPercentile]
      ,map.[Winter_Reading_TestRITScore]
      ,map.[Winter_Science_TestPercentile]
      ,map.[Winter_Science_TestRITScore]
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
  ON co.studentid = base.studentid
 AND co.year = base.year
LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals goals WITH(NOLOCK)
  ON co.studentid = goals.studentid
 AND co.year = goals.year
 AND base.measurementscale = goals.measurementscale
LEFT OUTER JOIN map WITH(NOLOCK)
  ON co.student_number = map.student_number
 AND co.year = map.academic_year 
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() - 1
  AND co.grade_level <= 8
  AND co.enroll_status = 0
  AND co.rn = 1