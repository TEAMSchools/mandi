USE Khan
GO

ALTER VIEW composite_exercises#identifiers AS
SELECT s.id AS studentid
      ,sub.*
FROM
      (SELECT e.*
             ,REPLACE(e.student, '@teamstudents.org', '') + '.student' AS id_key
       FROM Khan..composite_exercises e
       ) sub
JOIN KIPP_NJ..STUDENTS s
  ON sub.id_key = s.student_web_id