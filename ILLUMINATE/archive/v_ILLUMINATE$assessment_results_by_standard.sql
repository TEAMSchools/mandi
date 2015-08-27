USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_results_by_standard AS

SELECT *      
FROM OPENQUERY(ILLUMINATE,'
  SELECT s.local_student_id 
        ,agg_resp_standard.assessment_id
        ,agg_resp_standard.standard_id
        ,agg_resp_standard.performance_band_id
        ,agg_resp_standard.performance_band_level
        ,agg_resp_standard.mastered
        ,agg_resp_standard.points
        ,agg_resp_standard.points_possible
        ,agg_resp_standard.answered
        ,agg_resp_standard.percent_correct
        ,agg_resp_standard.number_of_questions        
        ,standards.parent_standard_id                
        ,standards.level        
        ,standards.description
        ,standards.custom_code        
  FROM dna_assessments.agg_student_responses_standard agg_resp_standard
  JOIN public.students s 
    ON agg_resp_standard.student_id = s.student_id
  JOIN standards.standards
    ON agg_resp_standard.standard_id = standards.standard_id
')