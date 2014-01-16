USE KIPP_NJ
GO

ALTER VIEW KTC$highest_ACT AS
SELECT s.student_number
      ,MAX(act.english) AS highest_english
      ,MAX(act.math) AS highest_math
      ,MAX(act.reading) AS highest_reading
      ,MAX(act.science) AS highest_science
      ,ROUND(((MAX(act.english) 
               + MAX(act.math) 
               + MAX(act.reading) 
               + MAX(act.science)) / 4),0) AS highest_composite
FROM STUDENTS s
JOIN NAVIANCE$ID_key nav
  ON s.id = nav.studentid
JOIN NAVIANCE$ACT_scores act
  ON nav.naviance_id = act.naviance_id
WHERE act.is_plan = 0
GROUP BY s.student_number