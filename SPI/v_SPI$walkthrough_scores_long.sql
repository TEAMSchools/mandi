USE KIPP_NJ
GO

ALTER VIEW SPI$walkthrough_scores_long AS 

WITH new_format AS (
  SELECT reporting_schoolid
        ,academic_year
        ,spi_round            
        ,observation_date
        ,observer      
        ,LEFT(field, CHARINDEX('_',field) - 1) AS domain
        ,SUBSTRING(field, CHARINDEX('_',field) + 1, LEN(field)) AS strand      
        ,field
        ,score
  FROM
      (
       SELECT spi.BINI_ID
             ,CASE
               WHEN spi.school = 'TEAM' THEN 133570965
               WHEN spi.school = 'Rise' THEN 73252
               WHEN spi.school = 'NCA' THEN 73253
               WHEN spi.school = 'SPARK' THEN 73254
               WHEN spi.school = 'Seek' THEN 73256
               WHEN spi.school = 'Life' THEN 73257
               WHEN spi.school = 'BOLD' THEN 73258
               WHEN spi.school = 'THRIVE' THEN 73255
               WHEN spi.school IN ('LSP','KLSP') THEN 179901
               WHEN spi.school = 'WEK' THEN 1799015075
               WHEN spi.school = 'KWM' THEN 179903
               WHEN spi.school IN ('LSM','KLSM') THEN 179902
              END AS reporting_schoolid
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,spi.date)) AS academic_year
             ,RIGHT(dts.time_per_name,1) AS spi_round
             ,CONVERT(DATE,spi.date) AS observation_date
             ,spi.ampm
             ,spi.observer           
             ,spi.teacher_environment
             ,spi.teacher_objectiveaimagenda
             ,spi.teacher_key_message
             ,spi.teacher_goals_connected
             ,spi.teacher_warm_demanding
             ,spi.teacher_jfactor
             ,spi.teacher_directionsexpectations
             ,spi.teacher_awareness
             ,spi.teacher_effective_redirections
             ,spi.teacher_schoolgrade_systems
             ,spi.teacher_transitions
             ,spi.teacher_classroom_systems
             ,spi.teacher_flowpacing
             ,spi.teacher_ratio
             ,spi.teacher_discourse
             ,spi.teacher_formative_cfu
             ,spi.teacher_wholeclass_feedback
             ,spi.teacher_cold_calls
             ,spi.teacher_evidence
             ,spi.teacher_question_quality
             ,spi.teacher_followup_and_response
             ,spi.teacher_grade_level_expectations
             ,spi.teacher_criteria_for_success
             ,spi.teacher_individual
             ,spi.teacher_daily_mastery
             ,spi.teacher_goalobjective
             ,spi.teacher_mastery_awareness
             ,spi.student_on_task
             ,spi.student_students_engaged
             ,spi.student_one_hundred_percent
             ,spi.student_quiet_for_adults
             ,spi.student_speedurgency
             ,spi.student_effective_redirections
             ,spi.student_smallgroupblended
             ,spi.student_peer_interactions
             ,spi.culture_hallways
             ,spi.culture_bathrooms
             ,spi.culture_main_office
             ,spi.culture_respect
             ,spi.culture_character
             ,spi.culture_jfactor
             ,spi.culture_engaged
             ,spi.culture_student_work
             ,spi.culture_missionvision
             ,spi.culture_celebrations
             ,spi.culture_common_spaces
             ,spi.culture_dress_code
             ,spi.culture_quiet_for_adults
             ,spi.culture_foodgumcandy
             ,spi.culture_cell_phones
             ,spi.culture_transition_time
             ,spi.culture_arrivaldismissal
       FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_SPI_walkthrough_admin] spi WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
         ON CONVERT(DATE,spi.date) BETWEEN dts.start_date AND dts.end_date
        AND dts.identifier = 'SPI'
      ) sub
  UNPIVOT(
    score
    FOR field IN (teacher_environment
                 ,teacher_objectiveaimagenda
                 ,teacher_key_message
                 ,teacher_goals_connected
                 ,teacher_warm_demanding
                 ,teacher_jfactor
                 ,teacher_directionsexpectations
                 ,teacher_awareness
                 ,teacher_effective_redirections
                 ,teacher_schoolgrade_systems
                 ,teacher_transitions
                 ,teacher_classroom_systems
                 ,teacher_flowpacing
                 ,teacher_ratio
                 ,teacher_discourse
                 ,teacher_formative_cfu
                 ,teacher_wholeclass_feedback
                 ,teacher_cold_calls
                 ,teacher_evidence
                 ,teacher_question_quality
                 ,teacher_followup_and_response
                 ,teacher_grade_level_expectations
                 ,teacher_criteria_for_success
                 ,teacher_individual
                 ,teacher_daily_mastery
                 ,teacher_goalobjective
                 ,teacher_mastery_awareness
                 ,student_on_task
                 ,student_students_engaged
                 ,student_one_hundred_percent
                 ,student_quiet_for_adults
                 ,student_speedurgency
                 ,student_effective_redirections
                 ,student_smallgroupblended
                 ,student_peer_interactions
                 ,culture_hallways
                 ,culture_bathrooms
                 ,culture_main_office
                 ,culture_respect
                 ,culture_character
                 ,culture_jfactor
                 ,culture_engaged
                 ,culture_student_work
                 ,culture_missionvision
                 ,culture_celebrations
                 ,culture_common_spaces
                 ,culture_dress_code
                 ,culture_quiet_for_adults
                 ,culture_foodgumcandy
                 ,culture_cell_phones
                 ,culture_transition_time
                 ,culture_arrivaldismissal)
   ) u
 )

,old_format AS (
  SELECT CASE
          WHEN spi.school = 'BOLD' THEN 73258
          WHEN spi.school = 'Life' THEN 73257
          WHEN spi.school = 'LSM' THEN 179902
          WHEN spi.school = 'LSP' THEN 179901
          WHEN spi.school = 'NCA' THEN 73253
          WHEN spi.school = 'Rise' THEN 73252
          WHEN spi.school = 'Seek' THEN 73256
          WHEN spi.school = 'SPARK' THEN 73254
          WHEN spi.school = 'TEAM' THEN 133570965
          WHEN spi.school = 'THRIVE' THEN 73255
         END AS reporting_schoolid             
        ,spi.academic_year
        ,spi.round AS spi_round
        ,CONVERT(DATE,spi.date) AS observation_date
        ,spi.rater AS observer
        ,KIPP_NJ.dbo.fn_StripCharacters(spi.rubric,'^A-Z0-9') AS domain
        ,KIPP_NJ.dbo.fn_StripCharacters(scl.scale,'^A-Z0-9') AS strand            
        ,KIPP_NJ.dbo.fn_StripCharacters(spi.element,'^A-Z0-9') AS field                
        --,spi.score
        --,spi.num_yes AS N_yes
        --,spi.num_no AS N_no
        --,(ISNULL(spi.num_yes,0) + ISNULL(spi.num_no,0)) AS total             
        ,CASE
          WHEN scl.rubric = 'culture' THEN score
          WHEN (spi.num_yes IS NULL AND spi.num_no IS NULL) THEN score
          WHEN (ISNULL(spi.num_yes,0) + ISNULL(spi.num_no,0)) = 0 THEN NULL
          WHEN (spi.num_yes IS NOT NULL OR spi.num_no IS NOT NULL) THEN (ISNULL(spi.num_yes,0) / (ISNULL(spi.num_yes,0) + ISNULL(spi.num_no,0))) * 10
         END AS score
  FROM KIPP_NJ..AUTOLOAD$GDOCS_SPI_walkthrough_scores spi WITH(NOLOCK)          
  JOIN KIPP_NJ..AUTOLOAD$GDOCS_SPI_walkthrough_scales scl WITH(NOLOCK)
    ON spi.academic_year = scl.academic_year
   AND spi.rubric = scl.rubric
   AND spi.element = scl.element     
 )

SELECT *
FROM new_format
UNION ALL
SELECT *
FROM old_format