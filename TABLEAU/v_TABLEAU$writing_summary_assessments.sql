USE KIPP_NJ
GO

ALTER VIEW TABLEAU$writing_summary_assessments AS

WITH assessments AS (
  SELECT a.repository_id
        ,a.schoolid
        ,a.grade_level
        ,a.title
        ,a.scope
        ,a.subject      
        ,a.date_administered
        ,dbo.fn_DateToSY(a.date_administered) AS academic_year
        ,f.label AS field_label
        ,f.name AS field_name        
  FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)
  JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
    ON a.repository_id = f.repository_id      
  WHERE a.title IN ('Writing - Interim - TEAM MS', 'Writing - Interim - TEAM HS')
 )

,results_wide AS (
  SELECT *
  FROM
      (
       SELECT s.SCHOOLID
             ,s.grade_level      
             ,s.id AS studentid
             ,s.STUDENT_NUMBER
             ,s.lastfirst      
             ,s.team
             ,a.repository_id
             ,a.title
             --,a.scope
             --,a.subject                            
             ,a.field_label
             ,res.repository_row_id
             ,res.value AS field_value           
       FROM STUDENTS s WITH(NOLOCK)        
       JOIN assessments a WITH(NOLOCK)
         ON s.schoolid = a.SCHOOLID
        AND s.grade_level = a.GRADE_LEVEL 
       JOIN ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
         ON s.student_number = res.student_id
        AND a.repository_id = res.repository_id
        AND a.field_name = res.field     
      ) sub

  PIVOT(
    MAX(field_value)
    FOR field_label IN ([Year]
                       ,[Interim]
                       ,[Overall]
                       ,[Organization]
                       ,[Elaboration]
                       ,[Conventions]
                       ,[Capitalization]
                       ,[End Punctuation])
   ) p
 )

,enrollments AS (
  SELECT cc.studentid
        ,c.COURSE_NAME      
        ,dbo.fn_ExprToPeriod(cc.EXPRESSION) AS period
        ,ROW_NUMBER() OVER(
           PARTITION BY cc.studentid
             ORDER BY c.course_number DESC) AS rn
  FROM CC WITH(NOLOCK)
  JOIN COURSES c WITH(NOLOCK)
    ON cc.course_number = c.course_number
   AND c.CREDITTYPE = 'RHET'
  WHERE cc.SCHOOLID = 73253
    AND cc.TERMID >= dbo.fn_Global_Term_Id()
    AND cc.SECTIONID > 0
 )

SELECT w.*
      ,cs.SPEDLEP
      ,co.grade_level AS test_grade_level
      ,enr.course_name AS nca_course_name
      ,enr.period AS nca_period
FROM results_wide w WITH(NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON w.studentid = cs.STUDENTID
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON w.student_number = co.student_number
 AND LEFT(w.year,4) = co.year
 AND co.rn = 1
LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
  ON w.studentid = enr.STUDENTID
 AND enr.rn = 1