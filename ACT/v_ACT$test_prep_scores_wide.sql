USE KIPP_NJ
GO

ALTER VIEW ACT$test_prep_scores_wide AS

SELECT student_number
      ,academic_year
      ,administration_round
      ,[English]
      ,[Mathematics]
      ,[Reading]
      ,[Science]
      ,[Composite]
      ,CASE WHEN [composite] >= 22 THEN 1.0 ELSE 0.0 END AS is_22
      ,CASE WHEN [composite] >= 25 THEN 1.0 ELSE 0.0 END AS is_25
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year
           ORDER BY administered_at DESC) AS rn_curr
FROM
    (
     SELECT student_number
           ,academic_year
           ,administration_round
           ,administered_at
           ,ISNULL(subject_area,'Composite') AS subject_area
           ,AVG(scale_score) AS scale_score
     FROM ACT$test_prep_scores WITH(NOLOCK)
     WHERE rn_dupe = 1
     GROUP BY student_number
             ,academic_year
             ,administration_round
             ,administered_at
             ,CUBE(subject_area)
    ) sub
PIVOT(
  MAX(scale_score)
  FOR subject_area IN ([English]
                      ,[Mathematics]
                      ,[Reading]
                      ,[Science]
                      ,[Composite])
 ) p