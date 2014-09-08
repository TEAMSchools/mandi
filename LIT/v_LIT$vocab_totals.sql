USE KIPP_NJ
GO

ALTER VIEW LIT$vocab_totals AS

WITH stu_test_roster AS (
  SELECT DISTINCT
         res.repository_id
        ,res.student_id AS ill_stu_id        
        ,id.student_number
        ,co.SCHOOLID
        ,co.GRADE_LEVEL
  FROM ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
  JOIN ILLUMINATE$student_id_key id WITH(NOLOCK)
    ON res.student_id = id.ill_stu_id
  JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
    ON id.studentid = co.STUDENTID
   AND co.RN = 1
  WHERE res.repository_id IN (SELECT repository_id FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK) WHERE a.scope = 'Reporting' AND a.subject = 'Vocabulary')
 )

,week_totals AS (
  SELECT r.SCHOOLID
        ,r.GRADE_LEVEL
        ,r.student_number
        ,a.scope
        ,a.subject
        ,LEFT(f.label,7) AS listweek_num
        ,res.value AS pct_correct_wk
  FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)
  JOIN stu_test_roster r WITH(NOLOCK)
    ON a.repository_id = r.repository_id      
   AND a.SCHOOLID = r.SCHOOLID
   AND a.GRADE_LEVEL = r.GRADE_LEVEL
  JOIN ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
    ON a.repository_id = res.repository_id
   AND r.ill_stu_id = res.student_id
  JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
    ON a.repository_id = f.repository_id
   AND res.field = f.name
   AND f.rn = 1  
  WHERE a.scope = 'Reporting'
    AND a.subject = 'Vocabulary'
 )
 
,year_totals AS (
  SELECT SCHOOLID
        ,GRADE_LEVEL      
        ,student_number        
        ,ROUND(AVG(pct_correct_wk),0) AS pct_correct_yr        
  FROM
      (
       SELECT r.SCHOOLID
             ,r.GRADE_LEVEL
             ,r.student_number
             ,a.scope
             ,a.subject             
             ,CONVERT(FLOAT,res.value) AS pct_correct_wk
       FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)
       JOIN stu_test_roster r WITH(NOLOCK)
         ON a.repository_id = r.repository_id     
        AND a.SCHOOLID = r.SCHOOLID
        AND a.GRADE_LEVEL = r.GRADE_LEVEL   
       JOIN ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
         ON a.repository_id = res.repository_id
        AND r.ill_stu_id = res.student_id
       JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
         ON a.repository_id = f.repository_id
        AND res.field = f.name
        AND f.rn = 1
       WHERE a.scope = 'Reporting'
         AND a.subject = 'Vocabulary'
      ) sub 
  GROUP BY SCHOOLID
          ,GRADE_LEVEL
          ,student_number          
 )
 
SELECT wk.*      
      ,yr.pct_correct_yr      
FROM week_totals wk WITH(NOLOCK)
JOIN year_totals yr WITH(NOLOCK)
  ON wk.student_number = yr.student_number