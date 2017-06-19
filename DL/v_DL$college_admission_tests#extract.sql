USE KIPP_NJ
GO

ALTER VIEW DL$college_admission_tests#extract AS

SELECT student_number
      ,'ACT' AS test_type
      ,CONCAT(LEFT(DATENAME(MONTH, test_date), 3), ' ', DATENAME(YEAR, test_date)) AS test_date
      ,composite AS act_composite
      ,math AS act_math
      ,science AS act_science
      ,english AS act_english
      ,reading AS act_reading
      ,writing AS act_writing
      ,NULL AS sat_total
      ,NULL AS sat_math
      ,NULL AS sat_reading      
      ,NULL AS sat_writing
      ,NULL AS sat_mc
      ,NULL AS sat_essay
FROM KIPP_NJ..NAVIANCE$ACT_clean WITH(NOLOCK)

UNION ALL

SELECT student_number
      ,'SAT' AS test_type
      ,CONCAT(LEFT(DATENAME(MONTH, test_date), 3), ' ', DATENAME(YEAR, test_date)) AS test_date
      ,NULL AS act_composite
      ,NULL AS act_math
      ,NULL AS act_science
      ,NULL AS act_english
      ,NULL AS act_reading
      ,NULL AS act_writing
      ,all_tests_total AS sat_total
      ,math AS sat_math
      ,verbal AS sat_reading      
      ,writing AS sat_writing
      ,mc_subscore AS sat_mc
      ,essay_subscore AS sat_essay
FROM KIPP_NJ..NAVIANCE$SAT_clean WITH(NOLOCK)