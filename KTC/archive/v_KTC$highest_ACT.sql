USE KIPP_NJ
GO

ALTER VIEW KTC$highest_ACT AS

SELECT STUDENT_NUMBER
      ,highest_english
      ,highest_math
      ,highest_reading
      ,highest_science
      ,highest_composite
FROM
     (
      SELECT act.student_number
            ,act.english AS highest_english
            ,act.math AS highest_math
            ,act.reading AS highest_reading
            ,act.science AS highest_science
            ,act.composite AS highest_composite
            ,ROW_NUMBER() OVER(
                PARTITION BY act.student_number
                    ORDER BY act.composite DESC) AS rn
      FROM NAVIANCE$ACT_clean act              
     ) sub
WHERE rn = 1