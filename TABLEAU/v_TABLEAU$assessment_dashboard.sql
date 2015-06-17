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
      ,COALESCE(enr.period, enr.section_number) AS section
      ,enr.behavior_tier AS rti_tier
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
      ,a.std_attempt_curr
      ,ROW_NUMBER() OVER(
         PARTITION BY ovr.student_number, a.assessment_id
           ORDER BY ovr.student_number) AS overall_rn
      ,ROW_NUMBER() OVER(
         PARTITION BY ovr.student_number, a.scope, a.standard_id
           ORDER BY a.administered_at DESC) AS rn_curr
FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH (NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH (NOLOCK) 
  ON a.academic_year = co.year
 AND a.grade_level = co.grade_level
 AND a.schoolid = co.schoolid
 AND co.rn = 1
JOIN KIPP_NJ..ILLUMINATE$assessment_results_overall#static ovr WITH(NOLOCK)
  ON co.student_number = ovr.student_number
 AND a.assessment_id = ovr.assessment_id 
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 AND a.subject = enr.illuminate_subject
 AND enr.drop_flags = 0
LEFT OUTER JOIN (
                 SELECT DISTINCT 
                        student_number
                       ,academic_year
                       ,illuminate_group AS groups
                 FROM KIPP_NJ..PS$enrollments_rollup#static WITH(NOLOCK)  
                 WHERE academic_year >= KIPP_NJ.dbo.fn_Global_Academic_Year() -- first year w/ Illuminate, so we can hard code this 
                ) groups
  ON co.STUDENT_NUMBER = groups.student_number
 AND co.year = groups.academic_year
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_results_by_standard#static res WITH (NOLOCK)
  ON a.assessment_id = res.assessment_id
 AND a.standard_id = res.standard_id  
 AND ovr.student_number = res.local_student_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$SPED_comments#static comm WITH(NOLOCK)
  ON ovr.student_number = comm.student_number
 AND a.subject = comm.subject
 AND comm.rn = 1
WHERE a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year() 

/*
UNION ALL

SELECT schoolid
      ,academic_year
      ,grade_level
      ,team
      ,groups
      ,student_number
      ,lastfirst
      ,spedlep
      ,enroll_status
      ,gender
      ,retained_yr_flag
      ,retained_ever_flag
      ,assessment_id
      ,title
      ,scope
      ,subject
      ,credittype
      ,COURSE_NAME
      ,teacher_name
      ,section
      ,rti_tier
      ,term
      ,fsa_week
      ,administered_at
      ,standards_tested
      ,standard_descr
      ,parent_standard
      ,percent_correct
      ,mastered
      ,overall_pct_correct
      ,comment
      ,comment_date
      ,std_attempt_rn
      ,NULL AS std_attempt_curr
      ,overall_rn
      ,rn_curr
FROM KIPP_NJ..TABLEAU$assessment_dashboard#ARCHIVE WITH(NOLOCK)
*/