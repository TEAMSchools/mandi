USE [KIPP_NJ]
GO

ALTER VIEW NAVIANCE$college_apps_clean AS

SELECT [hs_student_id] AS student_number
      ,CASE WHEN [ceeb_code] = 'NULL' THEN NULL ELSE CONVERT(VARCHAR,ceeb_code) END AS ceeb_code
      ,CASE WHEN [act_code] = 'NULL' THEN NULL ELSE [act_code] END AS [act_code]
      ,[collegename]      
      ,[state]
      ,[admissions_fax]
      ,[inst_control]
      ,[level]                        
      ,[stage]      
      ,[type]
      ,CASE WHEN [result_code] = 'NULL' THEN NULL ELSE [result_code] END AS [result_code]
      ,[attending]
      ,[waitlisted]
      ,[deferred]
      ,CASE WHEN [date_transcript_requested] = 'NULL' THEN NULL ELSE [date_transcript_requested] END AS [date_transcript_requested]
      ,[initial_transcript_sent]
      ,[midyear_transcript_sent]
      ,[final_transcript_sent]
      ,CASE WHEN [comments] = 'NULL' THEN NULL ELSE comments END AS comments
      ,[SPEC] AS special_prog
      ,[LEG] AS legacy
      ,[INTV] AS interviewed
      ,[VIS] AS visited
      ,[URG] AS urgent
FROM [dbo].[AUTOLOAD$NAVIANCE_college_applications] WITH(NOLOCK)