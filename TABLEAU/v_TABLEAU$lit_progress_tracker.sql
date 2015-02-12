USE KIPP_NJ
GO

USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_progress_tracker AS

SELECT co.school_name
      ,co.student_number
      ,co.lastfirst AS student_name
      ,co.grade_level
      ,co.cohort
      ,co.team
      ,co.advisor
      ,co.year AS academic_year      
      ,co.GENDER
      ,co.SPEDLEP AS IEP_status
      ,co.enroll_status
      ,enr.illuminate_group
      ,gr.t1_teach
      ,gr.t2_teach
      ,gr.t3_teach
      ,achv.test_round
      ,testid.status      
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.goal_lvl
      ,achv.goal_num
      ,testid.instruct_lvl
      ,achv.indep_lvl
      ,achv.GLEQ      
      ,testid.color
      ,testid.genre
      ,CONVERT(FLOAT,achv.met_goal) AS met_goal      
      ,growth.t1_growth_lvl AS DRT1_growth_lvl
      ,growth.t1_growth_GLEQ AS DRT1_growth_GLEQ
      ,growth.T1T2_growth_lvl
      ,growth.T1T2_growth_GLEQ
      ,growth.T2T3_growth_lvl
      ,growth.T2T3_growth_GLEQ
      ,growth.T3EOY_growth_lvl
      ,growth.T3EOY_growth_GLEQ
      ,long.unique_id      
      ,long.domain AS component_domain
      ,long.label AS component_strand
      ,long.score AS component_score
      ,long.benchmark AS component_benchmark
      ,long.is_prof AS component_prof
      ,long.margin AS component_margin      
      ,map.goal1name
      ,map.goal1ritscore
      ,map.goal1adjective
      ,map.goal2name
      ,map.goal2ritscore
      ,map.goal2adjective
      ,map.goal3name
      ,map.goal3ritscore
      ,map.goal3adjective
      ,map.goal4name
      ,map.goal4ritscore
      ,map.goal4adjective
      ,map.goal5name
      ,map.goal5ritscore
      ,map.goal5adjective
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr WITH(NOLOCK)
  ON co.studentid = enr.STUDENTID
 AND co.year = enr.academic_year 
 AND enr.measurementscale = 'Reading'
LEFT OUTER JOIN KIPP_NJ..[AUTOLOAD$GDOCS_LIT_GR_Group] gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
LEFT OUTER JOIN MAP$comprehensive#identifiers#static map WITH(NOLOCK)
  ON co.studentid = map.ps_studentid
 AND co.year = map.map_year_academic
 AND map.measurementscale = 'Reading'
 AND map.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..LIT$growth_measures_wide#static growth WITH(NOLOCK)
  ON co.studentid = growth.STUDENTID
 AND co.year = growth.YEAR
JOIN KIPP_NJ..LIT$achieved_by_round#static achv WITH(NOLOCK)
  ON co.studentid = achv.STUDENTID
 AND co.year = achv.academic_year
JOIN KIPP_NJ..LIT$test_events#identifiers testid WITH(NOLOCK)
  ON co.studentid = testid.studentid
 AND achv.unique_id = testid.unique_id
JOIN KIPP_NJ..LIT$readingscores_long long WITH(NOLOCK)
  ON co.studentid = long.studentid
 AND achv.unique_id = long.unique_id
WHERE co.rn = 1
  AND co.grade_level <= 8

UNION ALL

SELECT co.school_name
      ,co.student_number
      ,co.lastfirst AS student_name
      ,co.grade_level
      ,co.cohort
      ,co.team
      ,co.advisor
      ,co.year AS academic_year      
      ,co.GENDER
      ,co.SPEDLEP AS IEP_status
      ,co.enroll_status
      ,enr.illuminate_group
      ,gr.t1_teach
      ,gr.t2_teach
      ,gr.t3_teach
      ,achv.test_round
      ,testid.status      
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.goal_lvl
      ,achv.goal_num
      ,testid.instruct_lvl
      ,achv.indep_lvl
      ,achv.GLEQ      
      ,testid.color
      ,testid.genre
      ,CONVERT(FLOAT,achv.met_goal) AS met_goal      
      ,growth.t1_growth_lvl AS DRT1_growth_lvl
      ,growth.t1_growth_GLEQ AS DRT1_growth_GLEQ
      ,growth.T1T2_growth_lvl
      ,growth.T1T2_growth_GLEQ
      ,growth.T2T3_growth_lvl
      ,growth.T2T3_growth_GLEQ
      ,growth.T3EOY_growth_lvl
      ,growth.T3EOY_growth_GLEQ
      ,long.unique_id      
      ,long.domain AS component_domain
      ,long.label AS component_strand
      ,long.score AS component_score
      ,long.benchmark AS component_benchmark
      ,long.is_prof AS component_prof
      ,long.margin AS component_margin      
      ,map.goal1name
      ,map.goal1ritscore
      ,map.goal1adjective
      ,map.goal2name
      ,map.goal2ritscore
      ,map.goal2adjective
      ,map.goal3name
      ,map.goal3ritscore
      ,map.goal3adjective
      ,map.goal4name
      ,map.goal4ritscore
      ,map.goal4adjective
      ,map.goal5name
      ,map.goal5ritscore
      ,map.goal5adjective
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr WITH(NOLOCK)
  ON co.studentid = enr.STUDENTID
 AND co.year = enr.academic_year 
 AND enr.measurementscale = 'Reading'
LEFT OUTER JOIN KIPP_NJ..[AUTOLOAD$GDOCS_LIT_GR_Group] gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
LEFT OUTER JOIN MAP$comprehensive#identifiers#static map WITH(NOLOCK)
  ON co.studentid = map.ps_studentid
 AND co.year = map.map_year_academic
 AND map.measurementscale = 'Reading'
 AND map.rn_curr = 1
LEFT OUTER JOIN KIPP_NJ..LIT$growth_measures_wide#static growth WITH(NOLOCK)
  ON co.studentid = growth.STUDENTID
 AND co.year = growth.YEAR
JOIN KIPP_NJ..LIT$achieved_by_round#static achv WITH(NOLOCK)
  ON co.studentid = achv.STUDENTID
 AND co.year = achv.academic_year
JOIN KIPP_NJ..LIT$test_events#identifiers testid WITH(NOLOCK)
  ON co.studentid = testid.studentid
 AND co.year = testid.academic_year
 AND achv.test_round = testid.test_round
 AND testid.dna_round = 1
JOIN KIPP_NJ..LIT$readingscores_long long WITH(NOLOCK)
  ON co.studentid = long.studentid
 AND testid.unique_id = long.unique_id
WHERE co.rn = 1
  AND co.grade_level <= 8