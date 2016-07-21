USE SPI
GO

ALTER VIEW SPI$MAP_sgp AS

WITH roster AS (
  SELECT base.studentid
        ,base.year
        ,base.measurementscale
        ,REPLACE(co.school_name,'Revolution','Rev') AS school
        ,co.grade_level                
        ,LEFT(base.termname, (CHARINDEX(' ', termname) - 1)) AS base_term
  FROM KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
  JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
    ON base.studentid = co.studentid
   AND base.year = co.year
   AND co.rn = 1
   AND co.grade_level < 10
   AND co.schoolid != 999999   
   -- if it's the current year, only currently enrolled students
   AND ((co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status = 0) OR (co.year < KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status IS NOT NULL))
  WHERE base.year >= 2009    
    AND base.termname IS NOT NULL -- exclude students w/o baseline
 )

,scores_long AS (
  SELECT base.studentid        
        ,base.school
        ,base.grade_level      
        ,base.year            
        ,base.measurementscale
        -- for the current year, if spring is null, then use winter
        -- are starting terms are from each student's best baseline
        ,CASE 
          WHEN base.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND eoy.growth_percentile IS NULL THEN midyear.period_string 
          ELSE eoy.period_string
         END AS period
        ,CASE
          WHEN base.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND eoy.growth_percentile IS NULL THEN midyear.true_growth_projection
          ELSE eoy.true_growth_projection
         END AS growth_projection
        ,CASE
          WHEN base.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND eoy.growth_percentile IS NULL THEN midyear.rit_change
          ELSE eoy.rit_change
         END AS rit_change
        ,CASE
          WHEN base.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN COALESCE(eoy.growth_percentile, midyear.growth_percentile)
          ELSE eoy.growth_percentile
         END AS sgp      
        ,CASE
          WHEN base.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND eoy.growth_percentile IS NULL THEN midyear.met_typical_growth_target
          ELSE eoy.met_typical_growth_target
         END AS met_typ      
  FROM roster base WITH(NOLOCK)
  JOIN KIPP_NJ..MAP$growth_measures_long#static midyear WITH(NOLOCK)
    ON base.studentid = midyear.studentid
   AND base.measurementscale = midyear.measurementscale
   AND base.year = midyear.year
   AND base.base_term = midyear.start_term_string
   AND midyear.end_term_string = 'Winter'
  JOIN KIPP_NJ..MAP$growth_measures_long#static eoy WITH(NOLOCK)
    ON base.studentid = eoy.studentid
   AND base.measurementscale = eoy.measurementscale
   AND base.year = eoy.year
   AND base.base_term = eoy.start_term_string
   AND eoy.end_term_string = 'Spring'
 )

,averages AS (
  SELECT school
        ,ISNULL(CONVERT(VARCHAR,grade_level),'campus') AS grade_level
        ,year
        ,ISNULL(measurementscale,'All Subjects') AS measurementscale
        ,ROUND(AVG(CONVERT(FLOAT,growth_projection)),2) AS avg_growth_projection
        ,ROUND(AVG(CONVERT(FLOAT,rit_change)),2) AS avg_rit_change
        ,ROUND(AVG(CONVERT(FLOAT,sgp)),2) AS avg_sgp                  
        ,ROUND(AVG(CONVERT(FLOAT,met_typ)) * 100, 1) AS avg_typ_growth
        ,school + '@' + ISNULL(CONVERT(VARCHAR,grade_level),'campus') + '@' + CONVERT(VARCHAR,year) + '@' + ISNULL(measurementscale,'All Subjects') AS hash
  FROM scores_long WITH(NOLOCK)
  GROUP BY school
          ,year        
          ,CUBE(grade_level, measurementscale)
 )

,medians AS (
  SELECT DISTINCT school + '@' + 'campus' + '@' + CONVERT(VARCHAR,year) + '@' + ISNULL(measurementscale,'All Subjects') AS hash --only used at campus level currently
        ,PERCENTILE_DISC(0.5) 
           WITHIN GROUP (ORDER BY growth_projection) 
             OVER (PARTITION BY year, school, measurementscale) AS med_growth_projection
        ,PERCENTILE_DISC(0.5) 
           WITHIN GROUP (ORDER BY rit_change) 
             OVER (PARTITION BY year, school, measurementscale) AS med_rit_change
        ,PERCENTILE_DISC(0.5) 
           WITHIN GROUP (ORDER BY sgp) 
             OVER (PARTITION BY year, school, measurementscale) AS med_sgp
  FROM scores_long WITH(NOLOCK)
  WHERE sgp IS NOT NULL
 )

SELECT averages.school
      ,averages.grade_level
      ,averages.year
      ,averages.measurementscale
      ,averages.avg_growth_projection
      ,averages.avg_rit_change
      ,averages.avg_sgp
      ,medians.med_growth_projection
      ,medians.med_rit_change
      ,medians.med_sgp
      ,averages.avg_typ_growth
      ,averages.hash
FROM averages
LEFT OUTER JOIN medians
  ON averages.hash = medians.hash
WHERE averages.avg_rit_change IS NOT NULL