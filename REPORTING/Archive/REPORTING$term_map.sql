USE KIPP_NJ
GO

WITH term_scaffold AS (
  SELECT n
  FROM KIPP_NJ..UTIL$row_generator WITH(NOLOCK)
  WHERE n >= 1
    AND n <= 8
 )

-- AR
,hexes AS (
  SELECT 'HEX' AS time_per
        ,n
        ,'RT' + CONVERT(VARCHAR,n) AS hash
  FROM KIPP_NJ..UTIL$row_generator WITH(NOLOCK)
  WHERE n >= 1
    AND n <= 6
 )

-- LIT
,lit AS (
  SELECT 'LIT' AS time_per
        ,n
        ,'LIT' + CONVERT(VARCHAR,n) AS hash
  FROM KIPP_NJ..UTIL$row_generator WITH(NOLOCK)
  WHERE n >= 1
    AND n <= 4
 )

-- MAP
,map AS (
  SELECT time_per
        ,n
        ,CASE
          WHEN hash LIKE '%1%' THEN 'Fall'
          WHEN hash LIKE '%2%' THEN 'Winter'
          WHEN hash LIKE '%3%' THEN 'Spring'
         END AS hash
  FROM
      (
       SELECT 'MAP' AS time_per
             ,n
             ,'MAP' + CONVERT(VARCHAR,n) AS hash
       FROM KIPP_NJ..UTIL$row_generator WITH(NOLOCK)
       WHERE n >= 1
         AND n <= 3
      ) sub  
 )

-- all together now
,term_map AS (
  SELECT hexes.hash AS hex
        ,CASE 
          WHEN lit.hash LIKE '%1%' THEN 'BOY'
          WHEN lit.hash LIKE '%2%' THEN 'T1'
          WHEN lit.hash LIKE '%3%' THEN 'T2'
          WHEN lit.hash LIKE '%4%' THEN 'T3'
         END AS lit
        ,map.hash AS map
        ,0 AS is_curterm
  FROM term_scaffold
  LEFT OUTER JOIN lit
    ON ((term_scaffold.n + 1) / 2) = lit.n
  LEFT OUTER JOIN hexes
    ON term_scaffold.n = (hexes.n + 2)
  LEFT OUTER JOIN map
    ON ((term_scaffold.n - 1) / 2) = map.n

  UNION ALL

  SELECT 'Year' AS hex
        ,'Year' AS lit
        ,'Year' AS map
        ,0 AS is_curterm
 )

SELECT *
--INTO REPORTING$term_map
FROM term_map