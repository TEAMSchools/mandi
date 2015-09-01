USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$standards_cube AS

WITH standards_univ AS (
  SELECT state_num
        ,level
        ,custom_code
        ,standard_id
        ,parent_standard_id
  FROM KIPP_NJ..ILLUMINATE$standards#static WITH(NOLOCK)    
 )

SELECT state_num AS d1
      ,NULL AS d2
      ,NULL AS d3
      ,NULL AS d4
      ,NULL AS d5
      ,d1.level AS depth
      ,d1.custom_code AS standard
FROM standards_univ d1
WHERE [level] = 1

UNION ALL

SELECT d1.custom_code AS d1
      ,d2.custom_code AS d2
      ,NULL AS d3
      ,NULL AS d4
      ,NULL AS d5
      ,d2.level AS depth
      ,d2.custom_code AS standard
FROM standards_univ d2
JOIN standards_univ d1
  ON d2.parent_standard_id = d1.standard_id
WHERE d2.[level] = 2

UNION ALL

SELECT d1.custom_code AS d1
      ,d2.custom_code AS d2
      ,d3.custom_code AS d3
      ,NULL AS d4
      ,NULL AS d5
      ,d3.level AS depth
      ,d3.custom_code AS standard
FROM standards_univ d3
JOIN standards_univ d2
  ON d3.parent_standard_id = d2.standard_id
JOIN standards_univ d1
  ON d2.parent_standard_id = d1.standard_id
WHERE d3.[level] = 3

UNION ALL

SELECT d1.custom_code AS d1
      ,d2.custom_code AS d2
      ,d3.custom_code AS d3
      ,d4.custom_code AS d4
      ,NULL AS d5
      ,d4.level AS depth
      ,d4.custom_code AS standard
FROM standards_univ d4
JOIN standards_univ d3
  ON d4.parent_standard_id = d3.standard_id
JOIN standards_univ d2
  ON d3.parent_standard_id = d2.standard_id
JOIN standards_univ d1
  ON d2.parent_standard_id = d1.standard_id
WHERE d4.[level] = 4

UNION ALL

SELECT d1.custom_code AS d1
      ,d2.custom_code AS d2
      ,d3.custom_code AS d3
      ,d4.custom_code AS d4
      ,d5.custom_code AS d5
      ,d5.level AS depth
      ,d4.custom_code AS standard
FROM standards_univ d5
JOIN standards_univ d4
  ON d5.parent_standard_id = d4.standard_id
JOIN standards_univ d3
  ON d4.parent_standard_id = d3.standard_id
JOIN standards_univ d2
  ON d3.parent_standard_id = d2.standard_id
JOIN standards_univ d1
  ON d2.parent_standard_id = d1.standard_id
WHERE d5.[level] = 5