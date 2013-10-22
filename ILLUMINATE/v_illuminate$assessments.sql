--created to join assessment titles and related info directly off sql server view
--LD6 2013-09-18

USE KIPP_NJ
GO

--ALTER VIEW ILLUMINATE$assessments AS
SELECT *
FROM
     (SELECT oq.assessment_id
            ,oq.title
            ,oq.description
            ,oq.user_id
            ,oq.created_at
            ,oq.updated_at
            ,oq.deleted_at
            ,oq.administered_at
            ,oq.code_scope_id
            ,oq.code_subject_area_id
            ,oq.reports_db_virtual_table_id
            ,oq.academic_year
            ,oq.local_assessment_id
            ,oq.intel_assess_guid
            ,oq.guid
            ,oq.tags
            ,oq.edusoft_guid
            ,oq.performance_band_set_id
            ,oq.als_guid
            ,oq.curriculum_associate_guid
            ,oq.allow_duplicates
            ,oq.itembank_assessment_id
            ,oq.locked
            ,oq.raw_score_performance_band_set_id
            ,oq.show_in_parent_portal
            ,oq.subject
            ,oq.scope
            ,CASE WHEN tag = 'k' THEN '0' ELSE tag END AS tag
            ,CASE
              WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12') 
               THEN 'grade' 
                      + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                                           PARTITION BY assessment_id
                                            ORDER BY CASE WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12' ) THEN '1' ELSE '2' END))        
              --ELSE 'other' + CONVERT(VARCHAR,ROW_NUMBER() OVER(PARTITION BY assessment_id ORDER BY tag))
              ELSE NULL
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
             ') oq
     ) sub
           
--/*
PIVOT (
 MAX(tag)
 FOR tag_type
 IN (grade1
    ,grade2
    ,grade3
    ,grade4
    ,grade5
    --,other1
    --,other2
    --,other3
    )
) AS piv
--*/