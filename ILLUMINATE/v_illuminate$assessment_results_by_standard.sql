USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_results_by_standard AS

SELECT *
      ,dbo.fn_DateToSY(administered_at) AS academic_year
FROM OPENQUERY(ILLUMINATE,'
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
        ,ques.sheet_label AS questions
        ,ques.administered_at
        ,perf_bands.performance_band_set_id
        ,perf_bands.minimum_value
        ,perf_bands.label AS perf_band_label
        ,perf_bands.label_number
        ,perf_bands.color
        ,perf_bands.is_mastery
  FROM public.students s
  JOIN dna_assessments.agg_student_responses_standard agg_resp_standard
    ON s.student_id = agg_resp_standard.student_id
  JOIN standards.standards 
    USING (standard_id)
    --not sure how the logic works behind the scenes but this view has the performance band id, which 
    --indicates the proficiency bucket name.
  JOIN dna_assessments.performance_bands perf_bands
    USING (performance_band_id)
  LEFT OUTER JOIN (
                   SELECT a.assessment_id
                         ,a.administered_at             
                         ,fs.standard_id
                         ,GROUP_CONCAT(sheet_label) AS sheet_label       
                   FROM dna_assessments.assessments a
                   LEFT OUTER JOIN dna_assessments.fields f       
                     ON a.assessment_id = f.assessment_id
                   LEFT OUTER JOIN dna_assessments.field_standards fs
                     ON f.field_id = fs.field_id
                   GROUP BY a.assessment_id, fs.standard_id, a.administered_at
                  ) ques
    ON standards.standard_id = ques.standard_id
   AND agg_resp_standard.assessment_id = ques.assessment_id
')