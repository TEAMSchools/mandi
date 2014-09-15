USE KIPP_NJ
GO

ALTER VIEW LIT$sight_word_totals AS

WITH valid_tests AS (
  SELECT DISTINCT a.repository_id        
  FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)    
  WHERE a.scope = 'Reporting' 
    AND a.subject = 'Word Work'
 )

,scores_long AS (
  SELECT res.student_id AS student_number             
        ,'Week_' + SUBSTRING(label, CHARINDEX('_',label) + 1, 2) AS listweek_num
        ,SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1)) AS word
        ,CONVERT(FLOAT,value) AS value        
        ,CASE WHEN value = 0 AND 
           ROW_NUMBER() OVER(
             PARTITION BY res.student_id, res.value
               ORDER BY SUBSTRING(label, CHARINDEX('_',label) + 1, 2)) <= 10 
           THEN SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1))
          ELSE NULL
         END AS missed_word 
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
        ,SUM(CONVERT(FLOAT,CASE WHEN value IS NOT NULL THEN 1 ELSE NULL END)) AS n_total
        ,SUM(CONVERT(FLOAT,value)) AS n_correct
        ,COUNT(CONVERT(FLOAT,value)) - SUM(CONVERT(FLOAT,value)) AS n_missed
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct
        ,dbo.GROUP_CONCAT_DS(missed_word, ', ', 1) AS missed_words
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
        ,SUM(CONVERT(FLOAT,CASE WHEN value IS NOT NULL THEN 1 ELSE NULL END)) AS n_total_yr
        ,SUM(CONVERT(FLOAT,value)) AS n_correct_yr
        ,COUNT(CONVERT(FLOAT,value)) - SUM(CONVERT(FLOAT,value)) AS n_missed_yr
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct_yr
        ,dbo.GROUP_CONCAT_DS(missed_word, ', ', 1) AS missed_words_yr
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN scores_long res WITH(NOLOCK)
    ON r.STUDENT_NUMBER = res.student_number
  GROUP BY r.SCHOOLID
          ,r.GRADE_LEVEL
          ,r.STUDENT_NUMBER          
 )
 
SELECT wk.*
      ,yr.n_total_yr
      ,yr.n_correct_yr
      ,yr.n_missed_yr
      ,yr.pct_correct_yr
      ,yr.missed_words_yr
      ,ROUND(AVG(yr.n_total_yr) OVER(PARTITION BY yr.grade_level),0) AS avg_total_yr
      ,ROUND(AVG(yr.n_correct_yr) OVER(PARTITION BY yr.grade_level),0) AS avg_correct_yr
      ,ROUND(AVG(yr.pct_correct_yr) OVER(PARTITION BY yr.grade_level),0) AS avg_pct_correct_yr
FROM week_totals wk WITH(NOLOCK)
JOIN year_totals yr WITH(NOLOCK)
  ON wk.student_number = yr.student_number