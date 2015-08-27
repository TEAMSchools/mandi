USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$agg_student_responses_standard AS

SELECT *      
FROM OPENQUERY(ILLUMINATE,'
  SELECT s.local_student_id
        ,r.assessment_id
        ,r.standard_id
        ,r.performance_band_id
        ,r.performance_band_level
        ,r.mastered
        ,r.percent_correct
  FROM dna_assessments.agg_student_responses_standard r    
  JOIN public.students s 
    ON r.student_id = s.student_id
')