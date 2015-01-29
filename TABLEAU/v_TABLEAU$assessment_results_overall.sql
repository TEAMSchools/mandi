USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_results_overall AS 

WITH distinct_assessments AS (
  SELECT DISTINCT
         assessment_id        
        ,title
        ,scope
        ,subject
        ,credittype
        ,term
        ,academic_year
        ,administered_at        
  FROM ILLUMINATE$assessments#static WITH(NOLOCK)  
 )

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
      ,ROUND(AVG(percent_correct),1) AS avg_pct_correct
      ,ROUND(AVG(mastered) * 100,1) AS pct_mastery
FROM
    (
     SELECT co.schoolid
           ,co.year AS academic_year
           ,co.grade_level
           ,co.team
           --,groups.groups
           ,co.student_number
           ,co.lastfirst
           ,co.spedlep      
           ,a.assessment_id
           ,a.title
           ,a.scope            
           ,a.subject      
           ,a.credittype      
           ,enr.COURSE_NAME
           ,CASE WHEN co.schoolid = 73253 THEN enr.period ELSE enr.SECTION_NUMBER END AS section
           ,enr.teacher_name
           ,a.term
           ,a.administered_at            
           ,ROUND(CONVERT(FLOAT,res.percent_correct),1) AS percent_correct
           ,CONVERT(FLOAT,res.mastered) AS mastered      
     FROM ILLUMINATE$assessment_results_overall#static res WITH(NOLOCK)
     JOIN distinct_assessments a WITH (NOLOCK)
       ON res.assessment_id = a.assessment_id 
     JOIN COHORT$identifiers_long#static co WITH (NOLOCK)
       ON res.student_number = co.student_number
      AND a.academic_year = co.year
      AND co.schoolid IN (73253,73252,133570965)
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
        ,CUBE(spedlep)