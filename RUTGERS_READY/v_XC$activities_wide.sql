USE [RutgersReady]
GO

/****** Object:  View [dbo].[XC$activities_wide]    Script Date: 6/16/2014 8:43:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[XC$activities_wide] AS

SELECT student_number      
      ,yearid
      ,[Fall_1]
      ,[Fall_2]
      ,[Winter_1]
      ,[Winter_2]
      ,[Spring_1]
      ,[Spring_2]
      ,[Winter-Spring_1]
      ,[Winter-Spring_2]
      ,[Year-Round_1]
      ,[Year-Round_2]
      ,ISNULL([Fall_1],'')
         + ISNULL([Fall_2],'')
         + ISNULL([Winter_1],'') 
         + ISNULL([Winter_2],'') 
         + ISNULL([Spring_1],'') 
         + ISNULL([Spring_2],'') 
         + ISNULL([Winter-Spring_1],'') 
         + ISNULL([Winter-Spring_2],'') 
         + ISNULL([Year-Round_1],'') 
         + ISNULL([Year-Round_2],'') AS activity_hash
FROM
    (
     SELECT [student_number]
           ,[yearid]           
           ,[activity]
           ,[season] + '_' + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                                                PARTITION BY yearid, student_number, season
                                                    ORDER BY season, activity)) AS season_hash
     FROM [RutgersReady].[dbo].[rise_XC]
    ) sub


PIVOT(
      MAX(activity)
      FOR season_hash IN (
                          [Fall_1]
                         ,[Fall_2]
                         ,[Winter_1]
                         ,[Winter_2]
                         ,[Spring_1]
                         ,[Spring_2]
                         ,[Winter-Spring_1]
                         ,[Winter-Spring_2]
                         ,[Year-Round_1]
                         ,[Year-Round_2]
                         )
 ) piv
GO


