USE KIPP_NJ
GO

ALTER VIEW TABLEAU$assessment_dashboard AS

WITH distinct_assessments AS (
  SELECT DISTINCT
         assessment_id
        ,standard_id
        ,title
        ,scope
        ,subject
        ,credittype
        ,term
        ,administered_at
        ,standards_tested        
        ,standard_descr
  FROM ILLUMINATE$assessments#static WITH(NOLOCK)  
 )

,enrollments AS (
  SELECT cc.STUDENTID
        ,cc.TERMID
        ,dbo.fn_DateToSY(cc.DATEENROLLED) AS academic_year
        ,cou.CREDITTYPE
        ,cc.COURSE_NUMBER      
        ,cou.COURSE_NAME
        ,cc.SECTION_NUMBER
        ,cc.SECTIONID      
        ,CASE        
          WHEN cc.SCHOOLID != 73253 THEN cc.EXPRESSION
          WHEN cc.expression = '1(A)' THEN 'HR'
          WHEN cc.expression = '2(A)' THEN '1'
          WHEN cc.expression = '3(A)' THEN '2'
          WHEN cc.expression = '4(A)' THEN '3'
          WHEN cc.expression = '5(A)' THEN '4A'
          WHEN cc.expression = '6(A)' THEN '4B'
          WHEN cc.expression = '7(A)' THEN '4C'
          WHEN cc.expression = '8(A)' THEN '4D'
          WHEN cc.expression = '9(A)' THEN '5A'
          WHEN cc.expression = '10(A)' THEN '5B'
          WHEN cc.expression = '11(A)' THEN '5C'
          WHEN cc.expression = '12(A)' THEN '5D'
          WHEN cc.expression = '13(A)' THEN '6'
          WHEN cc.expression = '14(A)' THEN '7'       
         END AS period
        ,ROW_NUMBER() OVER(
           PARTITION BY cc.studentid, cou.credittype, dbo.fn_DateToSY(cc.DATEENROLLED)
             ORDER BY cc.termid DESC, cc.dateenrolled DESC) AS rn
   FROM CC WITH(NOLOCK)
   JOIN COURSES cou WITH(NOLOCK)
     ON cc.COURSE_NUMBER = cou.COURSE_NUMBER
    AND cou.CREDITTYPE IS NOT NULL
    AND cou.CREDITTYPE NOT IN ('LOG', 'PHYSED', 'STUDY')   
 )

,groups AS (
  SELECT student_number
        ,dbo.GROUP_CONCAT_D(group_name,', ') + ',' AS groups
  FROM ILLUMINATE$student_groups#static WITH(NOLOCK)
  GROUP BY student_number
 )

SELECT co.schoolid
      ,co.year AS academic_year
      ,co.grade_level
      ,s.team
      ,groups.groups
      ,co.student_number
      ,co.lastfirst
      ,cs.spedlep      
      ,a.title
      ,a.scope            
      ,a.subject      
      ,a.credittype      
      ,enr.COURSE_NAME
      ,CASE WHEN co.schoolid = 73253 THEN enr.period ELSE enr.SECTION_NUMBER END AS section
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
JOIN distinct_assessments a WITH (NOLOCK)
  ON res.assessment_id = a.assessment_id
 AND res.standard_id = a.standard_id  
LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 AND a.credittype = enr.credittype
 AND enr.rn = 1
LEFT OUTER JOIN groups WITH(NOLOCK)
  ON co.STUDENT_NUMBER = groups.student_number
