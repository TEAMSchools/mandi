USE KIPP_NJ
GO

ALTER VIEW MAP$norm_table_extended#2011 AS

WITH master_norms AS (
  SELECT *
  FROM KIPP_NJ..MAP$norm_table#2011 WITH(NOLOCK)
 )

--regular norm table
SELECT *
FROM master_norms

UNION ALL

--not covered areas:
--reading 12
SELECT measurementscale
      ,fallwinterspring
      ,12 AS grade
      ,RIT
      ,percentile
FROM master_norms
WHERE measurementscale = 'Reading'
  AND grade = 11

UNION ALL

--math 12
SELECT measurementscale
      ,fallwinterspring
      ,12 AS grade
      ,RIT
      ,percentile
FROM master_norms
WHERE measurementscale = 'Mathematics'
  AND grade = 11

UNION ALL

--language 12
SELECT measurementscale
      ,fallwinterspring
      ,12 AS grade
      ,RIT
      ,percentile
FROM master_norms
WHERE measurementscale = 'Language Usage'
  AND grade = 11

UNION ALL

--general science 11, 12
SELECT measurementscale
      ,fallwinterspring
      ,11 AS grade
      ,RIT
      ,percentile
FROM master_norms
WHERE measurementscale = 'General Science'
  AND grade = 10

UNION ALL

SELECT measurementscale
      ,fallwinterspring
      ,12 AS grade
      ,RIT
      ,percentile
FROM master_norms
WHERE measurementscale = 'General Science'
  AND grade = 10