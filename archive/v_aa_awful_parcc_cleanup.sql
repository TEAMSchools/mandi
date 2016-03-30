USE [KIPP_NJ]
GO

/****** Object:  View [dbo].[aa_awful_parcc_cleanup]    Script Date: 3/30/2016 1:03:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[aa_awful_parcc_cleanup] AS
WITH munge_p AS 
    (SELECT p.*,
            REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(p.STUDENT, '.', '')), ' ', '.'), 1)) AS n1,
            REVERSE(PARSENAME(REPLACE(REVERSE(REPLACE(p.STUDENT, '.', '')), ' ', '.'), 2)) AS n2
     FROM KIPP_NJ..aa_temp_parcc_long_1415 p),
     munge2 AS
    (SELECT p.student,
            p.subject,
            p.grade,
            CAST(p.scale AS INT) AS scale, 
            CAST(p.reading AS INT) AS reading,
            CAST(p.writing AS INT) AS writing,
            REPLACE(n1, ',', '') AS n1,
            p.n2
     FROM munge_p p
    ),
    knj AS 
   (SELECT c.*,
           s.first_name,
           s.last_name
    FROM KIPP_NJ..COHORT$comprehensive_long#static c 
    JOIN KIPP_NJ..STUDENTS s 
      ON c.studentid = s.id
    WHERE c.year = 2014 AND c. rn = 1
      AND c.grade_level >= 8
    ),
    munge3 AS
   (SELECT p.*,
           knj.studentid
    FROM munge2 p
    LEFT OUTER JOIN knj
      ON p.student = knj.lastfirst
   ),
   matched AS
   (SELECT *
    FROM munge3 
    WHERE munge3.studentid IS NOT NULL
   ),
   unmatched AS
   (SELECT *
    FROM munge3 
    WHERE munge3.studentid IS NULL
   ),
   match2 AS
   (SELECT p.student,
           p.subject,
           p.grade,
           p.scale, 
           p.reading,
           p.writing,
           p.n1,
           p.n2,
           knj.studentid
    FROM unmatched p
    LEFT OUTER JOIN knj
      ON p.n1 = knj.last_name
     AND p.n2 = knj.first_name
    ), 
    hand_match AS (
      SELECT 2982 AS studentid, 'COOK, ANDY' AS student
      UNION ALL
      SELECT 2527, 'HOOPER, YAKIMA'
      UNION ALL
      SELECT 2423, 'JONES, QUINCY'
      UNION ALL
      SELECT 1923, 'MILLER, EDDIE'
      UNION ALL
      SELECT 6170, 'SMITH, TAMARA'
      UNION ALL
      SELECT 4008, 'VELEZ, DANIEL'
    ),
    match3 AS
    (SELECT p.student,
            p.subject,
            p.grade,
            p.scale, 
            p.reading,
            p.writing,
            p.n1,
            p.n2,
            hand_match.studentid
     FROM match2 p
     LEFT OUTER JOIN hand_match
       ON p.student = hand_match.student
     WHERE p.studentid IS NULL
    )
SELECT *
FROM matched
UNION ALL
SELECT *
FROM match2
WHERE studentid IS NOT NULL
UNION ALL
SELECT *
FROM match3


/*

SELECT *
FROM match3

SELECT s.id, s.lastfirst, s.grade_level
FROM KIPP_NJ..STUDENTS s
WHERE s.LASTFIRST LIKE 'VELEZ%' 

*/



/*

SELECT p.*
      ,s.ID AS studentid
FROM KIPP_NJ..aa_temp_parcc_long_1415 p
LEFT OUTER JOIN KIPP_NJ..STUDENTS s
  ON p.student = s.LASTFIRST
WHERE p.STUDENT IN ('JOHNSON, AMIR', 'KERR, JAVON C.')

SELECT *
FROM KIPP_NJ..STUDENTS s
WHERE s.LAST_NAME = 'Kerr' OR s.LASTFIRST = 'Amir'
*/
GO


