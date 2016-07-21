USE Khan
GO

ALTER VIEW badge_detail#identifiers AS

SELECT s.id AS studentid
      ,sub.*
      ,KIPP_NJ.dbo.fn_DateToSY(sub.date_earned) AS academic_year
FROM
    (
     SELECT b.*
           ,REPLACE(stu_detail.identity_email, '@teamstudents.org', '') + '.student' AS id_key
     FROM Khan..badge_detail b WITH(NOLOCK)
     JOIN Khan..stu_detail WITH(NOLOCK)
       ON b.student = stu_detail.student
    ) sub
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON sub.id_key = s.student_web_id