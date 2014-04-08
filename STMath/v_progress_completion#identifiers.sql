USE STMath
GO

CREATE VIEW progress_completion#identifiers AS
SELECT p.*
      ,s.school_student_id AS student_number
      ,st.id AS studentid
FROM STMath..progress_completion p
JOIN STMath..student_id_linkages s
  ON p.UUID = s.UUID
JOIN KIPP_NJ..STUDENTS st
  ON s.school_student_id = st.student_number
