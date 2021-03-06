USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_dashboard AS

WITH groups AS (
  SELECT student_number
        ,academic_year
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(group_name, ', ') AS groups
  FROM ILLUMINATE$student_groups#static WITH(NOLOCK)
  GROUP BY student_number
          ,academic_year
 )

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
      ,a.subject_area AS subject
      ,a.credittype   
      ,CASE 
        WHEN a.tags IS NULL THEN 0
        WHEN CHARINDEX(REPLACE(co.grade_level, 0, 'K'), a.tags) = 0 THEN 1 
        ELSE 0 
       END AS is_replacement
      ,enr.COURSE_NAME
      ,enr.teacher_name
      ,COALESCE(enr.period, enr.section_number) AS section
      ,enr.behavior_tier AS rti_tier
      ,a.term
      ,a.reporting_wk AS fsa_week
      ,a.administered_at
      ,a.standard_code AS standards_tested      
      ,a.standard_description AS standard_descr
      ,NULL AS parent_standard
      ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS percent_correct
      ,CONVERT(FLOAT,res.mastered) AS mastered      
      ,CONVERT(DATE,ovr.date_taken) AS date_taken
      ,ovr.percent_correct AS overall_pct_correct
      ,comm.comment
      ,comm.date AS comment_date
      ,a.std_attempt_rn
      ,a.std_attempt_curr
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, a.assessment_id
           ORDER BY co.student_number) AS overall_rn
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, a.scope, a.standard_id
           ORDER BY a.administered_at DESC) AS rn_curr
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.year, a.standard_id
           ORDER BY ovr.date_taken ASC) AS stu_std_attempt_rn
FROM KIPP_NJ..ILLUMINATE$assessments_long#static a WITH (NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH (NOLOCK) 
  ON a.academic_year = co.year
 --AND a.grade_level = co.grade_level
 AND a.schoolid = co.schoolid
 AND co.rn = 1
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON co.student_number = ovr.local_student_id
 AND a.assessment_id = ovr.assessment_id  
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 AND a.subject_area = enr.illuminate_subject
 AND enr.drop_flags = 0
LEFT OUTER JOIN groups
  ON co.STUDENT_NUMBER = groups.student_number 
 AND co.year = groups.academic_year
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH (NOLOCK)
  ON co.student_number = res.local_student_id
 AND a.assessment_id = res.assessment_id
 AND a.standard_id = res.standard_id  
LEFT OUTER JOIN KIPP_NJ..REPORTING$SPED_comments#static comm WITH(NOLOCK)
  ON co.student_number = comm.student_number
 AND co.year = comm.academic_year
 AND a.subject_area = comm.subject
 AND comm.rn = 1
WHERE a.academic_year >= KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.schoolid != 999999
  AND ((co.schoolid = 73258 AND ovr.answered > 0) OR (co.schoolid != 73258))

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