USE KIPP_NJ
GO

ALTER VIEW STATE$partial_prof_running_total AS

WITH roster AS (
  SELECT year AS academic_year
        ,grade_level        
        ,STUDENT_NUMBER
        ,lastfirst
  FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE (co.grade_level BETWEEN 3 AND 8 OR co.grade_level IN (11,12))
    AND co.rn = 1
 )

,njask AS (
  SELECT student_number      
        ,academic_year      
        ,subject
        ,CASE WHEN is_prof = 1 THEN 0 ELSE 1 END AS is_below
  FROM KIPP_NJ..NJASK$detail WITH(NOLOCK)  
  WHERE subject IN ('ELA','Math')
  
  UNION ALL
  
  SELECT student_number      
        ,academic_year      
        ,subject
        ,CASE WHEN is_prof = 1 THEN 0 ELSE 1 END AS is_below
  FROM KIPP_NJ..HSPA$detail WITH(NOLOCK)
  WHERE subject IN ('ELA','Math')
 )

SELECT r.academic_year
      ,r.grade_level
      ,r.STUDENT_NUMBER      
      ,nj.subject
      ,nj.is_below
      ,SUM(ISNULL(is_below,0)) OVER(
         PARTITION BY r.student_number, nj.subject
           ORDER BY r.academic_year
           ROWS UNBOUNDED PRECEDING) AS running_total
FROM roster r
LEFT OUTER JOIN njask nj
  ON r.STUDENT_NUMBER = nj.STUDENT_NUMBER
 AND r.academic_year = nj.academic_year