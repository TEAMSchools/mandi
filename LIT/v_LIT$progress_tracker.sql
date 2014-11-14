USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[LIT$progress_tracker] AS

WITH goals_wide AS (
  SELECT studentid
        ,DR AS goal_dr
        ,T1 AS goal_t1
        ,T2 AS goal_t2
        ,T3 AS goal_t3
        ,EOY AS goal_eoy
  FROM
      (
       SELECT co.STUDENT_NUMBER
             ,co.studentid      
             ,goals.test_round
             ,COALESCE(indiv.goal, goals.read_lvl) AS goal      
       FROM COHORT$identifiers_long#static co WITH(NOLOCK)
       JOIN LIT$goals goals WITH(NOLOCK)
         ON co.grade_level = goals.grade_level
       LEFT OUTER JOIN LIT$individual_goals indiv WITH(NOLOCK)
         ON co.STUDENT_NUMBER = indiv.student_number
        AND goals.test_round = indiv.test_round
       WHERE co.year = dbo.fn_Global_Academic_Year()
         AND co.grade_level < 5
         AND co.rn = 1
      ) sub

  PIVOT (
    MAX(goal)
    FOR test_round IN ([DR],[T1],[T2],[T3],[EOY])
   ) piv
 )

,terms AS (      
  SELECT academic_year        
        ,CASE 
          WHEN school_level = 'MS' AND time_per_name = 'DR' THEN 'BOY' 
          ELSE REPLACE(time_per_name, 'Diagnostic', 'DR')
         END AS test_round
        ,ROW_NUMBER() OVER (
           PARTITION BY academic_year, schoolid
           ORDER BY start_date ASC) AS round_num
        ,CASE WHEN start_date <= GETDATE() AND end_date >= GETDATE() THEN 1 ELSE 0 END AS is_curr
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'LIT'      
    AND schoolid = 73254 -- peg it to SPARK's date, always peg it to SPARK's date
    AND academic_year = dbo.fn_Global_Academic_Year()
    AND start_date <= GETDATE()
 )

SELECT
 --REPORTING HASHES
       CONVERT(VARCHAR,details.student_number) + '_'
        + CONVERT(VARCHAR,scores.test_round) + '_Achieved_' 
        + CONVERT(VARCHAR,scores.academic_year) + '_1'
       AS reporting_hash
      ,NULL AS reasons_for_DNA
      ,CASE 
        WHEN details.achv_curr_yr = 1 AND scores.academic_year = dbo.fn_Global_Academic_Year() AND scores.test_round = (SELECT DISTINCT test_round FROM terms WHERE is_curr = 1)
         THEN CONVERT(VARCHAR,details.student_number) + '_MostCurrent_' + CONVERT(VARCHAR,dbo.fn_Global_Academic_Year())
        ELSE NULL 
       END AS mostcurr_hash
 --STUDENT IDENTIFIERS
      ,s.schoolid
      ,s.grade_level
      ,s.studentid
      ,s.student_number
      ,s.lastfirst
      ,s.full_name       
      ,scores.academic_year
      ,scores.schoolid AS test_schoolid
      ,scores.grade_level AS test_grade_level      
      ,s.team
      ,s.advisor
      ,s.SPEDLEP
      ,grteacher.t1_teach AS read_teacher_t1
      ,grteacher.t2_teach AS read_teacher_t2
      ,grteacher.t3_teach AS read_teacher_t3
            
--TEST IDENTIFIERS      
      ,details.testid
      ,CASE WHEN LTRIM(RTRIM(scores.test_round)) IN ('Diagnostic','BOY') THEN 'DR' ELSE LTRIM(RTRIM(scores.test_round)) END AS test_round
      ,details.test_date      
      ,details.color
      ,details.genre
      ,details.status
      ,scores.read_lvl
      ,ROUND(scores.GLEQ, 1, 1) AS GLEQ
      ,scores.lvl_num
      ,details.instruct_lvl
      ,details.indep_lvl
      ,scores.fp_wpmrate
      ,scores.fp_keylever
      ,CASE 
        WHEN scores.met_goal = 1 THEN 'On Track'
        WHEN scores.met_goal = 0 THEN 'Off Track'
        ELSE NULL
       END AS met_goal
      ,details.levels_behind
      ,goals_wide.goal_dr
      ,goals_wide.goal_t1
      ,goals_wide.goal_t2
      ,goals_wide.goal_t3
      ,goals_wide.goal_eoy
      
-- GROWTH MEASURES      
      ,growth.t1_growth_GLEQ AS DRT1_GLEQ
      ,growth.t1_growth_lvl AS DRT1_lvl
      ,growth.t1t2_growth_GLEQ AS T1T2_GLEQ
      ,growth.t1t2_growth_lvl AS T1T2_lvl
      ,growth.t2t3_growth_GLEQ AS T2T3_GLEQ
      ,growth.t2t3_growth_lvl AS T2T3_lvl
      ,growth.t3EOY_growth_GLEQ AS T3EOY_GLEQ
      ,growth.t3EOY_growth_lvl AS T3EOY_lvl
      ,ISNULL(growth.yr_growth_GLEQ,0) AS YTD_GLEQ
      ,ISNULL(growth.yr_growth_lvl,0) AS YTD_lvl
            
--MAP Reading
-- most recent test, if none, then baseline
      ,COALESCE(map.testritscore, base.testritscore) AS map_reading_rit
      ,COALESCE(map.testpercentile, base.testpercentile) AS map_reading_pct
      ,COALESCE(map.rittoreadingscore, base.lexile_score) AS lexile
      ,COALESCE(map.rittoreadingmax, base_detail.rittoreadingmax) AS lexile_max
      ,COALESCE(map.rittoreadingmin, base_detail.rittoreadingmin) AS lexile_min
      ,COALESCE(map.goal1name, base_detail.goal1name) AS goal1name
      ,COALESCE(map.goal1adjective, base_detail.goal1adjective) AS goal1adjective
      ,COALESCE(map.goal1ritscore, base_detail.goal1ritscore) AS goal1ritscore
      ,COALESCE(map.goal2name, base_detail.goal2name) AS goal2name
      ,COALESCE(map.goal2adjective, base_detail.goal2adjective) AS goal2adjective
      ,COALESCE(map.goal2ritscore, base_detail.goal2ritscore) AS goal2ritscore
      ,COALESCE(map.goal3name, base_detail.goal3name) AS goal3name
      ,COALESCE(map.goal3adjective, base_detail.goal3adjective) AS goal3adjective
      ,COALESCE(map.goal3ritscore, base_detail.goal3ritscore) AS goal3ritscore
      ,COALESCE(map.goal4name, base_detail.goal4name) AS goal4name
      ,COALESCE(map.goal4adjective, base_detail.goal4adjective) AS goal4adjective
      ,COALESCE(map.goal4ritscore, base_detail.goal4ritscore) AS goal4ritscore
      ,COALESCE(map.goal5name, base_detail.goal5name) AS goal5name
      ,COALESCE(map.goal5adjective, base_detail.goal5adjective) AS goal5adjective
      ,COALESCE(map.goal5ritscore, base_detail.goal5ritscore) AS goal5ritscore            
FROM LIT$achieved_by_round#static scores WITH(NOLOCK)      
JOIN LIT$test_events#identifiers details WITH(NOLOCK)
  ON scores.unique_id = details.unique_id
 AND details.status = 'Achieved'
LEFT OUTER JOIN LIT$growth_measures_wide#static growth WITH(NOLOCK)
  ON scores.studentid = growth.STUDENTID
 AND scores.academic_year = growth.year
JOIN COHORT$identifiers_long#static s WITH(NOLOCK)
  ON scores.studentid = s.studentid
 AND s.GRADE_LEVEL < 5
 AND s.year = dbo.fn_Global_Academic_Year()
 AND s.rn = 1
LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH (NOLOCK)
  ON scores.studentid = map.ps_studentid 
 AND scores.academic_year = map.map_year_academic
 AND map.measurementscale = 'Reading'
 AND map.rn_curr = 1
LEFT OUTER JOIN MAP$best_baseline#static base
  ON scores.STUDENTID = base.studentid
 AND scores.academic_year = base.year
 AND base.measurementscale = 'Reading'
LEFT OUTER JOIN MAP$comprehensive#identifiers base_detail WITH(NOLOCK)
  ON base.studentid = base_detail.ps_studentid 
 AND base.measurementscale = base_detail.measurementscale
 AND base.termname = base_detail.termname
 AND base_detail.rn = 1
LEFT OUTER JOIN [AUTOLOAD$GDOCS_LIT_GR_Group] grteacher WITH(NOLOCK)
  ON s.STUDENT_NUMBER = grteacher.student_number
LEFT OUTER JOIN goals_wide
  ON scores.STUDENTID = goals_wide.studentid
WHERE scores.academic_year >= dbo.fn_Global_Academic_Year()
  AND scores.test_round IN (SELECT test_round FROM terms WITH(NOLOCK))

UNION ALL

SELECT
 --REPORTING HASHES
       CONVERT(VARCHAR,scores.student_number) + '_'
        + CONVERT(VARCHAR,test_round) + '_Did Not Achieve_' 
        + CONVERT(VARCHAR, academic_year) + '_'
        + CONVERT(VARCHAR,dna_round) 
       AS reporting_hash
      ,dna.dna_reason AS reasons_for_DNA
      ,NULL AS mostcurr_hash
 --STUDENT IDENTIFIERS
      ,s.schoolid
      ,s.grade_level
      ,scores.studentid
      ,scores.student_number
      ,scores.lastfirst
      ,s.full_name       
      ,scores.academic_year
      ,scores.schoolid AS test_schoolid
      ,scores.grade_level AS test_grade_level      
      ,s.team
      ,s.advisor
      ,s.SPEDLEP
      ,grteacher.t1_teach AS read_teacher_t1
      ,grteacher.t2_teach AS read_teacher_t2
      ,grteacher.t3_teach AS read_teacher_t3
            
--TEST IDENTIFIERS      
      ,scores.testid
      ,CASE WHEN LTRIM(RTRIM(scores.test_round)) IN ('Diagnostic','BOY') THEN 'DR' ELSE LTRIM(RTRIM(scores.test_round)) END AS test_round
      ,scores.test_date      
      ,scores.color
      ,scores.genre
      ,'Did Not Achieve' AS status
      ,scores.read_lvl
      ,ROUND(scores.GLEQ, 1, 1) AS GLEQ
      ,scores.lvl_num
      ,scores.instruct_lvl
      ,scores.indep_lvl
      ,scores.fp_wpmrate
      ,scores.fp_keylever
      ,CASE 
        WHEN scores.met_goal = 1 THEN 'On Track'
        WHEN scores.met_goal = 0 THEN 'Off Track'
        ELSE NULL
       END AS met_goal
      ,scores.levels_behind
      ,goals_wide.goal_dr
      ,goals_wide.goal_t1
      ,goals_wide.goal_t2
      ,goals_wide.goal_t3
      ,goals_wide.goal_eoy
      
-- GROWTH MEASURES      
      ,growth.t1_growth_GLEQ AS DRT1_GLEQ
      ,growth.t1_growth_lvl AS DRT1_lvl
      ,growth.t1t2_growth_GLEQ AS T1T2_GLEQ
      ,growth.t1t2_growth_lvl AS T1T2_lvl
      ,growth.t2t3_growth_GLEQ AS T2T3_GLEQ
      ,growth.t2t3_growth_lvl AS T2T3_lvl
      ,growth.t3EOY_growth_GLEQ AS T3EOY_GLEQ
      ,growth.t3EOY_growth_lvl AS T3EOY_lvl
      ,growth.yr_growth_GLEQ AS YTD_GLEQ
      ,growth.yr_growth_lvl AS YTD_lvl

--MAP Reading
-- most recent test, if none, then baseline
      ,COALESCE(map.testritscore, base.testritscore) AS map_reading_rit
      ,COALESCE(map.testpercentile, base.testpercentile) AS map_reading_pct
      ,COALESCE(map.rittoreadingscore, base.lexile_score) AS lexile
      ,COALESCE(map.rittoreadingmax, base_detail.rittoreadingmax) AS lexile_max
      ,COALESCE(map.rittoreadingmin, base_detail.rittoreadingmin) AS lexile_min
      ,COALESCE(map.goal1name, base_detail.goal1name) AS goal1name
      ,COALESCE(map.goal1adjective, base_detail.goal1adjective) AS goal1adjective
      ,COALESCE(map.goal1ritscore, base_detail.goal1ritscore) AS goal1ritscore
      ,COALESCE(map.goal2name, base_detail.goal2name) AS goal2name
      ,COALESCE(map.goal2adjective, base_detail.goal2adjective) AS goal2adjective
      ,COALESCE(map.goal2ritscore, base_detail.goal2ritscore) AS goal2ritscore
      ,COALESCE(map.goal3name, base_detail.goal3name) AS goal3name
      ,COALESCE(map.goal3adjective, base_detail.goal3adjective) AS goal3adjective
      ,COALESCE(map.goal3ritscore, base_detail.goal3ritscore) AS goal3ritscore
      ,COALESCE(map.goal4name, base_detail.goal4name) AS goal4name
      ,COALESCE(map.goal4adjective, base_detail.goal4adjective) AS goal4adjective
      ,COALESCE(map.goal4ritscore, base_detail.goal4ritscore) AS goal4ritscore
      ,COALESCE(map.goal5name, base_detail.goal5name) AS goal5name
      ,COALESCE(map.goal5adjective, base_detail.goal5adjective) AS goal5adjective
      ,COALESCE(map.goal5ritscore, base_detail.goal5ritscore) AS goal5ritscore                      
FROM LIT$test_events#identifiers scores WITH(NOLOCK)      
LEFT OUTER JOIN LIT$dna_reasons dna WITH(NOLOCK)
  ON scores.unique_id = dna.unique_id
LEFT OUTER JOIN LIT$growth_measures_wide#static growth WITH(NOLOCK)
  ON scores.studentid = growth.STUDENTID
 AND scores.academic_year = growth.year
JOIN COHORT$identifiers_long#static s WITH(NOLOCK)
  ON scores.studentid = s.studentid
 AND s.GRADE_LEVEL < 5
 AND s.year = dbo.fn_Global_Academic_Year()
 AND s.rn = 1
LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH (NOLOCK)
  ON scores.studentid = map.ps_studentid 
 AND scores.academic_year = map.map_year_academic
 AND map.measurementscale = 'Reading'
 AND map.rn_curr = 1
LEFT OUTER JOIN MAP$best_baseline#static base WITH(NOLOCK)
  ON scores.STUDENTID = base.studentid 
 AND scores.academic_year = base.year
 AND base.measurementscale = 'Reading'
LEFT OUTER JOIN MAP$comprehensive#identifiers base_detail WITH(NOLOCK)
  ON base.studentid = base_detail.ps_studentid 
 AND base.measurementscale = base_detail.measurementscale
 AND base.termname = base_detail.termname
 AND base_detail.rn = 1
LEFT OUTER JOIN [AUTOLOAD$GDOCS_LIT_GR_Group] grteacher WITH(NOLOCK)
  ON s.STUDENT_NUMBER = grteacher.student_number
LEFT OUTER JOIN goals_wide
  ON scores.STUDENTID = goals_wide.studentid
WHERE scores.academic_year >= dbo.fn_Global_Academic_Year()
  AND scores.status = 'Did Not Achieve'