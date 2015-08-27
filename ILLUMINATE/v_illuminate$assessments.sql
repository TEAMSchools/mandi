USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessments AS

SELECT *
FROM OPENQUERY(ILLUMINATE,'
  SELECT a.assessment_id        
        ,a.title                
        ,a.administered_at         
        ,a.tags
        ,a.performance_band_set_id
        ,subj.code_translation AS subject_area
        ,scope.code_translation AS scope 
        ,u.state_id
  FROM dna_assessments.assessments a   
  JOIN public.users u
    ON a.user_id = u.user_id
  LEFT OUTER JOIN codes.dna_subject_areas subj
    ON a.code_subject_area_id = subj.code_id
  LEFT OUTER JOIN codes.dna_scopes scope
    ON a.code_scope_id = scope.code_id
  WHERE a.deleted_at IS NULL
')