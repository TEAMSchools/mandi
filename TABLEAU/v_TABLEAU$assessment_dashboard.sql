USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_dashboard AS

SELECT co.schoolid
      ,co.grade_level
      ,s.team
      --,grp.group_name
      ,co.student_number
      ,co.lastfirst
      ,cs.spedlep      
      ,a.title
      ,a.scope            
      ,a.subject      
      ,a.credittype      
      ,a.term
      ,a.administered_at
      ,CONVERT(VARCHAR,a.standards_tested) AS standards_tested
      ,dbo.ASCII_CONVERT(a.standard_descr) AS standard_descr
      ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS percent_correct
      ,CONVERT(FLOAT,res.mastered) AS mastered
      ,ROW_NUMBER() OVER(
          PARTITION BY co.studentid, a.scope, a.standards_tested
              ORDER BY a.administered_at DESC) AS rn_curr
FROM ILLUMINATE$assessment_results_by_standard#static res WITH (NOLOCK)
JOIN COHORT$comprehensive_long#static co WITH (NOLOCK)
  ON res.local_student_id = co.student_number
 AND res.academic_year = co.year
 AND co.rn = 1
JOIN STUDENTS s WITH(NOLOCK)
  ON co.studentid = s.id
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON co.studentid = cs.studentid
JOIN ILLUMINATE$assessments#static a WITH (NOLOCK)
  ON res.assessment_id = a.assessment_id
 AND res.standard_id = a.standard_id
 AND co.schoolid = a.schoolid
 AND co.grade_level = a.grade_level
 AND a.deleted_at IS NULL
--LEFT OUTER JOIN ILLUMINATE$student_groups#static grp WITH(NOLOCK)
--  ON co.STUDENT_NUMBER = grp.student_number
-- AND res.academic_year = grp.academic_year
-- --AND res.administered_at >= grp.eligibility_start_date
