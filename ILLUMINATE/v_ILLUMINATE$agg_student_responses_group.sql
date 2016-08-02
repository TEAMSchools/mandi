USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$agg_student_responses_group AS

SELECT *      
FROM OPENQUERY(ILLUMINATE, '
 SELECT s.local_student_id
       ,r.assessment_id       
       ,r.performance_band_id
       ,r.performance_band_level
       ,r.mastered
       ,r.points
       ,r.points_possible
       ,r.answered
       ,r.percent_correct
       ,r.number_of_questions
       ,r.reporting_group_id
       ,grp.label AS reporting_group
 FROM dna_assessments.agg_student_responses_group r
 JOIN public.students s
   ON r.student_id = s.student_id
 JOIN dna_assessments.reporting_groups grp
   ON r.reporting_group_id = grp.reporting_group_id
 WHERE r.reporting_group_id IN (5287, 274) /* ''Multiple Choice'' & ''Open-Ended Response'' */
')