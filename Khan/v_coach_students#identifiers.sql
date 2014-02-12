USE Khan
GO

CREATE VIEW coach_students#identifiers AS
SELECT s.id AS studentid
      ,sub.*
FROM
      (SELECT c.*
             ,REPLACE(c.student, '@teamstudents.org', '') + '.student' AS id_key
       FROM Khan..coach_students c
       ) sub
JOIN KIPP_NJ..STUDENTS s
  ON sub.id_key = s.student_web_id