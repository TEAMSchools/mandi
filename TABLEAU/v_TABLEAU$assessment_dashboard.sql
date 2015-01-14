USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_dashboard AS

WITH groups AS (
  SELECT DISTINCT student_number
        ,academic_year
        ,illuminate_group AS groups
  FROM PS$enrollments_rollup#static WITH(NOLOCK)  
  WHERE academic_year >= 2013 -- first year w/ Illuminate, so we can hard code this 
 )

SELECT co.schoolid
      ,co.year AS academic_year
      ,co.grade_level
      ,co.team
      ,groups.groups
      ,co.student_number
      ,co.lastfirst
      ,co.spedlep      
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
      ,a.administered_at
      ,CONVERT(VARCHAR,a.standards_tested) AS standards_tested      
      ,a.standard_descr
      ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS percent_correct
      ,CONVERT(FLOAT,res.mastered) AS mastered      
      ,ROW_NUMBER() OVER(
         PARTITION BY co.studentid, a.scope, a.standards_tested
           ORDER BY a.administered_at DESC) AS rn_curr
FROM ILLUMINATE$assessment_results_by_standard#static res WITH (NOLOCK)
JOIN ILLUMINATE$distinct_assessments#static a WITH (NOLOCK)
  ON res.assessment_id = a.assessment_id
 AND res.standard_id = a.standard_id  
JOIN COHORT$identifiers_long#static co WITH (NOLOCK)
  ON res.local_student_id = co.student_number
 AND a.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 AND a.credittype = enr.credittype 
 AND enr.academic_year >= 2013 -- first year w/ Illuminate, so we can hard code this 
LEFT OUTER JOIN groups WITH(NOLOCK)
  ON co.STUDENT_NUMBER = groups.student_number
 AND co.year = groups.academic_year