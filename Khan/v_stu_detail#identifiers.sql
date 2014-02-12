USE Khan
GO

ALTER VIEW stu_detail#identifiers AS
SELECT s.id AS studentid
      ,sub.*
FROM
      (SELECT s.*
             ,REPLACE(s.student, '@teamstudents.org', '') + '.student' AS id_key
       FROM Khan..stu_detail s
       ) sub
JOIN KIPP_NJ..STUDENTS s
  ON sub.id_key = s.student_web_id