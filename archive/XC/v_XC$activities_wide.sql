USE KIPP_NJ
GO

ALTER VIEW XC$activities_wide AS

SELECT student_number
      ,academic_year           
      ,KIPP_NJ.dbo.GROUP_CONCAT_D(program, CHAR(10)) AS activity_hash
FROM
    (
     SELECT DISTINCT 
            student_number
           ,academic_year           
           ,program                
     FROM KIPP_NJ..XC$roster_clean WITH(NOLOCK)     
    ) sub
GROUP BY student_number
        ,academic_year