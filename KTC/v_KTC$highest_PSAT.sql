USE KIPP_NJ
GO

ALTER VIEW KTC$highest_PSAT AS

SELECT psat.student_number
      ,MAX(psat.reading_test ) AS highest_crit_reading
      ,MAX(psat.math_test) AS highest_math
      ,MAX(psat.writing_test) AS highest_writing
      ,MAX(psat.reading_test)
        + MAX(psat.math_test)        
        AS highest_math_crit_reading
      ,MAX(psat.reading_test)
        + MAX(psat.math_test)
        + MAX(psat.writing_test)
        AS highest_combined
FROM NAVIANCE$PSAT_clean psat WITH(NOLOCK)  
GROUP BY psat.student_number