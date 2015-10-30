USE [KIPP_NJ]
GO

CREATE VIEW MAP$norm_table_extended#2015 AS

WITH master_norms AS (
  SELECT measurementscale,
         fallwinterspring, 
         grade,
         RIT,
         student_percentile
  FROM KIPP_NJ..MAP$norm_table#2015 WITH(NOLOCK)
 )
/*
--what is missing
SELECT DISTINCT measurementscale, grade
FROM master_norms
ORDER BY measurementscale, grade ASC
*/
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
      ,student_percentile
FROM master_norms
WHERE measurementscale = 'Reading'
  AND grade = 11

UNION ALL

--math 12
SELECT measurementscale
      ,fallwinterspring
      ,12 AS grade
      ,RIT
      ,student_percentile
FROM master_norms
WHERE measurementscale = 'Mathematics'
  AND grade = 11

UNION ALL

--language 12
SELECT measurementscale
      ,fallwinterspring
      ,12 AS grade
      ,RIT
      ,student_percentile
FROM master_norms
WHERE measurementscale = 'Language Usage'
  AND grade = 11

UNION ALL

--general science 9, 10, 11, 12
SELECT measurementscale
      ,fallwinterspring
      ,9 AS grade
      ,RIT
      ,student_percentile
FROM master_norms
WHERE measurementscale = 'General Science'
  AND grade = 8

UNION ALL

SELECT measurementscale
      ,fallwinterspring
      ,10 AS grade
      ,RIT
      ,student_percentile
FROM master_norms
WHERE measurementscale = 'General Science'
  AND grade = 8

UNION ALL

SELECT measurementscale
      ,fallwinterspring
      ,11 AS grade
      ,RIT
      ,student_percentile
FROM master_norms
WHERE measurementscale = 'General Science'
  AND grade = 8

UNION ALL

SELECT measurementscale
      ,fallwinterspring
      ,12 AS grade
      ,RIT
      ,student_percentile
FROM master_norms
WHERE measurementscale = 'General Science'
  AND grade = 8


