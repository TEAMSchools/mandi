USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessments AS

WITH schools_assessed AS (
  SELECT DISTINCT
         co.schoolid
        ,oq.assessment_id
  FROM OPENQUERY(ILLUMINATE,'
    SELECT agg.assessment_id       
          ,s.local_student_id
          ,a.administered_at
    FROM dna_assessments.agg_student_responses agg
    JOIN public.students s
      ON agg.student_id = s.student_id
    JOIN dna_assessments.assessments a
      ON agg.assessment_id = a.assessment_id
  ') oq 
  JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
    ON oq.local_student_id = co.student_number   
   AND dbo.fn_DateToSY(oq.administered_at) = co.YEAR
   AND co.rn = 1
 )

SELECT sub.assessment_id
      ,sub.schoolid
      ,sub.title
      ,sub.test_descr
      ,sub.grade_level
      ,sub.subject
      ,sub.credittype
      ,sub.scope
      ,sub.standards_tested
      ,sub.parent_standard
      ,sub.standard_type
      ,sub.standard_descr
      ,sub.user_id
      ,sub.teachernumber
      ,sub.created_by
      ,sub.fsa_week
      ,sub.academic_year
      ,sub.administered_at
      ,sub.created_at
      ,sub.updated_at
      ,sub.deleted_at
      ,sub.code_scope_id
      ,sub.code_subject_area_id
      ,sub.standard_id
      ,sub.parent_standard_id
      ,sub.reports_db_virtual_table_id
      ,sub.local_assessment_id
      ,sub.performance_band_set_id
      ,sub.itembank_assessment_id
      ,sub.locked
      ,sub.raw_score_performance_band_set_id
      ,sub.tags
      ,rt.alt_name AS term
      ,ROW_NUMBER() OVER (
          PARTITION BY sub.academic_year, fsa_week, sub.schoolid, grade_level, sub.scope, sub.performance_band_set_id
              ORDER BY sub.performance_band_set_id, subject, standards_tested) AS fsa_std_rn
      ,ROW_NUMBER() OVER (
          PARTITION BY sub.academic_year, sub.scope, sub.schoolid, standards_tested
              ORDER BY administered_at) AS std_freq_rn                    
      ,CASE
        WHEN sub.schoolid = 73253 THEN
          ROW_NUMBER() OVER (
             PARTITION BY sub.academic_year, sub.schoolid, sub.subject, standards_tested
                 ORDER BY administered_at ASC) 
        ELSE
          ROW_NUMBER() OVER (
          PARTITION BY sub.academic_year, sub.schoolid, sub.grade_level, standards_tested
              ORDER BY administered_at ASC) 
       END AS std_attempt_rn
      ,CASE
        WHEN sub.schoolid = 73253 THEN
          ROW_NUMBER() OVER (
             PARTITION BY sub.academic_year, sub.schoolid, sub.subject, standards_tested
                 ORDER BY administered_at DESC) 
        ELSE
          ROW_NUMBER() OVER (
          PARTITION BY sub.academic_year, sub.schoolid, sub.grade_level, standards_tested
              ORDER BY administered_at DESC) 
       END AS std_attempt_curr
FROM
    (
     SELECT oq.assessment_id                          
           ,sch.schoolid -- derived from test results, if a student reports a result on that test, then it was administered at that school
           ,oq.title
           ,oq.description AS test_descr                                        
           ,CASE 
             WHEN tag = 'k' THEN '0'
             WHEN tag IN ('1','2','3','4','5','6','7','8','9','10','11','12') THEN tag
             ELSE NULL
            END AS grade_level
           ,oq.subject
           ,CASE
             WHEN oq.subject = 'Arabic' THEN 'WLANG'
             WHEN oq.subject = 'Arts: Music' THEN 'ART'
             WHEN oq.subject = 'Arts: Theatre' THEN 'ART'
             WHEN oq.subject = 'Arts: Visual Arts' THEN 'ART'
             WHEN oq.subject = 'Comprehension' THEN 'ENG'
             WHEN oq.subject = 'English Language Arts' THEN 'ENG'
             WHEN oq.subject = 'English' THEN 'ENG'
             WHEN oq.subject = 'Vocabulary' THEN 'ENG'
             WHEN oq.subject = 'French' THEN 'WLANG'
             WHEN oq.subject = 'Grammar' THEN 'ENG'
             WHEN oq.subject = 'Historical Arts' THEN 'SOC'
             WHEN oq.subject = 'History' THEN 'SOC'
             WHEN oq.subject = 'Humanities' THEN 'SOC'
             WHEN oq.subject = 'Mathematics' THEN 'MATH'
             WHEN oq.subject = 'Performing Arts' THEN 'ART'
             WHEN oq.subject = 'Phonics' THEN 'ENG'
             WHEN oq.subject = 'Physical Education' THEN 'PHYSED'
             WHEN oq.subject = 'Reading' THEN 'ENG'
             WHEN oq.subject = 'Science' THEN 'SCI'
             WHEN oq.subject = 'Spanish' THEN 'WLANG'
             WHEN oq.subject = 'Word Work' THEN 'ENG'
             WHEN oq.subject = 'Writing' THEN 'RHET'
             ELSE oq.subject
            END AS credittype
           ,oq.scope
           ,oq.custom_code AS standards_tested -- I regret using the plaural form #cringe
           ,oq.parent_standard
           ,oq.label AS standard_type
           ,dbo.ASCII_CONVERT(oq.std_descr) AS standard_descr
           ,oq.user_id
           ,oq.state_id AS teachernumber
           ,oq.last_name + ', ' + oq.first_name AS created_by                          
           ,fsa_dates.time_per_name AS fsa_week -- to get clean row number for FSA standard by week
           ,KIPP_NJ.dbo.fn_DateToSY(oq.administered_at) AS academic_year
           ,CONVERT(DATE,oq.administered_at) AS administered_at
           ,CONVERT(DATE,oq.created_at) AS created_at
           ,CONVERT(DATE,oq.updated_at) AS updated_at             
           ,CONVERT(DATE,oq.deleted_at) AS deleted_at
           ,oq.code_scope_id
           ,oq.code_subject_area_id
           ,oq.standard_id
           ,oq.parent_standard_id
           ,oq.reports_db_virtual_table_id             
           ,oq.local_assessment_id             
           ,oq.performance_band_set_id
           ,oq.itembank_assessment_id
           ,oq.locked
           ,oq.raw_score_performance_band_set_id
           ,oq.tags                    
     FROM OPENQUERY(ILLUMINATE,'
       SELECT a.*
             ,subj.code_translation AS subject
             ,scope.code_translation AS scope
             ,CAST(tags.tag AS VARCHAR) AS tag
             ,u.state_id
             ,u.first_name
             ,u.last_name
             ,std.standard_id
             ,std.parent_standard_id
             ,std.custom_code
             ,std.label                                 
             ,std.description AS std_descr
             ,parent.custom_code AS parent_standard
       FROM dna_assessments.assessments a
       LEFT OUTER JOIN dna_assessments.assessments_tags tag_index
         ON a.assessment_id = tag_index.assessment_id
       LEFT OUTER JOIN dna_assessments.tags tags
         ON tags.tag_id = tag_index.tag_id                            
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
       LEFT OUTER JOIN standards.standards parent
         ON std.parent_standard_id = parent.standard_id     
       WHERE a.deleted_at IS NULL                      
         AND tags.tag IN (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'',''11'',''12'',''k'')
     ') oq            
     LEFT OUTER JOIN schools_assessed sch
       ON oq.assessment_id = sch.assessment_id
     LEFT OUTER JOIN REPORTING$dates fsa_dates WITH (NOLOCK)
       ON oq.administered_at >= fsa_dates.start_date
      AND oq.administered_at <= fsa_dates.end_date             
      AND ((sch.schoolid = fsa_dates.schoolid) OR fsa_dates.schoolid IS NULL)
      AND fsa_dates.identifier IN ('FSA', 'REP')     
    ) sub        
LEFT OUTER JOIN REPORTING$dates rt WITH (NOLOCK) -- this is outside the subquery because we need the schoolid from the cte
  ON sub.administered_at >= rt.start_date
 AND sub.administered_at <= rt.end_date
 AND sub.schoolid = rt.schoolid 
 AND rt.identifier = 'RT'