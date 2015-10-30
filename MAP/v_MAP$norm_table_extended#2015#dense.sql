USE [KIPP_NJ]
GO

CREATE VIEW MAP$norm_table_extended#2015#dense AS

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
        ,n.student_percentile
         --partition to get only one row per percentile
         --later we'll union to put humpty dumpty back together
        ,ROW_NUMBER() OVER(
           PARTITION BY n.measurementscale, n.fallwinterspring, n.grade, n.student_percentile
               ORDER BY RIT DESC) AS rn
  FROM KIPP_NJ..MAP$norm_table_extended#2015 n WITH (NOLOCK)
  WHERE n.student_percentile <= 50
  
  UNION 
  
  SELECT n.measurementscale
        ,n.fallwinterspring
        ,n.grade
        ,n.RIT
        ,n.student_percentile
        ,ROW_NUMBER() OVER(
           PARTITION BY n.measurementscale, n.fallwinterspring, n.grade, n.student_percentile
             ORDER BY RIT ASC) AS rn
  FROM KIPP_NJ..MAP$norm_table_extended#2015 n WITH (NOLOCK)
  WHERE n.student_percentile > 50
 )

SELECT sub.measurementscale
      ,sub.fallwinterspring
      ,sub.grade
      ,sub.RIT
      ,sub.student_percentile
FROM
    (
     SELECT base_norms.measurementscale
           ,base_norms.fallwinterspring
           ,base_norms.grade
           ,base_norms.RIT
           ,nums.n AS student_percentile
           ,ROW_NUMBER() OVER(
              PARTITION BY base_norms.measurementscale, base_norms.fallwinterspring, base_norms.grade, nums.n
                ORDER BY ABS(base_norms.student_percentile - nums.n)) AS rn
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
      ,base_norms.student_percentile
FROM base_norms
GO


