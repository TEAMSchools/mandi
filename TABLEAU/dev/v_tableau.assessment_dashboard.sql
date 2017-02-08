USE gabby
GO

ALTER VIEW tableau.assessment_dashboard AS

SELECT s.local_student_id
      ,s.last_name
      ,s.first_name        

      ,a.assessment_id
      ,a.title        
      ,a.administered_at        

      ,subj.code_translation AS subject_area
      ,scope.code_translation AS scope
      
      ,ovr.date_taken
      ,ovr.percent_correct AS overall_pct_correct            

      ,std.custom_code AS standards_tested      
      ,std.description AS standard_descr      

      ,res.percent_correct AS std_percent_correct
      ,res.mastered AS std_is_mastered
      ,res.performance_band_level AS proficiency_band
FROM illuminate_dna_assessments.assessments a  
JOIN illuminate_dna_assessments.students_assessments sa
  ON a.assessment_id = sa.assessment_id
 AND sa.student_assessment_id NOT IN (SELECT student_assessment_id FROM illuminate_dna_assessments.students_assessments_archive)
LEFT OUTER JOIN illuminate_codes.dna_subject_areas subj
  ON a.code_subject_area_id = subj.code_id   
LEFT OUTER JOIN illuminate_codes.dna_scopes scope
  ON a.code_scope_id = scope.code_id   
JOIN illuminate_dna_assessments.agg_student_responses ovr    
  ON sa.student_assessment_id = ovr.student_assessment_id
JOIN illuminate_public.students s
  ON sa.student_id = s.student_id
LEFT OUTER JOIN illuminate_dna_assessments.assessment_standards astd 
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN illuminate_standards.standards std
  ON astd.standard_id = std.standard_id    
LEFT OUTER JOIN illuminate_dna_assessments.agg_student_responses_standard res 
  ON sa.student_assessment_id = res.student_assessment_id
 AND astd.standard_id = res.standard_id        
WHERE a.administered_at >= '2016-07-01'