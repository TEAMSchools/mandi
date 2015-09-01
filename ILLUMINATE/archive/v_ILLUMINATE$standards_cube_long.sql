USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$standards_cube_long AS

--all the identities
SELECT d1 AS standard
      ,d1 AS up_the_tree
      ,depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 1

UNION ALL

SELECT d2 AS standard
      ,d2 AS up_the_tree
      ,depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 2

UNION ALL

SELECT d3 AS standard
      ,d3 AS up_the_tree
      ,depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 3

UNION ALL

SELECT d4 AS standard
      ,d4 AS up_the_tree
      ,depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 4

UNION ALL

SELECT d5 AS standard
      ,d5 AS up_the_tree
      ,depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 5

--up the chains
UNION ALL

  --level 2
SELECT d2 AS standard
      ,d1 AS up_the_tree
      ,1 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 2

UNION ALL

  --level 3
SELECT d3 AS standard
      ,d1 AS up_the_tree
      ,1 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 3

UNION ALL

SELECT d3 AS standard
      ,d2 AS up_the_tree
      ,2 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 3

UNION ALL
  --level 4
SELECT d4 AS standard
      ,d1 AS up_the_tree
      ,1 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 4

UNION ALL
 
SELECT d4 AS standard
      ,d2 AS up_the_tree
      ,2 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 4

UNION ALL
 
SELECT d4 AS standard
      ,d3 AS up_the_tree
      ,3 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 4

UNION ALL
  --level 5
SELECT d5 AS standard
      ,d1 AS up_the_tree
      ,1 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 5

UNION ALL
  
SELECT d5 AS standard
      ,d2 AS up_the_tree
      ,2 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 5

UNION ALL
  
SELECT d5 AS standard
      ,d3 AS up_the_tree
      ,3 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 5

UNION ALL
  
SELECT d5 AS standard
      ,d4 AS up_the_tree
      ,4 AS depth
FROM ILLUMINATE$standards_cube WITH(NOLOCK)
WHERE depth = 5