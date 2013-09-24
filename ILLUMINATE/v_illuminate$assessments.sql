--created to join assessment titles and related info directly off sql server view
--LD6 2013-09-18

USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessments AS
SELECT *
      ,CASE
        WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12') THEN 'grade'
        ELSE 'other'
       END AS tag_type
FROM OPENQUERY(ILLUMINATE,'
     SELECT a.*
           ,subj.code_translation AS subject
           ,scope.code_translation AS scope
           ,tags.tag
     FROM dna_assessments.assessments a
     LEFT OUTER JOIN dna_assessments.assessments_tags tag_index
       ON a.assessment_id = tag_index.assessment_id
     LEFT OUTER JOIN dna_assessments.tags tags
       ON tags.tag_id = tag_index.tag_id
     LEFT OUTER JOIN codes.dna_subject_areas subj
       ON a.code_subject_area_id = subj.code_id
     LEFT OUTER JOIN codes.dna_scopes scope
       ON a.code_scope_id = scope.code_id
     ')     
           
/*
PIVOT (
 MAX(tag)
 FOR tag_type
 IN (grade
    ,type
    ,subject
    ,other    
    ,uncategorized
    ,tag1
    ,tag2
    ,tag3
    ,tag4
    ,tag5
    ,tag6)
) AS piv
--*/