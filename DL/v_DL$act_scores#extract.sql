USE KIPP_NJ
GO

ALTER VIEW DL$act_scores#extract AS

SELECT student_number	
      ,academic_year
      ,[scale_score_act1]
      ,[scale_score_act2]
      ,[scale_score_act3]
      ,[scale_score_act4]
      ,[scale_score_act5]
      ,[scale_score_act6]
      ,[scale_score_act7]
FROM
    (
     SELECT student_number
           ,academic_year      
           ,CONCAT('scale_score_', LOWER(REPLACE(time_per_name,'-',''))) AS field
           ,scale_score
     FROM KIPP_NJ..ACT$test_prep_scores WITH(NOLOCK)
     WHERE subject_area = 'Composite'
       AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
PIVOT(
  MAX(scale_score)
  FOR field IN ([scale_score_act1]
               ,[scale_score_act2]
               ,[scale_score_act3]
               ,[scale_score_act4]
               ,[scale_score_act5]
               ,[scale_score_act6]
               ,[scale_score_act7])
 ) p