USE KIPP_NJ
GO

ALTER VIEW SPI$walkthrough_avgs AS

WITH long_data AS (
  SELECT reporting_schoolid AS schoolid
        ,strand
        ,CONCAT(domain, '_', ISNULL(strand,'overall')) AS pivot_field
        ,academic_year
        ,spi_round
        ,ROUND(AVG(score),1) AS avg_score        
  FROM KIPP_NJ..SPI$walkthrough_scores_long WITH(NOLOCK)
  WHERE academic_year >= 2016
  GROUP BY reporting_schoolid
          ,domain          
          ,CUBE(strand)
          ,academic_year
          ,spi_round

  UNION ALL
  
  SELECT reporting_schoolid
        ,strand
        ,CONCAT(domain, '_', strand, '_', ISNULL(field,'overall')) AS pivot_field
        ,academic_year
        ,spi_round
        ,ROUND(AVG(score),1) AS avg_score        
  FROM KIPP_NJ..SPI$walkthrough_scores_long WITH(NOLOCK)
  GROUP BY reporting_schoolid
          ,academic_year          
          ,spi_round
          ,domain
          ,strand
          ,CUBE(field)     
 )

SELECT *
      ,ROW_NUMBER() OVER(
         PARTITION BY schoolid, academic_year
           ORDER BY spi_round DESC) AS rn
FROM long_data
PIVOT(
  MAX(avg_score)
  FOR pivot_field IN ([classroom_engagement_environment]
                     ,[classroom_engagement_goalsconnected]
                     ,[classroom_engagement_goalspresent]
                     ,[classroom_engagement_jfactor]
                     ,[classroom_engagement_keymessages]
                     ,[classroom_engagement_overall]
                     ,[classroom_engagement_peerinteractions]
                     ,[classroom_engagement_studentsengaged]
                     ,[classroom_instruction_checksforunderstanding]
                     ,[classroom_instruction_criteriaforsuccess]
                     ,[classroom_instruction_directions]
                     ,[classroom_instruction_flowpacing]
                     ,[classroom_instruction_goalsconnected]
                     ,[classroom_instruction_objectiveaim]
                     ,[classroom_instruction_overall]
                     ,[classroom_instruction_questioning]
                     ,[classroom_instruction_ratio]
                     ,[classroom_instruction_rigor]
                     ,[classroom_instructionaldelivery_coldcalls]
                     ,[classroom_instructionaldelivery_criteriaforsuccess]
                     ,[classroom_instructionaldelivery_dailymastery]
                     ,[classroom_instructionaldelivery_discourse]
                     ,[classroom_instructionaldelivery_evidence]
                     ,[classroom_instructionaldelivery_flowpacing]
                     ,[classroom_instructionaldelivery_followupandresponse]
                     ,[classroom_instructionaldelivery_formativecfu]
                     ,[classroom_instructionaldelivery_goalobjective]
                     ,[classroom_instructionaldelivery_gradelevelexpectations]
                     ,[classroom_instructionaldelivery_individual]
                     ,[classroom_instructionaldelivery_masteryawareness]
                     ,[classroom_instructionaldelivery_overall]
                     ,[classroom_instructionaldelivery_questionquality]
                     ,[classroom_instructionaldelivery_ratio]
                     ,[classroom_instructionaldelivery_wholeclassfeedback]
                     ,[classroom_management_awareness]
                     ,[classroom_management_effectiveredirectionsstudent]
                     ,[classroom_management_effectiveredirectionsteacher]
                     ,[classroom_management_onehundredpercent]
                     ,[classroom_management_ontask]
                     ,[classroom_management_overall]
                     ,[classroom_management_quietforadults]
                     ,[classroom_management_speedurgency]
                     ,[classroom_management_warmdemanding]
                     ,[classroom_routinesrules_awareness]
                     ,[classroom_routinesrules_cellphones]
                     ,[classroom_routinesrules_clean]
                     ,[classroom_routinesrules_dresscode]
                     ,[classroom_routinesrules_effectiveredirections]
                     ,[classroom_routinesrules_homework]
                     ,[classroom_routinesrules_onehundredpercent]
                     ,[classroom_routinesrules_ontask]
                     ,[classroom_routinesrules_overall]
                     ,[classroom_routinesrules_studentsquietforadults]
                     ,[classroom_routinesrules_transitions]
                     ,[classroom_routinesrules_warmdemanding]
                     ,[classroom_routinesrules_workfast]
                     ,[classroom_routinestransitions_classroomsystems]
                     ,[classroom_routinestransitions_directionsexpectations]
                     ,[classroom_routinestransitions_objectiveaimagenda]
                     ,[classroom_routinestransitions_overall]
                     ,[classroom_routinestransitions_schoolgradesystems]
                     ,[classroom_routinestransitions_smallgroupblended]
                     ,[classroom_routinestransitions_transitions]
                     ,[culture_arrivaldismissal]
                     ,[culture_arrivaldismissal_culture_arrivaldismissal]
                     ,[culture_arrivaldismissal_overall]
                     ,[culture_bathrooms]
                     ,[culture_bathrooms_culture_bathrooms]
                     ,[culture_bathrooms_overall]
                     ,[culture_celebrations]
                     ,[culture_celebrations_culture_celebrations]
                     ,[culture_celebrations_overall]
                     ,[culture_cell_phones]
                     ,[culture_cell_phones_culture_cell_phones]
                     ,[culture_cell_phones_overall]
                     ,[culture_character]
                     ,[culture_character_culture_character]
                     ,[culture_character_overall]
                     ,[culture_common_spaces]
                     ,[culture_common_spaces_culture_common_spaces]
                     ,[culture_common_spaces_overall]
                     ,[culture_dress_code]
                     ,[culture_dress_code_culture_dress_code]
                     ,[culture_dress_code_overall]
                     ,[culture_engaged]
                     ,[culture_engaged_culture_engaged]
                     ,[culture_engaged_overall]
                     ,[culture_foodgumcandy]
                     ,[culture_foodgumcandy_culture_foodgumcandy]
                     ,[culture_foodgumcandy_overall]
                     ,[culture_hallways]
                     ,[culture_hallways_culture_hallways]
                     ,[culture_hallways_overall]
                     ,[culture_jfactor]
                     ,[culture_jfactor_culture_jfactor]
                     ,[culture_jfactor_overall]
                     ,[culture_main_office]
                     ,[culture_main_office_culture_main_office]
                     ,[culture_main_office_overall]
                     ,[culture_missionvision]
                     ,[culture_missionvision_culture_missionvision]
                     ,[culture_missionvision_overall]
                     ,[culture_overall]
                     ,[culture_quiet_for_adults]
                     ,[culture_quiet_for_adults_culture_quiet_for_adults]
                     ,[culture_quiet_for_adults_overall]
                     ,[culture_respect]
                     ,[culture_respect_culture_respect]
                     ,[culture_respect_overall]
                     ,[culture_schoolculture_arrivaldismissal]
                     ,[culture_schoolculture_bathrooms]
                     ,[culture_schoolculture_celebrations]
                     ,[culture_schoolculture_cellphones]
                     ,[culture_schoolculture_character]
                     ,[culture_schoolculture_commonspaces]
                     ,[culture_schoolculture_dresscode]
                     ,[culture_schoolculture_engaged]
                     ,[culture_schoolculture_foodgumcandy]
                     ,[culture_schoolculture_gumcandy]
                     ,[culture_schoolculture_hallways]
                     ,[culture_schoolculture_jfactor]
                     ,[culture_schoolculture_mainoffice]
                     ,[culture_schoolculture_meals]
                     ,[culture_schoolculture_missionvalues]
                     ,[culture_schoolculture_missionVision]
                     ,[culture_schoolculture_overall]
                     ,[culture_schoolculture_quietforadults]
                     ,[culture_schoolculture_respect]
                     ,[culture_schoolculture_studentwork]
                     ,[culture_schoolculture_transitiontime]
                     ,[culture_student_work]
                     ,[culture_student_work_culture_student_work]
                     ,[culture_student_work_overall]
                     ,[culture_transition_time]
                     ,[culture_transition_time_culture_transition_time]
                     ,[culture_transition_time_overall]
                     ,[student_effective_redirections]
                     ,[student_effective_redirections_overall]
                     ,[student_effective_redirections_student_effective_redirections]
                     ,[student_on_task]
                     ,[student_on_task_overall]
                     ,[student_on_task_student_on_task]
                     ,[student_one_hundred_percent]
                     ,[student_one_hundred_percent_overall]
                     ,[student_one_hundred_percent_student_one_hundred_percent]
                     ,[student_overall]
                     ,[student_peer_interactions]
                     ,[student_peer_interactions_overall]
                     ,[student_peer_interactions_student_peer_interactions]
                     ,[student_quiet_for_adults]
                     ,[student_quiet_for_adults_overall]
                     ,[student_quiet_for_adults_student_quiet_for_adults]
                     ,[student_smallgroupblended]
                     ,[student_smallgroupblended_overall]
                     ,[student_smallgroupblended_student_smallgroupblended]
                     ,[student_speedurgency]
                     ,[student_speedurgency_overall]
                     ,[student_speedurgency_student_speedurgency]
                     ,[student_students_engaged]
                     ,[student_students_engaged_overall]
                     ,[student_students_engaged_student_students_engaged]
                     ,[teacher_awareness]
                     ,[teacher_awareness_overall]
                     ,[teacher_awareness_teacher_awareness]
                     ,[teacher_classroom_systems]
                     ,[teacher_classroom_systems_overall]
                     ,[teacher_classroom_systems_teacher_classroom_systems]
                     ,[teacher_cold_calls]
                     ,[teacher_cold_calls_overall]
                     ,[teacher_cold_calls_teacher_cold_calls]
                     ,[teacher_criteria_for_success]
                     ,[teacher_criteria_for_success_overall]
                     ,[teacher_criteria_for_success_teacher_criteria_for_success]
                     ,[teacher_daily_mastery]
                     ,[teacher_daily_mastery_overall]
                     ,[teacher_daily_mastery_teacher_daily_mastery]
                     ,[teacher_directionsexpectations]
                     ,[teacher_directionsexpectations_overall]
                     ,[teacher_directionsexpectations_teacher_directionsexpectations]
                     ,[teacher_discourse]
                     ,[teacher_discourse_overall]
                     ,[teacher_discourse_teacher_discourse]
                     ,[teacher_effective_redirections]
                     ,[teacher_effective_redirections_overall]
                     ,[teacher_effective_redirections_teacher_effective_redirections]
                     ,[teacher_environment]
                     ,[teacher_environment_overall]
                     ,[teacher_environment_teacher_environment]
                     ,[teacher_evidence]
                     ,[teacher_evidence_overall]
                     ,[teacher_evidence_teacher_evidence]
                     ,[teacher_flowpacing]
                     ,[teacher_flowpacing_overall]
                     ,[teacher_flowpacing_teacher_flowpacing]
                     ,[teacher_followup_and_response]
                     ,[teacher_followup_and_response_overall]
                     ,[teacher_followup_and_response_teacher_followup_and_response]
                     ,[teacher_formative_cfu]
                     ,[teacher_formative_cfu_overall]
                     ,[teacher_formative_cfu_teacher_formative_cfu]
                     ,[teacher_goalobjective]
                     ,[teacher_goalobjective_overall]
                     ,[teacher_goalobjective_teacher_goalobjective]
                     ,[teacher_goals_connected]
                     ,[teacher_goals_connected_overall]
                     ,[teacher_goals_connected_teacher_goals_connected]
                     ,[teacher_grade_level_expectations]
                     ,[teacher_grade_level_expectations_overall]
                     ,[teacher_grade_level_expectations_teacher_grade_level_expectations]
                     ,[teacher_individual]
                     ,[teacher_individual_overall]
                     ,[teacher_individual_teacher_individual]
                     ,[teacher_jfactor]
                     ,[teacher_jfactor_overall]
                     ,[teacher_jfactor_teacher_jfactor]
                     ,[teacher_key_message]
                     ,[teacher_key_message_overall]
                     ,[teacher_key_message_teacher_key_message]
                     ,[teacher_mastery_awareness]
                     ,[teacher_mastery_awareness_overall]
                     ,[teacher_mastery_awareness_teacher_mastery_awareness]
                     ,[teacher_objectiveaimagenda]
                     ,[teacher_objectiveaimagenda_overall]
                     ,[teacher_objectiveaimagenda_teacher_objectiveaimagenda]
                     ,[teacher_overall]
                     ,[teacher_question_quality]
                     ,[teacher_question_quality_overall]
                     ,[teacher_question_quality_teacher_question_quality]
                     ,[teacher_ratio]
                     ,[teacher_ratio_overall]
                     ,[teacher_ratio_teacher_ratio]
                     ,[teacher_schoolgrade_systems]
                     ,[teacher_schoolgrade_systems_overall]
                     ,[teacher_schoolgrade_systems_teacher_schoolgrade_systems]
                     ,[teacher_transitions]
                     ,[teacher_transitions_overall]
                     ,[teacher_transitions_teacher_transitions]
                     ,[teacher_warm_demanding]
                     ,[teacher_warm_demanding_overall]
                     ,[teacher_warm_demanding_teacher_warm_demanding]
                     ,[teacher_wholeclass_feedback]
                     ,[teacher_wholeclass_feedback_overall]
                     ,[teacher_wholeclass_feedback_teacher_wholeclass_feedback])
 ) p