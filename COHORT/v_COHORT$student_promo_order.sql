USE KIPP_NJ
GO

ALTER VIEW COHORT$student_promo_order AS

SELECT year 
      ,year - 1 AS past_year
      ,year + 1 AS future_year
      ,student_number      
      ,grade_level
FROM KIPP_NJ..COHORT$comprehensive_long#static WITH(NOLOCK)
WHERE rn = 1