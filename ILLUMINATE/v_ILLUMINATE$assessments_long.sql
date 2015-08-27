USE KIPP_NJ
GO

--ALTER VIEW ILLUMINATE$assessments_long AS

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
     SELECT a.assessment_id                                     
           ,a.title       
           ,a.scope    
           ,a.subject_area           
           ,CASE
             WHEN a.subject_area = 'Arabic' THEN 'WLANG'
             WHEN a.subject_area = 'Arts: Music' THEN 'ART'
             WHEN a.subject_area = 'Arts: Theatre' THEN 'ART'
             WHEN a.subject_area = 'Arts: Visual Arts' THEN 'ART'
             WHEN a.subject_area = 'Comprehension' THEN 'ENG'
             WHEN a.subject_area = 'English Language Arts' THEN 'ENG'
             WHEN a.subject_area = 'English' THEN 'ENG'
             WHEN a.subject_area = 'Vocabulary' THEN 'ENG'
             WHEN a.subject_area = 'French' THEN 'WLANG'
             WHEN a.subject_area = 'Grammar' THEN 'ENG'
             WHEN a.subject_area = 'Historical Arts' THEN 'SOC'
             WHEN a.subject_area = 'History' THEN 'SOC'
             WHEN a.subject_area = 'Humanities' THEN 'SOC'
             WHEN a.subject_area = 'Mathematics' THEN 'MATH'
             WHEN a.subject_area = 'Performing Arts' THEN 'ART'
             WHEN a.subject_area = 'Phonics' THEN 'ENG'
             WHEN a.subject_area = 'Physical Education' THEN 'PHYSED'
             WHEN a.subject_area = 'Reading' THEN 'ENG'
             WHEN a.subject_area = 'Science' THEN 'SCI'
             WHEN a.subject_area = 'Spanish' THEN 'WLANG'
             WHEN a.subject_area = 'Word Work' THEN 'ENG'
             WHEN a.subject_area = 'Writing' THEN 'RHET'
             ELSE a.subject_area
            END AS credittype           
           ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,a.administered_at)) AS academic_year
           ,CONVERT(DATE,a.administered_at) AS administered_at
           ,a.state_id AS teachernumber
           ,a.performance_band_set_id
           ,sch.schoolid
           ,sch.grade_level
           ,std.custom_code AS standard_code
           ,KIPP_NJ.dbo.ASCII_CONVERT(std.description) AS standard_description
           ,rpt_wks.time_per_name AS reporting_wk
           ,rt.alt_name AS term

           --,a.tags                                          
           --,a.last_name + ', ' + a.first_name AS created_by                          
           --,a.description AS test_descr           
           --,a.parent_standard
           --,a.user_id           
           --,CONVERT(DATE,a.created_at) AS created_at
           --,CONVERT(DATE,a.updated_at) AS updated_at             
           --,CONVERT(DATE,a.deleted_at) AS deleted_at
           --,a.code_scope_id
           --,a.code_subject_area_id
           --,a.standard_id
           --,a.parent_standard_id
           --,a.reports_db_virtual_table_id             
           --,a.local_assessment_id                        
           --,a.itembank_assessment_id
           --,a.locked
           --,a.raw_score_performance_band_set_id
           --,CASE 
           --  WHEN tag = 'k' THEN '0'
           --  WHEN tag IN ('1','2','3','4','5','6','7','8','9','10','11','12') THEN tag
           --  ELSE NULL
           -- END AS grade_level           
           --,std.label AS standard_type           
     FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessments_sites#static sch WITH(NOLOCK)
       ON a.assessment_id = sch.assessment_id
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
       ON a.assessment_id = astd.assessment_id
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
       ON astd.standard_id = std.standard_id
     LEFT OUTER JOIN REPORTING$dates rpt_wks WITH(NOLOCK)
       ON a.administered_at BETWEEN rpt_wks.start_date AND rpt_wks.end_date
      AND sch.schoolid = rpt_wks.schoolid
      AND rpt_wks.identifier = 'REP'
     LEFT OUTER JOIN REPORTING$dates rt WITH (NOLOCK)
       ON a.administered_at BETWEEN rt.start_date AND rt.end_date
      AND sch.schoolid = rt.schoolid
      AND rt.identifier = 'RT'
    ) sub        
