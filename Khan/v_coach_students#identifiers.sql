USE Khan
GO

ALTER VIEW coach_students#identifiers AS

SELECT s.id AS studentid
      ,sub.*
FROM
    (
     SELECT c.*
           ,REPLACE(stu_detail.identity_email, '@teamstudents.org', '') + '.student' AS id_key
     FROM Khan..coach_students c WITH(NOLOCK)
     JOIN Khan..stu_detail WITH(NOLOCK)
       ON c.student = stu_detail.student
    ) sub
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON sub.id_key = s.student_web_id