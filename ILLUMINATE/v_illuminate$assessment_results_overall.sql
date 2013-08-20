USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_results_overall AS
SELECT *
FROM OPENQUERY(ILLUMINATE, '
 SELECT agg_resp.*
       ,perf_bands.performance_band_set_id
       ,perf_bands.minimum_value
       ,perf_bands.label
       ,perf_bands.label_number
       ,perf_bands.color
       ,perf_bands.is_mastery
 FROM dna_assessments.agg_student_responses agg_resp
   --not sure how the logic works behind the scenes but this view has the performance band id, which 
   --indicates the proficiency bucket name.
 JOIN dna_assessments.performance_bands perf_bands USING (performance_band_id)
')