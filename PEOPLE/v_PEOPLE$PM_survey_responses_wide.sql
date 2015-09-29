USE KIPP_NJ
GO

ALTER VIEW PEOPLE$PM_survey_responses_wide AS

WITH response_agg AS (
  SELECT survey_type
        ,academic_year
        ,term
        ,staff_member
        ,reporting_location
        ,team
        ,manager_name        
        ,KIPP_NJ.dbo.fn_StripCharacters(competency,'^A-Z') AS competency
        ,CASE WHEN question_code NOT LIKE 'q___' THEN question_code + '_1' ELSE question_code END AS question_code
        ,ROUND(AVG(CONVERT(FLOAT,response_value)),1) AS avg_response_value      
        ,ROUND(MAX(CONVERT(FLOAT,CASE WHEN manager_name = surveyed_by THEN response_value END)),1) AS manager_response_value
        ,COUNT(response_value) AS N_responses        
  FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
  WHERE is_open_ended = 0 /* open ended treated separately*/
  GROUP BY survey_type
          ,academic_year
          ,term
          ,staff_member
          ,reporting_location
          ,team
          ,manager_name
          ,competency
          ,question_code          
 )

,response_agg_all AS (
  SELECT s.survey_type
        ,s.academic_year
        ,s.term
        ,s.staff_member
        ,s.reporting_location
        ,s.team
        ,s.manager_name            
        ,s.competency
        ,s.question_code            
        /* competency level rollups */
        ,ROUND(AVG(s.avg_response_value) OVER(PARTITION BY s.survey_type, s.academic_year, s.term, s.reporting_location, s.team, s.competency),1) AS competency_team_avg
        ,ROUND(AVG(s.avg_response_value) OVER(PARTITION BY s.survey_type, s.academic_year, s.term, s.reporting_location, s.competency),1) AS competency_school_avg
        ,ROUND(AVG(s.avg_response_value) OVER(PARTITION BY s.survey_type, s.academic_year, s.term, s.competency),1) AS competency_network_avg
        ,ROUND(AVG(s.manager_response_value) OVER(PARTITION BY s.survey_type, s.academic_year, s.term, s.competency),1) AS competency_manager_avg
        /* question level rollups */
        ,CONVERT(FLOAT,s.N_responses) AS N_responses
        ,CONVERT(FLOAT,s.avg_response_value) AS question_person_avg
        ,ROUND(AVG(s.avg_response_value) OVER(PARTITION BY s.survey_type, s.academic_year, s.term, s.reporting_location, s.team, s.question_code),1) AS question_team_avg
        ,ROUND(AVG(s.avg_response_value) OVER(PARTITION BY s.survey_type, s.academic_year, s.term, s.reporting_location, s.question_code),1) AS question_school_avg
        ,ROUND(AVG(s.avg_response_value) OVER(PARTITION BY s.survey_type, s.academic_year, s.term, s.question_code),1) AS question_network_avg
        ,CONVERT(FLOAT,s.manager_response_value) AS question_manager_avg
  FROM response_agg s  
 )

,question_unpivot AS (
  SELECT survey_type
        ,academic_year
        ,term
        ,staff_member
        ,reporting_location
        ,team
        ,manager_name
        ,CONCAT(question_code, '_', field) AS pivot_field
        ,value AS pivot_value        
  FROM response_agg_all
  UNPIVOT(
    value
    FOR field IN (N_responses
                 ,question_person_avg
                 ,question_team_avg
                 ,question_school_avg
                 ,question_network_avg
                 ,question_manager_avg)
   ) u
 )

,competency_unpivot AS (
  SELECT survey_type
        ,academic_year
        ,term
        ,staff_member
        ,reporting_location
        ,team
        ,manager_name
        ,CONCAT(competency, '_', field) AS pivot_field
        ,value AS pivot_value
  FROM response_agg_all  
  UNPIVOT(
    value
    FOR field IN (competency_team_avg
                 ,competency_school_avg
                 ,competency_network_avg
                 ,competency_manager_avg)
   ) u
  WHERE survey_type != 'Manager'
 )

SELECT *
FROM
    (
     SELECT *
     FROM question_unpivot
     UNION ALL
     SELECT *
     FROM competency_unpivot
    ) sub
PIVOT(
  MAX(pivot_value)
  FOR pivot_field IN ([BuildingRelationships_competency_manager_avg]
                     ,[BuildingRelationships_competency_school_avg]
                     ,[BuildingRelationships_competency_team_avg]
                     ,[BuildingRelationshipsStudents_competency_manager_avg]
                     ,[BuildingRelationshipsStudents_competency_school_avg]
                     ,[BuildingRelationshipsStudents_competency_team_avg]
                     ,[Communication_competency_manager_avg]
                     ,[Communication_competency_school_avg]
                     ,[Communication_competency_team_avg]
                     ,[CommunicationStudents_competency_manager_avg]
                     ,[CommunicationStudents_competency_school_avg]
                     ,[CommunicationStudents_competency_team_avg]
                     ,[ContinuousLearning_competency_manager_avg]
                     ,[ContinuousLearning_competency_school_avg]
                     ,[ContinuousLearning_competency_team_avg]
                     ,[CulturalCompetence_competency_manager_avg]
                     ,[CulturalCompetence_competency_school_avg]
                     ,[CulturalCompetence_competency_team_avg]
                     ,[CulturalCompetenceStudents_competency_manager_avg]
                     ,[CulturalCompetenceStudents_competency_school_avg]
                     ,[CulturalCompetenceStudents_competency_team_avg]
                     ,[SelfAwarenessandSelfAdjustment_competency_manager_avg]
                     ,[SelfAwarenessandSelfAdjustment_competency_school_avg]
                     ,[SelfAwarenessandSelfAdjustment_competency_team_avg]
                     ,[Professionalism_competency_manager_avg]
                     ,[Professionalism_competency_school_avg]
                     ,[Professionalism_competency_team_avg]
                     ,[q1_1_question_manager_avg]
                     ,[q1_1_question_person_avg]
                     ,[q1_1_question_school_avg]
                     ,[q1_1_question_team_avg]
                     ,[q1_2_question_manager_avg]
                     ,[q1_2_question_person_avg]
                     ,[q1_2_question_school_avg]
                     ,[q1_2_question_team_avg]
                     ,[q1_3_question_manager_avg]
                     ,[q1_3_question_person_avg]
                     ,[q1_3_question_school_avg]
                     ,[q1_3_question_team_avg]
                     ,[q1_4_question_manager_avg]
                     ,[q1_4_question_person_avg]
                     ,[q1_4_question_school_avg]
                     ,[q1_4_question_team_avg]
                     ,[q1_5_question_manager_avg]
                     ,[q1_5_question_person_avg]
                     ,[q1_5_question_school_avg]
                     ,[q1_5_question_team_avg]
                     ,[q10_1_question_manager_avg]
                     ,[q10_1_question_person_avg]
                     ,[q10_1_question_school_avg]
                     ,[q10_1_question_team_avg]
                     ,[q11_1_question_manager_avg]
                     ,[q11_1_question_person_avg]
                     ,[q11_1_question_school_avg]
                     ,[q11_1_question_team_avg]
                     ,[q12_1_question_manager_avg]
                     ,[q12_1_question_person_avg]
                     ,[q12_1_question_school_avg]
                     ,[q12_1_question_team_avg]
                     ,[q13_1_question_manager_avg]
                     ,[q13_1_question_person_avg]
                     ,[q13_1_question_school_avg]
                     ,[q13_1_question_team_avg]
                     ,[q2_1_question_manager_avg]
                     ,[q2_1_question_person_avg]
                     ,[q2_1_question_school_avg]
                     ,[q2_1_question_team_avg]
                     ,[q2_2_question_manager_avg]
                     ,[q2_2_question_person_avg]
                     ,[q2_2_question_school_avg]
                     ,[q2_2_question_team_avg]
                     ,[q2_3_question_manager_avg]
                     ,[q2_3_question_person_avg]
                     ,[q2_3_question_school_avg]
                     ,[q2_3_question_team_avg]
                     ,[q2_4_question_manager_avg]
                     ,[q2_4_question_person_avg]
                     ,[q2_4_question_school_avg]
                     ,[q2_4_question_team_avg]
                     ,[q3_1_question_manager_avg]
                     ,[q3_1_question_person_avg]
                     ,[q3_1_question_school_avg]
                     ,[q3_1_question_team_avg]
                     ,[q3_2_question_manager_avg]
                     ,[q3_2_question_person_avg]
                     ,[q3_2_question_school_avg]
                     ,[q3_2_question_team_avg]
                     ,[q3_3_question_manager_avg]
                     ,[q3_3_question_person_avg]
                     ,[q3_3_question_school_avg]
                     ,[q3_3_question_team_avg]
                     ,[q3_4_question_manager_avg]
                     ,[q3_4_question_person_avg]
                     ,[q3_4_question_school_avg]
                     ,[q3_4_question_team_avg]
                     ,[q3_5_question_manager_avg]
                     ,[q3_5_question_person_avg]
                     ,[q3_5_question_school_avg]
                     ,[q3_5_question_team_avg]
                     ,[q4_1_question_manager_avg]
                     ,[q4_1_question_person_avg]
                     ,[q4_1_question_school_avg]
                     ,[q4_1_question_team_avg]
                     ,[q4_2_question_manager_avg]
                     ,[q4_2_question_person_avg]
                     ,[q4_2_question_school_avg]
                     ,[q4_2_question_team_avg]
                     ,[q4_3_question_manager_avg]
                     ,[q4_3_question_person_avg]
                     ,[q4_3_question_school_avg]
                     ,[q4_3_question_team_avg]
                     ,[q5_1_question_manager_avg]
                     ,[q5_1_question_person_avg]
                     ,[q5_1_question_school_avg]
                     ,[q5_1_question_team_avg]
                     ,[q5_2_question_manager_avg]
                     ,[q5_2_question_person_avg]
                     ,[q5_2_question_school_avg]
                     ,[q5_2_question_team_avg]
                     ,[q5_3_question_manager_avg]
                     ,[q5_3_question_person_avg]
                     ,[q5_3_question_school_avg]
                     ,[q5_3_question_team_avg]
                     ,[q5_4_question_manager_avg]
                     ,[q5_4_question_person_avg]
                     ,[q5_4_question_school_avg]
                     ,[q5_4_question_team_avg]
                     ,[q5_5_question_manager_avg]
                     ,[q5_5_question_person_avg]
                     ,[q5_5_question_school_avg]
                     ,[q5_5_question_team_avg]
                     ,[q5_6_question_manager_avg]
                     ,[q5_6_question_person_avg]
                     ,[q5_6_question_school_avg]
                     ,[q5_6_question_team_avg]
                     ,[q6_1_question_manager_avg]
                     ,[q6_1_question_person_avg]
                     ,[q6_1_question_school_avg]
                     ,[q6_1_question_team_avg]
                     ,[q6_2_question_manager_avg]
                     ,[q6_2_question_person_avg]
                     ,[q6_2_question_school_avg]
                     ,[q6_2_question_team_avg]
                     ,[q6_3_question_manager_avg]
                     ,[q6_3_question_person_avg]
                     ,[q6_3_question_school_avg]
                     ,[q6_3_question_team_avg]
                     ,[q6_4_question_manager_avg]
                     ,[q6_4_question_person_avg]
                     ,[q6_4_question_school_avg]
                     ,[q6_4_question_team_avg]
                     ,[q6_5_question_manager_avg]
                     ,[q6_5_question_person_avg]
                     ,[q6_5_question_school_avg]
                     ,[q6_5_question_team_avg]
                     ,[q7_1_question_manager_avg]
                     ,[q7_1_question_person_avg]
                     ,[q7_1_question_school_avg]
                     ,[q7_1_question_team_avg]
                     ,[q7_2_question_manager_avg]
                     ,[q7_2_question_person_avg]
                     ,[q7_2_question_school_avg]
                     ,[q7_2_question_team_avg]
                     ,[q7_3_question_manager_avg]
                     ,[q7_3_question_person_avg]
                     ,[q7_3_question_school_avg]
                     ,[q7_3_question_team_avg]
                     ,[q7_4_question_manager_avg]
                     ,[q7_4_question_person_avg]
                     ,[q7_4_question_school_avg]
                     ,[q7_4_question_team_avg]
                     ,[q8_1_question_manager_avg]
                     ,[q8_1_question_person_avg]
                     ,[q8_1_question_school_avg]
                     ,[q8_1_question_team_avg]
                     ,[q8_2_question_manager_avg]
                     ,[q8_2_question_person_avg]
                     ,[q8_2_question_school_avg]
                     ,[q8_2_question_team_avg]
                     ,[q8_3_question_manager_avg]
                     ,[q8_3_question_person_avg]
                     ,[q8_3_question_school_avg]
                     ,[q8_3_question_team_avg]
                     ,[q9_1_question_manager_avg]
                     ,[q9_1_question_person_avg]
                     ,[q9_1_question_school_avg]
                     ,[q9_1_question_team_avg]
                     ,[q9_2_question_manager_avg]
                     ,[q9_2_question_person_avg]
                     ,[q9_2_question_school_avg]
                     ,[q9_2_question_team_avg]
                     ,[q9_3_question_manager_avg]
                     ,[q9_3_question_person_avg]
                     ,[q9_3_question_school_avg]
                     ,[q9_3_question_team_avg]
                     ,[q9_4_question_manager_avg]
                     ,[q9_4_question_person_avg]
                     ,[q9_4_question_school_avg]
                     ,[q9_4_question_team_avg]
                     ,[q9_5_question_manager_avg]
                     ,[q9_5_question_person_avg]
                     ,[q9_5_question_school_avg]
                     ,[q9_5_question_team_avg])
 ) p