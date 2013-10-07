--Now an sp, use the static table ILLUMINATE$assessment_results_by_standard#static

USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_results_by_standard AS
SELECT *
FROM OPENQUERY(ILLUMINATE, '
       SELECT s.local_student_id 
             ,agg_resp_standard.*
             ,standards.parent_standard_id
             ,standards.category_id
             ,standards.subject_id
             ,standards.state_num
             ,standards.label AS standard_label
             ,standards.level
             ,standards.seq
             ,standards.description
             ,standards.custom_code
             ,perf_bands.performance_band_set_id
             ,perf_bands.minimum_value
             ,perf_bands.label AS perf_band_label
             ,perf_bands.label_number
             ,perf_bands.color
             ,perf_bands.is_mastery
       FROM public.students s
       JOIN dna_assessments.agg_student_responses_standard agg_resp_standard
         ON s.student_id = agg_resp_standard.student_id
       JOIN standards.standards USING (standard_id)
         --not sure how the logic works behind the scenes but this view has the performance band id, which 
         --indicates the proficiency bucket name.
       JOIN dna_assessments.performance_bands perf_bands USING (performance_band_id)
       ')