USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_dashboard_rollup AS 

SELECT schoolid
      ,academic_year
      --,grade_level
      --,team      
      ,spedlep      
      ,assessment_id
      ,title
      ,scope
      ,subject
      ,credittype
      ,COURSE_NAME
      ,teacher_name
      ,section
      --,rti_tier -- too many combinations
      ,term
      ,administered_at
      ,standards_tested
      ,standard_descr
      ,ROUND(AVG(percent_correct),1) AS avg_pct_correct
      ,ROUND(AVG(mastered) * 100,1) AS pct_mastery
      --,ROW_NUMBER() OVER(
      --   PARTITION BY section, scope, standards_tested
      --     ORDER BY administered_at DESC) AS rn_curr
FROM
    (
     SELECT co.schoolid
           ,co.year AS academic_year
           ,co.grade_level
           ,co.team           
           ,co.student_number
           ,co.lastfirst
           ,co.spedlep                 
           ,a.assessment_id
           ,a.title
           ,a.scope            
           ,a.subject_area AS subject
           ,a.credittype      
           ,enr.COURSE_NAME
           ,enr.teacher_name
           ,CASE WHEN co.schoolid = 73253 THEN enr.period ELSE enr.SECTION_NUMBER END AS section
           ,enr.tier AS rti_tier
           ,a.term
           ,a.administered_at
           ,CONVERT(VARCHAR,a.standard_code) AS standards_tested      
           ,a.standard_description AS standard_descr
           ,CONVERT(FLOAT,res.percent_correct) AS percent_correct
           ,CONVERT(FLOAT,res.mastered) AS mastered                 
     FROM KIPP_NJ..ILLUMINATE$agg_student_responses_standard#static res WITH (NOLOCK)
     JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH (NOLOCK)
       ON res.assessment_id = a.assessment_id
      AND res.standard_id = a.standard_id  
     JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH (NOLOCK)
       ON res.local_student_id = co.student_number
      AND a.academic_year = co.year
      AND a.schoolid = co.schoolid
      AND a.grade_level = co.grade_level
      AND co.rn = 1     
     LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       ON co.studentid = enr.studentid
      AND co.year = enr.academic_year
      AND a.credittype = enr.credittype            
    ) sub
GROUP BY schoolid
        ,academic_year        
        ,assessment_id
        ,title
        ,scope
        ,subject
        ,credittype
        ,COURSE_NAME
        ,teacher_name
        ,section        
        ,term
        ,administered_at
        ,standards_tested
        ,standard_descr
        ,CUBE(spedlep)