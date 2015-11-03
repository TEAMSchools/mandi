USE KIPP_NJ
GO

ALTER VIEW KTC$highest_scores_wide AS

SELECT s.student_number            
      ,psat.highest_math AS PSAT_highest_math
      ,psat.highest_crit_reading AS PSAT_highest_verbal
      ,psat.highest_writing AS PSAT_highest_writing      
      ,psat.highest_combined AS PSAT_highest_combined
      ,sat.highest_math AS SAT_highest_math
      ,sat.highest_verbal AS SAT_highest_verbal
      ,sat.highest_writing AS SAT_highest_writing
      ,sat.highest_math_verbal AS SAT_highest_math_verbal
      ,sat.highest_combined AS SAT_highest_combined
      ,act.highest_math AS ACT_highest_math
      ,act.highest_english AS ACT_highest_english
      ,act.highest_reading AS ACT_highest_reading
      ,act.highest_science AS ACT_highest_science
      ,act.highest_composite AS ACT_highest_composite
FROM PS$students#static S WITH(NOLOCK)
LEFT OUTER JOIN KTC$highest_PSAT psat WITH(NOLOCK)
  ON s.STUDENT_NUMBER = psat.student_number  
LEFT OUTER JOIN KTC$highest_SAT sat WITH(NOLOCK)
  ON s.STUDENT_NUMBER = sat.student_number  
LEFT OUTER JOIN KTC$highest_ACT act WITH(NOLOCK)
  ON s.STUDENT_NUMBER = act.student_number