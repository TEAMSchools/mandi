SELECT student_id AS ill_stu_id
      ,local_student_id AS student_number
      ,s.ID AS studentid      
FROM OPENQUERY(ILLUMINATE,'
  SELECT student_id
        ,local_student_id
  FROM kippteamschools.public.students
  ') ill_stu
LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)  
  ON ill_stu.local_student_id = s.STUDENT_NUMBER