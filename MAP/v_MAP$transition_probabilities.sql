USE KIPP_NJ
GO

CREATE VIEW MAP$transition_probabilities AS
WITH map_cte AS
    (SELECT g.studentid
           ,g.year
           ,g.cohort
           ,g.grade_level
           ,g.period_string
           ,g.measurementscale
           ,g.start_rit
           ,ROUND(g.start_rit/5, 0) * 5 AS rounded_start
           ,g.end_rit
           ,ROUND(g.end_rit/5, 0) * 5 AS rounded_end
     FROM KIPP_NJ..MAP$growth_measures_long#static g
     WHERE g.valid_observation = 1
       AND g.period_string IN ('Fall to Spring', 'Spring to Spring')
     )

SELECT sub.*
      ,start_denom.start_n AS group_denom
      ,CAST(ROUND((sub.end_n + 0.0) / start_denom.start_n, 3) AS float) AS pct
FROM
       --first get counts of end rit, given starting rit
      (SELECT TOP 10000000
              map_cte.grade_level
             ,map_cte.measurementscale
             ,map_cte.period_string
             ,map_cte.rounded_start
             ,map_cte.rounded_end
             ,COUNT(*) AS end_n
       FROM map_cte
       GROUP BY map_cte.grade_level
               ,map_cte.measurementscale
               ,map_cte.period_string
               ,map_cte.rounded_start
               ,map_cte.rounded_end
       ORDER BY map_cte.grade_level
               ,map_cte.measurementscale
               ,map_cte.period_string
               ,map_cte.rounded_start
               ,map_cte.rounded_end
       ) sub
--fetch denominators separately 
JOIN 
  (SELECT map_cte.grade_level
         ,map_cte.measurementscale
         ,map_cte.period_string
         ,map_cte.rounded_start
         ,COUNT(*) AS start_n
   FROM map_cte
   GROUP BY map_cte.grade_level
           ,map_cte.measurementscale
           ,map_cte.period_string
           ,map_cte.rounded_start
  ) start_denom
ON sub.grade_level = start_denom.grade_level
AND sub.measurementscale = start_denom.measurementscale
AND sub.period_string = start_denom.period_string
AND sub.rounded_start = start_denom.rounded_start