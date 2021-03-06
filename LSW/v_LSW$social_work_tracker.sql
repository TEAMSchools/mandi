USE KIPP_NJ
GO

ALTER VIEW LSW$social_work_tracker AS

SELECT sw.student_number      
      ,co.lastfirst AS student_name
      ,co.school_name
      ,co.grade_level
      ,KIPP_NJ.dbo.fn_DateToSY(sw.[Date]) AS academic_year
      ,CONVERT(DATE,sw.[Date]) AS observation_date
      ,sw.social_worker
      ,sw.[Group]
      ,sw.[Environment] AS environment
      ,sw.goal_category AS goal_cat      
      ,sw.skill_description AS skill_descr
      ,sw.[Rating] AS rating
      ,sw.[Narrative] AS narrative
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_LSW_Data_Entry] sw WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sw.student_number = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(sw.[Date]) = co.year
 AND co.rn = 1

UNION ALL

SELECT sw.student_number      
      ,co.lastfirst AS student_name
      ,co.school_name
      ,co.grade_level
      ,KIPP_NJ.dbo.fn_DateToSY(sw.[Date]) AS academic_year
      ,CONVERT(DATE,sw.[Date]) AS observation_date
      ,sw.social_worker
      ,sw.[Group]
      ,sw.[Environment] AS environment
      ,sw.goal_category AS goal_cat      
      ,sw.skill_description AS skill_descr
      ,sw.[Rating] AS rating
      ,sw.[Narrative] AS narrative
FROM KIPP_NJ..[LSW$data_entry#archive] sw WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON sw.student_number = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(sw.[Date]) = co.year
 AND co.rn = 1