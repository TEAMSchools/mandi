USE KIPP_NJ
GO

ALTER VIEW REPORTING$transcript_current_classes_wide AS

WITH long_data AS (     
  SELECT STUDENTID                
        ,CONCAT('Current Schedule (', MAX(academic_year) + ')' + MAX(academic_year_delimiter), REPLICATE(' ', 4) + CHAR(9) + CHAR(9), 'Cr') AS academic_year_header
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(
           CONCAT(is_included_GPA + ' '
                 ,is_honors + ' '
                 ,COURSE_NAME + course_name_delimiter + CHAR(9) + CHAR(9)
                 ,potential_credits)
          ,CHAR(10)) AS course_list
  FROM
      (
       SELECT enr.STUDENTID      
             ,CONVERT(NVARCHAR(MAX),CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(), ' - ', (KIPP_NJ.dbo.fn_Global_Academic_Year() + 1))) AS academic_year      
             ,enr.COURSE_NUMBER
             ,enr.COURSE_NAME      
             ,CASE WHEN enr.GRADESCALEID = 712 THEN 'H' ELSE ' ' END AS is_honors
             ,CASE WHEN enr.EXCLUDEFROMGPA = 1 THEN ' ' ELSE '*' END AS is_included_GPA
             ,CASE WHEN LEN(enr.CREDIT_HOURS) = 1 THEN CONCAT(enr.CREDIT_HOURS,'.0') ELSE CONVERT(VARCHAR,enr.CREDIT_HOURS) END AS potential_credits                          
             /* add spaces to compensate for longest course name */
             ,REPLICATE(' ',(40 - LEN(CONCAT('Current Schedule (', KIPP_NJ.dbo.fn_Global_Academic_Year(), ' - ', (KIPP_NJ.dbo.fn_Global_Academic_Year() + 1), ')')))) AS academic_year_delimiter
             ,REPLICATE(' ',(40 - LEN(enr.COURSE_NAME))) AS course_name_delimiter      
       FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
       WHERE enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND enr.drop_flags = 0
         AND enr.COURSE_NUMBER NOT IN ('HR','CCR405','STUDY10')      
      ) sub
  GROUP BY studentid                    
 )

SELECT STUDENTID      
      ,[academic_year_header_cur]
      ,[course_list_cur]
FROM
    (
     SELECT STUDENTID           
           ,CONCAT(field,'_cur') AS pivot_field
           ,value
     FROM long_data
     UNPIVOT(
       value
       FOR field IN (academic_year_header, course_list)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([academic_year_header_cur], [course_list_cur])
 ) p