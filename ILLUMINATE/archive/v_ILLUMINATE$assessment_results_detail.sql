USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_results_detail AS 

SELECT *
FROM OPENQUERY(ILLUMINATE,'
  WITH stu_assess AS ( 
    SELECT sa.student_assessment_id
          ,sa.assessment_id
          ,sa.student_id
          ,s.local_student_id
    FROM dna_assessments.students_assessments sa
    JOIN public.students s
      ON sa.student_id = s.student_id
    --WHERE sa.assessment_id > 3750  
   )
  
  SELECT stu_assess.*
        ,a.title AS assessment_name
        ,f.order
        ,f.sheet_label
        ,r.response AS stu_resp
        ,f.maximum AS points_possible
        ,COALESCE(fr.points,0) AS points_earned
  FROM dna_assessments.assessments a
  JOIN dna_assessments.fields f
    ON a.assessment_id = f.assessment_id
  JOIN stu_assess 
    ON stu_assess.assessment_id = a.assessment_id
  LEFT OUTER JOIN dna_assessments.students_assessments_responses sar
    ON stu_assess.student_assessment_id = sar.student_assessment_id
   AND f.field_id = sar.field_id
  LEFT OUTER JOIN dna_assessments.responses r
    ON sar.response_id = r.response_id
  LEFT OUTER JOIN dna_assessments.field_responses fr
    ON f.field_id = fr.field_id
   AND sar.response_id = fr.response_id  
')