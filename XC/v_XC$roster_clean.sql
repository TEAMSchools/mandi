USE KIPP_NJ
GO

ALTER VIEW XC$roster_clean AS

SELECT 133570965 AS schoolid      
      ,CONVERT(INT,CONVERT(FLOAT,academic_year)) AS academic_year
      ,CONVERT(INT,CONVERT(FLOAT,student_number)) AS student_number
      ,name AS student_name
      ,program
      ,start_term
      ,end_term
FROM KIPP_NJ..[AUTOLOAD$GDOCS_XC_TEAM_Roster] WITH(NOLOCK)
WHERE student_number IS NOT NULL

UNION ALL

SELECT 73252 AS schoolid
      ,CONVERT(INT,CONVERT(FLOAT,academic_year)) AS academic_year
      ,CONVERT(INT,CONVERT(FLOAT,student_number)) AS student_number
      ,student_name
      ,program
      ,start_season AS start_term
      ,end_season AS end_term
FROM KIPP_NJ..[AUTOLOAD$GDOCS_XC_Rise_Roster] WITH(NOLOCK)
WHERE student_number IS NOT NULL