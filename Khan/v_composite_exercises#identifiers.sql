USE Khan
GO

ALTER VIEW composite_exercises#identifiers AS
SELECT s.id AS studentid
      ,sub.*
FROM
      (SELECT e.*
             ,REPLACE(stu_detail.identity_email, '@teamstudents.org', '') + '.student' AS id_key
       FROM Khan..composite_exercises e
       JOIN Khan..stu_detail
         ON e.student = stu_detail.student
       ) sub
JOIN KIPP_NJ..STUDENTS s
  ON sub.id_key = s.student_web_id