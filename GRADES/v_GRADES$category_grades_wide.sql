USE KIPP_NJ
GO

ALTER VIEW GRADES$category_grades_wide AS

WITH course_order AS (
  SELECT student_number
        ,academic_year
        ,course_number
        ,credittype
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year
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
              student_number      
             ,academic_year            
             ,course_number      
             ,credittype      
       FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
       WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND credittype NOT IN ('LOG')
         AND course_number NOT IN ('')
      ) sub
 )

SELECT student_number
      ,SCHOOLID
      ,academic_year
      ,CREDITTYPE
      ,COURSE_NUMBER
      ,class_rn
      ,sectionid
      ,teacher_name
      ,reporting_term      
      ,[A] AS A_term /* assessments */
      ,[C] AS C_term /* classwork */      
      ,[H] AS H_term /* homework */
      ,[P] AS P_term /* class performance */
      ,[S] AS S_term /* summative assessments */
      ,CASE WHEN schoolid = 73253 THEN NULL ELSE [E] END AS E_term /* homework quality */      
      
      ,ROUND(AVG([A]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS A_Y1 
      ,ROUND(AVG([C]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS C_Y1      
      ,ROUND(AVG([H]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS H_Y1      
      ,ROUND(AVG([P]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS P_Y1
      ,ROUND(AVG([S]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) AS S_Y1
      ,CASE WHEN schoolid = 73253 THEN NULL ELSE ROUND(AVG([E]) OVER(PARTITION BY student_number, academic_year, course_number ORDER BY reporting_term ASC),0) END AS E_Y1
FROM
    (
     SELECT cat.student_number
           ,cat.SCHOOLID
           ,cat.academic_year
           ,cat.CREDITTYPE
           ,cat.COURSE_NUMBER
           ,cat.sectionid
           ,cat.teacher_name
           ,cat.reporting_term      
           ,cat.grade_category
           ,cat.grade_category_pct
           ,o.class_rn
     FROM KIPP_NJ..GRADES$category_grades_long#static cat WITH(NOLOCK)
     JOIN course_order o
       ON cat.student_number = o.student_number
      AND cat.academic_year = o.academic_year
      AND cat.COURSE_NUMBER = o.course_number
     WHERE cat.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
PIVOT(
  MAX(grade_category_pct)
  FOR grade_category IN ([A]
                        ,[C]
                        ,[E]
                        ,[F]
                        ,[H]
                        ,[M]
                        ,[P]
                        ,[S])
 ) p