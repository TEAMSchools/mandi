USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessment_results_overall AS

SELECT CONVERT(INT,local_student_id) AS student_number
      ,assessment_id
      ,date_taken
      ,performance_band_id
      ,performance_band_level
      ,mastered
      ,points
      ,points_possible
      ,answered
      ,percent_correct
      ,number_of_questions
FROM OPENQUERY(ILLUMINATE, '
 SELECT s.local_student_id
       ,agg_resp.assessment_id
       ,agg_resp.date_taken
       ,agg_resp.performance_band_id
       ,agg_resp.performance_band_level
       ,agg_resp.mastered
       ,agg_resp.points
       ,agg_resp.points_possible
       ,agg_resp.answered
       ,agg_resp.percent_correct
       ,agg_resp.number_of_questions
 FROM dna_assessments.agg_student_responses agg_resp    
 JOIN public.students s
   ON s.student_id = agg_resp.student_id
 LIMIT 100
')