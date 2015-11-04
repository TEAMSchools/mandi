USE KIPP_NJ
GO

ALTER VIEW QA$Illuminate_CMA_entry_audit AS

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status      
      ,dt.alt_name AS term
      ,dt.start_date
      ,dt.end_date
      ,a.assessment_id
      ,a.title
      ,a.administered_at
      ,a.subject_area
      ,a.scope   
      ,ovr.percent_correct   
      ,0 AS is_replacement
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
JOIN KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  ON co.year = a.academic_year
 AND CHARINDEX(REPLACE(co.grade_level,0,'K'), a.tags) != 0 
 AND a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')
 AND a.administered_at BETWEEN dt.start_date AND dt.end_date
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON co.student_number = ovr.local_student_id
 AND a.assessment_id = ovr.assessment_id
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND co.rn = 1