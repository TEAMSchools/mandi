CREATE VIEW ILLUMINATE$student_response_detail_long AS
SELECT *
FROM OPENQUERY(ILLUMINATE, '
  SELECT agg_resp.*
        ,bands.performance_band_set_id
        ,bands.minimum_value
        ,bands.label AS performance_band_label
        ,bands.label_number AS performance_band_number
        ,bands.color
        ,bands.is_mastery
        ,reporting_groups.label AS reporting_group_label
  FROM dna_assessments.agg_student_responses_group agg_resp
  JOIN dna_assessments.performance_bands bands USING (performance_band_id)
  JOIN dna_assessments.reporting_groups USING (reporting_group_id)
  --JOIN students USING (student_id)
')
