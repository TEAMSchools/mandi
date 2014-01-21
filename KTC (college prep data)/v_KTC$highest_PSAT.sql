USE KIPP_NJ
GO

ALTER VIEW KTC$highest_PSAT AS
SELECT s.student_number
      ,MAX(psat.critical_reading) AS highest_crit_reading
      ,MAX(psat.math) AS highest_math
      ,MAX(psat.writing) AS highest_writing
      ,MAX(psat.critical_reading)
        + MAX(psat.math)        
        AS highest_math_crit_reading
      ,MAX(psat.critical_reading)
        + MAX(psat.math)
        + MAX(psat.writing)
        AS highest_combined
FROM STUDENTS s
LEFT OUTER JOIN CUSTOM_STUDENTS cs
  ON s.id = cs.studentid
JOIN NAVIANCE$ID_key nav
  ON s.id = nav.studentid
JOIN NAVIANCE$PSAT_scores psat
  ON nav.naviance_id = psat.naviance_id
GROUP BY s.student_number