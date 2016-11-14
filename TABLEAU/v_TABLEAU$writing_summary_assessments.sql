USE KIPP_NJ
GO

ALTER VIEW TABLEAU$writing_summary_assessments AS

WITH enrollments AS (
  SELECT enr.student_number
        ,enr.academic_year
        ,REPLACE(enr.COURSE_NUMBER,'ENG11','ENG10') AS course_number
        ,enr.course_name
        ,enr.period AS course_period
        ,enr.teacher_name      
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year, course_number
             ORDER BY drop_flags DESC, dateenrolled DESC) AS rn
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year >= 2015
    AND enr.CREDITTYPE = 'ENG'      
    AND enr.SCHOOLID = 73253
  
  UNION ALL

  SELECT enr.student_number
        ,enr.academic_year
        ,'ENG' AS course_number
        ,enr.course_name
        ,enr.period AS course_period
        ,enr.teacher_name      
        ,1 AS rn
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year <= 2014
    AND enr.CREDITTYPE = 'ENG'  
    AND enr.drop_flags = 0
    AND enr.rn_subject = 1
    AND enr.SCHOOLID = 73253
 )  

SELECT co.SCHOOLID
      ,co.GRADE_LEVEL      
      ,co.student_number
      ,co.lastfirst
      ,co.team
      ,co.SPEDLEP      
      ,'OER' AS test_type

      ,w.title
      ,w.academic_year
      ,w.term
      ,w.unit_number
      ,w.course_number            
      ,w.strand
      ,w.prompt_number
      ,CONVERT(FLOAT,w.field_value) AS score     
      
      ,enr.course_name
      ,enr.course_period
      ,enr.teacher_name
FROM KIPP_NJ..ILLUMINATE$writing_scores_long#static w WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON w.student_number = co.student_number
 AND w.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year 
 AND w.course_number = enr.course_number 
 AND enr.rn = 1

UNION ALL

/* DBQs */
SELECT sub.schoolid
      ,sub.grade_level
      ,sub.student_number
      ,sub.lastfirst
      ,sub.team
      ,sub.SPEDLEP
      ,'DBQ' AS test_type
      ,sub.title
      ,sub.academic_year
      ,sub.term
      ,sub.unit_number
      ,sub.course_number
      ,sub.strand
      ,sub.prompt_number
      ,sub.score
      ,enr.course_name
      ,enr.period AS course_period
      ,enr.teacher_name
FROM
    (
     SELECT co.schoolid
           ,co.grade_level
           ,co.student_number
           ,co.lastfirst
           ,co.team
           ,co.SPEDLEP

           ,a.title
           ,a.academic_year      
           ,dts.alt_name AS term      
           ,SUBSTRING(a.title, PATINDEX('%QE_%', a.title), 3) AS unit_number
           ,LEFT(a.title, 6) AS course_number            
           ,std.description AS strand
           ,1 AS prompt_number
           ,CONVERT(FLOAT,r.percent_correct) AS score           
           
     FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
     JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
       ON a.administered_at BETWEEN dts.start_date AND dts.end_date
      AND dts.schoolid = 73253
      AND dts.identifier = 'RT'
     JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static astd WITH(NOLOCK)
       ON a.assessment_id = astd.assessment_id
     JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
       ON astd.standard_id = std.standard_id
     JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard r WITH(NOLOCK)
       ON a.assessment_id = r.assessment_id
      AND astd.standard_id = r.standard_id
     JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       ON r.local_student_id = co.student_number
      AND a.academic_year = co.year 
      AND co.rn = 1
     WHERE a.scope = 'DBQ'
       AND a.subject_area = 'History'
    ) sub
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON sub.student_number = enr.student_number
 AND sub.academic_year = enr.academic_year
 AND sub.course_number = enr.COURSE_NUMBER
 AND enr.drop_flags = 0