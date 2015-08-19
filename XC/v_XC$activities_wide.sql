USE KIPP_NJ
GO

ALTER VIEW XC$activities_wide AS

SELECT student_number
      ,academic_year
      ,[Fall]      
      ,[Fall-Winter]      
      ,[Winter]      
      ,[Spring]      
      ,[Winter-Spring]      
      ,[Year-Round]      
      ,ISNULL([Fall],'')         
         + ISNULL([Winter],'')          
         + ISNULL([Spring],'')          
         + ISNULL([Fall-Winter],'')          
         + ISNULL([Winter-Spring],'')          
         + ISNULL([Year-Round],'') AS activity_hash
FROM
    (
     SELECT student_number
           ,academic_year
           ,season
           ,KIPP_NJ.dbo.GROUP_CONCAT_D(program, ', ') AS activity
     FROM
         (
          SELECT student_number
                ,academic_year           
                ,program
                ,CASE 
                  WHEN start_term = 'Fall' AND end_term = 'Spring' THEN 'Year-Round'
                  WHEN start_term = 'Year-Round' THEN start_term
                  WHEN start_term = end_term THEN start_term
                  ELSE start_term + '-' + end_term
                 END AS season
                 -- + '_' 
                 -- + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                 --                     PARTITION BY academic_year, student_number,CASE WHEN start_term = end_term THEN start_term ELSE start_term + '-to-' + end_term END
                 --                         ORDER BY CASE WHEN start_term = end_term THEN start_term ELSE start_term + '-to-' + end_term END, program)) AS season_hash
          FROM KIPP_NJ..XC$roster_clean WITH(NOLOCK)     
         ) sub
     GROUP BY student_number
             ,academic_year
             ,season
    ) sub
PIVOT(
  MAX(activity)
  FOR season IN ([Fall]      
                ,[Fall-Winter]      
                ,[Winter]      
                ,[Spring]      
                ,[Winter-Spring]      
                ,[Year-Round])
 ) p