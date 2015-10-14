USE KIPP_NJ
GO

ALTER VIEW REPORTING$reading_log#NCA AS

WITH curterm AS (
  SELECT time_per_name
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE schoolid = 73253
    AND identifier = 'RT'
    AND CONVERT(DATE,GETDATE()) BETWEEN start_date AND end_date
 )

SELECT s.LASTFIRST
      ,s.FIRST_NAME
      ,s.LAST_NAME
      ,s.ADVISOR
      ,s.GRADE_LEVEL
      ,s.SPEDLEP
      
      ,CASE WHEN ar_Q1.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,ar_q1.points_goal) END AS AR_goal_Q1
      ,CASE WHEN ar_q2.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,ar_q2.points_goal) END AS AR_goal_Q2
      ,CASE WHEN ar_q3.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,ar_q3.points_goal) END AS AR_goal_Q3
      ,CASE WHEN ar_q4.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,ar_q4.points_goal) END AS AR_goal_Q4
      ,CASE WHEN ar_yr.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,ar_yr.points_goal) END AS AR_goal_yr
      ,ar_Q1.points AS AR_Pts_Q1
      ,ar_q2.points AS AR_Pts_Q2
      ,ar_q3.points AS AR_Pts_Q3
      ,ar_q4.points AS AR_Pts_Q4
      ,ar_yr.points AS AR_Pts_Yr      
      ,CASE WHEN (ar_q1.points_goal - ar_q1.points) <= 0 THEN 0 ELSE (ar_q1.points_goal - ar_q1.points) END AS AR_pts_to_goal_Q1
      ,CASE WHEN (ar_q2.points_goal - ar_q2.points) <= 0 THEN 0 ELSE (ar_q2.points_goal - ar_q2.points) END AS AR_pts_to_goal_Q2
      ,CASE WHEN (ar_q3.points_goal - ar_q3.points) <= 0 THEN 0 ELSE (ar_q3.points_goal - ar_q3.points) END AS AR_pts_to_goal_Q3
      ,CASE WHEN (ar_q4.points_goal - ar_q4.points) <= 0 THEN 0 ELSE (ar_q4.points_goal - ar_q4.points) END AS AR_pts_to_goal_Q4
      ,CASE WHEN (ar_yr.points_goal - ar_yr.points) <= 0 THEN 0 ELSE (ar_yr.points_goal - ar_yr.points) END AS AR_pts_to_goal_Yr
      ,CASE WHEN ar_cur.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,CONVERT(FLOAT,ROUND((ar_cur.points / ar_cur.points_goal * 100),1))) END AS AR_progress_cur
      ,CASE WHEN ar_q1.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,CONVERT(FLOAT,ROUND((ar_q1.points / ar_q1.points_goal * 100),1))) END AS AR_pct_of_goal_Q1
      ,CASE WHEN ar_q2.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,CONVERT(FLOAT,ROUND((ar_q2.points / ar_q2.points_goal * 100),1))) END AS AR_pct_of_goal_q2
      ,CASE WHEN ar_q3.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,CONVERT(FLOAT,ROUND((ar_q3.points / ar_q3.points_goal * 100),1))) END AS AR_pct_of_goal_q3
      ,CASE WHEN ar_q4.points_goal = -1 THEN 'Exempt' ELSE CONVERT(VARCHAR,CONVERT(FLOAT,ROUND((ar_q4.points / ar_q4.points_goal * 100),1))) END AS AR_pct_of_goal_q4      
      ,CASE WHEN ar_q1.points = 0 THEN 'Tied for last place with 0 points' ELSE CONVERT(VARCHAR,ar_q1.rank_points_grade_in_school) END AS AR_graderank_Q1
      ,CASE WHEN ar_q2.points = 0 THEN 'Tied for last place with 0 points' ELSE CONVERT(VARCHAR,ar_q2.rank_points_grade_in_school) END AS AR_graderank_q2
      ,CASE WHEN ar_q3.points = 0 THEN 'Tied for last place with 0 points' ELSE CONVERT(VARCHAR,ar_q3.rank_points_grade_in_school) END AS AR_graderank_q3
      ,CASE WHEN ar_q4.points = 0 THEN 'Tied for last place with 0 points' ELSE CONVERT(VARCHAR,ar_q4.rank_points_grade_in_school) END AS AR_graderank_q4
      ,CASE WHEN ar_yr.points = 0 THEN 'Tied for last place with 0 points' ELSE CONVERT(VARCHAR,ar_yr.rank_points_grade_in_school) END AS AR_graderank_yr
      ,ar_q1.rank_points_overall_in_school AS AR_schoolrank_Q1
      ,ar_q2.rank_points_overall_in_school AS AR_schoolrank_Q2
      ,ar_q3.rank_points_overall_in_school AS AR_schoolrank_Q3
      ,ar_q4.rank_points_overall_in_school AS AR_schoolrank_Q4
      ,ar_yr.rank_points_overall_in_school AS AR_schoolrank_Yr      
      
      ,CASE WHEN ROUND(((ar_cur.points / ar_cur.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_cur
      ,CASE WHEN ROUND(((ar_q1.points / ar_q1.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q1
      ,CASE WHEN ROUND(((ar_q2.points / ar_q2.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q2
      ,CASE WHEN ROUND(((ar_q3.points / ar_q3.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q3
      ,CASE WHEN ROUND(((ar_q4.points / ar_q4.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q4
      ,CASE WHEN ROUND(((ar_yr.points / ar_yr.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_yr            
      ,ar_yr.mastery AS mastery_yr      

      ,base.lexile_score AS lexile_base
      ,base.lexile_score AS lexile_fall
      ,lex_winter.rittoreadingscore AS lexile_winter
      ,lex_spring.rittoreadingscore AS lexile_spring
      ,lex_cur.rittoreadingscore AS lexile_current
      ,CONVERT(VARCHAR,lex_cur.rittoreadingmin) + ' - ' + CONVERT(VARCHAR,lex_cur.rittoreadingmax) AS lexile_range_current
      ,base.testritscore AS RIT_base
      ,lex_winter.testritscore AS RIT_winter
      ,lex_spring.testritscore AS RIT_spr
      ,rr.keep_up_rit
      ,rr.rutgers_ready_rit      
      
      ,eng1.COURSE_NAME AS eng1_course
      ,eng1.SECTION_NUMBER AS eng1_section
      ,eng1.period AS eng1_period
      ,eng1.teacher_name AS eng1_teacher
      ,eng2.COURSE_NAME AS eng2_course
      ,eng2.SECTION_NUMBER AS eng2_section
      ,eng2.period AS eng2_period
      ,eng2.teacher_name AS eng2_teacher      
      ,diff.teacher_name AS diff_block_teacher
      ,diff.period AS diff_block_period
      ,diff.COURSE_NAME AS diff_block_assignment      
FROM KIPP_NJ..COHORT$identifiers_long#static s WITH (NOLOCK)
CROSS JOIN curterm  
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON s.studentid = ar_yr.studentid 
 AND s.year = ar_yr.academic_year
 AND ar_yr.time_period_name = 'Year'
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q1 WITH (NOLOCK)
  ON s.studentid = ar_q1.studentid 
 AND s.year = ar_q1.academic_year
 AND ar_q1.time_period_name = 'RT1' 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q2 WITH (NOLOCK)
  ON s.studentid = ar_q2.studentid
 AND s.year = ar_q2.academic_year
 AND ar_q2.time_period_name = 'RT2' 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q3 WITH (NOLOCK)
  ON s.studentid = ar_q3.studentid
 AND s.year = ar_q3.academic_year
 AND ar_q3.time_period_name = 'RT3' 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q4 WITH (NOLOCK)
  ON s.studentid = ar_q4.studentid
 AND s.year = ar_q4.academic_year
 AND ar_q4.time_period_name = 'RT4' 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_cur WITH (NOLOCK)
  ON s.studentid = ar_cur.studentid
 AND s.year = ar_cur.academic_year
 AND ar_cur.time_period_name = curterm.time_per_name 
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_cur WITH (NOLOCK)
  ON s.studentid = lex_cur.studentid
 AND s.year = lex_cur.academic_year
 AND lex_cur.measurementscale  = 'Reading' 
 AND lex_cur.rn_curr = 1
LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
  ON s.studentid = rr.studentid 
 AND s.year = rr.year
 AND rr.measurementscale = 'Reading' 
LEFT OUTER JOIN MAP$best_baseline#static base WITH(NOLOCK)
  ON s.studentid = base.studentid
 AND s.year = base.year
 AND base.measurementscale = 'Reading'
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_winter WITH (NOLOCK)
  ON s.studentid = lex_winter.studentid
 AND s.year = lex_winter.academic_year 
 AND lex_winter.measurementscale  = 'Reading'  
 AND lex_winter.term = 'Winter'
 AND lex_winter.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static lex_spring WITH (NOLOCK)
  ON s.studentid = lex_spring.studentid
 AND s.year = lex_spring.academic_year
 AND lex_spring.measurementscale  = 'Reading' 
 AND lex_spring.term = 'Spring'
 AND lex_spring.rn = 1
LEFT OUTER JOIN PS$course_enrollments#static eng1 WITH(NOLOCK)                 
  ON s.studentid = eng1.STUDENTID
 AND s.year = eng1.academic_year
 AND eng1.CREDITTYPE = 'ENG'
 AND eng1.course_number NOT LIKE 'ENG0%'                                      
 AND eng1.rn_subject = 1
LEFT OUTER JOIN PS$course_enrollments#static eng2 WITH(NOLOCK)                 
  ON s.studentid = eng2.STUDENTID
 AND s.year = eng2.academic_year
 AND eng2.CREDITTYPE = 'ENG'
 AND eng2.course_number NOT LIKE 'ENG0%'                                      
 AND eng2.rn_subject = 2
LEFT OUTER JOIN PS$course_enrollments#static diff WITH (NOLOCK)
  ON s.studentid = diff.studentid 
 AND s.year = diff.academic_year
 AND diff.period IN ('LA','LB')
 AND diff.drop_flags = 0        
WHERE s.SCHOOLID = 73253
  AND s.ENROLL_STATUS = 0
  AND s.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND s.rn = 1