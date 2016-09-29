USE KIPP_NJ
GO

ALTER VIEW ACT$test_scores AS

SELECT hs_student_id AS student_number
      ,test_type
      ,english
      ,math
      ,reading
      ,science
      ,writing
      ,writing_sub
      ,comb_eng_write
      ,ela
      ,stem
      ,composite
      ,predicted_act
      ,test_date      
      ,CASE WHEN composite >= 25 THEN 1 ELSE 0 END AS is_25
      ,CASE WHEN composite >= 22 THEN 1 ELSE 0 END AS is_22
      ,CASE WHEN composite >= 20 THEN 1 ELSE 0 END AS is_20
      
      ,ROW_NUMBER() OVER(
         PARTITION BY hs_student_id
           ORDER BY composite DESC) AS rn
FROM KIPP_NJ..AUTOLOAD$NAVIANCE_3_act_scores WITH(NOLOCK)
WHERE composite IS NOT NULL