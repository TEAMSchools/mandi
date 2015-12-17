USE KIPP_NJ
GO

ALTER VIEW SPI$walkthrough_avgs AS

WITH long_data AS (
  SELECT schoolid
        ,CONCAT(rubric, '_', scale, '_', ISNULL(element,'overall')) AS pivot_field
        ,academic_year
        ,round
        ,ROUND(AVG(score_clean),1) AS avg_score        
  FROM
      (
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
              END AS schoolid             
             ,KIPP_NJ.dbo.fn_StripCharacters(spi.rubric,'^A-Z0-9') AS rubric             
             ,KIPP_NJ.dbo.fn_StripCharacters(scl.scale,'^A-Z0-9') AS scale             
             ,KIPP_NJ.dbo.fn_StripCharacters(spi.element,'^A-Z0-9') AS element             
             ,spi.academic_year
             ,spi.round           
             ,spi.score
             ,spi.num_yes AS N_yes
             ,spi.num_no AS N_no
             ,(ISNULL(spi.num_yes,0) + ISNULL(spi.num_no,0)) AS total             
             ,CASE
               WHEN scl.rubric = 'culture' THEN score
               WHEN (spi.num_yes IS NULL AND spi.num_no IS NULL) THEN score
               WHEN (ISNULL(spi.num_yes,0) + ISNULL(spi.num_no,0)) = 0 THEN NULL
               WHEN (spi.num_yes IS NOT NULL OR spi.num_no IS NOT NULL) THEN (ISNULL(spi.num_yes,0) / (ISNULL(spi.num_yes,0) + ISNULL(spi.num_no,0))) * 10
              END AS score_clean
       FROM KIPP_NJ..AUTOLOAD$GDOCS_SPI_walkthrough_scores spi WITH(NOLOCK)          
       JOIN KIPP_NJ..AUTOLOAD$GDOCS_SPI_walkthrough_scales scl WITH(NOLOCK)
         ON spi.academic_year = scl.academic_year
        AND spi.rubric = scl.rubric
        AND spi.element = scl.element
      ) sub
  GROUP BY schoolid
          ,rubric
          ,scale
          ,CUBE(element)
          ,academic_year
          ,round
 )

SELECT *
      ,ROW_NUMBER() OVER(
         PARTITION BY schoolid, academic_year
           ORDER BY round DESC) AS rn
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
                     ,[culture_schoolculture_transitiontime])
 ) p