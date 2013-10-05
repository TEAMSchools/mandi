USE KIPP_NJ
GO

CREATE VIEW ILLUMINATE$standards_cube AS
WITH standards_univ AS
   (SELECT *
    FROM KIPP_NJ..ILLUMINATE$standards
    --comment out
    --WHERE std_title = 'Mathematics'
    --  AND cat_title = 'Grade 12'
   )

SELECT state_num AS d1
      ,NULL AS d2
      ,NULL AS d3
      ,NULL AS d4
      ,NULL AS d5
      ,d1.state_num AS standard
FROM standards_univ d1
WHERE [level] = 1

UNION ALL

SELECT d1.state_num AS d1
      ,d2.state_num AS d2
      ,NULL AS d3
      ,NULL AS d4
      ,NULL AS d5
      ,d2.state_num AS standard
FROM standards_univ d2
JOIN standards_univ d1
  ON d2.parent_standard_id = d1.standard_id
WHERE d1.[level] = 2

UNION ALL

SELECT d1.state_num AS d1
      ,d2.state_num AS d2
      ,d3.state_num AS d3
      ,NULL AS d4
      ,NULL AS d5
      ,d3.state_num AS standard
FROM standards_univ d3
JOIN standards_univ d2
  ON d3.parent_standard_id = d2.standard_id
JOIN standards_univ d1
  ON d2.parent_standard_id = d1.standard_id
WHERE d3.[level] = 3

UNION ALL

SELECT d1.state_num AS d1
      ,d2.state_num AS d2
      ,d3.state_num AS d3
      ,d4.state_num AS d4
      ,NULL AS d5
      ,d4.state_num AS standard
FROM standards_univ d4
JOIN standards_univ d3
  ON d4.parent_standard_id = d3.standard_id
JOIN standards_univ d2
  ON d3.parent_standard_id = d2.standard_id
JOIN standards_univ d1
  ON d2.parent_standard_id = d1.standard_id
WHERE d4.[level] = 4

UNION ALL

SELECT d1.state_num AS d1
      ,d2.state_num AS d2
      ,d3.state_num AS d3
      ,d4.state_num AS d4
      ,d5.state_num AS d5
      ,d4.state_num AS standard
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