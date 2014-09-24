USE KIPP_NJ
GO

ALTER VIEW MAP$MAP$norm_table_extended#2011#dense AS
WITH nums AS
    (SELECT n
     FROM KIPP_NJ..UTIL$row_generator
     WHERE n < 100 AND n > 0
    )
    ,base_norms AS
    (SELECT n.*
            --partition to get only one row per percentile
            --later we'll union to put humpty dumpty back together
           ,ROW_NUMBER() OVER
             (PARTITION BY n.measurementscale
                          ,n.fallwinterspring
                          ,n.grade
                          ,n.percentile
              ORDER BY RIT DESC
             ) AS rn
     FROM KIPP_NJ..MAP$norm_table_extended#2011 n
     WHERE n.percentile <= 50
     UNION 
     SELECT n.*
           ,ROW_NUMBER() OVER
             (PARTITION BY n.measurementscale
                          ,n.fallwinterspring
                          ,n.grade
                          ,n.percentile
              ORDER BY RIT ASC
             ) AS rn
     FROM KIPP_NJ..MAP$norm_table_extended#2011 n
     WHERE n.percentile > 50
    )
SELECT TOP 1000000000 sub.measurementscale
      ,sub.fallwinterspring
      ,sub.grade
      ,sub.RIT
      ,sub.percentile
FROM
      (SELECT base_norms.measurementscale
             ,base_norms.fallwinterspring
             ,base_norms.grade
             ,base_norms.RIT
             ,nums.n AS percentile
             ,ROW_NUMBER() OVER
                (PARTITION BY base_norms.measurementscale
                             ,base_norms.fallwinterspring
                             ,base_norms.grade
                             ,nums.n
                 ORDER BY ABS(base_norms.percentile - nums.n)
                ) AS rn
       FROM nums
       JOIN base_norms
         ON 1=1
        AND base_norms.rn = 1
       ) sub
WHERE sub.rn = 1
UNION 
SELECT TOP 1000000000 base_norms.measurementscale
      ,base_norms.fallwinterspring
      ,base_norms.grade
      ,base_norms.RIT
      ,base_norms.percentile
FROM base_norms
ORDER BY measurementscale
        ,grade
        ,fallwinterspring
        ,percentile
        ,RIT