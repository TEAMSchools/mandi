--created to join assessment titles and related info directly off sql server view
--LD6 2013-09-18

USE KIPP_NJ
GO

--ALTER VIEW ILLUMINATE$assessments AS
SELECT *
FROM  
     (SELECT assessment_id
            ,title
            ,description
            ,user_id
            ,created_at
            ,updated_at
            ,deleted_at
            ,administered_at
            ,code_scope_id
            ,code_subject_area_id
            ,reports_db_virtual_table_id
            ,academic_year
            ,local_assessment_id
            ,intel_assess_guid
            ,guid
            ,tags
            ,edusoft_guid
            ,performance_band_set_id
            ,als_guid
            ,curriculum_associate_guid
            ,allow_duplicates
            ,itembank_assessment_id
            ,locked
            ,raw_score_performance_band_set_id
            ,show_in_parent_portal
            ,tag
            ,CASE
              WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12') THEN 'grade'
              WHEN tag IN ('fsa','site assessment','unit assessments') THEN 'type'
              WHEN tag IN ('reading','mathematics','english language arts','comprehension','phonics','english language development','grammar','science','historysocial science','arts music','arts dance','spanish','writing','world language') THEN 'subject'
              WHEN tag IN ('measured progress','special education','kipp networkwide','teacher created') THEN 'other'
              ELSE 'uncategorized'
             END AS tag_type
      FROM
           (SELECT a.*
                  ,tags.tag                  
            FROM OPENQUERY(ILLUMINATE, '
                   SELECT *
                   FROM dna_assessments.assessments
                 ') a
            LEFT OUTER JOIN (SELECT *
                             FROM OPENQUERY(ILLUMINATE,'
                              SELECT assess.assessment_id
                                    ,assess.title
                                    ,assess.description
                                    ,assess.code_scope_id
                                    ,assess.code_subject_area_id
                                    ,tags.tag_id
                                    ,tag_index.tag
                              FROM dna_assessments.assessments assess
                              LEFT OUTER JOIN dna_assessments.assessments_tags tags
                                ON assess.assessment_id = tags.assessment_id
                              LEFT OUTER JOIN dna_assessments.tags tag_index
                                ON tag_index.tag_id = tags.tag_id
                             ')
                            ) tags
              ON a.assessment_id = tags.assessment_id
            ) sub1
     ) sub2
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
--WHERE title LIKE 'Math - G2 - FSA%'
--WHERE type = 'fsa'
--WHERE assessment_id = 1251
--ORDER BY GRADE