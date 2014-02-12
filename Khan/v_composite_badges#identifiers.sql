USE Khan
GO

CREATE VIEW composite_badges#identifiers AS
SELECT s.id AS studentid
      ,sub.*
FROM
      (SELECT b.*
             ,REPLACE(b.student, '@teamstudents.org', '') + '.student' AS id_key
       FROM Khan..composite_badges b
       ) sub
JOIN KIPP_NJ..STUDENTS s
  ON sub.id_key = s.student_web_id