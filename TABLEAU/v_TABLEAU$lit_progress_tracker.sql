USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_progress_tracker AS

WITH gr_curr AS (
  SELECT student_number
        ,CASE 
          WHEN term = 'eoy_teach' THEN 'EOY'
          ELSE UPPER(LEFT(term,2)) 
         END AS term
        ,gr_teacher
  FROM
      ( 
       SELECT student_number
             ,t1_teach
             ,t2_teach
             ,t3_teach
             ,COALESCE(eoy_teach, t3_teach) AS eoy_teach
       FROM [AUTOLOAD$GDOCS_LIT_GR_Group] WITH(NOLOCK)
      ) sub
  UNPIVOT(
    gr_teacher
    FOR term IN (t1_teach, t2_teach, t3_teach, eoy_teach)
   ) u
 )

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
      ,co.LEP_STATUS
      ,co.enroll_status
      ,enr.illuminate_group
      ,gr.t1_teach
      ,gr.t2_teach
      ,gr.t3_teach
      ,gr_curr.gr_teacher AS curr_gr_teach
      ,achv.test_round
      ,testid.status      
      ,achv.read_lvl
      ,achv.lvl_num
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.natl_goal_lvl
      ,achv.natl_goal_num
      ,achv.default_goal_lvl
      ,achv.default_goal_num
      ,NULL AS last_achieved_lvl
      ,NULL AS last_achieved_num
      ,achv.lvl_num - achv.goal_num AS distance_from_goal
      ,testid.instruct_lvl
      ,achv.indep_lvl
      ,achv.GLEQ      
      ,testid.color
      ,testid.genre
      ,CONVERT(FLOAT,achv.met_goal) AS met_goal
      ,CONVERT(FLOAT,achv.met_natl_goal) AS met_natl_goal
      ,CONVERT(FLOAT,achv.met_default_goal) AS met_default_goal  
      ,CASE
        WHEN achv.test_round = 'DR' THEN NULL
        WHEN achv.test_round = 'T1' AND growth.t1_growth_lvl > 0 THEN 1.0
        WHEN achv.test_round = 'T2' AND growth.T1T2_growth_lvl > 0 THEN 1.0
        WHEN achv.test_round = 'T3' AND growth.T2T3_growth_lvl > 0 THEN 1.0
        WHEN achv.test_round = 'EOY' AND growth.T3EOY_growth_lvl > 0 THEN 1.0
        ELSE 0.0
       END AS moved_lvl
      ,growth.t1_growth_lvl AS DRT1_growth_lvl
      ,growth.t1_growth_GLEQ AS DRT1_growth_GLEQ
      ,growth.T1T2_growth_lvl
      ,growth.T1T2_growth_GLEQ
      ,growth.T2T3_growth_lvl
      ,growth.T2T3_growth_GLEQ
      ,growth.T3EOY_growth_lvl
      ,growth.T3EOY_growth_GLEQ
      ,growth.yr_growth_lvl
      ,growth.yr_growth_GLEQ
      ,long.unique_id      
      ,long.domain AS component_domain
      ,long.label AS component_strand
      ,long.specific_label AS component_strand_specific
      ,long.score AS component_score
      ,long.benchmark AS component_benchmark
      ,long.is_prof AS component_prof
      ,long.margin AS component_margin      
      ,long.dna_reason
      ,long.dna_filter
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
 AND enr.course_number LIKE '%HR%'
LEFT OUTER JOIN KIPP_NJ..[AUTOLOAD$GDOCS_LIT_GR_Group] gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map WITH(NOLOCK)
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
LEFT OUTER JOIN gr_curr
  ON co.student_number = gr_curr.student_number
 AND achv.test_round = gr_curr.term
JOIN KIPP_NJ..LIT$test_events#identifiers testid WITH(NOLOCK)
  ON co.studentid = testid.studentid
 AND achv.unique_id = testid.unique_id
 AND testid.status = 'Achieved'
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
      ,co.LEP_STATUS
      ,co.enroll_status
      ,enr.illuminate_group
      ,gr.t1_teach
      ,gr.t2_teach
      ,gr.t3_teach
      ,gr_curr.gr_teacher AS curr_gr_teach
      ,achv.test_round
      ,testid.status      
      ,testid.read_lvl
      ,testid.lvl_num
      ,achv.goal_lvl
      ,achv.goal_num
      ,achv.natl_goal_lvl
      ,achv.natl_goal_num
      ,achv.default_goal_lvl
      ,achv.default_goal_num
      ,achv.read_lvl AS last_achieved_lvl
      ,achv.lvl_num AS last_achieved_num
      ,testid.lvl_num - achv.goal_num AS distance_from_goal
      ,testid.instruct_lvl
      ,testid.indep_lvl
      ,testid.GLEQ      
      ,testid.color
      ,testid.genre
      ,CONVERT(FLOAT,achv.met_goal) AS met_goal
      ,CONVERT(FLOAT,achv.met_natl_goal) AS met_natl_goal
      ,CONVERT(FLOAT,achv.met_default_goal) AS met_default_goal
      ,CASE
        WHEN achv.test_round = 'T1' AND growth.t1_growth_lvl > 0 THEN 1.0
        WHEN achv.test_round = 'T2' AND growth.T1T2_growth_lvl > 0 THEN 1.0
        WHEN achv.test_round = 'T3' AND growth.T2T3_growth_lvl > 0 THEN 1.0
        WHEN achv.test_round = 'EOY' AND growth.T3EOY_growth_lvl > 0 THEN 1.0
        ELSE 0.0
       END AS moved_lvl
      ,growth.t1_growth_lvl AS DRT1_growth_lvl
      ,growth.t1_growth_GLEQ AS DRT1_growth_GLEQ
      ,growth.T1T2_growth_lvl
      ,growth.T1T2_growth_GLEQ
      ,growth.T2T3_growth_lvl
      ,growth.T2T3_growth_GLEQ
      ,growth.T3EOY_growth_lvl
      ,growth.T3EOY_growth_GLEQ
      ,growth.yr_growth_lvl
      ,growth.yr_growth_GLEQ
      ,long.unique_id      
      ,long.domain AS component_domain
      ,long.label AS component_strand
      ,long.specific_label AS component_strand_specific
      ,long.score AS component_score
      ,long.benchmark AS component_benchmark
      ,long.is_prof AS component_prof
      ,long.margin AS component_margin      
      ,long.dna_reason
      ,long.dna_filter
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
 AND enr.course_number LIKE '%HR%'
LEFT OUTER JOIN KIPP_NJ..[AUTOLOAD$GDOCS_LIT_GR_Group] gr WITH(NOLOCK)
  ON co.student_number = gr.student_number
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map WITH(NOLOCK)
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
LEFT OUTER JOIN gr_curr
  ON co.student_number = gr_curr.student_number
 AND achv.test_round = gr_curr.term 
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