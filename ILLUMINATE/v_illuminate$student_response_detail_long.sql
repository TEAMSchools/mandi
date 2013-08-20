USE KIPP_NJ
GO
ALTER VIEW ILLUMINATE$student_response_detail_long AS
SELECT *
FROM OPENQUERY(ILLUMINATE, '
  SELECT sa.student_id
        ,f.field_id
        ,f.sheet_label
        ,r.response
  FROM dna_assessments.students_assessments_responses sar
  JOIN dna_assessments.students_assessments sa USING (student_assessment_id)
  JOIN dna_assessments.responses r USING (response_id)
  JOIN dna_assessments.fields f USING (field_id)
')