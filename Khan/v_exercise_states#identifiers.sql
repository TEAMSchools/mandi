USE Khan
GO

ALTER VIEW exercise_states#identifiers AS
WITH states_munge AS 
    (SELECT b.*,
           REPLACE(stu_detail.identity_email, '@teamstudents.org', '') AS cleaned_email
     FROM Khan..exercise_states b  WITH(NOLOCK)
     JOIN Khan..stu_detail  WITH(NOLOCK)
       ON b.student = stu_detail.student 
    ),
    add_id AS
    (SELECT m.*
           ,REPLACE(SUBSTRING(m.cleaned_email, 1, CHARINDEX(',', m.cleaned_email)-1) , 'norm:', '') + '.student' AS id_key
     FROM states_munge m
    )
SELECT s.id AS studentid
      ,add_id.*
FROM add_id
JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
  ON add_id.id_key = s.student_web_id








