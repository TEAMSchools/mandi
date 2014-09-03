USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[LIT$progress_tracker] AS

SELECT
 --REPORTING HASHES
       CONVERT(VARCHAR,details.student_number) + '_'
        + CONVERT(VARCHAR,scores.test_round) + '_' 
        + 'Achieved_' 
        + CONVERT(VARCHAR,details.academic_year) + '_'
        + '1'
       AS reporting_hash
      ,NULL AS reasons_for_DNA
      ,CASE WHEN details.achv_curr_yr = 1 THEN CONVERT(VARCHAR,details.student_number) + '_MostCurrent_' + CONVERT(VARCHAR,scores.academic_year) ELSE NULL END AS mostcurr_hash
 --STUDENT IDENTIFIERS
      ,s.schoolid
      ,s.grade_level
      ,s.id AS studentid
      ,s.student_number
      ,s.lastfirst
      ,s.FIRST_NAME + ' ' + s.LAST_NAME AS full_name       
      ,scores.academic_year
      ,scores.schoolid AS test_schoolid
      ,scores.grade_level AS test_grade_level      
      ,s.team
      ,cs.advisor
      ,cs.SPEDLEP
      ,NULL AS read_teacher      
            
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
FROM LIT$achieved_by_round#static scores WITH(NOLOCK)      
JOIN LIT$test_events#identifiers details WITH(NOLOCK)
  ON scores.unique_id = details.unique_id
 AND details.status = 'Achieved'
LEFT OUTER JOIN LIT$growth_measures_wide#static growth WITH(NOLOCK)
  ON scores.studentid = growth.STUDENTID
 AND scores.academic_year = growth.year
JOIN STUDENTS s WITH(NOLOCK)
  ON scores.studentid = s.id
 AND s.GRADE_LEVEL < 5
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
  ON scores.studentid = cs.studentid
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
  ON base.studentid = base_detail.studentid
 AND base.year = base_detail.map_year_academic
 AND base.measurementscale = base_detail.measurementscale
 AND base.termname = base_detail.termname
 AND base_detail.rn = 1
WHERE scores.academic_year >= dbo.fn_Global_Academic_Year()

UNION ALL

SELECT
 --REPORTING HASHES
       CONVERT(VARCHAR,scores.student_number) + '_'
        + CONVERT(VARCHAR,test_round) + '_' 
        + 'Did Not Achieve_' 
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
      ,s.FIRST_NAME + ' ' + s.LAST_NAME AS full_name       
      ,scores.academic_year
      ,scores.schoolid AS test_schoolid
      ,scores.grade_level AS test_grade_level      
      ,s.team
      ,cs.advisor
      ,cs.SPEDLEP
      ,NULL AS read_teacher      
            
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
      
-- GROWTH MEASURES      
      ,NULL AS DRT1_GLEQ
      ,NULL AS DRT1_lvl
      ,NULL AS T1T2_GLEQ
      ,NULL AS T1T2_lvl
      ,NULL AS T2T3_GLEQ
      ,NULL AS T2T3_lvl
      ,NULL AS T3EOY_GLEQ
      ,NULL AS T3EOY_lvl
      ,NULL AS YTD_GLEQ
      ,NULL AS YTD_lvl

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
--LEFT OUTER JOIN LIT$growth_measures_wide growth WITH(NOLOCK)
--  ON scores.studentid = growth.STUDENTID
-- AND scores.academic_year = growth.year
JOIN STUDENTS s WITH(NOLOCK)
  ON scores.studentid = s.id
 AND s.GRADE_LEVEL < 5
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
  ON scores.studentid = cs.studentid
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
  ON base.studentid = base_detail.studentid
 AND base.year = base_detail.map_year_academic
 AND base.measurementscale = base_detail.measurementscale
 AND base.termname = base_detail.termname
 AND base_detail.rn = 1
WHERE scores.academic_year >= dbo.fn_Global_Academic_Year()
  AND scores.status = 'Did Not Achieve'