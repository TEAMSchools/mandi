USE KIPP_NJ
GO

ALTER VIEW TABLEAU$DBQ_dashboard AS

WITH enrollments AS (
  SELECT enr.student_number
        ,enr.academic_year
        ,enr.course_number
        ,enr.course_name
        ,enr.period AS course_period
        ,enr.teacher_name      
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year >= 2015
    AND enr.CREDITTYPE = 'SOC'  
    AND enr.drop_flags = 0    
    AND enr.SCHOOLID = 73253

  UNION ALL
  
  SELECT enr.student_number
        ,enr.academic_year
        ,enr.course_number
        ,enr.course_name
        ,enr.period AS course_period
        ,enr.teacher_name      
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year <= 2014
    AND enr.CREDITTYPE = 'SOC'  
    AND enr.drop_flags = 0
    AND enr.rn_subject = 1
    AND enr.SCHOOLID = 73253    
 )  

SELECT co.grade_level
      ,co.lastfirst
      ,co.SPEDLEP      
      ,co.enroll_status
      ,a.academic_year
      ,a.term      
      ,a.administered_at
      ,a.title      
      ,a.standard_code
      ,a.standard_description      
      ,ovr.local_student_id AS student_number
      ,ovr.percent_correct AS overall_pct_correct
      ,std.percent_correct AS standard_pct_correct
      ,dbq.overall_index
      ,dbq._total_docs AS n_total_docs
      ,dbq._req_docs AS n_req_docs
      ,dbq.doc_type_diversity
      ,dbq.doc_complexity
      ,dbq.bucketing_complexity__potential
      ,dbq.bucketing_complexity__required
      ,dbq.promptquestion AS prompt_question_complexity
      ,dbq.[time] AS time_given
      ,dbq.preteaching_scaffolds
      ,ovr.percent_correct * ISNULL(dbq.overall_index,1) AS indexed_overall_score
      ,LAG((ovr.percent_correct * ISNULL(dbq.overall_index,1)), 1) OVER(
         PARTITION BY a.academic_year, ovr.local_student_id
           ORDER BY a.administered_at) AS prev_indexed_overall_score
      ,ROW_NUMBER() OVER(
         PARTITION BY a.assessment_id, ovr.local_student_id
           ORDER BY ovr.local_student_id) AS overall_score_rn

      ,enr.COURSE_NAME
      ,enr.course_period
      ,enr.teacher_name
FROM KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
  ON a.assessment_id = ovr.assessment_id
JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard std WITH(NOLOCK)
  ON a.assessment_id = std.assessment_id
 AND a.standard_id = std.standard_id
 AND ovr.local_student_id = std.local_student_id
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_DBQ_dbq_difficulty_index dbq WITH(NOLOCK)
  ON a.title = dbq.assessment_title
 --AND a.academic_year = dbq.academic_year
 --AND a.term = dbq.term 
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON ovr.local_student_id = co.student_number
 AND a.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN enrollments enr
  ON ovr.local_student_id = enr.student_number
 AND a.academic_year = enr.academic_year 
 AND ((a.academic_year >= 2015 AND LEFT(a.title,6) = enr.course_number)
        OR (a.academic_year <= 2014))
WHERE (a.academic_year >= 2015 
         AND a.subject_area = 'History' 
         AND a.scope = 'DBQ')
        OR (a.academic_year <= 2014 
              AND a.subject_area IN ('Comparative Government','Global Studies/ AWH','History','Modern World History','US History') 
              AND a.scope = 'Interim Assessment')