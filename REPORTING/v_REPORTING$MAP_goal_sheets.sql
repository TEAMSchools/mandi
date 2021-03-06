USE KIPP_NJ
GO

ALTER VIEW REPORTING$MAP_goal_sheets AS

SELECT *
	     ,Baseline_Reading_keep_up_goal / 2 AS Winter_Reading_keep_up_goal
	     ,Baseline_Reading_keep_up_rit - (Baseline_Reading_keep_up_goal / 2) AS Winter_Reading_keep_up_rit
	     ,Baseline_Reading_rutgers_ready_goal / 2 AS Winter_Reading_rutgers_ready_goal
	     ,Baseline_Reading_rutgers_ready_rit - (Baseline_Reading_rutgers_ready_goal / 2) AS Winter_Reading_rutgers_ready_rit
	     ,Baseline_Mathematics_keep_up_goal / 2 AS Winter_Mathematics_keep_up_goal
	     ,Baseline_Mathematics_keep_up_rit - (Baseline_Mathematics_keep_up_goal / 2) AS Winter_Mathematics_keep_up_rit
	     ,Baseline_Mathematics_rutgers_ready_goal / 2 AS Winter_Mathematics_rutgers_ready_goal
	     ,Baseline_Mathematics_rutgers_ready_rit - (Baseline_Mathematics_rutgers_ready_goal / 2) AS Winter_Mathematics_rutgers_ready_rit
	     ,Baseline_Language_keep_up_goal / 2 AS Winter_Language_keep_up_goal
	     ,Baseline_Language_keep_up_rit - (Baseline_Language_keep_up_goal / 2) AS Winter_Language_keep_up_rit
	     ,Baseline_Language_rutgers_ready_goal / 2 AS Winter_Language_rutgers_ready_goal
	     ,Baseline_Language_rutgers_ready_rit - (Baseline_Language_rutgers_ready_goal / 2) AS Winter_Language_rutgers_ready_rit
	     ,Baseline_Science_keep_up_goal / 2 AS Winter_Science_keep_up_goal
	     ,Baseline_Science_keep_up_rit - (Baseline_Science_keep_up_goal / 2) AS Winter_Science_keep_up_rit
	     ,Baseline_Science_rutgers_ready_goal / 2 AS Winter_Science_rutgers_ready_goal
	     ,Baseline_Science_rutgers_ready_rit - (Baseline_Science_rutgers_ready_goal / 2) AS Winter_Science_rutgers_ready_rit
	     ,CASE 
        WHEN grade_level = 0 THEN 'Kindergarten'
	       WHEN grade_level = 1 THEN '1st'
			     WHEN grade_level = 2 THEN '2nd'
			     WHEN grade_level = 3 THEN '3rd'
			     WHEN grade_level = 4 THEN '4th'
			     WHEN grade_level = 5 THEN '5th'
			     WHEN grade_level = 6 THEN '6th'
			     WHEN grade_level = 7 THEN '7th'
			     WHEN grade_level = 8 THEN '8th'
			     WHEN grade_level = 9 THEN '9th'
			     WHEN grade_level = 10 THEN '10th'
			     WHEN grade_level = 11 THEN '11th'
	       ELSE NULL 
	      END AS grade_level_name
FROM
    (
     SELECT schoolid                  
           ,school_name
           ,academic_year
           ,student_number
           ,lastfirst
		         ,last_name
		         ,first_name
           ,grade_level
           ,team
           ,advisor            
           ,CONCAT(term, '_', measurementscale, '_', field) AS pivot_field
           ,value
     FROM
         (
          SELECT co.schoolid                  
                ,co.school_name
                ,co.year AS academic_year
                ,co.student_number
                ,co.lastfirst
				            ,co.last_name
				            ,co.first_name
                ,co.grade_level
                ,co.team
                ,co.advisor            
                ,map.term           
                ,CASE
                  WHEN CHARINDEX(' ', map.MeasurementScale) = 0 THEN map.MeasurementScale 
                  ELSE LEFT(map.MeasurementScale, CHARINDEX(' ', map.MeasurementScale) - 1) 
                 END AS measurementscale
                ,CONVERT(INT,map.TestRITScore) AS TestRITScore
                ,CONVERT(INT,map.TestPercentile) AS TestPercentile
                --,NULL AS keep_up_rit
                --,NULL AS keep_up_goal
                --,NULL AS rutgers_ready_rit
                --,NULL AS rutgers_ready_goal
                ,ROW_NUMBER() OVER(
                   PARTITION BY co.student_number, map.academic_year, map.term, map.measurementscale
                     ORDER BY map.testritscore DESC) AS rn_high
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
            ON co.student_number = map.student_number                                                       
           AND co.year = map.academic_year
          --LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals goals WITH(NOLOCK)
          --  ON co.studentid = goals.studentid
          -- AND co.year = goals.year
          -- AND map.measurementscale = goals.measurementscale
          WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND co.grade_level <= 11
            AND co.rn = 1
            AND co.enroll_status = 0

          UNION ALL

          SELECT co.schoolid                  
                ,co.school_name
                ,co.year
                ,co.student_number
                ,co.lastfirst
				            ,co.last_name
				            ,co.first_name
                ,co.grade_level
                ,co.team
                ,co.advisor            
                ,'Baseline' AS term
                ,CASE
                  WHEN CHARINDEX(' ', base.measurementscale) = 0 THEN base.MeasurementScale 
                  ELSE LEFT(base.measurementscale, CHARINDEX(' ', base.MeasurementScale) - 1) 
                 END AS measurementscale
                ,CONVERT(INT,base.TestRITScore) AS TestRITScore
                ,CONVERT(INT,base.TestPercentile) AS TestPercentile
                --,NULL AS keep_up_rit
                --,NULL AS keep_up_goal
                --,NULL AS rutgers_ready_rit
                --,NULL AS rutgers_ready_goal
                ,1 AS rn_high
          FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
          LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
            ON co.studentid = base.studentid
           AND co.year = base.year
          --LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals goals WITH(NOLOCK)
          --  ON co.studentid = goals.studentid
          -- AND co.year = goals.year
          -- AND base.measurementscale = goals.measurementscale
          WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND co.grade_level <= 11
            AND co.rn = 1
            AND co.enroll_status = 0
         ) sub
     UNPIVOT(
       value
       FOR field IN (testritscore
                    ,testpercentile)
                    --,keep_up_rit      
                    --,keep_up_goal
                    --,rutgers_ready_rit                  
                    --,rutgers_ready_goal)
      ) u
     WHERE rn_high = 1
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([Baseline_Reading_TestPercentile]
                     ,[Baseline_Reading_TestRITScore]
                     ,[Baseline_Mathematics_TestPercentile]
                     ,[Baseline_Mathematics_TestRITScore]                     
                     ,[Baseline_Language_TestPercentile]
                     ,[Baseline_Language_TestRITScore]                     
                     ,[Baseline_Science_TestPercentile]
                     ,[Baseline_Science_TestRITScore] 
                     ,[Baseline_Mathematics_keep_up_goal]
                     ,[Baseline_Mathematics_keep_up_rit]
                     ,[Baseline_Mathematics_rutgers_ready_goal]
                     ,[Baseline_Mathematics_rutgers_ready_rit]             
                     ,[Baseline_Reading_keep_up_goal]
                     ,[Baseline_Reading_keep_up_rit]
                     ,[Baseline_Reading_rutgers_ready_goal]
                     ,[Baseline_Reading_rutgers_ready_rit]         
                     ,[Baseline_Language_keep_up_goal]
                     ,[Baseline_Language_keep_up_rit]
                     ,[Baseline_Language_rutgers_ready_goal]
                     ,[Baseline_Language_rutgers_ready_rit]                             
                     ,[Baseline_Science_keep_up_goal]
                     ,[Baseline_Science_keep_up_rit]
                     ,[Baseline_Science_rutgers_ready_goal]
                     ,[Baseline_Science_rutgers_ready_rit]      
               					 ,[Fall_Reading_TestPercentile]
                     ,[Fall_Reading_TestRITScore]                     
                     ,[Fall_Mathematics_TestPercentile]
                     ,[Fall_Mathematics_TestRITScore]                     
                     ,[Fall_Language_TestPercentile]
                     ,[Fall_Language_TestRITScore]                     
                     ,[Fall_Science_TestPercentile]
                     ,[Fall_Science_TestRITScore]                                          
                     ,[Winter_Language_TestPercentile]
                     ,[Winter_Language_TestRITScore]                     
                     ,[Winter_Mathematics_TestPercentile]
                     ,[Winter_Mathematics_TestRITScore]
                     ,[Winter_Reading_TestPercentile]
                     ,[Winter_Reading_TestRITScore]
                     ,[Winter_Science_TestPercentile]
                     ,[Winter_Science_TestRITScore]					 
 					               ,[Spring_Reading_TestPercentile]
                     ,[Spring_Reading_TestRITScore]
                     ,[Spring_Mathematics_TestPercentile]
                     ,[Spring_Mathematics_TestRITScore]
                     ,[Spring_Language_TestPercentile]
                     ,[Spring_Language_TestRITScore]
                     ,[Spring_Science_TestPercentile]
                     ,[Spring_Science_TestRITScore])
 ) p