USE KIPP_NJ
GO

ALTER VIEW XC$activities_wide AS

SELECT student_number
      ,yearid
      ,[Fall_1]
      ,[Fall_2]
      ,[Fall_3]
      ,[Fall-Winter_1]
      ,[Fall-Winter_2]
      ,[Fall-Winter_3]
      ,[Winter_1]
      ,[Winter_2]
      ,[Winter_3]
      ,[Spring_1]
      ,[Spring_2]
      ,[Spring_3]
      ,[Winter-Spring_1]
      ,[Winter-Spring_2]
      ,[Winter-Spring_3]
      ,[Year-Round_1]
      ,[Year-Round_2]
      ,[Year-Round_3]
      ,ISNULL([Fall_1],'')
         + ISNULL([Fall_2],'')
         + ISNULL([Fall_3],'')
         + ISNULL([Winter_1],'') 
         + ISNULL([Winter_2],'') 
         + ISNULL([Winter_3],'') 
         + ISNULL([Spring_1],'') 
         + ISNULL([Spring_2],'') 
         + ISNULL([Spring_3],'') 
         + ISNULL([Fall-Winter_1],'') 
         + ISNULL([Fall-Winter_2],'') 
         + ISNULL([Fall-Winter_3],'') 
         + ISNULL([Winter-Spring_1],'') 
         + ISNULL([Winter-Spring_2],'') 
         + ISNULL([Winter-Spring_3],'') 
         + ISNULL([Year-Round_1],'') 
         + ISNULL([Year-Round_2],'') 
         + ISNULL([Year-Round_3],'') AS activity_hash
FROM
    (
     SELECT [student number] AS student_number
           ,[yearid]           
           ,program AS activity
           ,CASE 
             WHEN [Start Season] = 'Fall' AND [End Season] = 'Spring' THEN 'Year-Round'
             WHEN [Start Season] = 'Year-Round' THEN [Start Season]
             WHEN [Start Season] = [End Season] THEN [Start Season]
             ELSE [Start Season] + '-' + [End Season]
            END
             + '_' 
             + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                                 PARTITION BY yearid, [student number],CASE WHEN [Start Season] = [End Season] THEN [Start Season] ELSE [Start Season] + '-to-' + [End Season] END
                                     ORDER BY CASE WHEN [Start Season] = [End Season] THEN [Start Season] ELSE [Start Season] + '-to-' + [End Season] END, program)) AS season_hash
     FROM [dbo].[AUTOLOAD$GDOCS_XC_Rise_Roster] WITH(NOLOCK)
     WHERE [Student Name] IS NOT NULL
    ) sub

PIVOT(
      MAX(activity)
      FOR season_hash IN (
                          [Fall_1]
                         ,[Fall_2]
                         ,[Fall_3]
                         ,[Fall-Winter_1]
                         ,[Fall-Winter_2]
                         ,[Fall-Winter_3]
                         ,[Winter_1]
                         ,[Winter_2]
                         ,[Winter_3]
                         ,[Spring_1]
                         ,[Spring_2]
                         ,[Spring_3]
                         ,[Winter-Spring_1]
                         ,[Winter-Spring_2]
                         ,[Winter-Spring_3]
                         ,[Year-Round_1]
                         ,[Year-Round_2]
                         ,[Year-Round_3]
                         )
 ) piv