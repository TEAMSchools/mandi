USE KIPP_NJ
GO

ALTER VIEW MAP$norm_table#act_ES_extensions AS

WITH base_norms AS (
  SELECT n_hi.*
        ,ROW_NUMBER() OVER(
           PARTITION BY measurementscale, fallwinterspring, grade, percentile
               ORDER BY RIT ASC) AS rn
  FROM KIPP_NJ..MAP$norm_table_extended#2011#dense n_hi WITH (NOLOCK)
  WHERE n_hi.percentile > 50
    AND (fallwinterspring = 'Spring' OR (fallwinterspring = 'Fall' AND grade = 0))
    AND n_hi.measurementscale IN ('Reading', 'Mathematics')
    AND grade < 3
  
  UNION ALL
  
  SELECT n_lo.*
        ,ROW_NUMBER() OVER
          (PARTITION BY measurementscale
                       ,fallwinterspring
                       ,grade
                       ,percentile
           ORDER BY RIT DESC) AS rn
  FROM KIPP_NJ..MAP$norm_table_extended#2011#dense n_lo WITH (NOLOCK)
  WHERE n_lo.percentile <= 50
    AND (fallwinterspring = 'Spring' OR (fallwinterspring = 'Fall' AND grade = 0))
    AND n_lo.measurementscale IN ('Reading', 'Mathematics')
    AND grade < 3
 )

SELECT 'Model' as school
      ,0 as cohort
      ,CASE
         WHEN fallwinterspring = 'Spring' THEN grade
         WHEN fallwinterspring = 'Winter' THEN grade - 0.5
         WHEN fallwinterspring = 'Fall'   THEN grade - 0.8
       END AS grade
      ,RIT as rit
      ,act_band AS act
      ,measurementscale AS subject
FROM
    (
     SELECT sub.measurementscale
           ,sub.fallwinterspring
           ,sub.grade
           ,sub.percentile
           ,sub.RIT
           ,CASE
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 2 AND act_band IS NULL THEN 13
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 4 THEN 14
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 8 THEN 15
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 12 THEN 16
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 18 THEN 17
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 24 THEN 18
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 35 THEN 19
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 44 THEN 20
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 53 THEN 21
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 62 THEN 22
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 73 THEN 23
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 80 THEN 24
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 86 THEN 25
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 90 THEN 26
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 94 THEN 27
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 96 THEN 28
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 97 THEN 29
              WHEN sub.measurementscale = 'Mathematics' AND sub.percentile = 98 AND act_band IS NULL THEN 30
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 2 AND act_band IS NULL THEN 8
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 4 THEN 9
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 5 THEN 10
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 8 THEN 11
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 10 THEN 12
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 15 THEN 13
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 18 THEN 14
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 22 THEN 15
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 28 THEN 16
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 33 THEN 17
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 41 THEN 18
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 47 THEN 19
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 52 THEN 20
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 60 THEN 21
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 66 THEN 22
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 73 THEN 23
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 77 THEN 24
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 81 THEN 25
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 86 THEN 26
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 89 THEN 27
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 92 THEN 28
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 94 THEN 29
              WHEN sub.measurementscale = 'Reading' AND sub.percentile = 95 AND act_band IS NULL THEN 30
              ELSE act_band
            END AS act_band
     FROM
         (
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT
                ,NULL AS act_band 
          FROM base_norms base
          WHERE rn = 1
          
          UNION
          
          --all stuff below ACT 13 (2nd percentile)
          --since we CANT follow the percentile line, we need to approximate
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 3 AS rit
                ,12 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 6 AS rit
                ,11 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 10 AS rit
                ,10 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 13 AS rit
                ,9 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 16 AS rit
                ,8 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 20 AS rit
                ,7 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 23 AS rit
                ,6 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 26 AS rit
                ,5 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 29 AS rit
                ,4 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 32 AS rit
                ,3 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 36 AS rit
                ,2 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 39 AS rit
                ,1 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          --reading below act 8 (2nd percentile)
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 3 AS rit
                ,7 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 5 AS rit
                ,6 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 8 AS rit
                ,5 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 10 AS rit
                ,4 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 12 AS rit
                ,3 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 15 AS rit
                ,2 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT - 17 AS rit
                ,1 AS act_band
          FROM base_norms 
          WHERE percentile = 2
            AND rn = 1
            AND measurementscale = 'Reading'
          
          --stuff ABOVE ACT 30 math (98th percentile)
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 4 AS rit
                ,31 AS act_band
          FROM base_norms 
          WHERE percentile = 98
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 7 AS rit
                ,32 AS act_band
          FROM base_norms 
          WHERE percentile = 98
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 10 AS rit
                ,33 AS act_band
          FROM base_norms 
          WHERE percentile = 98
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 13 AS rit
                ,34 AS act_band
          FROM base_norms 
          WHERE percentile = 98
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 17 AS rit
                ,35 AS act_band
          FROM base_norms 
          WHERE percentile = 98
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 20 AS rit
                ,36 AS act_band
          FROM base_norms 
          WHERE percentile = 98
            AND rn = 1
            AND measurementscale = 'Mathematics'
          
          --stuff above ACT 30 reading (95th percentile)
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 3 AS rit
                ,31 AS act_band
          FROM base_norms 
          WHERE percentile = 95
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 5 AS rit
                ,32 AS act_band
          FROM base_norms 
          WHERE percentile = 95
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 7 AS rit
                ,33 AS act_band
          FROM base_norms 
          WHERE percentile = 95
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 10 AS rit
                ,34 AS act_band
          FROM base_norms 
          WHERE percentile = 95
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 12 AS rit
                ,35 AS act_band
          FROM base_norms 
          WHERE percentile = 95
            AND rn = 1
            AND measurementscale = 'Reading'
          
          UNION ALL
          
          SELECT measurementscale
                ,fallwinterspring
                ,grade
                ,percentile
                ,RIT + 15 AS rit
                ,36 AS act_band
          FROM base_norms 
          WHERE percentile = 95
            AND rn = 1
            AND measurementscale = 'Reading'
         ) sub
    ) sub
WHERE act_band IS NOT NULL