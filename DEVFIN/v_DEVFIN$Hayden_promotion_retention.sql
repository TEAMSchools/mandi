USE KIPP_NJ
GO

ALTER VIEW DEVFIN$Hayden_promotion_retention AS

WITH roster AS (
  SELECT co.studentid      
        ,co.year AS academic_year
        ,co.grade_level
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE co.schoolid != 999999    
    AND co.entrydate <= CONVERT(DATE,CONVERT(VARCHAR,co.year) + '-10-15')
    AND co.exitdate >= CONVERT(DATE,CONVERT(VARCHAR,co.year) + '-10-15')
 )

SELECT academic_year
      ,grade_level
      ,COUNT(studentid) AS enrollment
      ,SUM(promoted) AS promoted
      ,SUM(retained) AS retained
      ,SUM(new) AS new
FROM
    (
     SELECT r1.studentid
           ,r1.academic_year
           ,r1.grade_level
           ,r_prev.grade_level AS prev_grade_level
           ,CASE WHEN r_prev.grade_level < r1.grade_level THEN 1 ELSE 0 END AS promoted
           ,CASE WHEN r_prev.grade_level >= r1.grade_level THEN 1 ELSE 0 END AS retained
           ,CASE WHEN r_prev.grade_level IS NULL THEN 1 ELSE 0 END AS new
     FROM roster r1 WITH(NOLOCK)
     LEFT OUTER JOIN roster r_prev WITH(NOLOCK)
       ON r1.studentid = r_prev.studentid
      AND r1.academic_year = (r_prev.academic_year + 1)
    ) sub
GROUP BY academic_year
        ,grade_level