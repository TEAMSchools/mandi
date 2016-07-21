USE Khan
GO

ALTER VIEW exercise_states#identifiers AS

WITH states_munge AS (
  SELECT *
        ,REPLACE(SUBSTRING(m.cleaned_email, 1, CHARINDEX(',', m.cleaned_email)-1) , 'norm:', '') + '.student' AS id_key
  FROM
      (
       SELECT b.*
             ,REPLACE(stu_detail.identity_email, '@teamstudents.org', '') AS cleaned_email
       FROM Khan..exercise_states b WITH(NOLOCK)
       JOIN Khan..stu_detail WITH(NOLOCK)
         ON b.student = stu_detail.student
      ) m
 )
 
SELECT s.id AS studentid
      ,states_munge.*
FROM states_munge
JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON states_munge.id_key = s.student_web_id








