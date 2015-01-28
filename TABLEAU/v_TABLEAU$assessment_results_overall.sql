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

--,enrollments AS (
--  SELECT cc.STUDENTID        
--        ,cc.academic_year
--        ,cou.CREDITTYPE        
--        ,cou.COURSE_NAME                
--        ,CASE        
--          WHEN cc.SCHOOLID != 73253 THEN cc.section_number
--          WHEN cc.schoolid = 73253 THEN cc.period
--         END AS section
--        ,ROW_NUMBER() OVER(
--           PARTITION BY cc.studentid, cou.credittype, cc.academic_year
--             ORDER BY cc.termid DESC, cc.dateenrolled DESC) AS rn
--  FROM CC WITH(NOLOCK)
--  JOIN COURSES cou WITH(NOLOCK)
--    ON cc.COURSE_NUMBER = cou.COURSE_NUMBER
--   AND cou.CREDITTYPE IS NOT NULL
--   AND cou.CREDITTYPE NOT IN ('LOG', 'PHYSED', 'STUDY')   
--  WHERE cc.termid >= 2300 -- first year w/ Illuminate, OK to be hard-coded
--    AND cc.SCHOOLID IN (73252,73253,133570965)
-- )

,groups AS (
  SELECT DISTINCT 
         student_number
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
      ,enr.section
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
 AND co.rn = 1
--LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
--  ON co.studentid = enr.studentid
-- AND co.year = enr.academic_year
-- AND a.credittype = enr.credittype
-- AND enr.rn = 1
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr WITH(NOLOCK)
  ON co.studentid = enr.studentid
 AND co.year = enr.academic_year
 AND a.credittype = enr.credittype 
 AND enr.academic_year >= 2013 -- first year w/ Illuminate, so we can hard code this 
LEFT OUTER JOIN groups WITH(NOLOCK)
  ON co.STUDENT_NUMBER = groups.student_number
 AND co.year = groups.academic_year