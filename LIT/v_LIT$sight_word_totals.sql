USE KIPP_NJ
GO

ALTER VIEW LIT$sight_word_totals AS

WITH stu_test_roster AS (
  SELECT DISTINCT
         res.repository_id
        ,res.student_id AS ill_stu_id        
        ,id.student_number
        ,co.SCHOOLID
        ,co.GRADE_LEVEL
  FROM ILLUMINATE$summary_assessment_results_long#static res
  JOIN ILLUMINATE$student_id_key id
    ON res.student_id = id.ill_stu_id
  JOIN COHORT$comprehensive_long#static co
    ON id.studentid = co.STUDENTID
   AND co.RN = 1
  WHERE res.repository_id IN (SELECT repository_id FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK) WHERE a.scope = 'Reporting' AND a.subject = 'Word Work')
 )

,week_totals AS (
  SELECT SCHOOLID
        ,GRADE_LEVEL      
        ,student_number
        ,listweek_num
        ,COUNT(CONVERT(FLOAT,value)) AS n_total
        ,SUM(CONVERT(FLOAT,value)) AS n_correct
        ,COUNT(CONVERT(FLOAT,value)) - SUM(CONVERT(FLOAT,value)) AS n_missed
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct
        ,dbo.GROUP_CONCAT_DS(missed_word, ', ', 1) AS missed_words
  FROM
      (
       SELECT r.SCHOOLID
             ,r.GRADE_LEVEL
             ,r.student_number
             ,a.scope
             ,a.subject
             ,'Week_' + SUBSTRING(label, CHARINDEX('_',label) + 1, 2) AS listweek_num
             ,SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1)) AS word
             ,res.value
             ,CASE 
               WHEN value = 0 THEN SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1)) 
               ELSE NULL 
              END AS missed_word
       FROM ILLUMINATE$summary_assessments#static a
       JOIN stu_test_roster r
         ON a.repository_id = r.repository_id
        AND a.SCHOOLID = r.SCHOOLID
        AND a.GRADE_LEVEL = r.GRADE_LEVEL
       JOIN ILLUMINATE$summary_assessment_results_long#static res
         ON a.repository_id = res.repository_id
        AND r.ill_stu_id = res.student_id
       JOIN ILLUMINATE$repository_fields f
         ON a.repository_id = f.repository_id
        AND res.field = f.name
        AND f.rn = 1
      WHERE a.scope = 'Reporting'
        AND a.subject = 'Word Work'
      ) sub 
  GROUP BY SCHOOLID
          ,GRADE_LEVEL
          ,student_number
          ,listweek_num
 )
 
,year_totals AS (
  SELECT SCHOOLID
        ,GRADE_LEVEL      
        ,student_number        
        ,COUNT(CONVERT(FLOAT,value)) AS n_total_yr
        ,SUM(CONVERT(FLOAT,value)) AS n_correct_yr
        ,COUNT(CONVERT(FLOAT,value)) - SUM(CONVERT(FLOAT,value)) AS n_missed_yr
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct_yr
        ,dbo.GROUP_CONCAT_DS(missed_word, ', ', 1) AS missed_words_yr
  FROM
      (
       SELECT r.SCHOOLID
             ,r.GRADE_LEVEL
             ,r.student_number
             ,a.scope
             ,a.subject             
             ,SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1)) AS word
             ,res.value
             ,CASE 
               WHEN value = 0 THEN SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1)) 
               ELSE NULL 
              END AS missed_word
       FROM ILLUMINATE$summary_assessments#static a
       JOIN stu_test_roster r
         ON a.repository_id = r.repository_id
        AND a.SCHOOLID = r.SCHOOLID
        AND a.GRADE_LEVEL = r.GRADE_LEVEL
       JOIN ILLUMINATE$summary_assessment_results_long#static res
         ON a.repository_id = res.repository_id
        AND r.ill_stu_id = res.student_id
       JOIN ILLUMINATE$repository_fields f
         ON a.repository_id = f.repository_id
        AND res.field = f.name
        AND f.rn = 1
      WHERE a.scope = 'Reporting'
        AND a.subject = 'Word Work'
      ) sub 
  GROUP BY SCHOOLID
          ,GRADE_LEVEL
          ,student_number          
 )
 
SELECT wk.*
      ,yr.n_total_yr
      ,yr.n_correct_yr
      ,yr.n_missed_yr
      ,yr.pct_correct_yr
      ,yr.missed_words_yr    
FROM week_totals wk
JOIN year_totals yr
  ON wk.student_number = yr.student_number