USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$student_groups AS

SELECT local_student_id AS student_number
      ,group_id
      ,group_name
      ,dbo.fn_DateToSY(start_date) AS academic_year
      ,start_date
      ,end_date
      ,eligibility_start_date
      ,eligibility_end_date
      ,s.SCHOOLID
FROM OPENQUERY(ILLUMINATE,'
  SELECT s.local_student_id
        ,g.group_id
        ,g.group_name
        ,aff.start_date
        ,aff.end_date
        ,aff.eligibility_start_date
        ,aff.eligibility_end_date        
  FROM groups.groups g
  JOIN groups.group_student_aff aff
    ON g.group_id = aff.group_id
  JOIN public.students s
    ON aff.student_id = s.student_id
') oq
JOIN STUDENTS s WITH(NOLOCK)
  ON oq.local_student_id = s.STUDENT_NUMBER