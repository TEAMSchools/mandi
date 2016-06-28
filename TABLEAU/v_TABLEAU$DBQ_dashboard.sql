USE KIPP_NJ
GO

ALTER VIEW TABLEAU$DBQ_dashboard AS

WITH assessment_data AS (
  SELECT *        
        ,LAG(indexed_overall_score, 1) OVER(
           PARTITION BY local_student_id, academic_year 
             ORDER BY administered_at ASC) AS prev_indexed_overall_score                        
        ,LAG(indexed_overall_score, CASE WHEN rn = 1 THEN NULL ELSE rn - 1 END) OVER(
           PARTITION BY local_student_id, academic_year 
             ORDER BY administered_at ASC) AS first_indexed_overall_score                        
  FROM
      (
       SELECT a.academic_year
             ,a.administered_at
             ,CASE
               WHEN a.academic_year >= 2015 THEN LEFT(LTRIM(RTRIM(a.title)),6) 
               ELSE 'SOC'
              END AS course_number
             ,a.assessment_id
             ,a.title                   
             ,CASE WHEN a.title LIKE '%modified%' THEN 1 ELSE 0 END AS is_modified
             ,COUNT(a.assessment_id) OVER(PARTITION BY ovr.local_student_id, a.academic_year) AS n_dbq_possible             
             ,COUNT(CASE WHEN ovr.percent_correct < 20 THEN NULL ELSE ovr.percent_correct END) OVER(PARTITION BY ovr.local_student_id, a.academic_year) AS n_dbq_taken            

             ,ovr.local_student_id
             ,ovr.percent_correct AS overall_pct_correct             
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
             
             ,CONVERT(FLOAT,ovr.percent_correct) * ISNULL(dbq.overall_index, 1.0) AS indexed_overall_score                     
             ,ROW_NUMBER() OVER(
                PARTITION BY ovr.local_student_id, a.academic_year 
                  ORDER BY a.administered_at ASC) AS rn             
       FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
       JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
         ON a.assessment_id = ovr.assessment_id
        AND ovr.answered > 0
       LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_DBQ_dbq_difficulty_index dbq WITH(NOLOCK)
         ON LTRIM(RTRIM(a.title)) = dbq.assessment_title
       WHERE ((a.academic_year >= 2015 AND a.subject_area = 'History' AND a.scope = 'DBQ')
                 OR (a.academic_year <= 2014 AND a.title LIKE '%DBQ%' AND a.scope = 'Interim Assessment'AND a.subject_area IN ('Comparative Government'
                                                                                                                              ,'Global Studies/ AWH'
                                                                                                                              ,'History'
                                                                                                                              ,'Modern World History'
                                                                                                                              ,'US History')))
      ) sub
 )

,enrollments AS (
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
        ,enr.credittype AS course_number
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

SELECT co.student_number
      ,co.lastfirst      
      ,co.grade_level
      ,co.SPEDLEP      
      ,co.enroll_status
      ,co.year AS academic_year
      
      ,enr.COURSE_NAME
      ,enr.course_period
      ,enr.teacher_name
            
      ,d.alt_name AS term      
      
      ,a.assessment_id
      ,a.title      
      ,a.is_modified
      ,a.n_dbq_taken
      ,a.n_dbq_possible
      ,a.overall_pct_correct
      ,std.custom_code AS standard_code
      ,std.description AS standard_description                  
      ,res.percent_correct AS standard_pct_correct      
      
      ,a.overall_index
      ,a.n_total_docs
      ,a.n_req_docs
      ,a.doc_type_diversity
      ,a.doc_complexity
      ,a.bucketing_complexity__potential
      ,a.bucketing_complexity__required
      ,a.prompt_question_complexity
      ,a.time_given
      ,a.preteaching_scaffolds      
      ,a.indexed_overall_score      
      ,a.prev_indexed_overall_score
      ,CASE
        WHEN a.indexed_overall_score > a.prev_indexed_overall_score THEN 1
        WHEN a.indexed_overall_score <= a.prev_indexed_overall_score THEN 0
       END AS is_positive_growth
      ,a.first_indexed_overall_score
      ,CASE
        WHEN a.indexed_overall_score > a.first_indexed_overall_score THEN 1
        WHEN a.indexed_overall_score <= a.first_indexed_overall_score THEN 0
       END AS is_positive_growth_ytd

      ,ROW_NUMBER() OVER(
         PARTITION BY a.assessment_id, co.student_number
           ORDER BY co.student_number) AS overall_score_rn      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN enrollments enr
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year 
JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON co.schoolid = d.schoolid
 AND co.year = d.academic_year
 AND d.identifier = 'RT'
 AND d.start_date <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN assessment_data a
  ON co.student_number = a.local_student_id
 AND co.year = a.academic_year
 AND a.administered_at BETWEEN d.start_date AND d.end_date
 AND enr.COURSE_NUMBER = a.course_number
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd
  ON a.assessment_id = astd.assessment_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std
  ON astd.standard_id = std.standard_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
  ON a.assessment_id = res.assessment_id
 AND a.local_student_id = res.local_student_id
 AND astd.standard_id = res.standard_id   
WHERE co.year >= 2013
  AND co.schoolid = 73253
  AND co.enroll_status IN (0,3)
  AND co.rn = 1