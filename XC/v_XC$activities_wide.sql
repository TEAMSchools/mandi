USE KIPP_NJ
GO

ALTER VIEW XC$activities_wide AS

SELECT student_number
      ,academic_year
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
     SELECT student_number
           ,academic_year           
           ,program AS activity           
           ,CASE 
             WHEN start_term = 'Fall' AND end_term = 'Spring' THEN 'Year-Round'
             WHEN start_term = 'Year-Round' THEN start_term
             WHEN start_term = end_term THEN start_term
             ELSE start_term + '-' + end_term
            END
             + '_' 
             + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                                 PARTITION BY academic_year, student_number,CASE WHEN start_term = end_term THEN start_term ELSE start_term + '-to-' + end_term END
                                     ORDER BY CASE WHEN start_term = end_term THEN start_term ELSE start_term + '-to-' + end_term END, program)) AS season_hash
     FROM KIPP_NJ..XC$roster_clean WITH(NOLOCK)     
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