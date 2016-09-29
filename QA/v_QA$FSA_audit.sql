USE KIPP_NJ
GO

ALTER VIEW QA$FSA_audit AS

SELECT DISTINCT 
       a.assessment_id      
      ,a.title      
      ,a.scope
      ,a.subject_area
      ,a.administered_at
      ,a.state_id AS teachernumber            
      ,u.lastfirst AS created_by      
      ,rt.alt_name AS term      
      ,co.reporting_schoolid AS schoolid
      ,'SCOPE' AS audit_type
      ,CASE 
        WHEN a.scope IN ('Exit Ticket') AND co.reporting_schoolid = 73258 THEN 1
        WHEN a.scope IN ('CMA - End-of-Module'
                        ,'CMA - Mid-Module'
                        ,'CMA - Checkpoint 1'
                        ,'CMA - Checkpoint 2'
                        ,'Topic Assessments'                        
                        ,'Unit Assessment') THEN 1
        ELSE 0 
       END AS audit_result      
FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
  ON a.state_id = u.teachernumber
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
  ON astd.standard_id = std.standard_id
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON a.assessment_id = ovr.assessment_id
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON ovr.local_student_id = co.student_number
 AND a.academic_year = co.year
 AND co.rn = 1
JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
  ON co.schoolid = rt.schoolid
 AND a.administered_at BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
WHERE a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

UNION ALL

SELECT DISTINCT 
       a.assessment_id      
      ,a.title      
      ,a.scope
      ,a.subject_area
      ,a.administered_at
      ,a.state_id AS teachernumber      
      ,u.lastfirst AS created_by      
      ,rt.alt_name AS term      
      ,co.reporting_schoolid AS schoolid
      ,'SUBJECT' AS audit_type
      ,CASE 
        WHEN a.subject_area IN ('Text Study'
                               ,'Mathematics'
                               ,'Science'
                               ,'Social Studies') THEN 1 
        WHEN a.scope IN ('Unit Assessment','Exit Ticket') AND a.subject_area IN ('Performing Arts','Visual Arts') THEN 1
        ELSE 0 
       END AS audit_result      
FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
  ON a.state_id = u.teachernumber
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
  ON astd.standard_id = std.standard_id
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON a.assessment_id = ovr.assessment_id
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON ovr.local_student_id = co.student_number
 AND a.academic_year = co.year
 AND co.rn = 1
JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
  ON co.schoolid = rt.schoolid
 AND a.administered_at BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
WHERE a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

UNION ALL

SELECT a.assessment_id      
      ,a.title      
      ,a.scope
      ,a.subject_area
      ,a.administered_at
      ,a.state_id AS teachernumber      
      ,u.lastfirst AS created_by      
      ,rt.alt_name AS term      
      ,co.reporting_schoolid AS schoolid
      ,'STANDARDS' AS audit_type
      ,CASE 
        WHEN COUNT(DISTINCT std.custom_code) > 0 THEN 1 
        ELSE 0 
       END AS audit_result
      --,COUNT(DISTINCT ovr.local_student_id) AS N_students_tested      
FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$USERS#static u WITH(NOLOCK)
  ON a.state_id = u.teachernumber
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
  ON astd.standard_id = std.standard_id
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON a.assessment_id = ovr.assessment_id
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON ovr.local_student_id = co.student_number
 AND a.academic_year = co.year
 AND co.rn = 1
JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
  ON co.schoolid = rt.schoolid
 AND a.administered_at BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
WHERE a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
GROUP BY a.assessment_id
        ,a.title
        ,a.scope
        ,a.subject_area
        ,a.administered_at
        ,a.state_id
        ,u.lastfirst                
        ,rt.alt_name
        ,co.reporting_schoolid