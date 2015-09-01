USE KIPP_NJ
GO

ALTER VIEW LIT$spelling_totals AS

WITH valid_tests AS (
  SELECT a.repository_id        
  FROM ILLUMINATE$repositories#static a WITH(NOLOCK)    
  WHERE a.scope = 'Reporting' 
    AND a.subject_area = 'Spelling'
 )

,scores_long AS (
  SELECT res.student_id AS student_number             
        ,'Week_' + SUBSTRING(f.label, CHARINDEX('_',f.label) + 1, 2) AS listweek_num        
        ,res.value AS value                
  FROM ILLUMINATE$repository_data res WITH(NOLOCK)
  JOIN ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON res.repository_id = f.repository_id
   AND res.field = f.name   
  WHERE res.repository_id IN (SELECT repository_id FROM valid_tests WITH(NOLOCK))
 )

,roster AS (
  SELECT co.schoolid
        ,co.year AS academic_year
        ,co.grade_level
        ,STUDENT_NUMBER
        ,dt.time_per_name
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN REPORTING$dates dt WITH(NOLOCK)
    ON co.schoolid = dt.schoolid 
   AND co.year = dt.academic_year
   AND dt.start_date <= CONVERT(DATE,GETDATE())
   AND dt.identifier = 'REP'   
  WHERE co.rn = 1    
    AND co.grade_level < 5
 )

,week_totals AS (
  SELECT r.schoolid
        ,r.academic_year
        ,r.grade_level      
        ,r.STUDENT_NUMBER
        ,r.time_per_name AS listweek_num        
        ,CONVERT(FLOAT,res.value) AS pct_correct_wk
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN scores_long res WITH(NOLOCK)
    ON r.STUDENT_NUMBER = res.student_number
   AND r.time_per_name = res.listweek_num
 )
 
,year_totals AS (
  SELECT r.schoolid
        ,r.academic_year
        ,r.grade_level      
        ,r.STUDENT_NUMBER                
        ,AVG(CONVERT(FLOAT,res.value)) AS pct_correct_yr        
  FROM roster r WITH(NOLOCK)
  LEFT OUTER JOIN scores_long res WITH(NOLOCK)
    ON r.STUDENT_NUMBER = res.student_number
   AND r.time_per_name = res.listweek_num
  GROUP BY r.SCHOOLID
          ,r.GRADE_LEVEL
          ,r.STUDENT_NUMBER          
          ,r.academic_year
 )
 
SELECT wk.schoolid
      ,wk.academic_year
      ,wk.grade_level
      ,wk.STUDENT_NUMBER
      ,wk.listweek_num
      ,wk.pct_correct_wk
      ,yr.pct_correct_yr      
      ,ROUND(AVG(yr.pct_correct_yr) OVER(PARTITION BY yr.schoolid, yr.grade_level),0) AS avg_pct_correct_yr
FROM week_totals wk WITH(NOLOCK)
JOIN year_totals yr WITH(NOLOCK)
  ON wk.student_number = yr.student_number
 AND wk.academic_year = yr.academic_year