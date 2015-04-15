USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_dashboard AS

SELECT co.schoolid
      ,co.year AS academic_year
      ,co.grade_level
      ,co.team
      ,groups.groups
      ,co.student_number
      ,co.lastfirst
      ,co.spedlep  
      ,co.enroll_status    
      ,co.gender
      ,co.retained_yr_flag
      ,co.retained_ever_flag
      ,a.assessment_id
      ,a.title
      ,a.scope            
      ,a.subject      
      ,a.credittype      
      ,enr.COURSE_NAME
      ,enr.teacher_name
      ,enr.section
      ,enr.rti_tier
      ,a.term
      ,a.fsa_week
      ,a.administered_at
      ,CONVERT(VARCHAR,a.standards_tested) AS standards_tested      
      ,a.standard_descr
      ,a.parent_standard
      ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS percent_correct
      ,CONVERT(FLOAT,res.mastered) AS mastered      
      ,ovr.percent_correct AS overall_pct_correct
      ,comm.comment
      ,comm.date AS comment_date
      ,a.std_attempt_rn
      ,ROW_NUMBER() OVER(
         PARTITION BY ovr.student_number, a.assessment_id
           ORDER BY ovr.student_number) AS overall_rn
      ,ROW_NUMBER() OVER(
         PARTITION BY ovr.student_number, a.scope, a.standard_id
           ORDER BY a.administered_at DESC) AS rn_curr
FROM ILLUMINATE$assessments#static a WITH (NOLOCK)
JOIN COHORT$identifiers_long#static co WITH (NOLOCK) 
  ON a.academic_year = co.year
 AND a.grade_level = co.grade_level
 AND a.schoolid= co.schoolid
 AND co.rn = 1
JOIN ILLUMINATE$assessment_results_overall#static ovr WITH(NOLOCK)
  ON ovr.student_number = co.student_number
 AND a.assessment_id = ovr.assessment_id 
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 AND a.credittype = enr.credittype  
LEFT OUTER JOIN (
                 SELECT DISTINCT 
                        student_number
                       ,academic_year
                       ,illuminate_group AS groups
                 FROM PS$enrollments_rollup#static WITH(NOLOCK)  
                 WHERE academic_year >= 2013 -- first year w/ Illuminate, so we can hard code this 
                ) groups
  ON co.STUDENT_NUMBER = groups.student_number
 AND co.year = groups.academic_year
LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static res WITH (NOLOCK)
  ON a.assessment_id = res.assessment_id
 AND a.standard_id = res.standard_id  
 AND ovr.student_number = res.local_student_id
LEFT OUTER JOIN ILLUMINATE$SPED_comments#static comm WITH(NOLOCK)
  ON ovr.student_number = comm.student_number
 AND a.subject = comm.subject
 AND comm.rn = 1