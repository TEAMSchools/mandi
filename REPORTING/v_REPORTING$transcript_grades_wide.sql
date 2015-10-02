USE KIPP_NJ
GO

ALTER VIEW REPORTING$transcript_grades_wide AS

WITH year_order AS (
  SELECT studentid
        ,schoolid
        ,year
        ,ROW_NUMBER() OVER(
          PARTITION BY studentid
            ORDER BY year DESC) AS rn
  FROM KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
  WHERE co.grade_level BETWEEN 5 AND 12
    AND rn = 1
)

,long_data AS (     
  SELECT STUDENTID
        ,schoolid
        ,year_rn
        ,CONCAT(MAX(academic_year) + MAX(academic_year_delimiter) + REPLICATE(' ',4) + CHAR(9)
               ,'Gr' + CHAR(9)
               ,'Cr') AS academic_year_header
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(
           CONCAT(is_included_GPA + ' '
                 ,is_honors + ' '
                 ,COURSE_NAME + course_name_delimiter + CHAR(9)
                 ,GRADE + CHAR(9)
                 ,EARNEDCRHRS)
          ,CHAR(10)) AS course_list
  FROM
      (
       SELECT sg.STUDENTID      
             ,CONVERT(NVARCHAR(MAX),CONCAT(sg.academic_year, ' - ', (sg.academic_year + 1))) AS academic_year
             ,yr.schoolid
             ,yr.rn AS year_rn             
             ,sg.COURSE_NAME
             ,sg.GRADE
             ,CASE WHEN c.GRADESCALEID = 712 THEN 'H' ELSE ' ' END AS is_honors
             ,CASE WHEN sg.EXCLUDEFROMGPA = 1 THEN ' ' ELSE '*' END AS is_included_GPA
             ,CASE WHEN LEN(EARNEDCRHRS) = 1 THEN CONCAT(EARNEDCRHRS,'.0') ELSE CONVERT(VARCHAR,EARNEDCRHRS) END AS EARNEDCRHRS                          
             /* add spaces to compensate for longest course name */
             ,REPLICATE(' ',(40 - LEN(CONCAT(sg.academic_year, ' - ', (sg.academic_year + 1))))) AS academic_year_delimiter
             ,REPLICATE(' ',(40 - LEN(sg.COURSE_NAME))) AS course_name_delimiter
             --,sg.EXCLUDEFROMGRADUATION             
             --,CASE WHEN LEN(sg.POTENTIALCRHRS) = 1 THEN CONCAT(sg.POTENTIALCRHRS,'.0') ELSE CONVERT(VARCHAR,sg.POTENTIALCRHRS) END AS POTENTIALCRHRS
       FROM KIPP_NJ..GRADES$STOREDGRADES#static sg
       LEFT OUTER JOIN KIPP_NJ..PS$COURSES#static c
         ON sg.course_number = c.course_number
       JOIN year_order yr
         ON sg.STUDENTID = yr.studentid
        AND sg.academic_year = yr.year          
       WHERE sg.SCHOOLID = 73253
         AND sg.STORECODE = 'Y1'     
         AND ISNULL(EXCLUDEFROMTRANSCRIPTS,0) = 0         
      ) sub
  GROUP BY studentid          
          ,schoolid
          ,year_rn
 )

SELECT STUDENTID
      ,schoolid
      ,[academic_year_header_yr_1]
      ,[academic_year_header_yr_2]
      ,[academic_year_header_yr_3]
      ,[academic_year_header_yr_4]
      ,[academic_year_header_yr_5]
      ,[academic_year_header_yr_6]
      ,[course_list_yr_1]
      ,[course_list_yr_2]
      ,[course_list_yr_3]
      ,[course_list_yr_4]
      ,[course_list_yr_5]
      ,[course_list_yr_6]
FROM
    (
     SELECT STUDENTID
           ,schoolid
           ,CONCAT(field, '_yr_', year_rn) AS pivot_field
           ,value
     FROM long_data
     UNPIVOT(
       value
       FOR field IN (academic_year_header, course_list)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([academic_year_header_yr_1]
                     ,[academic_year_header_yr_2]
                     ,[academic_year_header_yr_3]
                     ,[academic_year_header_yr_4]
                     ,[academic_year_header_yr_5]
                     ,[academic_year_header_yr_6]
                     ,[course_list_yr_1]
                     ,[course_list_yr_2]
                     ,[course_list_yr_3]
                     ,[course_list_yr_4]
                     ,[course_list_yr_5]
                     ,[course_list_yr_6])
 ) p