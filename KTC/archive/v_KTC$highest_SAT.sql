USE KIPP_NJ
GO

ALTER VIEW KTC$highest_SAT AS

SELECT s.student_number
      ,s.id AS studentid
      ,MAX(sat.verbal) AS highest_verbal
      ,MAX(sat.math) AS highest_math
      ,MAX(sat.writing) AS highest_writing
      ,MAX(sat.verbal)
        + MAX(sat.math)        
        AS highest_math_verbal
      ,MAX(sat.verbal)
        + MAX(sat.math)
        + MAX(sat.writing)
        AS highest_combined
FROM STUDENTS s WITH(NOLOCK)
JOIN NAVIANCE$SAT_clean sat WITH(NOLOCK)
  ON s.STUDENT_NUMBER = sat.student_number
GROUP BY s.student_number, s.id