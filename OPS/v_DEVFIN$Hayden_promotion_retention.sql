USE KIPP_NJ
GO

ALTER VIEW DEVFIN$Hayden_promotion_retention AS

WITH roster AS (
  SELECT co.studentid      
        ,co.year AS academic_year
        ,co.reporting_schoolid AS schoolid
        ,co.grade_level
        ,co.GENDER
        ,co.ETHNICITY
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)
  WHERE (CONVERT(DATE,CONVERT(VARCHAR,co.year) + '-10-15') BETWEEN co.entrydate AND co.exitdate) OR co.schoolid = 999999
 )

SELECT r1.studentid
      ,r1.academic_year
      ,r1.schoolid
      ,r1.grade_level
      ,r1.GENDER
      ,r1.ETHNICITY
      ,r_next.grade_level AS next_grade_level
      ,r_prev.grade_level AS prev_grade_level
      ,CASE         
        WHEN r_next.grade_level IS NULL THEN 'transferred'        
        WHEN r1.grade_level < r_next.grade_level THEN 'promoted'
        WHEN r1.grade_level >= r_next.grade_level THEN 'retained'
       END AS promo_status      
FROM roster r1 WITH(NOLOCK)
LEFT OUTER JOIN roster r_next WITH(NOLOCK)
  ON r1.studentid = r_next.studentid
 AND r1.academic_year = (r_next.academic_year - 1)
LEFT OUTER JOIN roster r_prev WITH(NOLOCK)
  ON r1.studentid = r_prev.studentid
 AND r1.academic_year = (r_prev.academic_year + 1)
WHERE r1.schoolid != 999999
  AND r1.academic_year < KIPP_NJ.dbo.fn_Global_Academic_Year()