USE KIPP_NJ
GO

ALTER VIEW KTC$highest_SAT AS
SELECT s.student_number
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
FROM STUDENTS s
LEFT OUTER JOIN CUSTOM_STUDENTS cs
  ON s.id = cs.studentid
JOIN NAVIANCE$ID_key nav
  ON s.id = nav.studentid
JOIN NAVIANCE$SAT_scores sat
  ON nav.naviance_id = sat.naviance_id
GROUP BY s.student_number