USE SPI
GO

ALTER VIEW SPI$MAP_sgp AS

WITH roster AS (
  SELECT co.studentid
        ,co.school_name AS school
        ,co.grade_level
        ,co.year
        ,co.year_in_network                
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
  WHERE co.rn = 1
    AND co.year >= 2009
    AND co.grade_level < 10
    AND co.schoolid != 999999
 ) 
 
,scales AS (
  SELECT 'Mathematics' AS measurementscale
  UNION ALL
  SELECT 'Reading'
  UNION ALL
  SELECT 'Language Usage'
  UNION ALL 
  SELECT 'General Science'
 )

,sgp_s2s AS (
  SELECT sgp_s2s.studentid
        ,sgp_s2s.year
        ,sgp_s2s.measurementscale
        ,sgp_s2s.period_string AS s2s_period
        ,sgp_s2s.true_growth_projection AS s2s_growth_projection
        ,sgp_s2s.rit_change AS s2s_change
        ,sgp_s2s.growth_percentile AS s2s_sgp
        ,sgp_s2s.met_typical_growth_target AS s2s_met_typ      
  FROM KIPP_NJ..MAP$growth_measures_long#static sgp_s2s WITH(NOLOCK)
  WHERE sgp_s2s.period_string = 'Spring to Spring'
 )

,sgp_f2s AS (
  SELECT sgp_f2s.studentid
        ,sgp_f2s.year
        ,sgp_f2s.measurementscale
        ,sgp_f2s.period_string AS f2s_period
        ,sgp_f2s.true_growth_projection AS f2s_growth_projection
        ,sgp_f2s.rit_change AS f2s_change
        ,sgp_f2s.growth_percentile AS f2s_sgp
        ,sgp_f2s.met_typical_growth_target AS f2s_met_typ
  FROM KIPP_NJ..MAP$growth_measures_long#static sgp_f2s WITH(NOLOCK)  
  WHERE sgp_f2s.period_string = 'Fall to Spring'
 )

,scores_long AS (
  SELECT r.studentid
        ,r.school
        ,r.grade_level
        ,r.year
        ,scales.measurementscale
        ,CASE WHEN year_in_network = 1 OR (f2s_sgp > 0 AND s2s_sgp IS NULL) THEN f2s_period ELSE s2s_period END AS period
        ,CASE WHEN year_in_network = 1 OR (f2s_sgp > 0 AND s2s_sgp IS NULL) THEN f2s_growth_projection ELSE s2s_growth_projection END AS growth_projection
        ,CASE WHEN year_in_network = 1 OR (f2s_sgp > 0 AND s2s_sgp IS NULL) THEN f2s_change ELSE s2s_change END AS rit_change
        ,CASE WHEN year_in_network = 1 OR (f2s_sgp > 0 AND s2s_sgp IS NULL) THEN f2s_sgp ELSE s2s_sgp END AS sgp
        ,CASE WHEN year_in_network = 1 OR (f2s_sgp > 0 AND s2s_sgp IS NULL) THEN f2s_met_typ ELSE s2s_met_typ END AS met_typ 
  FROM roster r WITH(NOLOCK)
  JOIN scales WITH(NOLOCK)
    ON 1 = 1
  LEFT OUTER JOIN sgp_s2s WITH(NOLOCK)
    ON r.studentid = sgp_s2s.studentid
   AND r.year = sgp_s2s.year
   AND scales.measurementscale = sgp_s2s.measurementscale
  LEFT OUTER JOIN sgp_f2s WITH(NOLOCK)
    ON r.studentid = sgp_f2s.studentid
   AND r.year = sgp_f2s.year
   AND scales.measurementscale = sgp_f2s.measurementscale
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