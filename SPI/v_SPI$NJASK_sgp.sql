USE SPI
GO

ALTER VIEW SPI$NJASK_sgp AS

WITH sgp_query AS (
  SELECT cohort.school_name AS school
        ,njask.year
        ,njask.grade
        ,njask.subject
        ,njask.growth_score AS sgp
  FROM KIPP_NJ..NJASK$sgp_detail njask WITH(NOLOCK)  
  JOIN KIPP_NJ..COHORT$identifiers_long#static cohort WITH(NOLOCK)
    ON njask.STUDENT_NUMBER = cohort.STUDENT_NUMBER   
   AND njask.year = cohort.year
   AND cohort.rn = 1  
 )
  
,medians AS (
  SELECT DISTINCT 
         school
        ,YEAR
        ,ISNULL(CONVERT(VARCHAR,grade),'campus') AS grade
        ,subject
        ,PERCENTILE_DISC(0.5) 
           WITHIN GROUP (ORDER BY sgp) 
             OVER (PARTITION BY year, school, grade, subject) AS [MEDIAN(SGP)]
  FROM sgp_query
  
  UNION ALL
  
  SELECT DISTINCT 
         school
        ,YEAR
        ,'campus' AS grade
        ,subject        
        ,PERCENTILE_DISC(0.5) 
           WITHIN GROUP (ORDER BY sgp) 
             OVER (PARTITION BY year, school, subject) AS [MEDIAN(SGP)]
  FROM sgp_query
 )

,aggregates AS (
  SELECT school
        ,YEAR
        ,ISNULL(CONVERT(VARCHAR,grade),'campus') AS grade
        ,subject      
        ,COUNT(*) AS N      
  FROM sgp_query
  GROUP BY school
          ,year             
          ,subject        
          ,CUBE(grade)
 )

SELECT agg.school
      ,agg.year
      ,agg.grade
      ,agg.subject
      ,med.[MEDIAN(SGP)]
      ,agg.n
      ,agg.school + '@' + CONVERT(VARCHAR,agg.YEAR) + '@' + agg.grade + '@' + agg.SUBJECT AS hash
FROM aggregates agg
LEFT OUTER JOIN medians med
  ON agg.school = med.school
 AND agg.YEAR = med.YEAR
 AND agg.SUBJECT = med.SUBJECT
 AND agg.grade = med.grade