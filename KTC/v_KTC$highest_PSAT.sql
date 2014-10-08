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
FROM STUDENTS s WITH(NOLOCK)
JOIN NAVIANCE$PSAT_clean psat WITH(NOLOCK)
  ON s.STUDENT_NUMBER = psat.student_number
GROUP BY s.student_number