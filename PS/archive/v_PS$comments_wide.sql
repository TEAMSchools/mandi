USE KIPP_NJ
GO

ALTER VIEW PS$comments_wide AS

WITH course_order AS (
  SELECT studentid
        ,academic_year
        ,course_number
        ,credittype
        ,ROW_NUMBER() OVER(
           PARTITION BY studentid, academic_year
             ORDER BY CASE
                       WHEN credittype = 'ENG' THEN 01
                       WHEN credittype = 'RHET' THEN 02
                       WHEN credittype = 'MATH' THEN 03
                       WHEN credittype = 'SCI' THEN 04
                       WHEN credittype = 'SOC' THEN 05
                       WHEN credittype = 'WLANG' THEN 11
                       WHEN credittype = 'PHYSED' THEN 12
                       WHEN credittype = 'ART' THEN 13
                       WHEN credittype = 'STUDY' THEN 21
                       WHEN credittype = 'COCUR' THEN 22
                       WHEN credittype = 'ELEC' THEN 22
                       WHEN credittype = 'LOG' THEN 22
                      END
                     ,course_number) AS class_rn      
  FROM
      (
       SELECT DISTINCT
              studentid      
             ,academic_year            
             ,course_number      
             ,credittype      
       FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
       WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND credittype NOT IN ('LOG')
         AND course_number NOT IN ('')
      ) sub
 )

SELECT studentid      
      ,term
      ,[rc1_comment]
      ,[rc2_comment]
      ,[rc3_comment]
      ,[rc4_comment]
      ,[rc5_comment]
      ,[rc6_comment]
      ,[rc7_comment]
      ,[rc8_comment]
      ,[rc9_comment]
      ,[rc10_comment]
      ,[advisor_comment]
FROM
    (
     SELECT comm.studentid           
           ,comm.term                 
           ,comm.teacher_comment
           ,CASE
             WHEN comm.course_number = 'HR' THEN 'advisor_comment'
             ELSE CONCAT('rc', rc.class_rn, '_comment') 
            END AS pivot_hash
     FROM PS$comments#static comm WITH(NOLOCK)
     LEFT OUTER JOIN course_order rc WITH(NOLOCK)
       ON comm.studentid = rc.studentid
      AND comm.course_number = rc.course_number
     ) sub
PIVOT(
  MAX(teacher_comment)
  FOR pivot_hash IN ([rc1_comment]
                    ,[rc2_comment]
                    ,[rc3_comment]
                    ,[rc4_comment]
                    ,[rc5_comment]
                    ,[rc6_comment]
                    ,[rc7_comment]
                    ,[rc8_comment]
                    ,[rc9_comment]
                    ,[rc10_comment]
                    ,[advisor_comment])
 ) p