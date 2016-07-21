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

UNION ALL

SELECT 179902 AS schoolid
      ,2015 AS academic_year
      ,CONVERT(INT,CONVERT(FLOAT,student_number)) AS student_number
      ,s.LASTFIRST
      ,xc.enrichment AS program
      ,NULL AS start_term
      ,NULL AS end_term
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_XC_enrichment_roster] xc WITH(NOLOCK)
JOIN KIPP_NJ..PS$STUDENTS#static s WitH(NOLOCK)
  ON xc.student_name = s.LASTFIRST
 AND s.SCHOOLID = 179902