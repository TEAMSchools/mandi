USE STMath
GO

CREATE VIEW progress_completion#identifiers AS
SELECT p.*
      ,s.id AS studentid
FROM STMath..progress_completion p
JOIN KIPP_NJ..STUDENTS s
  ON p.school_student_id = s.student_number