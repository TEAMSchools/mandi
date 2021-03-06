USE Khan
GO

ALTER VIEW stu_detail#identifiers AS

SELECT s.id AS studentid
      ,sub.*
FROM
    (
     SELECT s.*
           ,REPLACE(s.identity_email, '@teamstudents.org', '') + '.student' AS id_key
     FROM Khan..stu_detail s WITH(NOLOCK)
    ) sub
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON sub.id_key = s.student_web_id