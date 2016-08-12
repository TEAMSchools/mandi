USE KIPP_NJ
GO

ALTER VIEW COMPLIANCE$NJ_annual_report_MAP_results AS

SELECT academic_year
      ,region      
      ,measurementscale
      ,grade_level
      ,COUNT(studentid) AS N_valid
      ,AVG(start_npr) AS avg_start_pctile
      ,AVG(end_npr) AS avg_end_pctile
      ,SUM(score_increased) AS N_score_increased
FROM
    (
    SELECT studentid
          ,CASE WHEN schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END AS region
          ,grade_level      
          ,year AS academic_year
          ,measurementscale
          ,start_npr
          ,end_npr
          ,CASE WHEN end_rit > start_rit THEN 1 ELSE 0 END AS score_increased
    FROM KIPP_NJ..MAP$growth_measures_long#static grow WITH(NOLOCK)      
    WHERE ((year_in_network = 1 AND period_string = 'Fall to Spring')
            OR 
           (year_in_network > 1 AND period_string = 'Spring to Spring'))
      AND valid_observation = 1
   ) sub
GROUP BY academic_year
        ,region
        ,measurementscale
        ,grade_level
        