USE KIPP_NJ
GO

ALTER VIEW AR$progress_to_goal_wide AS 

WITH long_data AS (
  SELECT student_number
        ,academic_year
        ,CONCAT(time_period_name,'_',field) AS pivot_field
        ,value
  FROM
      (
       SELECT ar.student_number
             ,ar.academic_year
             ,CASE WHEN ar.time_period_name = 'Year' THEN 'Y1' ELSE ar.time_period_name END AS time_period_name
             ,CONVERT(FLOAT,ar.words_goal) AS words_goal
             ,CONVERT(FLOAT,ar.points_goal) AS points_goal
             ,CONVERT(FLOAT,ar.words) AS words
             ,CONVERT(FLOAT,ar.points) AS points
             ,ROUND((CONVERT(FLOAT,ar.words) / CASE WHEN ar.words_goal = 0 THEN NULL ELSE CONVERT(FLOAT,ar.words_goal) END) * 100,1) AS pct_to_goal_words
             ,ROUND((CONVERT(FLOAT,ar.points) / CASE WHEN ar.points_goal = 0 THEN NULL ELSE CONVERT(FLOAT,ar.points_goal) END) * 100,1) AS pct_to_goal_points
             ,CONVERT(FLOAT,ar.mastery) AS mastery
             ,CONVERT(FLOAT,ar.mastery_fiction) AS mastery_fiction
             ,CONVERT(FLOAT,ar.mastery_nonfiction) AS mastery_nonfiction
             ,CONVERT(FLOAT,ar.pct_fiction) AS pct_fiction
             ,CONVERT(FLOAT,100 - ar.pct_fiction) AS pct_nonfiction
             ,CONVERT(FLOAT,ar.avg_lexile) AS avg_lexile
             ,ROUND((CONVERT(FLOAT,ar.N_passed) / CASE WHEN ar.N_total = 0 THEN NULL ELSE CONVERT(FLOAT,ar.N_total) END) * 100,1) AS pct_passed                 
             ,CONVERT(FLOAT,ar.ontrack_words) AS ontrack_words
             ,CONVERT(FLOAT,ar.ontrack_points) AS ontrack_points           
             ,CONVERT(FLOAT,ar.words_needed) AS words_needed
             ,CONVERT(FLOAT,ar.points_needed) AS points_needed
             ,CONVERT(FLOAT,ar.rank_words_grade_in_school) AS rank_words_grade_in_school
             ,CONVERT(FLOAT,ar.rank_words_overall_in_school) AS rank_words_overall_in_school
             ,CONVERT(FLOAT,ar.rank_points_grade_in_school) AS rank_points_grade_in_school      
             ,CONVERT(FLOAT,ar.rank_points_overall_in_school) AS rank_points_overall_in_school
       FROM KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
       UNION ALL
       SELECT ar.student_number
             ,ar.academic_year
             ,'CUR' AS time_period_name
             ,CONVERT(FLOAT,ar.words_goal) AS words_goal
             ,CONVERT(FLOAT,ar.points_goal) AS points_goal
             ,CONVERT(FLOAT,ar.words) AS words
             ,CONVERT(FLOAT,ar.points) AS points
             ,ROUND((CONVERT(FLOAT,ar.words) / CASE WHEN ar.words_goal = 0 THEN NULL ELSE CONVERT(FLOAT,ar.words_goal) END) * 100,1) AS pct_to_goal_words
             ,ROUND((CONVERT(FLOAT,ar.points) / CASE WHEN ar.points_goal = 0 THEN NULL ELSE CONVERT(FLOAT,ar.points_goal) END) * 100,1) AS pct_to_goal_points
             ,CONVERT(FLOAT,ar.mastery) AS mastery
             ,CONVERT(FLOAT,ar.mastery_fiction) AS mastery_fiction
             ,CONVERT(FLOAT,ar.mastery_nonfiction) AS mastery_nonfiction
             ,CONVERT(FLOAT,ar.pct_fiction) AS pct_fiction
             ,CONVERT(FLOAT,100 - ar.pct_fiction) AS pct_nonfiction
             ,CONVERT(FLOAT,ar.avg_lexile) AS avg_lexile
             ,ROUND((CONVERT(FLOAT,ar.N_passed) / CASE WHEN ar.N_total = 0 THEN NULL ELSE CONVERT(FLOAT,ar.N_total) END) * 100,1) AS pct_passed                 
             ,CONVERT(FLOAT,ar.ontrack_words) AS ontrack_words
             ,CONVERT(FLOAT,ar.ontrack_points) AS ontrack_points           
             ,CONVERT(FLOAT,ar.words_needed) AS words_needed
             ,CONVERT(FLOAT,ar.points_needed) AS points_needed
             ,CONVERT(FLOAT,ar.rank_words_grade_in_school) AS rank_words_grade_in_school
             ,CONVERT(FLOAT,ar.rank_words_overall_in_school) AS rank_words_overall_in_school
             ,CONVERT(FLOAT,ar.rank_points_grade_in_school) AS rank_points_grade_in_school      
             ,CONVERT(FLOAT,ar.rank_points_overall_in_school) AS rank_points_overall_in_school
       FROM KIPP_NJ..AR$progress_to_goals_long#static ar WITH(NOLOCK)
       JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
         ON ar.schoolid = dts.schoolid
        AND ar.academic_year = dts.academic_year
        AND ar.time_period_name = dts.time_per_name
        AND dts.identifier = 'AR' 
        AND CONVERT(DATE,GETDATE()) BETWEEN dts.start_date AND dts.end_date
      ) sub
  UNPIVOT(
    value
    FOR field IN (words_goal
                 ,points_goal
                 ,words
                 ,points
                 ,pct_to_goal_words
                 ,pct_to_goal_points
                 ,mastery
                 ,mastery_fiction
                 ,mastery_nonfiction
                 ,pct_fiction
                 ,pct_nonfiction
                 ,avg_lexile
                 ,pct_passed
                 --,last_book
                 ,ontrack_words
                 ,ontrack_points
                 --,stu_status_words
                 --,stu_status_points
                 ,words_needed
                 ,points_needed
                 ,rank_words_grade_in_school
                 ,rank_words_overall_in_school
                 ,rank_points_grade_in_school
                 ,rank_points_overall_in_school)
   ) u
 )

SELECT *
FROM long_data
PIVOT(
  MAX(value)
  FOR pivot_field IN ([CUR_avg_lexile]
                     ,[CUR_mastery]
                     ,[CUR_mastery_fiction]
                     ,[CUR_mastery_nonfiction]
                     ,[CUR_ontrack_points]
                     ,[CUR_ontrack_words]
                     ,[CUR_pct_fiction]
                     ,[CUR_pct_nonfiction]
                     ,[CUR_pct_passed]
                     ,[CUR_pct_to_goal_points]
                     ,[CUR_pct_to_goal_words]
                     ,[CUR_points]
                     ,[CUR_points_goal]
                     ,[CUR_points_needed]
                     ,[CUR_rank_points_grade_in_school]
                     ,[CUR_rank_points_overall_in_school]
                     ,[CUR_rank_words_grade_in_school]
                     ,[CUR_rank_words_overall_in_school]
                     ,[CUR_words]
                     ,[CUR_words_goal]
                     ,[CUR_words_needed]
                     ,[RT1_avg_lexile]
                     ,[RT1_mastery]
                     ,[RT1_mastery_fiction]
                     ,[RT1_mastery_nonfiction]
                     ,[RT1_ontrack_points]
                     ,[RT1_ontrack_words]
                     ,[RT1_pct_fiction]
                     ,[RT1_pct_nonfiction]
                     ,[RT1_pct_passed]
                     ,[RT1_pct_to_goal_points]
                     ,[RT1_pct_to_goal_words]
                     ,[RT1_points]
                     ,[RT1_points_goal]
                     ,[RT1_points_needed]
                     ,[RT1_rank_points_grade_in_school]
                     ,[RT1_rank_points_overall_in_school]
                     ,[RT1_rank_words_grade_in_school]
                     ,[RT1_rank_words_overall_in_school]
                     ,[RT1_words]
                     ,[RT1_words_goal]
                     ,[RT1_words_needed]
                     ,[RT2_avg_lexile]
                     ,[RT2_mastery]
                     ,[RT2_mastery_fiction]
                     ,[RT2_mastery_nonfiction]
                     ,[RT2_ontrack_points]
                     ,[RT2_ontrack_words]
                     ,[RT2_pct_fiction]
                     ,[RT2_pct_nonfiction]
                     ,[RT2_pct_passed]
                     ,[RT2_pct_to_goal_points]
                     ,[RT2_pct_to_goal_words]
                     ,[RT2_points]
                     ,[RT2_points_goal]
                     ,[RT2_rank_points_grade_in_school]
                     ,[RT2_rank_points_overall_in_school]
                     ,[RT2_rank_words_grade_in_school]
                     ,[RT2_rank_words_overall_in_school]
                     ,[RT2_words]
                     ,[RT2_words_goal]
                     ,[RT3_avg_lexile]
                     ,[RT3_mastery]
                     ,[RT3_mastery_fiction]
                     ,[RT3_mastery_nonfiction]
                     ,[RT3_ontrack_points]
                     ,[RT3_ontrack_words]
                     ,[RT3_pct_fiction]
                     ,[RT3_pct_nonfiction]
                     ,[RT3_pct_passed]
                     ,[RT3_pct_to_goal_points]
                     ,[RT3_pct_to_goal_words]
                     ,[RT3_points]
                     ,[RT3_points_goal]
                     ,[RT3_rank_points_grade_in_school]
                     ,[RT3_rank_points_overall_in_school]
                     ,[RT3_rank_words_grade_in_school]
                     ,[RT3_rank_words_overall_in_school]
                     ,[RT3_words]
                     ,[RT3_words_goal]
                     ,[RT4_avg_lexile]
                     ,[RT4_mastery]
                     ,[RT4_mastery_fiction]
                     ,[RT4_mastery_nonfiction]
                     ,[RT4_ontrack_points]
                     ,[RT4_ontrack_words]
                     ,[RT4_pct_fiction]
                     ,[RT4_pct_nonfiction]
                     ,[RT4_pct_passed]
                     ,[RT4_pct_to_goal_points]
                     ,[RT4_pct_to_goal_words]
                     ,[RT4_points]
                     ,[RT4_points_goal]
                     ,[RT4_rank_points_grade_in_school]
                     ,[RT4_rank_points_overall_in_school]
                     ,[RT4_rank_words_grade_in_school]
                     ,[RT4_rank_words_overall_in_school]
                     ,[RT4_words]
                     ,[RT4_words_goal]
                     ,[RT5_avg_lexile]
                     ,[RT5_mastery]
                     ,[RT5_mastery_fiction]
                     ,[RT5_mastery_nonfiction]
                     ,[RT5_ontrack_words]
                     ,[RT5_pct_fiction]
                     ,[RT5_pct_nonfiction]
                     ,[RT5_pct_passed]
                     ,[RT5_pct_to_goal_words]
                     ,[RT5_points]
                     ,[RT5_rank_points_grade_in_school]
                     ,[RT5_rank_points_overall_in_school]
                     ,[RT5_rank_words_grade_in_school]
                     ,[RT5_rank_words_overall_in_school]
                     ,[RT5_words]
                     ,[RT5_words_goal]
                     ,[RT6_avg_lexile]
                     ,[RT6_mastery]
                     ,[RT6_mastery_fiction]
                     ,[RT6_mastery_nonfiction]
                     ,[RT6_ontrack_words]
                     ,[RT6_pct_fiction]
                     ,[RT6_pct_nonfiction]
                     ,[RT6_pct_passed]
                     ,[RT6_pct_to_goal_words]
                     ,[RT6_points]
                     ,[RT6_rank_points_grade_in_school]
                     ,[RT6_rank_points_overall_in_school]
                     ,[RT6_rank_words_grade_in_school]
                     ,[RT6_rank_words_overall_in_school]
                     ,[RT6_words]
                     ,[RT6_words_goal]
                     ,[Y1_avg_lexile]
                     ,[Y1_mastery]
                     ,[Y1_mastery_fiction]
                     ,[Y1_mastery_nonfiction]
                     ,[Y1_ontrack_points]
                     ,[Y1_ontrack_words]
                     ,[Y1_pct_fiction]
                     ,[Y1_pct_nonfiction]
                     ,[Y1_pct_passed]
                     ,[Y1_pct_to_goal_points]
                     ,[Y1_pct_to_goal_words]
                     ,[Y1_points]
                     ,[Y1_points_goal]
                     ,[Y1_points_needed]
                     ,[Y1_rank_points_grade_in_school]
                     ,[Y1_rank_points_overall_in_school]
                     ,[Y1_rank_words_grade_in_school]
                     ,[Y1_rank_words_overall_in_school]
                     ,[Y1_words]
                     ,[Y1_words_goal]
                     ,[Y1_words_needed])
 ) p