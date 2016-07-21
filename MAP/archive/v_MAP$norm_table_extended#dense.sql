USE KIPP_NJ
GO

ALTER VIEW MAP$norm_table_extended#2011#dense AS

WITH nums AS (
  SELECT n
  FROM KIPP_NJ..UTIL$row_generator WITH (NOLOCK)
  WHERE n BETWEEN 0 AND 100
 )

,base_norms AS (
  SELECT n.measurementscale
        ,n.fallwinterspring
        ,n.grade
        ,n.RIT
        ,n.percentile
         --partition to get only one row per percentile
         --later we'll union to put humpty dumpty back together
        ,ROW_NUMBER() OVER(
           PARTITION BY n.measurementscale, n.fallwinterspring, n.grade, n.percentile
               ORDER BY RIT DESC) AS rn
  FROM KIPP_NJ..MAP$norm_table_extended#2011 n WITH (NOLOCK)
  WHERE n.percentile <= 50
  
  UNION 
  
  SELECT n.measurementscale
        ,n.fallwinterspring
        ,n.grade
        ,n.RIT
        ,n.percentile
        ,ROW_NUMBER() OVER(
           PARTITION BY n.measurementscale, n.fallwinterspring, n.grade, n.percentile
             ORDER BY RIT ASC) AS rn
  FROM KIPP_NJ..MAP$norm_table_extended#2011 n WITH (NOLOCK)
  WHERE n.percentile > 50
 )

SELECT sub.measurementscale
      ,sub.fallwinterspring
      ,sub.grade
      ,sub.RIT
      ,sub.percentile
FROM
    (
     SELECT base_norms.measurementscale
           ,base_norms.fallwinterspring
           ,base_norms.grade
           ,base_norms.RIT
           ,nums.n AS percentile
           ,ROW_NUMBER() OVER(
              PARTITION BY base_norms.measurementscale, base_norms.fallwinterspring, base_norms.grade, nums.n
                ORDER BY ABS(base_norms.percentile - nums.n)) AS rn
     FROM nums WITH(NOLOCK)
     JOIN base_norms WITH(NOLOCK)
       ON base_norms.rn = 1
     ) sub
WHERE sub.rn = 1

UNION 

SELECT base_norms.measurementscale
      ,base_norms.fallwinterspring
      ,base_norms.grade
      ,base_norms.RIT
      ,base_norms.percentile
FROM base_norms