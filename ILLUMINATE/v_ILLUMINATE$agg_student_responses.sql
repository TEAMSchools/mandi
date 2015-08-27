USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$agg_student_responses AS

SELECT *
FROM OPENQUERY(ILLUMINATE, '
 SELECT s.local_student_id
       ,r.assessment_id
       ,r.date_taken
       ,r.performance_band_id
       ,r.performance_band_level
       ,r.percent_correct
 FROM dna_assessments.agg_student_responses r    
 JOIN public.students s
   ON s.student_id = r.student_id 
')