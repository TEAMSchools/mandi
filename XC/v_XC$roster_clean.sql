USE KIPP_NJ
GO

ALTER VIEW XC$roster_clean AS

SELECT [School ID] AS schoolid      
      ,[Academic Year] AS academic_year      
      ,[Student Number] AS student_number
      ,name AS student_name
      ,program
      ,[Start Term] AS start_term
      ,[End Term] AS end_term
FROM KIPP_NJ..[AUTOLOAD$GDOCS_XC_TEAM_Roster] WITH(NOLOCK)
WHERE [Student Number] IS NOT NULL

UNION ALL

SELECT 73252 AS schoolid
      ,academic_year
      ,[Student Number] AS student_number
      ,[Student Name] AS student_name
      ,program
      ,[Start Season] AS start_term
      ,[End Season] AS end_term
FROM KIPP_NJ..[AUTOLOAD$GDOCS_XC_Rise_Roster] WITH(NOLOCK)
WHERE [Student Number] IS NOT NULL