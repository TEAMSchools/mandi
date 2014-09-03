USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$student_groups AS

SELECT local_student_id AS student_number
      ,group_id
      ,group_name
      ,CASE
        WHEN DATEPART(MONTH,start_date) <= 6 THEN (DATEPART(YEAR,start_date) - 1)
        ELSE DATEPART(YEAR,start_date)
       END AS academic_year
      ,start_date
      ,end_date
      ,eligibility_start_date
      ,eligibility_end_date
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
')