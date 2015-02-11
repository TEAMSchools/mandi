USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_SGP AS 

WITH base AS (
  SELECT base.studentid
        ,base.schoolid
        ,co.school_name
        ,base.grade_level
        ,co.team
        ,co.SPEDLEP
        ,co.enroll_status
        ,base.year
        ,base.measurementscale      
        ,LEFT(base.termname, (CHARINDEX(' ', termname) - 1)) AS base_term
  FROM KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
  JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON base.studentid = co.studentid
   AND base.year = co.year
   AND co.rn = 1
 )

SELECT base.studentid        
      ,base.school_name
      ,base.grade_level
      ,base.team
      ,base.year
      ,base.enroll_status
      ,base.SPEDLEP
      ,'MY' AS growth_term
      ,base.measurementscale
      ,midyear.period_string
      ,midyear.true_growth_projection
      ,midyear.rit_change
      ,midyear.growth_percentile
      ,midyear.met_typical_growth_target
FROM base WITH(NOLOCK)
JOIN KIPP_NJ..MAP$growth_measures_long#static midyear WITH(NOLOCK)
  ON base.studentid = midyear.studentid
 AND base.measurementscale = midyear.measurementscale
 AND base.year = midyear.year
 AND base.base_term = midyear.start_term_string
 AND midyear.end_term_string = 'Winter'
  
UNION ALL

SELECT base.studentid        
      ,base.school_name
      ,base.grade_level
      ,base.team
      ,base.year
      ,base.enroll_status
      ,base.SPEDLEP
      ,'EOY' AS growth_term
      ,base.measurementscale        
      ,eoy.period_string
      ,eoy.true_growth_projection
      ,eoy.rit_change
      ,eoy.growth_percentile
      ,eoy.met_typical_growth_target
FROM base WITH(NOLOCK)
JOIN KIPP_NJ..MAP$growth_measures_long#static eoy WITH(NOLOCK)
  ON base.studentid = eoy.studentid
 AND base.measurementscale = eoy.measurementscale
 AND base.year = eoy.year
 AND base.base_term = eoy.start_term_string
 AND eoy.end_term_string = 'Spring'