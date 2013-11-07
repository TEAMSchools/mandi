--created to join assessment titles and related info directly off sql server view --LD6 2013-09-18
--long by standard and grade level --CB 2013-11-06

USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessments AS
SELECT *
FROM
(SELECT *
       ,ROW_NUMBER() OVER
           (PARTITION BY fsa_week, schoolid, grade_level, scope
                ORDER BY standards_tested) AS fsa_std_rn
       ,ROW_NUMBER() OVER
           (PARTITION BY schoolid, standards_tested                
                ORDER BY administered_at) AS std_freq_rn
 FROM
      (SELECT oq.assessment_id
             --no hard-coded schoolid, derived from test creator
             ,CASE WHEN t.lastfirst = 'Test, Admin' THEN NULL ELSE t.schoolid END AS schoolid
             ,oq.title
             ,oq.description AS test_descr
             --/*
             --hard-coded grade-level involves multiple joins to an indexed grade level k = 1, 12 = 13 for whatever reason
             --it's simpler just to use the tag
             ,CASE 
               WHEN tag = 'k' THEN '0'
               WHEN tag IN ('1','2','3','4','5','6','7','8','9','10','11','12') THEN tag
               ELSE NULL
              END AS grade_level
             --*/            
             ,oq.subject
             ,oq.scope            
             ,oq.custom_code AS standards_tested
             ,oq.label AS standard_type
             ,oq.description AS standard_descr
             ,oq.user_id
             ,t.lastfirst AS created_by
             --needed to get clean row number for FSA standard by week
             ,fsa_dates.time_per_name AS fsa_week
             ,oq.administered_at
             ,CONVERT(DATE,oq.created_at) AS created_at
             ,CONVERT(DATE,oq.updated_at) AS updated_at
             --,oq.deleted_at            
             ,oq.code_scope_id
             ,oq.code_subject_area_id
             ,oq.standard_id
             ,oq.parent_standard_id
             ,oq.reports_db_virtual_table_id
             ,oq.academic_year
             ,oq.local_assessment_id             
             ,oq.performance_band_set_id
             ,oq.itembank_assessment_id
             ,oq.locked
             ,oq.raw_score_performance_band_set_id
             --UNUSED STUFF IN ASSESSMENTS VIEW
             --,oq.intel_assess_guid
             --,oq.guid
             ,oq.tags
             --,oq.edusoft_guid
             --,oq.als_guid
             --,oq.curriculum_associate_guid
             --,oq.allow_duplicates
             --,oq.show_in_parent_portal            
             /*
             --only used for PIVOT
             ,CASE
               WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12') 
                THEN 'grade' 
                       + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                                            PARTITION BY assessment_id
                                             ORDER BY CASE WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12' ) THEN '1' ELSE '2' END))        
               --ELSE 'other' + CONVERT(VARCHAR,ROW_NUMBER() OVER(PARTITION BY assessment_id ORDER BY tag))
               ELSE NULL
              END AS tag_type
             --*/
       FROM OPENQUERY(ILLUMINATE,'
              SELECT a.*
                    ,subj.code_translation AS subject
                    ,scope.code_translation AS scope
                    ,tags.tag
                    ,u.state_id
                    ,std.standard_id
                    ,std.parent_standard_id
                    ,std.custom_code
                    ,std.label
                    ,std.description AS std_descr
              FROM dna_assessments.assessments a
              LEFT OUTER JOIN dna_assessments.assessments_tags tag_index
                ON a.assessment_id = tag_index.assessment_id
              JOIN dna_assessments.tags tags
                ON tags.tag_id = tag_index.tag_id
               AND tags.tag IN (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'',''11'',''12'',''k'')
              LEFT OUTER JOIN codes.dna_subject_areas subj
                ON a.code_subject_area_id = subj.code_id
              LEFT OUTER JOIN codes.dna_scopes scope
                ON a.code_scope_id = scope.code_id
              LEFT OUTER JOIN public.users u
                ON a.user_id = u.user_id
              LEFT OUTER JOIN dna_assessments.assessment_standards a_std
                ON a.assessment_id = a_std.assessment_id
              LEFT OUTER JOIN standards.standards std
                ON a_std.standard_id = std.standard_id
              ') oq            
       LEFT OUTER JOIN TEACHERS t
         ON oq.state_id = t.teachernumber
       LEFT OUTER JOIN REPORTING$dates fsa_dates
         ON oq.administered_at >= fsa_dates.start_date
        AND oq.administered_at <= fsa_dates.end_date
        AND fsa_dates.identifier = 'FSA'         
       --deleted tests are kept in the database for the record
       WHERE oq.deleted_at IS NULL
      ) sub 
) sub_2
--WHERE schoolid = 73254 AND subject = 'Comprehension' AND grade_level = 2
--WHERE standards_tested = 'CCSS.LA.2.RI.2.5'
--ORDER BY schoolid, standards_tested--, administered_at
           
/*
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