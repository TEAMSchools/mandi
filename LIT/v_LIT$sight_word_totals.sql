USE KIPP_NJ
GO

ALTER VIEW LIT$sight_word_totals AS

WITH valid_tests AS (
  SELECT a.repository_id                
  FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)    
  WHERE a.scope = 'Reporting' 
    AND a.subject_area = 'Word Work'
    AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,scores_long AS (
  SELECT res.student_id AS student_number             
        ,'Week_' + SUBSTRING(label, CHARINDEX('_',label) + 1, 2) AS listweek_num
        ,SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1)) AS word
        ,CASE WHEN CONVERT(FLOAT,value) = 9 THEN NULL ELSE CONVERT(FLOAT,value) END AS value                
        ,CASE WHEN CONVERT(FLOAT,value) IN (0,9) AND 
           ROW_NUMBER() OVER(
             PARTITION BY res.student_id, res.value
               ORDER BY SUBSTRING(label, CHARINDEX('_',label) + 1, 2)) <= 10 
           THEN SUBSTRING(label, CHARINDEX('_',label,CHARINDEX('_',label) + 1) + 1, LEN(label) - CHARINDEX('_',label,CHARINDEX('_',label) + 1))
          ELSE NULL
         END AS missed_word 
  FROM KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$repository_fields#static f WITH(NOLOCK)
    ON res.repository_id = f.repository_id
   AND res.field = f.name
  WHERE res.repository_id IN (SELECT repository_id FROM valid_tests WITH(NOLOCK))
 )
 
,roster AS (
  SELECT co.schoolid
        ,co.year AS academic_year
        ,grade_level
        ,STUDENT_NUMBER
        ,dt.time_per_name
  FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON co.schoolid = dt.schoolid   
   AND co.year = dt.academic_year 
   AND dt.start_date <= CONVERT(DATE,GETDATE())
   AND dt.identifier = 'REP'
  WHERE co.rn = 1
    AND co.grade_level <= 4
    AND co.schoolid != 73252
 )

,week_totals AS (
  SELECT r.schoolid
        ,r.academic_year
        ,r.grade_level      
        ,r.STUDENT_NUMBER
        ,r.time_per_name AS listweek_num
        ,COUNT(CONVERT(FLOAT,value)) AS n_total
        ,SUM(CONVERT(FLOAT,value)) AS n_correct
        ,COUNT(CONVERT(FLOAT,value)) - SUM(CONVERT(FLOAT,value)) AS n_missed
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(missed_word, ', ') AS missed_words
  FROM roster r WITH(NOLOCK)
  JOIN scores_long res WITH(NOLOCK)
    ON r.STUDENT_NUMBER = res.student_number
   AND r.time_per_name = res.listweek_num
  GROUP BY r.schoolid
          ,r.grade_level
          ,r.STUDENT_NUMBER
          ,r.time_per_name
          ,r.academic_year
 )
 
,year_totals AS (
  SELECT r.schoolid
        ,r.academic_year
        ,r.grade_level      
        ,r.STUDENT_NUMBER                
        ,COUNT(CONVERT(FLOAT,value)) AS n_total_yr
        ,SUM(CONVERT(FLOAT,value)) AS n_correct_yr
        ,COUNT(CONVERT(FLOAT,value)) - SUM(CONVERT(FLOAT,value)) AS n_missed_yr
        ,ROUND(SUM(CONVERT(FLOAT,value)) / COUNT(CONVERT(FLOAT,value)) * 100,0) AS pct_correct_yr
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(missed_word, ', ') AS missed_words_yr
  FROM roster r WITH(NOLOCK)
  JOIN scores_long res WITH(NOLOCK)
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
      ,wk.n_total
      ,wk.n_correct
      ,wk.n_missed
      ,wk.pct_correct
      ,wk.missed_words
      ,yr.n_total_yr
      ,yr.n_correct_yr
      ,yr.n_missed_yr
      ,yr.pct_correct_yr
      ,yr.missed_words_yr
      ,ROUND(AVG(yr.n_total_yr) OVER(PARTITION BY yr.schoolid, yr.grade_level),0) AS avg_total_yr
      ,ROUND(AVG(yr.n_correct_yr) OVER(PARTITION BY yr.schoolid, yr.grade_level),0) AS avg_correct_yr
      ,ROUND(
        ROUND(AVG(CONVERT(FLOAT,yr.n_correct_yr)) OVER(PARTITION BY yr.schoolid, yr.grade_level),0)
         /
        ROUND(AVG(CONVERT(FLOAT,yr.n_total_yr)) OVER(PARTITION BY yr.schoolid, yr.grade_level),0)
         * 100, 0) AS avg_pct_correct_yr
FROM week_totals wk WITH(NOLOCK)
JOIN year_totals yr WITH(NOLOCK)
  ON wk.student_number = yr.student_number
 AND wk.academic_year = yr.academic_year
 AND yr.n_total_yr > 0