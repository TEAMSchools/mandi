USE KIPP_NJ
GO

ALTER VIEW TABLEAU$professionalism_tracker AS

SELECT [Staff Name]
      ,CONVERT(DATE,[Date]) AS date
      ,[Grade]
      ,[Manager]
      ,[On Time]
      ,[Present]
      ,[Attire]
      ,[LP]
      ,[GR LP]
      ,[Notes (optional)]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROFESSIONALISM_LL_Data_Entry] WITH(NOLOCK)
WHERE [Staff Name] IS NOT NULL

UNION ALL

SELECT [Staff Name]
      ,CONVERT(DATE,[Date]) AS date
      ,[Grade]
      ,[Manager]
      ,[On Time]
      ,[Present]
      ,[Attire]
      ,[LP]
      ,[GR LP]
      ,[Notes (optional)]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROFESSIONALISM_LU_Data_Entry] WITH(NOLOCK)
WHERE [Staff Name] IS NOT NULL

UNION ALL

SELECT [Staff Name]
      ,CONVERT(DATE,[Date]) AS date
      ,[Grade]
      ,[Manager]
      ,[On Time]
      ,[Present]
      ,[Attire]
      ,[LP]
      ,[GR LP]
      ,[Notes (optional)]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROFESSIONALISM_Rev_Data_Entry] WITH(NOLOCK)
WHERE [Staff Name] IS NOT NULL

UNION ALL

SELECT [Staff Name]
      ,CONVERT(DATE,[Date]) AS date
      ,[Grade]
      ,[Manager]
      ,[On Time]
      ,[Present]
      ,[Attire]
      ,[LP]
      ,[GR LP]
      ,[Notes (optional)]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROFESSIONALISM_Seek_Data_Entry] WITH(NOLOCK)
WHERE [Staff Name] IS NOT NULL

UNION ALL

SELECT [Staff Name]
      ,CONVERT(DATE,[Date]) AS date
      ,[Grade]
      ,[Manager]
      ,[On Time]
      ,[Present]
      ,[Attire]
      ,[LP]
      ,[GR LP]
      ,[Notes (optional)]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROFESSIONALISM_THRIVE_Data_Entry] WITH(NOLOCK)
WHERE [Staff Name] IS NOT NULL

UNION ALL

SELECT [Staff Name]
      ,CONVERT(DATE,[Date]) AS date
      ,[Grade]
      ,[Manager]
      ,[On Time]
      ,[Present]
      ,[Attire]
      ,[LP]
      ,[GR LP]
      ,[Notes (optional)]
FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PROFESSIONALISM_SPARK_Data_Entry] WITH(NOLOCK)
WHERE [Staff Name] IS NOT NULL