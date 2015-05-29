USE KIPP_NJ
GO

ALTER VIEW LSW$social_work_tracker AS

SELECT sw.[Student Number] AS student_number      
      ,KIPP_NJ.dbo.fn_DateToSY(sw.[Date]) AS academic_year
      ,sw.[Date] AS observation_date
      ,sw.[Social Worker] AS social_worker
      ,sw.[Environment] AS environment
      ,sw.[Goal] AS goal
      ,sw.[Rating] AS rating
      ,sw.[Narrative] AS narrative
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_LSW_Data_Entry] sw WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sw.[Student Number] = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(sw.[Date]) = co.year
 AND co.rn = 1