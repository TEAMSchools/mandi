USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$student_response_detail_long AS

SELECT *
FROM OPENQUERY(ILLUMINATE, '
  SELECT a.assessment_id
        ,a.title
        ,s.local_student_id
        ,sa.date_taken
        ,sar.field_id
        ,f.order
        ,f.sheet_label
        ,f.is_rubric
        ,sar.response_id
        ,r.response AS student_response
        ,CASE
           WHEN fr.points IS NULL THEN 0
           ELSE fr.points
         END AS points
        ,f.maximum AS out_of
  FROM dna_assessments.assessments a
  JOIN dna_assessments.students_assessments sa
    ON a.assessment_id = sa.assessment_id
  JOIN dna_assessments.students_assessments_responses sar
    ON sa.student_assessment_id = sar.student_assessment_id
  JOIN dna_assessments.fields f
    ON sar.field_id = f.field_id
  LEFT OUTER JOIN dna_assessments.field_responses fr
    ON sar.field_id = fr.field_id
   AND sar.response_id = fr.response_id
  JOIN public.students s
    ON sa.student_id = s.student_id
  JOIN dna_assessments.responses r
    ON sar.response_id = r.response_id  
')