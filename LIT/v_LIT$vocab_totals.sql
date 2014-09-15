USE KIPP_NJ
GO

ALTER VIEW LIT$vocab_totals AS

WITH valid_tests AS (
  SELECT DISTINCT a.repository_id        
  FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)    
  WHERE a.scope = 'Reporting' 
    AND a.subject = 'Vocabulary'
 )

,scores_long AS (
  SELECT res.student_id AS student_number             
        ,'Week_' + SUBSTRING(label, CHARINDEX('_',label) + 1, 2) AS listweek_num        
        ,CONVERT(FLOAT,value) AS value                
  FROM ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
  JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
    ON res.repository_id = f.repository_id
   AND res.field = f.name
   AND f.rn = 1
  WHERE res.repository_id IN (SELECT repository_id FROM valid_tests WITH(NOLOCK))
 )

,roster AS (
  SELECT schoolid
        ,grade_level
        ,STUDENT_NUMBER
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE co.rn = 1
    AND co.year = dbo.fn_Global_Academic_Year()
    AND co.grade_level < 5
 )

,week_totals AS (
  SELECT r.schoolid
        ,r.grade_level      
        ,r.STUDENT_NUMBER
        ,listweek_num        
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct_wk
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN scores_long res WITH(NOLOCK)
    ON r.STUDENT_NUMBER = res.student_number
  GROUP BY r.schoolid
          ,r.grade_level
          ,r.STUDENT_NUMBER
          ,res.listweek_num
 )
 
,year_totals AS (
  SELECT r.schoolid
        ,r.grade_level      
        ,r.STUDENT_NUMBER                
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct_yr        
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN scores_long res WITH(NOLOCK)
    ON r.STUDENT_NUMBER = res.student_number
  GROUP BY r.SCHOOLID
          ,r.GRADE_LEVEL
          ,r.STUDENT_NUMBER          
 )
 
SELECT wk.*      
      ,yr.pct_correct_yr      
      ,ROUND(AVG(yr.pct_correct_yr) OVER(PARTITION BY yr.grade_level),0) AS avg_pct_correct_yr
FROM week_totals wk WITH(NOLOCK)
JOIN year_totals yr WITH(NOLOCK)
  ON wk.student_number = yr.student_number